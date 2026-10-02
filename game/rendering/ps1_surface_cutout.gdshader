shader_type spatial;
render_mode cull_disabled;
// Alpha-scissor, double-sided kit surfaces (mosquito net weave).

#include "res://rendering/ps1_surface.gdshaderinc"

void fragment() {
	vec4 texel = texture(albedo_texture, UV);
	ALBEDO = texel.rgb * albedo_color.rgb;
	ALPHA = texel.a * albedo_color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
