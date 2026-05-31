shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed = 0.1;

void fragment() {
	vec2 uv = UV - direction * speed * TIME;
	COLOR = texture(TEXTURE, uv);
}
