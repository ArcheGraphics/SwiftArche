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

struct Sphere {
    // radius
    float rad;
    // position, emission, colour
    float3 pos, emi, col;
    // reflection type (e.g. diffuse)
    Refl_t refl;
    
    float intersect_sphere(thread const Ray &r) const constant {
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

// SCENE
// 9 spheres forming a Cornell box
// small enough to be in constant GPU memory
// { float radius, { float3 position }, { float3 emission }, { float3 colour }, refl_type }
constant Sphere spheres[] = {
    { 1e5f, { 1e5f + 1.0f, 40.8f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { 0.75f, 0.25f, 0.25f }, DIFF }, //Left
    { 1e5f, { -1e5f + 99.0f, 40.8f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .25f, .25f, .75f }, DIFF }, //Rght
    { 1e5f, { 50.0f, 40.8f, 1e5f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Back
    { 1e5f, { 50.0f, 40.8f, -1e5f + 600.0f }, { 0.0f, 0.0f, 0.0f }, { 1.00f, 1.00f, 1.00f }, DIFF }, //Frnt
    { 1e5f, { 50.0f, 1e5f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Botm
    { 1e5f, { 50.0f, -1e5f + 81.6f, 81.6f }, { 0.0f, 0.0f, 0.0f }, { .75f, .75f, .75f }, DIFF }, //Top
    { 16.5f, { 27.0f, 16.5f, 47.0f }, { 0.0f, 0.0f, 0.0f }, { 1.0f, 1.0f, 1.0f }, DIFF }, // small sphere 1
    { 16.5f, { 73.0f, 16.5f, 78.0f }, { 0.0f, 0.0f, 0.0f }, { 1.0f, 1.0f, 1.0f }, DIFF }, // small sphere 2
    { 600.0f, { 50.0f, 681.6f - .77f, 81.6f }, { 2.0f, 1.8f, 1.6f }, { 0.0f, 0.0f, 0.0f }, DIFF }  // Light
};

inline bool intersect_scene(thread const Ray &r, thread float &t, thread int &id){
    // t is distance to closest intersection, initialise t to a huge number outside scene
    float n = sizeof(spheres) / sizeof(Sphere), d, inf = t = 1e20;
    
    // test all scene objects for intersection
    for (int i = int(n); i--;) {
        // if newly computed intersection distance d is smaller than current closest intersection distance
        if ((d = spheres[i].intersect_sphere(r)) && d<t){
            // keep track of distance along ray to closest intersection point
            t = d;
            // and closest intersected object
            id = i;
        }
    }
    
    // returns true if an intersection with the scene occurred, false when no hit
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

// radiance function, the meat of path tracing
// solves the rendering equation:
// outgoing radiance (at a point) = emitted radiance + reflected radiance
// reflected radiance is sum (integral) of incoming radiance from all directions in hemisphere above point,
// multiplied by reflectance function of material (BRDF) and cosine incident angle
float3 radiance(thread Ray &r, thread unsigned int *s1, thread unsigned int *s2){ // returns ray color
    // accumulates ray colour with each iteration through bounce loop
    float3 accucolor = float3(0.0f, 0.0f, 0.0f);
    float3 mask = float3(1.0f, 1.0f, 1.0f);
    
    // ray bounce loop (no Russian Roulette used)
    // iteration up to 4 bounces (replaces recursion in CPU code)
    for (int bounces = 0; bounces < 4; bounces++){
        // distance to closest intersection
        float t;
        // index of closest intersected sphere
        int id = 0;
        
        // test ray for intersection with scene
        if (!intersect_scene(r, t, id)) {
            // if miss, return black
            return float3(0.0f, 0.0f, 0.0f);
        }
        
        // else, we've got a hit!
        // compute hitpoint and normal
        // hitobject
        constant const Sphere &obj = spheres[id];
        // hitpoint
        float3 x = r.orig + r.dir*t;
        // normal
        float3 n = normalize(x - obj.pos);
        // front facing normal
        float3 nl = dot(n, r.dir) < 0 ? n : n * -1;
        
        // add emission of current sphere to accumulated colour
        // (first term in rendering equation sum)
        accucolor += mask * obj.emi;
        
        // all spheres in the scene are diffuse
        // diffuse material reflects light uniformly in all directions
        // generate new diffuse ray:
        // origin = hitpoint of previous ray in path
        // random direction in hemisphere above hitpoint (see "Realistic Ray Tracing", P. Shirley)
        
        // create 2 random numbers
        // pick random number on unit circle (radius = 1, circumference = 2*Pi) for azimuth
        float r1 = 2 * M_PI_F * getrandom(s1, s2);
        // pick random number for elevation
        float r2 = getrandom(s1, s2);
        float r2s = sqrt(r2);
        
        // compute local orthonormal basis uvw at hitpoint to use for calculation random ray direction
        // first vector = normal at hitpoint, second vector is orthogonal to first, third vector is orthogonal to first two vectors
        float3 w = nl;
        float3 u = normalize(cross((fabs(w.x) > .1 ? float3(0, 1, 0) : float3(1, 0, 0)), w));
        float3 v = cross(w,u);
        
        // compute random ray direction on hemisphere using polar coordinates
        // cosine weighted importance sampling (favours ray directions closer to normal direction)
        float3 d = normalize(u*cos(r1)*r2s + v*sin(r1)*r2s + w*sqrt(1 - r2));
        
        // new ray origin is intersection point of previous ray with scene
        // offset ray origin slightly to prevent self intersection
        r.orig = x + nl*0.05f;
        r.dir = d;
        
        // multiply with colour of object
        mask *= obj.col;
        // weigh light contribution using cosine of angle between incident light and normal
        mask *= dot(d,nl);
        // fudge factor
        mask *= 2;
    }
    
    return accucolor;
}

inline float clamp(float x){
    return x < 0.0f ? 0.0f : x > 1.0f ? 1.0f : x;
}

#define samps 1024 // samples

kernel void render(texture2d<float, access::write> output [[ texture(0) ]],
                   uint3 tpig [[ thread_position_in_grid ]]) {
    uint width = output.get_width();
    uint height = output.get_height();
    // seeds for random number generator
    unsigned int s1 = tpig.x;
    unsigned int s2 = tpig.y;
    
    // generate ray directed at lower left corner of the screen
    // compute directions for all other rays by adding cx and cy increments in x and y direction
    // first hardcoded camera ray(origin, direction)
    Ray cam(float3(50, 52, 295.6), normalize(float3(0, -0.042612, -1)));
    // ray direction offset in x direction
    float3 cx = float3(width * .5135 / height, 0.0f, 0.0f);
    // ray direction offset in y direction (.5135 is field of view angle)
    float3 cy = normalize(cross(cx, cam.dir)) * .5135;
    // r is final pixel color
    float3 r;
    
    // reset r to zero for every pixel
    r = float3(0.0f);
    
    // Camera rays are pushed ^^^^^ forward to start in interior
    for (int s = 0; s < samps; s++){  // samples per pixel
        // compute primary ray direction
        float3 d = cam.dir + cx*((.25 + tpig.x) / width - .5) + cy*((.25 + tpig.y) / height - .5);
        // create primary ray, add incoming radiance to pixelcolor
        Ray ray = Ray(cam.orig + d * 40, normalize(d));
        r = r + radiance(ray, &s1, &s2)*(1. / samps);
    }
    
    // write rgb value of pixel to image buffer on the GPU, clamp value to [0.0f, 1.0f] range
    output.write(float4(clamp(r.x, 0.0f, 1.0f), clamp(r.y, 0.0f, 1.0f), clamp(r.z, 0.0f, 1.0f), 1.0), ushort2(tpig.xy));
}
