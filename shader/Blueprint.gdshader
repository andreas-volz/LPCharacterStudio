shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;
uniform vec4 flat_color : source_color = vec4(1.0);

const int MAX_LAYERS = 32;
uniform sampler2DArray tex_array;
uniform int layer_count;
uniform int layer_flat_color_mask; // flags on which layer the flat color should be applied

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;

	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);

	float a = texture(TEXTURE, UV).a;

	vec4 flat_texture = vec4(flat_color.rgb, a * flat_color.a);
	
	COLOR = mix(flat_texture, line_color, outline - flat_texture.a);

}