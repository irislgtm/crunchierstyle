#version 120

// PSX Vertex Snap + Affine UV Warp — Entity Variant
// Drop-in replacement for SEUS PBR gbuffers_entities.vsh.
// Same vertex snapping and affine UV prep as terrain variant,
// applied to mobs, items, armour stands, etc.

uniform float u_snapResolution;
uniform bool   u_snapEnabled;
uniform bool   u_affineEnabled;

varying vec2  v_texcoord;
varying vec2  v_texcoordAffine;
varying float v_posW;
varying vec2  v_lightcoord;
varying vec4  v_color;
varying vec3  v_normal;

void main() {
    v_texcoord   = gl_MultiTexCoord0.xy;
    v_lightcoord = gl_MultiTexCoord1.xy;
    v_color      = gl_Color;

    v_normal = normalize(gl_NormalMatrix * gl_Normal);

    vec4 pos = ftransform();

    if (u_snapEnabled) {
        float res = max(u_snapResolution, 0.001);
        pos.xy = floor(pos.xy * res + 0.5) / res;
    }

    v_posW = pos.w;

    if (u_affineEnabled) {
        v_texcoordAffine = v_texcoord * pos.w;
    } else {
        v_texcoordAffine = v_texcoord;
    }

    gl_Position = pos;
}
