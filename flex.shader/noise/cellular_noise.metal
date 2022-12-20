//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

#include "cellular_noise.h"

// Cellular noise, returning F1 and F2 in a float2.
// Standard 3x3 search window for good F1 and F2 values
float2 cellular(float2 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 3/7
#define jitter 1.0 // Less gives more regular pattern
    float2 Pi = mod289(floor(P));
    float2 Pf = fract(P);
    float3 oi = float3(-1.0, 0.0, 1.0);
    float3 of = float3(-0.5, 0.5, 1.5);
    float3 px = permute(Pi.x + oi);
    float3 p = permute(px.x + Pi.y + oi); // p11, p12, p13
    float3 ox = fract(p*K) - Ko;
    float3 oy = mod7(floor(p*K))*K - Ko;
    float3 dx = Pf.x + 0.5 + jitter*ox;
    float3 dy = Pf.y - of + jitter*oy;
    float3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
    p = permute(px.y + Pi.y + oi); // p21, p22, p23
    ox = fract(p*K) - Ko;
    oy = mod7(floor(p*K))*K - Ko;
    dx = Pf.x - 0.5 + jitter*ox;
    dy = Pf.y - of + jitter*oy;
    float3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
    p = permute(px.z + Pi.y + oi); // p31, p32, p33
    ox = fract(p*K) - Ko;
    oy = mod7(floor(p*K))*K - Ko;
    dx = Pf.x - 1.5 + jitter*ox;
    dy = Pf.y - of + jitter*oy;
    float3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
    // Sort out the two smallest distances (F1, F2)
    float3 d1a = min(d1, d2);
    d2 = max(d1, d2); // Swap to keep candidates for F2
    d2 = min(d2, d3); // neither F1 nor F2 are now in d3
    d1 = min(d1a, d2); // F1 is now in d1
    d2 = max(d1a, d2); // Swap to keep candidates for F2
    d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
    d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
    d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
    d1.y = min(d1.y, d1.z); // nor in  d1.z
    d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
    return sqrt(d1.xy);
#undef K
#undef Ko
#undef jitter
}


// Cellular noise, returning F1 and F2 in a float2.
// Speeded up by using 2x2 search window instead of 3x3,
// at the expense of some strong pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a smooth F2, use the slower 3x3 version.
// F1 is sometimes wrong, too, but OK for most purposes.
float2 cellular2x2(float2 P) {
#define K 0.142857142857 // 1/7
#define K2 0.0714285714285 // K/2
#define jitter 0.8 // jitter 1.0 makes F1 wrong more often
    float2 Pi = mod289(floor(P));
    float2 Pf = fract(P);
    float4 Pfx = Pf.x + float4(-0.5, -1.5, -0.5, -1.5);
    float4 Pfy = Pf.y + float4(-0.5, -0.5, -1.5, -1.5);
    float4 p = permute(Pi.x + float4(0.0, 1.0, 0.0, 1.0));
    p = permute(p + Pi.y + float4(0.0, 0.0, 1.0, 1.0));
    float4 ox = mod7(p)*K+K2;
    float4 oy = mod7(floor(p*K))*K+K2;
    float4 dx = Pfx + jitter*ox;
    float4 dy = Pfy + jitter*oy;
    float4 d = dx * dx + dy * dy; // d11, d12, d21 and d22, squared
    // Sort out the two smallest distances
#if 0
    // Cheat and pick only F1
    d.xy = min(d.xy, d.zw);
    d.x = min(d.x, d.y);
    return float2(sqrt(d.x)); // F1 duplicated, F2 not computed
#else
    // Do it right and find both F1 and F2
    d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap if smaller
    d.xz = (d.x < d.z) ? d.xz : d.zx;
    d.xw = (d.x < d.w) ? d.xw : d.wx;
    d.y = min(d.y, d.z);
    d.y = min(d.y, d.w);
    return sqrt(d.xy);
#endif
    
#undef K
#undef K2
#undef jitter
}

