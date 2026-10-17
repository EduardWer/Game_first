shader_type canvas_item;

// Перекрашивает жидкость в спрайте красного зелья в нужный цвет,
// не трогая пробку и стекло.
uniform vec4 liquid : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Во fragment() COLOR уже умножен на текстуру, поэтому modulate берём из вершины.
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.r - c.g > 0.25) {
		vec3 col = liquid.rgb * (0.3 + c.r * 0.8);
		col = mix(col, vec3(1.0), clamp(c.g - 0.3, 0.0, 0.5));
		c.rgb = col;
	}
	COLOR = c * modulate;
}
