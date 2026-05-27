#version 120

// PSX Final Pass
// Tonemaps the HDR scene (SEUS-style filmic), applies gamma correction,
// then optionally snaps UVs to a low-resolution pixel grid to simulate
// a 320x240 internal resolution without changing the framebuffer.

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

uniform bool u_pixelateEnabled;

varying vec2 texCoord;

// SEUS-style filmic tonemap (Hable/Uncharted 2 curve)
vec3 TonemapFilmic(vec3 x) {
    float a = 0.15;
    float b = 0.50;
    float c = 0.10;
    float d = 0.20;
    float e = 0.02;
    float f = 0.30;

    return ((x * (a * x + c * b) + d * e) / (x * (a * x + b) + d * f)) - e / f;
}

vec3 LinearToSRGB(vec3 linear) {
    return pow(linear, vec3(1.0 / 2.2));
}

void main() {
    vec2 uv = texCoord;

    // Nearest-neighbour pixel grid snap (applied to UV before sampling)
    if (u_pixelateEnabled) {
        vec2 grid = vec2(320.0, 240.0) * vec2(aspectRatio, 1.0);
        uv = floor(uv * grid + 0.5) / grid;
    }

    vec3 color = texture2D(colortex0, uv).rgb;

    // Filmic tonemap (HDR to LDR)
    color = TonemapFilmic(color);

    // Gamma correction (linear to sRGB)
    color = LinearToSRGB(color);

    gl_FragColor = vec4(color, 1.0);
}