// Cellular noise, returning F1 and F2 in a float2.
// Speeded up by using 2x2x2 search window instead of 3x3x3,
// at the expense of some pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a good F2, use the slower 3x3x3 version.
float2 cellular2x2x2(float3 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 1/2-K/2
#define K2 0.020408163265306 // 1/(7*7)
#define Kz 0.166666666667 // 1/6
#define Kzo 0.416666666667 // 1/2-1/6*2
#define jitter 0.8 // smaller jitter gives less errors in F2
    float3 Pi = mod289(floor(P));
    float3 Pf = fract(P);
    float4 Pfx = Pf.x + float4(0.0, -1.0, 0.0, -1.0);
    float4 Pfy = Pf.y + float4(0.0, 0.0, -1.0, -1.0);
    float4 p = permute(Pi.x + float4(0.0, 1.0, 0.0, 1.0));
    p = permute(p + Pi.y + float4(0.0, 0.0, 1.0, 1.0));
    float4 p1 = permute(p + Pi.z); // z+0
    float4 p2 = permute(p + Pi.z + float4(1.0)); // z+1
    float4 ox1 = fract(p1*K) - Ko;
    float4 oy1 = mod7(floor(p1*K))*K - Ko;
    float4 oz1 = floor(p1*K2)*Kz - Kzo; // p1 < 289 guaranteed
    float4 ox2 = fract(p2*K) - Ko;
    float4 oy2 = mod7(floor(p2*K))*K - Ko;
    float4 oz2 = floor(p2*K2)*Kz - Kzo;
    float4 dx1 = Pfx + jitter*ox1;
    float4 dy1 = Pfy + jitter*oy1;
    float4 dz1 = Pf.z + jitter*oz1;
    float4 dx2 = Pfx + jitter*ox2;
    float4 dy2 = Pfy + jitter*oy2;
    float4 dz2 = Pf.z - 1.0 + jitter*oz2;
    float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1; // z+0
    float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2; // z+1
    
    // Sort out the two smallest distances (F1, F2)
#if 0
    // Cheat and sort out only F1
    d1 = min(d1, d2);
    d1.xy = min(d1.xy, d1.wz);
    d1.x = min(d1.x, d1.y);
    return float2(sqrt(d1.x));
#else
    // Do it right and sort out both F1 and F2
    float4 d = min(d1,d2); // F1 is now in d
    d2 = max(d1,d2); // Make sure we keep all candidates for F2
    d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap smallest to d.x
    d.xz = (d.x < d.z) ? d.xz : d.zx;
    d.xw = (d.x < d.w) ? d.xw : d.wx; // F1 is now in d.x
    d.yzw = min(d.yzw, d2.yzw); // F2 now not in d2.yzw
    d.y = min(d.y, d.z); // nor in d.z
    d.y = min(d.y, d.w); // nor in d.w
    d.y = min(d.y, d2.x); // F2 is now in d.y
    return sqrt(d.xy); // F1 and F2
#endif
    
#undef K
#undef Ko
#undef K2
#undef Kz
#undef Kzo
#undef jitter
}

