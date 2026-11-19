shader_type spatial;
// T-264: a fake room behind a window quad (interior mapping), no geometry. The quad's UV spans the window (u from the
// viewer's left to right, v from the top down); UV2 holds the window's width and height in metres. The room is `depth`
// metres deep. The ray from the camera through the fragment is followed in the room's frame (the quad's normal, which
// points out of the room, and the world up) to the first surface it meets: a side wall, the floor, the ceiling or the
// back wall, each a cell of the atlas (row = the kind of room). Rooms vary per window (a hash of its corner): some are
// darker, some empty. Lit like any surface (the torch lights it through the glass); no emission, no light added.
render_mode cull_back;

uniform sampler2D atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform float row = 0.0;
uniform float depth = 3.2;
uniform float dim : hint_range(0.0, 2.0) = 0.8;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.85;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

vec3 cell(vec2 uv, float col) {
	uv = clamp(uv, vec2(0.006), vec2(0.994));
	return texture(atlas, (vec2(col, row) + uv) / 4.0).rgb;
}

float hash(vec3 p) {
	return fract(sin(dot(floor(p * 2.0), vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 right = normalize(cross(up, n));
	float w = max(UV2.x, 0.1);
	float h = max(UV2.y, 0.1);
	vec3 p0 = vec3(UV.x * w, (1.0 - UV.y) * h, 0.0);
	vec3 corner = world_pos - right * p0.x - up * p0.y;
	vec3 dir = normalize(world_pos - CAMERA_POSITION_WORLD);
	vec3 d = vec3(dot(dir, right), dot(dir, up), -dot(dir, n));
	d.z = max(d.z, 1e-4);
	float tx = d.x > 1e-5 ? (w - p0.x) / d.x : (d.x < -1e-5 ? -p0.x / d.x : 1e9);
	float ty = d.y > 1e-5 ? (h - p0.y) / d.y : (d.y < -1e-5 ? -p0.y / d.y : 1e9);
	float tz = depth / d.z;
	float t = min(tz, min(tx, ty));
	vec3 hit = p0 + d * t;
	vec3 col;
	if (t == tz) {
		col = cell(vec2(hit.x / w, 1.0 - hit.y / h), 3.0);
	} else if (t == tx) {
		float s = d.x > 0.0 ? hit.z / depth : 1.0 - hit.z / depth;
		col = cell(vec2(s, 1.0 - hit.y / h), 0.0);
	} else if (d.y < 0.0) {
		col = cell(vec2(hit.x / w, hit.z / depth), 1.0);
	} else {
		col = cell(vec2(hit.x / w, 1.0 - hit.z / depth), 2.0);
	}
	float k = hash(corner);
	float room_dim = k < 0.18 ? 0.25 : mix(0.65, 1.0, fract(k * 7.31));
	col *= mix(1.0, 0.5, clamp(hit.z / depth, 0.0, 1.0));
	ALBEDO = col * dim * room_dim;
	ROUGHNESS = roughness_value;
	SPECULAR = 0.2;
}
