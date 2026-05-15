#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);

    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    float saturation = 1.45;

    color.rgb = mix(vec3(gray), color.rgb, saturation);

    fragColor = color;
}
