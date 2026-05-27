#version 120

uniform sampler2D texture;

uniform float u_affineStrength;
uniform bool   u_affineEnabled;

varying vec2  v_texcoord;
varying vec2  v_texcoordAffine;
varying float v_posW;
varying vec2  v_lightcoord;
varying vec4  v_color;
varying vec3  v_normal;

void main() {
    vec2 texCoord = v_texcoord;

    if (u_affineEnabled) {
        vec2 affineUV = v_texcoordAffine / v_posW;
        texCoord = mix(v_texcoord, affineUV, u_affineStrength);
    }

    vec4 albedo = texture2D(texture, texCoord) * v_color;

    vec3 n = normalize(v_normal);
    vec3 encodedNormal = n * 0.5 + 0.5;

    float smoothness = 0.0;
    float metalness  = 0.0;
    float emission   = 0.0;

    /* DRAWBUFFERS:0123 */
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(encodedNormal, 1.0);
    gl_FragData[2] = vec4(smoothness, metalness, emission, 1.0);
    gl_FragData[3] = vec4(gl_FragCoord.z, 0.0, 0.0, 0.0);
}
