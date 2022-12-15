//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;
#include "type_common.h"

class SDFBaker {
public:
    constant static constexpr int BVH_STACK_SIZE = 32;
    
    struct Node {
        float minX;
        float minY;
        float minZ;
        float maxX;
        float maxY;
        float maxZ;
        uint  childIndex;
        uint  childCount;
    };
    
    constant Node* Nodes;
    constant float3* Vertices;
    constant float3* Normals;
    uint SignRayCount;
    uint TriangleCount;
    
    float sdf(float3 p, float upperBound) {
        if(upperBound <= 0)
            upperBound = estimateUpperBound(p, 6);
        
        UDF2Result udf2Result = udf2(p, upperBound * upperBound, 0);
        
        float udfVal = sqrt(udf2Result.udf2);
        int triIdx = udf2Result.triIdx;
        
        int signEstimator = 0;
        for(uint i = 0; i < SignRayCount; ++i) {
            signEstimator += estimateSign(p, mix(0.0f, 1.0f, (i + 0.5f) / SignRayCount));
        }
        
        if(signEstimator > 0)
            return udfVal;
        if(signEstimator < 0)
            return -udfVal;
        
        float3 a = Vertices[triIdx * 3 + 0];
        float3 b = Vertices[triIdx * 3 + 1];
        float3 c = Vertices[triIdx * 3 + 2];
        
        float3 na = Normals[triIdx * 3 + 0];
        float3 nb = Normals[triIdx * 3 + 1];
        float3 nc = Normals[triIdx * 3 + 2];
        
        int ja = dot(p - a, na) >= 0 ? 1 : -1;
        int jb = dot(p - b, nb) >= 0 ? 1 : -1;
        int jc = dot(p - c, nc) >= 0 ? 1 : -1;
        
        return ja + jb + jc > 0 ? udfVal : -udfVal;
    }
    
private:
    struct UDF2Result {
        int   triIdx;
        float udf2;
    };
    
    bool isLeaf(Node node) {
        return node.childCount != 0;
    }
    
    bool intersectSphereBox(float3 lower, float3 upper, float3 p, float radius2) {
        float3 q = clamp(p, lower, upper);
        return dot(p - q, p - q) <= radius2;
    }
    
    bool intersectSphereTriangle(float3 a, float3 b, float3 c, float3 o, float r2) {
        return udf2Triangle(a, b, c, o) <= r2;
    }
    
    bool closestIntersectionWithTriangle(float3 o, float3 d, float maxT,
                                         float3 A, float3 B_A, float3 C_A, thread float& r_t) {
        float3 s1 = cross(d, C_A);
        float div = dot(s1, B_A);
        float invDiv = 1 / div;

        float3 o_A = o - A;
        float alpha = dot(o_A, s1) * invDiv;

        float3 s2 = cross(o_A, B_A);
        float beta = dot(d, s2) * invDiv;
        
        const float t = dot(C_A, s2) * invDiv;
        if(t < 0 || t > maxT || alpha < 0 || beta < 0 || alpha + beta > 1)
            return false;

        r_t = t;
        return true;
    }
    
    float max4(float x, float y, float z, float w) {
        return max(max(x, y), max(z, w));
    }

    float min4(float x, float y, float z, float w) {
        return min(min(x, y), min(z, w));
    }
    
    bool intersectRayBox(float3 o, float3 invD, float t0, float t1, float3 lower, float3 upper) {
        float3 n = invD * (lower - o);
        float3 f = invD * (upper - o);

        float3 minnf = min(n, f);
        float3 maxnf = max(n, f);

        t0 = max4(t0, minnf.x, minnf.y, minnf.z);
        t1 = min4(t1, maxnf.x, maxnf.y, maxnf.z);

        return t0 <= t1;
    }
    
    // https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
    float udf2Triangle(float3 a, float3 b, float3 c, float3 p) {
        float3 ba = b - a; float3 pa = p - a;
        float3 cb = c - b; float3 pb = p - b;
        float3 ac = a - c; float3 pc = p - c;
        float3 nor = cross(ba, ac);
        
        if(sign(dot(cross(ba, nor), pa)) + sign(dot(cross(cb, nor), pb)) + sign(dot(cross(ac, nor), pc)) < 2) {
            return min(
                       min(
                           length_squared(ba * clamp(dot(ba, pa) / length_squared(ba), 0.0f, 1.0f) - pa),
                           length_squared(cb * clamp(dot(cb, pb) / length_squared(cb), 0.0f, 1.0f) - pb)
                           ), length_squared(ac * clamp(dot(ac, pc) / length_squared(ac), 0.0f, 1.0f) - pc)
                       );
        }
        
        return dot(nor, pa) * dot(nor, pa) / length_squared(nor);
    }
    
    bool containsTriangle(float3 o, float radius2, uint nodeIndex) {
        uint stack[BVH_STACK_SIZE];
        stack[0] = nodeIndex;
        int stackTop = 1;
        
        while(stackTop) {
            uint ni = stack[--stackTop];
            Node node = Nodes[ni];
            
            if(!intersectSphereBox(float3(node.minX, node.minY, node.minZ), float3(node.maxX, node.maxY, node.maxY), o, radius2))
                continue;
            
            if(isLeaf(node)) {
                for(uint i = 0, j = 3 * node.childIndex; i < node.childCount; ++i, j += 3) {
                    if(intersectSphereTriangle(
                                               Vertices[j], Vertices[j + 1], Vertices[j + 2], o, radius2))
                        return true;
                }
                return false;
            }
            
            stack[stackTop++] = node.childIndex;
            stack[stackTop++] = node.childIndex + 1;
        }
        
        return false;
    }
    
