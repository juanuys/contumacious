shader_type canvas_item;
uniform float scroll_speed;
void fragment() {
	vec2 shifted_uv = UV;
	shifted_uv.x += TIME * scroll_speed;
	vec4 colour = texture(TEXTURE, shifted_uv);
	COLOR = colour;
}