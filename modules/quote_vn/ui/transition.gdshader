shader_type canvas_item;
// 화면 전환 효과
// 기본: 0 페이드 1 와이프 2 블라인드 3 원형 조리개 4 디졸브 5 대각선
// 고급: 6 잉크 번짐 7 불타는 종이 8 물결 왜곡 9 픽셀화 10 시계 쓸기 11 하트 조리개 12 색수차 글리치
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int mode = 0;
uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV;
	vec2 suv = SCREEN_UV;
	float asp = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec4 col = vec4(tint.rgb, 0.0);
	float p = progress;

	if (mode == 0) {
		col.a = p;
	} else if (mode == 1) {
		col.a = step(uv.x, p * 1.02);
	} else if (mode == 2) {
		col.a = step(fract(uv.y * 9.0), p);
	} else if (mode == 3) {
		col.a = 1.0 - step(distance(uv, vec2(0.5)) * 1.45, 1.0 - p);
	} else if (mode == 4) {
		col.a = step(hash(floor(uv * vec2(96.0, 54.0))), p);
	} else if (mode == 5) {
		col.a = step((uv.x + uv.y) * 0.5, p * 1.02);
	} else if (mode == 6) {
		// 잉크 번짐: 가운데서 번지는 먹물, 가장자리는 부드럽게 스민다
		float d = distance(uv * vec2(asp, 1.0), vec2(0.5 * asp, 0.5));
		float n = fbm(uv * 5.0) * 0.55;
		float field = d * 0.9 + n;
		float edge = p * 1.6;
		col.a = smoothstep(edge, edge - 0.08, field);
		col.rgb = mix(tint.rgb, tint.rgb + vec3(0.25, 0.05, 0.12), smoothstep(edge - 0.08, edge, field) * 0.8);
	} else if (mode == 7) {
		// 불타는 종이: 타들어 가는 경계가 주황색으로 빛난다
		float n = fbm(uv * 4.0 + vec2(0.0, 1.3));
		float t = p * 1.25;
		float burnt = step(n, t - 0.12);
		float glow = smoothstep(t - 0.12, t, n) * step(n, t);
		col.rgb = mix(tint.rgb, vec3(1.0, 0.55, 0.15), glow);
		col.rgb += vec3(1.0, 0.85, 0.4) * pow(glow, 3.0) * 0.8;
		col.a = max(burnt, glow);
	} else if (mode == 8) {
		// 물결 왜곡: 화면 자체가 일렁이다 잠긴다
		float amp = sin(p * 3.14159) * 0.03;
		vec2 off = vec2(sin(uv.y * 28.0 + p * 14.0), cos(uv.x * 22.0 + p * 11.0)) * amp;
		vec3 s = texture(screen_tex, suv + off).rgb;
		col.rgb = mix(s, tint.rgb, smoothstep(0.35, 1.0, p));
		col.a = step(0.001, p);
	} else if (mode == 9) {
		// 픽셀화: 점점 굵어지는 모자이크
		float cells = mix(320.0, 10.0, pow(p, 0.6));
		vec2 cell = vec2(cells, cells / asp);
		vec2 q = (floor(suv * cell) + 0.5) / cell;
		vec3 s = texture(screen_tex, q).rgb;
		col.rgb = mix(s, tint.rgb, smoothstep(0.6, 1.0, p));
		col.a = step(0.001, p);
	} else if (mode == 10) {
		// 시계 쓸기: 12시 방향부터 부드럽게 돈다
		vec2 c = uv - vec2(0.5);
		float ang = fract(atan(c.x, -c.y) / 6.28318 + 1.0);
		col.a = smoothstep(ang, ang + 0.02, p * 1.02);
	} else if (mode == 11) {
		// 하트 조리개: 하트 모양으로 좁혀진다
		vec2 h = (uv - vec2(0.5, 0.45)) * vec2(asp, 1.0) * 2.2;
		h.y = -h.y;
		float heart = pow(h.x * h.x + h.y * h.y - 1.0, 3.0) - h.x * h.x * h.y * h.y * h.y;
		float scale = mix(3.2, 0.0001, p);
		vec2 hs = h / max(scale, 0.0001);
		float hv = pow(hs.x * hs.x + hs.y * hs.y - 1.0, 3.0) - hs.x * hs.x * hs.y * hs.y * hs.y;
		col.a = step(0.0, hv);
		col.rgb = tint.rgb;
	} else {
		// 색수차 글리치: 가로 띠가 밀리고 색이 갈라진다
		float band = floor(uv.y * 24.0);
		float jit = (hash(vec2(band, floor(p * 20.0))) - 0.5) * 0.12 * sin(p * 3.14159);
		float split = 0.012 * sin(p * 3.14159);
		float r = texture(screen_tex, suv + vec2(jit + split, 0.0)).r;
		float g = texture(screen_tex, suv + vec2(jit, 0.0)).g;
		float b = texture(screen_tex, suv + vec2(jit - split, 0.0)).b;
		col.rgb = mix(vec3(r, g, b), tint.rgb, smoothstep(0.55, 1.0, p));
		col.a = step(0.001, p);
	}
	COLOR = vec4(col.rgb, col.a * tint.a);
}
