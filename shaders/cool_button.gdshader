shader_type canvas_item;

uniform vec3 x_color : source_color;
uniform float flip : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = x_color;
	COLOR.a = clamp(1.0 - COLOR.a + flip, 0.0, 1.0);
}
