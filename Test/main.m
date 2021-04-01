#import <Metal/Metal.h>

int main(int argc, const char * argv[]) {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    NSString * shader = @"\
    #include <metal_stdlib>\n\
    #include <simd/simd.h>\n\
    \n\
    constexpr constant unsigned NUM_PARTICLES = 1500u;\n\
    constexpr constant float const_0f = 0.0;\n\
    constexpr constant int const_0i = 0;\n\
    constexpr constant unsigned const_0u = 0u;\n\
    constexpr constant int const_1i = 1;\n\
    constexpr constant unsigned const_1u = 1u;\n\
    constexpr constant float const_1f = 1.0;\n\
    constexpr constant float const_0_10f = 0.1;\n\
    constexpr constant float const_n1f = -1.0;\n\
    typedef uint type;\n\
    typedef metal::float2 type1;\n\
    struct Particle {\n\
    type1 pos;\n\
    type1 vel;\n\
    };\n\
    typedef float type2;\n\
    struct SimParams {\n\
    type2 deltaT;\n\
    type2 rule1Distance;\n\
    type2 rule2Distance;\n\
    type2 rule3Distance;\n\
    type2 rule1Scale;\n\
    type2 rule2Scale;\n\
    type2 rule3Scale;\n\
    };\n\
    typedef Particle type3[1];\n\
    struct Particles {\n\
    type3 particles;\n\
    };\n\
    typedef metal::uint3 type4;\n\
    typedef int type5;\n\
    struct main1Input {\n\
    };\n\
    kernel void main1(\n\
    type4 global_invocation_id [[thread_position_in_grid]]\n\
    , constant SimParams& params [[buffer(0)]]\n\
    , constant Particles& particlesSrc [[buffer(1)]]\n\
    , device Particles& particlesDst [[buffer(2)]]\n\
    ) {\n\
    type1 vPos;\n\
    type1 vVel;\n\
    type1 cMass;\n\
    type1 cVel;\n\
    type1 colVel;\n\
    type5 cMassCount = const_0i;\n\
    type5 cVelCount = const_0i;\n\
    type1 pos1;\n\
    type1 vel1;\n\
    type i = const_0u;\n\
    if (global_invocation_id.x >= NUM_PARTICLES) {\n\
    return;\n\
    }\n\
    vPos = particlesSrc.particles[global_invocation_id.x].pos;\n\
    vVel = particlesSrc.particles[global_invocation_id.x].vel;\n\
    cMass = metal::float2(const_0f, const_0f);\n\
    cVel = metal::float2(const_0f, const_0f);\n\
    colVel = metal::float2(const_0f, const_0f);\n\
    bool loop_init = true;\n\
    while(true) {\n\
    if (!loop_init) {\n\
    i = i + const_1u;\n\
    }\n\
    loop_init = false;\n\
    if (i >= NUM_PARTICLES) {\n\
    break;\n\
    }\n\
    if (i == global_invocation_id.x) {\n\
    continue;\n\
    }\n\
    pos1 = particlesSrc.particles[i].pos;\n\
    vel1 = particlesSrc.particles[i].vel;\n\
    if (metal::distance(pos1, vPos) < params.rule1Distance) {\n\
    cMass = cMass + pos1;\n\
    cMassCount = cMassCount + const_1i;\n\
    }\n\
    if (metal::distance(pos1, vPos) < params.rule2Distance) {\n\
    colVel = colVel - (pos1 - vPos);\n\
    }\n\
    if (metal::distance(pos1, vPos) < params.rule3Distance) {\n\
    cVel = cVel + vel1;\n\
    cVelCount = cVelCount + const_1i;\n\
    }\n\
    }\n\
    if (cMassCount > const_0i) {\n\
    cMass = (cMass * (const_1f / static_cast<float>(cMassCount))) - vPos;\n\
    }\n\
    if (cVelCount > const_0i) {\n\
    cVel = cVel * (const_1f / static_cast<float>(cVelCount));\n\
    }\n\
    vVel = ((vVel + (cMass * params.rule1Scale)) + (colVel * params.rule2Scale)) + (cVel * params.rule3Scale);\n\
    vVel = metal::normalize(vVel) * metal::clamp(metal::length(vVel), const_0f, const_0_10f);\n\
    vPos = vPos + (vVel * params.deltaT);\n\
    if (vPos.x < const_n1f) {\n\
    vPos.x = const_1f;\n\
    }\n\
    if (vPos.x > const_1f) {\n\
    vPos.x = const_n1f;\n\
    }\n\
    if (vPos.y < const_n1f) {\n\
    vPos.y = const_1f;\n\
    }\n\
    if (vPos.y > const_1f) {\n\
    vPos.y = const_n1f;\n\
    }\n\
    particlesDst.particles[global_invocation_id.x].pos = vPos;\n\
    particlesDst.particles[global_invocation_id.x].vel = vVel;\n\
    return;\n\
    }\
    ";
    NSError *error = nil;
    [device newLibraryWithSource:shader options:NULL error:&error];
    if (error) {
        NSLog(@"Error compiling shader: %@", error);
    }
}
