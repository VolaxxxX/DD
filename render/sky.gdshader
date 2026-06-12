shader_type sky;
// Stylised-realistic sky: atmospheric gradient, sun disc + halo, animated
// fbm clouds, faint stars near night. Cheap enough for the Mobile renderer.

uniform vec3 top_color: source_color = vec3(0.18, 0.30, 0.45);
uniform vec3 horizon_color: source_color = vec3(0.78, 0.72, 0.55);
uniform vec3 ground_color: source_color = vec3(0.12, 0.10, 0.10);
uniform vec3 sun_tint: source_color = vec3(1.0, 0.95, 0.85);
uniform float cloud_coverage: hint_range(0.0, 1.0) = 0.45;
uniform float cloud_speed = 0.006;
uniform vec3 cloud_color: source_color = vec3(1.0, 0.98, 0.95);
uniform float stars_amount: hint_range(0.0, 1.0) = 0.0;
uniform float haze: hint_range(0.0, 1.0) = 0.25;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec2(17.3, 9.1);
		a *= 0.5;
	}
	return v;
}

void sky() {
	float h = EYEDIR.y;
	// --- Base atmospheric gradient (denser near horizon) ---
	float t = clamp(h, 0.0, 1.0);
	float grad = pow(1.0 - t, 2.2);
	vec3 col = mix(top_color, horizon_color, grad);
	// Below horizon: dark ground haze.
	if (h < 0.0) {
		col = mix(horizon_color, ground_color, clamp(-h * 6.0, 0.0, 1.0));
	}
	// --- Sun disc + halo ---
	if (LIGHT0_ENABLED) {
		float sun_d = distance(EYEDIR, LIGHT0_DIRECTION);
		// Wide scattering halo.
		col += sun_tint * 0.35 * pow(clamp(1.0 - sun_d, 0.0, 1.0), 4.0);
		// Tight bright halo.
		col += sun_tint * 0.8 * pow(clamp(1.0 - sun_d, 0.0, 1.0), 24.0);
		// Disc.
		float disc = smoothstep(0.035, 0.025, sun_d);
		col = mix(col, sun_tint * 3.0, disc);
	}
	// --- Clouds (projected onto a virtual plane above the camera) ---
	if (h > 0.02) {
		vec2 uv = EYEDIR.xz / (h + 0.15);
		uv = uv * 1.6 + vec2(TIME * cloud_speed, TIME * cloud_speed * 0.6);
		float n = fbm(uv);
		// Coverage shaping: soft cauliflower edges.
		float cl = smoothstep(1.0 - cloud_coverage, 1.0 - cloud_coverage + 0.28, n);
		// Fade clouds toward the horizon for depth.
		float horizon_fade = smoothstep(0.02, 0.22, h);
		cl *= horizon_fade;
		// Self-shading: denser core slightly darker.
		float core = smoothstep(1.0 - cloud_coverage + 0.15, 1.0, n);
		vec3 ccol = mix(cloud_color, cloud_color * 0.72, core);
		// Sun-side warm tint on clouds.
		if (LIGHT0_ENABLED) {
			float sun_amt = pow(clamp(1.0 - distance(EYEDIR, LIGHT0_DIRECTION), 0.0, 1.0), 2.0);
			ccol = mix(ccol, sun_tint * 1.15, sun_amt * 0.45);
		}
		col = mix(col, ccol, cl * 0.85);
	}
	// --- Stars (pre-dawn only) ---
	if (stars_amount > 0.01 && h > 0.05) {
		vec2 sp = EYEDIR.xz / (h + 0.6) * 90.0;
		float s = hash12(floor(sp));
		float star = step(0.995, s) * stars_amount;
		// Twinkle.
		star *= 0.6 + 0.4 * sin(TIME * 2.0 + s * 60.0);
		col += vec3(star);
	}
	// --- Horizon haze veil ---
	col = mix(col, horizon_color, haze * pow(1.0 - clamp(abs(h) * 3.0, 0.0, 1.0), 2.0));
	COLOR = col;
}
