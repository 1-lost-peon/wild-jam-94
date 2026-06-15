shader_type canvas_item;

uniform sampler2D texture_a : source_color;
uniform sampler2D texture_b : source_color;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float feather : hint_range(0.0, 0.1) = 0.0;

void fragment() {
    vec4 color_a = texture(texture_a, UV);
    vec4 color_b = texture(texture_b, UV);

    float mask = smoothstep(
        progress - feather,
        progress + feather,
        UV.x
    );

    COLOR = mix(color_a, color_b, mask);
}