shader_type spatial;
render_mode unshaded, fog_disabled;
// D-105: furnished room 407 mirrors; mirror_surface.gdshader with smooth filtering and a faint glass tint.

uniform sampler2D reflection_texture : source_color, filter_linear;
uniform bool active = false;
uniform vec3 tint : source_color = vec3(0.92, 0.95, 0.94);

void fragment() {
	// Camera basis is right-handed. Horizontal flip restores mirror handedness.
	vec3 reflected = texture(reflection_texture, vec2(1.0 - UV.x, UV.y)).rgb;
	ALBEDO = active ? reflected * tint : vec3(0.035, 0.04, 0.042);
}
