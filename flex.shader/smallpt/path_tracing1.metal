//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include <metal_stdlib>
using namespace metal;

struct Ray {
    // ray origin
    float3 orig;
    // ray direction
    float3 dir;
    Ray(float3 o_, float3 d_) : orig(o_), dir(d_) {}
};

// material types, used in radiance(), only DIFF used here
enum Refl_t { DIFF, SPEC, REFR };

// MARK: - SPHERES
struct Sphere {
    // radius
    float rad;
    // position, emission, colour
    float3 pos, emi, col;
    // reflection type (e.g. diffuse)
    Refl_t refl;
    
    float intersect(thread const Ray &r) const constant {
        // ray/sphere intersection
        // returns distance t to intersection point, 0 if no hit
        // ray equation: p(x,y,z) = ray.orig + t*ray.dir
        // general sphere equation: x^2 + y^2 + z^2 = rad^2
        // classic quadratic equation of form ax^2 + bx + c = 0
        // solution x = (-b +- sqrt(b*b - 4ac)) / 2a
        // solve t^2*ray.dir*ray.dir + 2*t*(orig-p)*ray.dir + (orig-p)*(orig-p) - rad*rad = 0
        // more details in "Realistic Ray Tracing" book by P. Shirley or Scratchapixel.com
        
        // distance from ray.orig to center sphere
        float3 op = pos - r.orig;
        // epsilon required to prevent floating point precision artefacts
        float t, epsilon = 0.0001f;
        // b in quadratic equation
        float b = dot(op, r.dir);
        // discriminant quadratic equation
        float disc = b*b - dot(op, op) + rad*rad;
        
        if (disc<0) {
            // if disc < 0, no real solution (we're not interested in complex roots)
            return 0;
        } else {
            // if disc >= 0, check for solutions using negative and positive discriminant
            disc = sqrt(disc);
        }
        // pick closest point in front of ray origin
        return (t = b - disc)>epsilon ? t : ((t = b + disc)>epsilon ? t : 0);
    }
};

//MARK: - TRIANGLES
// the classic ray triangle intersection: http://www.cs.virginia.edu/~gfx/Courses/2003/ImageSynthesis/papers/Acceleration/Fast%20MinimumStorage%20RayTriangle%20Intersection.pdf
// for an explanation see http://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/moller-trumbore-ray-triangle-intersection
float RayTriangleIntersection(thread const Ray &r, thread const float3 &v0, thread const float3 &edge1, thread const float3 &edge2) {
    float3 tvec = r.orig - v0;
    float3 pvec = cross(r.dir, edge2);
    float  det = dot(edge1, pvec);
    
    det = divide(1.0f, det);
    
    float u = dot(tvec, pvec) * det;
    
    if (u < 0.0f || u > 1.0f)
        return -1.0f;
    
    float3 qvec = cross(tvec, edge1);
    
    float v = dot(r.dir, qvec) * det;
    
    if (v < 0.0f || (u + v) > 1.0f)
        return -1.0f;
    
    return dot(edge2, qvec) * det;
}

float3 getTriangleNormal(const int triangleIndex, texture1d<float, access::read> triangle_texture){
    float4 edge1 = triangle_texture.read(ushort(triangleIndex * 3 + 1));
    float4 edge2 = triangle_texture.read(ushort(triangleIndex * 3 + 2));
    
    // cross product of two triangle edges yields a vector orthogonal to triangle plane
    float3 trinormal = cross(edge1.xyz, edge2.xyz);
    trinormal = normalize(trinormal);
    
    return trinormal;
}

void intersectAllTriangles(thread const Ray& r,  thread float& t_scene, thread int& triangle_id,
                           const int number_of_triangles, thread int& geomtype,
                           texture1d<float, access::read> triangle_texture){
    for (int i = 0; i < number_of_triangles; i++) {
        // the triangles are packed into the 1D texture using three consecutive float4 structs for each triangle,
        // first float4 contains the first vertex, second float4 contains the first precomputed edge, third float4 contains second precomputed edge like this:
        // (float4(vertex.x,vertex.y,vertex.z, 0), float4 (egde1.x,egde1.y,egde1.z,0),float4 (egde2.x,egde2.y,egde2.z,0))
        
        // i is triangle index, each triangle represented by 3 float4s in triangle_texture
        float4 v0 = triangle_texture.read(ushort(i * 3));
        float4 edge1 = triangle_texture.read(ushort(i * 3 + 1));
        float4 edge2 = triangle_texture.read(ushort(i * 3 + 2));
        
        // intersect ray with reconstructed triangle
        float t = RayTriangleIntersection(r, v0.xyz, edge1.xyz, edge2.xyz);
        
        // keep track of closest distance and closest triangle
        // if ray/tri intersection finds an intersection point that is closer than closest intersection found so far
        if (t < t_scene && t > 0.001) {
            t_scene = t;
            triangle_id = i;
            geomtype = 3;
        }
    }
}

