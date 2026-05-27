#version 120

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

uniform bool u_pixelateEnabled;

varying vec2 texCoord;

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

    if (u_pixelateEnabled) {
        vec2 grid = vec2(320.0, 240.0) * vec2(aspectRatio, 1.0);
        uv = floor(uv * grid + 0.5) / grid;
    }

    vec3 color = texture2D(colortex0, uv).rgb;

    color = TonemapFilmic(color);
    color = LinearToSRGB(color);

    gl_FragColor = vec4(color, 1.0);
}