    float estimateUpperBound(float3 p, int precison) {
        Node root = Nodes[0];
        float3 lower = float3(root.minX, root.minY, root.minZ);
        float3 upper = float3(root.maxX, root.maxY, root.maxZ);
        
        float L = 0;
        float R = distance(0.5 * (lower + upper), p) + distance(lower, upper);
        
        for(int i = 0; i < precison; ++i) {
            float mid = 0.5 * (L + R);
            if(containsTriangle(p, mid * mid, 0))
                R = mid;
            else
                L = mid;
        }
        
        return R;
    }
    
    UDF2Result udf2(float3 p, float u2, uint nodeIndex) {
        uint stack[BVH_STACK_SIZE];
        stack[0] = nodeIndex;
        int stackTop = 1;
        
        int finalTriIdx = -1;
        
        while(stackTop) {
            uint ni = stack[--stackTop];
            Node node = Nodes[ni];
            
            if(!intersectSphereBox(float3(node.minX, node.minY, node.minZ),
                                   float3(node.maxX, node.maxY, node.maxZ), p, u2))
                continue;
            
            if(isLeaf(node)) {
                for(uint i = 0, j = 3 * node.childIndex; i < node.childCount; ++i, j += 3) {
                    float newUDF2 = udf2Triangle(Vertices[j], Vertices[j + 1], Vertices[j + 2], p);
                    
                    if(newUDF2 < u2) {
                        u2 = newUDF2;
                        finalTriIdx = int(i + node.childIndex);
                    }
                }
            } else {
                stack[stackTop++] = node.childIndex;
                stack[stackTop++] = node.childIndex + 1;
            }
        }
        
        UDF2Result result;
        result.triIdx = finalTriIdx;
        result.udf2   = u2;
        
        return result;
    }
    
    int traceTriangleIndex(float3 o, float3 d, float maxT) {
        float3 invD = 1.0f / d;

        uint stack[BVH_STACK_SIZE];
        stack[0] = 0;
        int stackTop = 1;

        int finalIdx = -1;
        float finalT = maxT;

        while(stackTop) {
            uint ni = stack[--stackTop];
            Node node = Nodes[ni];

            if(!intersectRayBox(o, invD, 0, finalT, float3(node.minX, node.minY, node.minZ), float3(node.maxX, node.maxY, node.maxZ)))
                continue;

            if(isLeaf(node)) {
                for(uint i = 0, j = 3 * node.childIndex; i < node.childCount; ++i, j += 3) {
                    float3 a = Vertices[j];
                    float3 b = Vertices[j + 1];
                    float3 c = Vertices[j + 2];

                    float newT;
                    if(closestIntersectionWithTriangle(o, d, finalT, a, b - a, c - a, newT)) {
                        finalT   = newT;
                        finalIdx = i + node.childIndex;
                    }
                }
            } else {
                stack[stackTop++] = node.childIndex;
                stack[stackTop++] = node.childIndex + 1;
            }
        }

        return finalIdx;
    }
    
    int estimateSign(float3 o, float rn) {
        int rndTriIdx = int(rn * (TriangleCount - 1));

        float3 a = Vertices[rndTriIdx * 3 + 0];
        float3 b = Vertices[rndTriIdx * 3 + 1];
        float3 c = Vertices[rndTriIdx * 3 + 2];

        float3 d = 1.0f / 3 * (a + b + c) - o;

        int triIdx = traceTriangleIndex(o, d, 1.0f / 0.0f);
        if(triIdx < 0)
            return 0;

        float3 na = Normals[triIdx * 3 + 0];
        float3 nb = Normals[triIdx * 3 + 1];
        float3 nc = Normals[triIdx * 3 + 2];

        return dot(d, na + nb + nc) < 0 ? 1 : -1;
    }
};

kernel void sdfBaker(// bvh
                     constant SDFBaker::Node* Nodes [[buffer(1)]],
                     constant float3* Vertices [[buffer(2)]],
                     constant float3* Normals [[buffer(3)]],
                     // constant
                     constant float3& SDFLower [[buffer(4)]],
                     constant float3& SDFUpper [[buffer(5)]],
                     constant uint32_t& TriangleCount [[buffer(7)]],
                     constant uint32_t& SignRayCount [[buffer(8)]],
                     constant uint32_t& XBeg [[buffer(9)]],
                     constant uint32_t& XEnd [[buffer(10)]],
                     // output
                     texture3d<float, access::write> sdf [[ texture(0) ]],
                     uint3 tpig [[ thread_position_in_grid ]]) {
    SDFBaker baker;
    baker.SignRayCount = SignRayCount;
    baker.TriangleCount = TriangleCount;
    baker.Nodes = Nodes;
    baker.Vertices = Vertices;
    baker.Normals = Normals;
    
    int width = sdf.get_width();
    int height = sdf.get_height();
    int depth = sdf.get_depth();
    
    float dx = 1.05f * (SDFUpper.x - SDFLower.x) / width;

    float zf = mix(SDFLower.z, SDFUpper.z, (tpig.z + 0.5f) / depth);
    float yf = mix(SDFLower.y, SDFUpper.y, (tpig.y + 0.5f) / height);

    float lastUDF = -100 * dx;
    for(uint x = XBeg; x < XEnd; ++x) {
        float xf = mix(SDFLower.x, SDFUpper.x, (x + 0.5f) / width);
        float upperBound = lastUDF + dx;

        float newSDF = baker.sdf(float3(xf, yf, zf), upperBound);
        lastUDF = abs(newSDF);
        
        sdf.write(float4(newSDF, 0, 0, 0), ushort3(x, tpig.y, tpig.z));
    }
}