//MARK: - AXIS ALIGNED BOXES
struct Box {
    float3 min; // minimum bounds
    float3 max; // maximum bounds
    float3 emi; // emission
    float3 col; // colour
    Refl_t refl; // material type
    
    // ray/box intersection
    // for theoretical background of the algorithm see
    // http://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection
    // optimised code from http://www.gamedev.net/topic/495636-raybox-collision-intersection-point/
    float intersect(thread const Ray &r) const constant {
        float epsilon = 0.001f; // required to prevent self intersection
        
        float3 tmin = (min - r.orig) / r.dir;
        float3 tmax = (max - r.orig) / r.dir;
        
        float3 real_min = ::min(tmin, tmax);
        float3 real_max = ::max(tmin, tmax);
        
        float minmax = ::min(::min(real_max.x, real_max.y), real_max.z);
        float maxmin = ::max(::max(real_min.x, real_min.y), real_min.z);
        
        if (minmax >= maxmin) {
            return maxmin > epsilon ? maxmin : 0;
        } else {
            return 0;
        }
    }
    
    float intersect(thread const Ray &r) const thread {
        float epsilon = 0.001f; // required to prevent self intersection
        
        float3 tmin = (min - r.orig) / r.dir;
        float3 tmax = (max - r.orig) / r.dir;
        
        float3 real_min = ::min(tmin, tmax);
        float3 real_max = ::max(tmin, tmax);
        
        float minmax = ::min(::min(real_max.x, real_max.y), real_max.z);
        float maxmin = ::max(::max(real_min.x, real_min.y), real_min.z);
        
        if (minmax >= maxmin) {
            return maxmin > epsilon ? maxmin : 0;
        }
        else return 0;
    }
    
    // calculate normal for point on axis aligned box
    float3 normalAt(thread float3 &point) const constant {
        float3 normal = float3(0.f, 0.f, 0.f);
        float epsilon = 0.001f;
        
        if (fabs(min.x - point.x) < epsilon) {
            normal = float3(-1, 0, 0);
        } else if (fabs(max.x - point.x) < epsilon) {
            normal = float3(1, 0, 0);
        } else if (fabs(min.y - point.y) < epsilon) {
            normal = float3(0, -1, 0);
        } else if (fabs(max.y - point.y) < epsilon) {
            normal = float3(0, 1, 0);
        } else if (fabs(min.z - point.z) < epsilon) {
            normal = float3(0, 0, -1);
        } else {
            normal = float3(0, 0, 1);
        }
        
        return normal;
    }
};

// MARK: - SCENE
// scene: 9 spheres forming a Cornell box
// small enough to fit in constant GPU memory
constant Sphere spheres[] = {
    // FORMAT: { float radius, float3 position, float3 emission, float3 colour, Refl_t material }
    // cornell box
    //{ 1e5f, { 1e5f + 1.0f, 40.8f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { 0.75f, 0.25f, 0.25f }, DIFF }, //Left 1e5f
    //{ 1e5f, { -1e5f + 99.0f, 40.8f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .25f, .25f, .75f }, DIFF }, //Right
    //{ 1e5f, { 50.0f, 40.8f, 1e5f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Back
    //{ 1e5f, { 50.0f, 40.8f, -1e5f + 600.0f }, { 0.0f, 0.0f, 0.0f }, { 0.00f, 0.00f, 0.00f }, DIFF }, //Front
    //{ 1e5f, { 50.0f, -1e5f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Bottom
    //{ 1e5f, { 50.0f, -1e5f + 81.6f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Top
    //{ 16.5f, { 27.0f, 16.5f, 47.0f }, { 0.0f, 0.0f, 0.0f }, { 0.99f, 0.99f, 0.99f }, SPEC }, // small sphere 1
    //{ 16.5f, { 73.0f, 16.5f, 78.0f }, { 0.0f, 0.f, .0f }, { 0.09f, 0.49f, 0.3f }, REFR }, // small sphere 2
    //{ 600.0f, { 50.0f, 681.6f - .5f, 81.6f }, { 3.0f, 2.5f, 2.0f }, { 0.0f, 0.0f, 0.0f }, DIFF }  // Light 12, 10 ,8
    
    //outdoor scene: radius, position, emission, color, material
    
    //{ 1600, { 3000.0f, 10, 6000 }, { 37, 34, 30 }, { 0.f, 0.f, 0.f }, DIFF },  // 37, 34, 30 // sun
    //{ 1560, { 3500.0f, 0, 7000 }, { 50, 25, 2.5 }, { 0.f, 0.f, 0.f }, DIFF },  //  150, 75, 7.5 // sun 2
    { 10000, { 50.0f, 40.8f, -1060 }, { 0.0003, 0.01, 0.15 }, { 0.175f, 0.175f, 0.25f }, DIFF }, // sky
    { 100000, { 50.0f, -100000, 0 }, { 0.0, 0.0, 0 }, { 0.8f, 0.2f, 0.f }, DIFF }, // ground
    { 110000, { 50.0f, -110048.5, 0 }, { 3.6, 2.0, 0.2 }, { 0.f, 0.f, 0.f }, DIFF },  // horizon brightener
    { 4e4, { 50.0f, -4e4 - 30, -3000 }, { 0, 0, 0 }, { 0.2f, 0.2f, 0.2f }, DIFF }, // mountains
    { 82.5, { 30.0f, 180.5, 42 }, { 16, 12, 6 }, { .6f, .6f, 0.6f }, DIFF },  // small sphere 1
    { 12, { 115.0f, 10, 105 }, { 0.0, 0.0, 0.0 }, { 0.9f, 0.9f, 0.9f }, REFR },  // small sphere 2
    { 22, { 65.0f, 22, 24 }, { 0, 0, 0 }, { 0.9f, 0.9f, 0.9f }, SPEC }, // small sphere 3
};

