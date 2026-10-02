shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D reflection_texture : source_color, filter_nearest;
uniform bool active = false;

void fragment() {
	// Camera basis is right-handed. Horizontal flip restores mirror handedness.
	vec3 reflected = texture(reflection_texture, vec2(1.0 - UV.x, UV.y)).rgb;
	ALBEDO = active ? reflected * vec3(0.88, 0.94, 0.90) : vec3(0.045, 0.065, 0.065);
}
