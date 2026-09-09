shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float mask = smoothstep(0.5, 0.48, dist);
	COLOR.a *= mask;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
