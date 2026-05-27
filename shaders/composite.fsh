#version 120

// PSX Post-Processing Composite
// Operates on SEUS PBR's fully-lit HDR scene (colortex0).
// Applies: 4x4 Bayer ordered dither → 5-5-5 RGB quantization → linear fog.
// No tonemapping or gamma — SEUS final pass handles that.

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3  fogColor;
uniform int   isEyeInWater;

uniform mat4 gbufferProjectionInverse;

uniform float u_ditherStrength;
uniform bool  u_ditherEnabled;
uniform bool  u_fogEnabled;

varying vec2 texCoord;

// 4x4 Bayer matrix values in row-major order
const float bayer4[16] = float[16](
     0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0,
    12.0/16.0,  4.0/16.0, 14.0/16.0,  6.0/16.0,
     3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0,
    15.0/16.0,  7.0/16.0, 13.0/16.0,  5.0/16.0
);

float GetBayer4(vec2 coord) {
    ivec2 p = ivec2(int(mod(coord.x, 4.0)), int(mod(coord.y, 4.0)));
    return bayer4[p.y * 4 + p.x];
}

float GetLinearDepth(float depth) {
    depth = depth * 2.0 - 1.0;
    vec2 zw = depth * gbufferProjectionInverse[2].zw + gbufferProjectionInverse[3].zw;
    return -zw.x / zw.y;
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    // Bayer ordered dither (applied BEFORE quantization)
    if (u_ditherEnabled && u_ditherStrength > 0.0) {
        float threshold = (GetBayer4(gl_FragCoord.xy) - 0.5) * u_ditherStrength;
        color += threshold;
    }

    // 5-5-5 RGB quantization (15-bit colour, PSX style)
    color = floor(color * 31.0 + 0.5) / 31.0;

    // Linear-space distance fog (before tonemapping, in HDR)
    if (u_fogEnabled) {
        float linDepth = GetLinearDepth(depth);

        float fogStart = 0.6 * far;
        float fogEnd   = far;
        float fogFactor = 1.0 - clamp((fogEnd - linDepth) / (fogEnd - fogStart), 0.0, 1.0);

        vec3 fogCol = fogColor;

        if (isEyeInWater == 1) {
            fogCol = vec3(0.0, 0.1, 0.25);
        } else if (isEyeInWater == 2) {
            fogCol = vec3(0.6, 0.1, 0.0);
        }

        color = mix(color, fogCol, fogFactor);
    }

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}
