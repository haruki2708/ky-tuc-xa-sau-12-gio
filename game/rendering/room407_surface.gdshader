shader_type spatial;
#include "res://rendering/ps1_surface.gdshaderinc"
uniform vec2 uv_scale = vec2(1.0);
void fragment() {
	ALBEDO = texture(albedo_texture, UV * uv_scale).rgb * albedo_color.rgb;
	ROUGHNESS = 0.95;
}