// Cellular noise, returning F1 and F2 in a float2.
// 3x3x3 search region for good F2 everywhere, but a lot
// slower than the 2x2x2 version.
// The code below is a bit scary even to its author,
// but it has at least half decent performance on a
// modern GPU. In any case, it beats any software
// implementation of Worley noise hands down.
float2 cellular(float3 P) {
#define K 0.142857142857 // 1/7
#define Ko 0.428571428571 // 1/2-K/2
#define K2 0.020408163265306 // 1/(7*7)
#define Kz 0.166666666667 // 1/6
#define Kzo 0.416666666667 // 1/2-1/6*2
#define jitter 1.0 // smaller jitter gives more regular pattern
    
    float3 Pi = mod289(floor(P));
    float3 Pf = fract(P) - 0.5;
    
    float3 Pfx = Pf.x + float3(1.0, 0.0, -1.0);
    float3 Pfy = Pf.y + float3(1.0, 0.0, -1.0);
    float3 Pfz = Pf.z + float3(1.0, 0.0, -1.0);
    
    float3 p = permute(Pi.x + float3(-1.0, 0.0, 1.0));
    float3 p1 = permute(p + Pi.y - 1.0);
    float3 p2 = permute(p + Pi.y);
    float3 p3 = permute(p + Pi.y + 1.0);
    
    float3 p11 = permute(p1 + Pi.z - 1.0);
    float3 p12 = permute(p1 + Pi.z);
    float3 p13 = permute(p1 + Pi.z + 1.0);
    
    float3 p21 = permute(p2 + Pi.z - 1.0);
    float3 p22 = permute(p2 + Pi.z);
    float3 p23 = permute(p2 + Pi.z + 1.0);
    
    float3 p31 = permute(p3 + Pi.z - 1.0);
    float3 p32 = permute(p3 + Pi.z);
    float3 p33 = permute(p3 + Pi.z + 1.0);
    
    float3 ox11 = fract(p11*K) - Ko;
    float3 oy11 = mod7(floor(p11*K))*K - Ko;
    float3 oz11 = floor(p11*K2)*Kz - Kzo; // p11 < 289 guaranteed
    
    float3 ox12 = fract(p12*K) - Ko;
    float3 oy12 = mod7(floor(p12*K))*K - Ko;
    float3 oz12 = floor(p12*K2)*Kz - Kzo;
    
    float3 ox13 = fract(p13*K) - Ko;
    float3 oy13 = mod7(floor(p13*K))*K - Ko;
    float3 oz13 = floor(p13*K2)*Kz - Kzo;
    
    float3 ox21 = fract(p21*K) - Ko;
    float3 oy21 = mod7(floor(p21*K))*K - Ko;
    float3 oz21 = floor(p21*K2)*Kz - Kzo;
    
    float3 ox22 = fract(p22*K) - Ko;
    float3 oy22 = mod7(floor(p22*K))*K - Ko;
    float3 oz22 = floor(p22*K2)*Kz - Kzo;
    
    float3 ox23 = fract(p23*K) - Ko;
    float3 oy23 = mod7(floor(p23*K))*K - Ko;
    float3 oz23 = floor(p23*K2)*Kz - Kzo;
    
    float3 ox31 = fract(p31*K) - Ko;
    float3 oy31 = mod7(floor(p31*K))*K - Ko;
    float3 oz31 = floor(p31*K2)*Kz - Kzo;
    
    float3 ox32 = fract(p32*K) - Ko;
    float3 oy32 = mod7(floor(p32*K))*K - Ko;
    float3 oz32 = floor(p32*K2)*Kz - Kzo;
    
    float3 ox33 = fract(p33*K) - Ko;
    float3 oy33 = mod7(floor(p33*K))*K - Ko;
    float3 oz33 = floor(p33*K2)*Kz - Kzo;
    
    float3 dx11 = Pfx + jitter*ox11;
    float3 dy11 = Pfy.x + jitter*oy11;
    float3 dz11 = Pfz.x + jitter*oz11;
    
    float3 dx12 = Pfx + jitter*ox12;
    float3 dy12 = Pfy.x + jitter*oy12;
    float3 dz12 = Pfz.y + jitter*oz12;
    
    float3 dx13 = Pfx + jitter*ox13;
    float3 dy13 = Pfy.x + jitter*oy13;
    float3 dz13 = Pfz.z + jitter*oz13;
    
    float3 dx21 = Pfx + jitter*ox21;
    float3 dy21 = Pfy.y + jitter*oy21;
    float3 dz21 = Pfz.x + jitter*oz21;
    
    float3 dx22 = Pfx + jitter*ox22;
    float3 dy22 = Pfy.y + jitter*oy22;
    float3 dz22 = Pfz.y + jitter*oz22;
    
    float3 dx23 = Pfx + jitter*ox23;
    float3 dy23 = Pfy.y + jitter*oy23;
    float3 dz23 = Pfz.z + jitter*oz23;
    
    float3 dx31 = Pfx + jitter*ox31;
    float3 dy31 = Pfy.z + jitter*oy31;
    float3 dz31 = Pfz.x + jitter*oz31;
    
    float3 dx32 = Pfx + jitter*ox32;
    float3 dy32 = Pfy.z + jitter*oy32;
    float3 dz32 = Pfz.y + jitter*oz32;
    
    float3 dx33 = Pfx + jitter*ox33;
    float3 dy33 = Pfy.z + jitter*oy33;
    float3 dz33 = Pfz.z + jitter*oz33;
    
    float3 d11 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
    float3 d12 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
    float3 d13 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
    float3 d21 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
    float3 d22 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
    float3 d23 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
    float3 d31 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
    float3 d32 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
    float3 d33 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;
    
    // Sort out the two smallest distances (F1, F2)
#if 0
    // Cheat and sort out only F1
    float3 d1 = min(min(d11,d12), d13);
    float3 d2 = min(min(d21,d22), d23);
    float3 d3 = min(min(d31,d32), d33);
    float3 d = min(min(d1,d2), d3);
    d.x = min(min(d.x,d.y),d.z);
    return float2(sqrt(d.x)); // F1 duplicated, no F2 computed
#else
    // Do it right and sort out both F1 and F2
    float3 d1a = min(d11, d12);
    d12 = max(d11, d12);
    d11 = min(d1a, d13); // Smallest now not in d12 or d13
    d13 = max(d1a, d13);
    d12 = min(d12, d13); // 2nd smallest now not in d13
    float3 d2a = min(d21, d22);
    d22 = max(d21, d22);
    d21 = min(d2a, d23); // Smallest now not in d22 or d23
    d23 = max(d2a, d23);
    d22 = min(d22, d23); // 2nd smallest now not in d23
    float3 d3a = min(d31, d32);
    d32 = max(d31, d32);
    d31 = min(d3a, d33); // Smallest now not in d32 or d33
    d33 = max(d3a, d33);
    d32 = min(d32, d33); // 2nd smallest now not in d33
    float3 da = min(d11, d21);
    d21 = max(d11, d21);
    d11 = min(da, d31); // Smallest now in d11
    d31 = max(da, d31); // 2nd smallest now not in d31
    d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
    d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
    d12 = min(d12, d21); // 2nd smallest now not in d21
    d12 = min(d12, d22); // nor in d22
    d12 = min(d12, d31); // nor in d31
    d12 = min(d12, d32); // nor in d32
    d11.yz = min(d11.yz,d12.xy); // nor in d12.yz
    d11.y = min(d11.y,d12.z); // Only two more to go
    d11.y = min(d11.y,d11.z); // Done! (Phew!)
    return sqrt(d11.xy); // F1, F2
#endif
    
#undef K
#undef Ko
#undef K2
#undef Kz
#undef Kzo
#undef jitter
}