constant Box boxes[] = {
    // FORMAT: { float3 minbounds,    float3 maxbounds,         float3 emission,    float3 colour,       Refl_t }
    { { 5.0f, 0.0f, 70.0f }, { 45.0f, 11.0f, 115.0f }, { .0f, .0f, 0.0f }, { 0.5f, 0.5f, 0.5f }, DIFF },
    { { 85.0f, 0.0f, 95.0f }, { 95.0f, 20.0f, 105.0f }, { .0f, .0f, 0.0f }, { 0.5f, 0.5f, 0.5f }, DIFF },
    { { 75.0f, 20.0f, 85.0f }, { 105.0f, 22.0f, 115.0f }, { .0f, .0f, 0.0f }, { 0.5f, 0.5f, 0.5f }, DIFF },
};

inline bool intersect_scene(thread const Ray &r, thread float &t, thread int &sphere_id, thread int &box_id, thread int& triangle_id,
                            constant const int& number_of_triangles, thread int &geomtype, constant const float3& bbmin, constant const float3& bbmax,
                            texture1d<float, access::read> triangle_texture){
    float d = 1e21;
    float k = 1e21;
    float inf = t = 1e20;
    
    // SPHERES
    // intersect all spheres in the scene
    float numspheres = sizeof(spheres) / sizeof(Sphere);
    for (int i = int(numspheres); i--;)  // for all spheres in scene
        // keep track of distance from origin to closest intersection point
        if ((d = spheres[i].intersect(r)) && d < t){ t = d; sphere_id = i; geomtype = 1; }
    
    // BOXES
    // intersect all boxes in the scene
    float numboxes = sizeof(boxes) / sizeof(Box);
    for (int i = int(numboxes); i--;) // for all boxes in scene
        if ((k = boxes[i].intersect(r)) && k < t){ t = k; box_id = i; geomtype = 2; }
    
    // TRIANGLES
    Box scene_bbox; // bounding box around triangle meshes
    scene_bbox.min = bbmin;
    scene_bbox.max = bbmax;
    
    // if ray hits bounding box of triangle meshes, intersect ray with all triangles
    if (scene_bbox.intersect(r)){
        intersectAllTriangles(r, t, triangle_id, number_of_triangles, geomtype, triangle_texture);
    }
    
    // t is distance to closest intersection of ray with all primitives in the scene (spheres, boxes and triangles)
    return t<inf;
}

// random number generator from https://github.com/gz/rust-raytracer
float getrandom(thread unsigned int *seed0, thread unsigned int *seed1) {
    // hash the seeds using bitwise AND and bitshifts
    *seed0 = 36969 * ((*seed0) & 65535) + ((*seed0) >> 16);
    *seed1 = 18000 * ((*seed1) & 65535) + ((*seed1) >> 16);
    
    unsigned int ires = ((*seed0) << 16) + (*seed1);
    
    // Convert to float
    union {
        float f;
        unsigned int ui;
    } res;
    
    res.ui = (ires & 0x007fffff) | 0x40000000;  // bitwise AND, bitwise OR
    
    return (res.f - 2.f) / 2.f;
}

