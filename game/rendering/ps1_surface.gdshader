shader_type spatial;
// Opaque kit surfaces (walls, beds, lockers...). See ps1_surface.gdshaderinc.

#include "res://rendering/ps1_surface.gdshaderinc"

void fragment() {
	vec4 texel = texture(albedo_texture, UV);
	ALBEDO = texel.rgb * albedo_color.rgb;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
