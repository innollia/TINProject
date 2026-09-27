shader_type canvas_item;
// 화면 전환 효과. mode: 0 페이드, 1 와이프, 2 블라인드, 3 원형 조리개, 4 디졸브, 5 대각선
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int mode = 0;
uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(floor(p), vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float a = 0.0;
	if (mode == 0) {
		a = progress;
	} else if (mode == 1) {
		a = step(uv.x, progress * 1.02);
	} else if (mode == 2) {
		a = step(fract(uv.y * 9.0), progress);
	} else if (mode == 3) {
		a = 1.0 - step(distance(uv, vec2(0.5)) * 1.45, 1.0 - progress);
	} else if (mode == 4) {
		a = step(hash(uv * vec2(96.0, 54.0)), progress);
	} else {
		a = step((uv.x + uv.y) * 0.5, progress * 1.02);
	}
	COLOR = vec4(tint.rgb, tint.a * a);
}
