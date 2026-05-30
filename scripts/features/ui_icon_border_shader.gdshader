shader_type canvas_item;

uniform vec4 outline_color : source_color =
	vec4(0.0, 0.0, 0.0, 1.0);

uniform float outline_size = 8.0;
uniform float edge_softness = 1.5;

varying vec4 modulate_color;

void vertex() {
	modulate_color = COLOR;
}

void fragment() {

	vec4 tex = texture(TEXTURE, UV);

	vec4 icon = tex * modulate_color;

	float center_alpha = tex.a;

	// Find nearest edge distance (brute-force SDF approximation)
	float min_dist = outline_size + 1.0;

	int radius = int(ceil(outline_size));

	for (int x = -radius; x <= radius; x++) {
		for (int y = -radius; y <= radius; y++) {

			vec2 offset = vec2(float(x), float(y));
			float dist = length(offset);

			if (dist > outline_size)
				continue;

			vec2 sample_uv = UV + offset * TEXTURE_PIXEL_SIZE;

			float sample_alpha = texture(TEXTURE, sample_uv).a;

			if (sample_alpha > 0.001) {
				min_dist = min(min_dist, dist - sample_alpha);
			}
		}
	}

	// Soft falloff at outer edge
	float outer = 1.0 - smoothstep(
		outline_size - edge_softness,
		outline_size,
		min_dist
	);

	outer *= (1.0 - center_alpha);

	vec4 border = outline_color * modulate_color;

	// --- Proper alpha compositing (NO max()) ---

	float outline_a = outer * border.a;

	float final_a =
		outline_a + icon.a * (1.0 - outline_a);

	vec3 final_rgb =
		(border.rgb * outline_a * (1.0 - icon.a)) +
		(icon.rgb * icon.a);

	final_rgb /= max(final_a, 0.0001);

	COLOR = vec4(final_rgb, final_a);
}