// hash function to calculate new seed for each frame
// see http://www.reedbeta.com/blog/2013/01/12/quick-and-easy-gpu-random-numbers-in-d3d11/
uint WangHash(uint a) {
    a = (a ^ 61) ^ (a >> 16);
    a = a + (a << 3);
    a = a ^ (a >> 4);
    a = a * 0x27d4eb2d;
    a = a ^ (a >> 15);
    return a;
}

// radiance function
// compute path bounces in scene and accumulate returned color from each path sgment
float3 radiance(thread Ray &r, thread unsigned int *s1, thread unsigned int *s2, constant const int& numtriangles,
                constant const float3& scene_aabb_min, constant const float3& scene_aabb_max,
                texture1d<float, access::read> triangle_texture) { // returns ray color
    // colour mask
    float3 mask = float3(1.0f, 1.0f, 1.0f);
    // accumulated colour
    float3 accucolor = float3(0.0f, 0.0f, 0.0f);
    
    for (int bounces = 0; bounces < 5; bounces++){  // iteration up to 4 bounces (instead of recursion in CPU code)
        // reset scene intersection function parameters
        float t = 100000; // distance to intersection
        int sphere_id = -1;
        int box_id = -1;   // index of intersected sphere
        int triangle_id = -1;
        int geomtype = -1;
        float3 f;  // primitive colour
        float3 emit; // primitive emission colour
        float3 x; // intersection point
        float3 n; // normal
        float3 nl; // oriented normal
        float3 d; // ray direction of next path segment
        Refl_t refltype;
        
        // intersect ray with scene
        // intersect_scene keeps track of closest intersected primitive and distance to closest intersection point
        if (!intersect_scene(r, t, sphere_id, box_id, triangle_id, numtriangles, geomtype,
                             scene_aabb_min, scene_aabb_max, triangle_texture))
            return float3(0.0f, 0.0f, 0.0f); // if miss, return black
        
        // else: we've got a hit with a scene primitive
        // determine geometry type of primitive: sphere/box/triangle
        
        // if sphere:
        if (geomtype == 1){
            constant Sphere &sphere = spheres[sphere_id]; // hit object with closest intersection
            x = r.orig + r.dir*t;  // intersection point on object
            n = normalize(x - sphere.pos);        // normal
            nl = dot(n, r.dir) < 0 ? n : n * -1; // correctly oriented normal
            f = sphere.col;   // object colour
            refltype = sphere.refl;
            emit = sphere.emi;  // object emission
            accucolor += (mask * emit);
        }
        
        // if box:
        if (geomtype == 2){
            constant Box &box = boxes[box_id];
            x = r.orig + r.dir*t;  // intersection point on object
            n = normalize(box.normalAt(x)); // normal
            nl = dot(n, r.dir) < 0 ? n : n * -1;  // correctly oriented normal
            f = box.col;  // box colour
            refltype = box.refl;
            emit = box.emi; // box emission
            accucolor += (mask * emit);
        }
        
        // if triangle:
        if (geomtype == 3){
            int tri_index = triangle_id;
            x = r.orig + r.dir*t;  // intersection point
            n = normalize(getTriangleNormal(tri_index, triangle_texture));  // normal
            nl = dot(n, r.dir) < 0 ? n : n * -1;  // correctly oriented normal
            
            // colour, refltype and emit value are hardcoded and apply to all triangles
            // no per triangle material support yet
            f = float3(0.9f, 0.4f, 0.1f);  // triangle colour
            refltype = REFR;
            emit = float3(0.0f, 0.0f, 0.0f);
            accucolor += (mask * emit);
        }
        
        // SHADING: diffuse, specular or refractive
        
        // ideal diffuse reflection (see "Realistic Ray Tracing", P. Shirley)
        if (refltype == DIFF){
            // create 2 random numbers
            float r1 = 2 * M_PI_F * getrandom(s1, s2);
            float r2 = getrandom(s1, s2);
            float r2s = sqrt(r2);
            
            // compute orthonormal coordinate frame uvw with hitpoint as origin
            float3 w = nl;
            float3 u = normalize(cross((fabs(w.x) > .1 ? float3(0, 1, 0) : float3(1, 0, 0)), w));
            float3 v = cross(w, u);
            
            // compute cosine weighted random ray direction on hemisphere
            d = normalize(u*cos(r1)*r2s + v*sin(r1)*r2s + w*sqrt(1 - r2));
            
            // offset origin next path segment to prevent self intersection
            x += nl * 0.03;
            
            // multiply mask with colour of object
            mask *= f;
        }
        
        // ideal specular reflection (mirror)
        if (refltype == SPEC){
            
            // compute relfected ray direction according to Snell's law
            d = r.dir - 2.0f * n * dot(n, r.dir);
            
            // offset origin next path segment to prevent self intersection
            x += nl * 0.01f;
            
            // multiply mask with colour of object
            mask *= f;
        }
        
        // ideal refraction (based on smallpt code by Kevin Beason)
        if (refltype == REFR){
            
            bool into = dot(n, nl) > 0; // is ray entering or leaving refractive material?
            float nc = 1.0f;  // Index of Refraction air
            float nt = 1.5f;  // Index of Refraction glass/water
            float nnt = into ? nc / nt : nt / nc;  // IOR ratio of refractive materials
            float ddn = dot(r.dir, nl);
            float cos2t = 1.0f - nnt*nnt * (1.f - ddn*ddn);
            
            if (cos2t < 0.0f) {
                // total internal reflection
                d = reflect(r.dir, n); //d = r.dir - 2.0f * n * dot(n, r.dir);
                x += nl * 0.01f;
            } else {
                // cos2t > 0
                // compute direction of transmission ray
                float3 tdir = normalize(r.dir * nnt - n * ((into ? 1 : -1) * (ddn*nnt + sqrt(cos2t))));
                
                float R0 = (nt - nc)*(nt - nc) / (nt + nc)*(nt + nc);
                float c = 1.f - (into ? -ddn : dot(tdir, n));
                float Re = R0 + (1.f - R0) * c * c * c * c * c;
                float Tr = 1 - Re; // Transmission
                float P = .25f + .5f * Re;
                float RP = Re / P;
                float TP = Tr / (1.f - P);
                
                // randomly choose reflection or transmission ray
                if (getrandom(s1, s2) < 0.25) {
                    // reflection ray
                    mask *= RP;
                    d = reflect(r.dir, n);
                    x += nl * 0.02f;
                } else {
                    // transmission ray
                    mask *= TP;
                    d = tdir; //r = Ray(x, tdir);
                    x += nl * 0.0005f; // epsilon must be small to avoid artefacts
                }
            }
        }
        
        // set up origin and direction of next path segment
        r.orig = x;
        r.dir = d;
    }
    
    // add radiance up to a certain ray depth
    // return accumulated ray colour after all bounces are computed
    return accucolor;
}

