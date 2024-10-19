shader_type canvas_item;

uniform bool screen_mode = true;
//uniform int num_colors;
uniform float precision : hint_range(0.0, 1.0, 0.1) = 0.1;

uniform sampler2D palette_in: filter_nearest;
uniform sampler2D palette_out: filter_nearest;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

group_uniforms		cycling;
uniform float		cycleRate: hint_range(-120, 120, 1);
uniform float		cycleOffset: hint_range(0, 1, 0.1);
//uniform bool		colorBlending;

vec4 swap_color(vec4 color) {
	ivec2	palSize	 = textureSize(palette_out, 0) + ivec2(1,0);

	float idxCycle	 = cycleOffset + TIME * cycleRate;	// Cycle frame
	vec2 trueCycle	 = mod(vec2(idxCycle), float(palSize.x / palSize.y));

	float inc = 1.0 / float(palSize.x);
	for (float i = 0.0; i < 1.0; i += inc) {
		vec2 uv = vec2(i, trueCycle.x);
		vec4 color_in = texture(palette_in, uv);
		if (distance(color, color_in) <= precision) {
			return texture(palette_out, uv);
		}
	}
	return color;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (screen_mode) {
		color = texture(SCREEN_TEXTURE, SCREEN_UV);
	}
	COLOR = swap_color(color);
}