inline float clamp(float x){
    return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x;
}

#define samps 1 // samples

kernel void render(texture2d<float, access::read_write> output [[ texture(0) ]],
                   constant float3& firstcamorig [[buffer(0)]],
                   constant const int& numtriangles [[buffer(1)]],
                   constant int& framenumber [[buffer(2)]],
                   constant uint& hashedframenumber [[buffer(3)]],
                   constant float3& scene_bbmin [[buffer(4)]],
                   constant float3& scene_bbmax [[buffer(5)]],
                   texture1d<float, access::read> triangle_texture [[ texture(1) ]],
                   uint3 tpig [[ thread_position_in_grid ]]) {
    uint width = output.get_width();
    uint height = output.get_height();
    // seeds for random number generator
    unsigned int s1 = tpig.x;
    unsigned int s2 = tpig.y;
    
    Ray cam(firstcamorig, normalize(float3(0, -0.042612, -1)));
    float3 cx = float3(width * .5135 / height, 0.0f, 0.0f);  // ray direction offset along X-axis
    float3 cy = normalize(cross(cx, cam.dir)) * .5135; // ray dir offset along Y-axis, .5135 is FOV angle
    float3 pixelcol; // final pixel color
    
    pixelcol = float3(0.0f, 0.0f, 0.0f); // reset to zero for every pixel
    
    for (int s = 0; s < samps; s++){
        // compute primary ray direction
        float3 d = cx*((.25 + tpig.x) / width - .5) + cy*((.25 + tpig.y) / height - .5) + cam.dir;
        // normalize primary ray direction
        d = normalize(d);
        // add accumulated colour from path bounces
        auto ray = Ray(cam.orig + d * 40, d);
        pixelcol += radiance(ray, &s1, &s2, numtriangles, scene_bbmin, scene_bbmax, triangle_texture) * (1./ samps);
    }       // Camera rays are pushed ^^^^^ forward to start in interior
    // averaged colour: divide colour by the number of calculated frames so far
    float3 averagedColor = (output.read(tpig.xy).xyz * (framenumber - 1) + pixelcol) / framenumber;
    
    // write rgb value of pixel to image buffer on the GPU, clamp value to [0.0f, 1.0f] range
    output.write(float4(averagedColor.xyz, 1.0), ushort2(tpig.xy));
}
