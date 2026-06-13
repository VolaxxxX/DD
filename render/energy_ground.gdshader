shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Otherworldly ground: a dark surface veined with slow-pulsing glowing energy.
// Used for the anomaly (cold blue) and corrupted (sickly red) biomes — far more
// fitting than a flat photo texture.

uniform vec3 base_color: source_color = vec3(0.05, 0.06, 0.12);
uniform vec3 glow_color: source_color = vec3(0.3, 0.55, 1.0);
uniform float glow_strength = 2.5;
uniform float vein_scale = 0.18;
uniform float pulse_speed = 0.5;

float hash(vec2 p){ p = fract(p*vec2(123.34,456.21)); p += dot(p,p+45.32); return fract(p.x*p.y); }
float vnoise(vec2 p){
	vec2 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);
	float a=hash(i),b=hash(i+vec2(1,0)),c=hash(i+vec2(0,1)),d=hash(i+vec2(1,1));
	return mix(mix(a,b,f.x),mix(c,d,f.x),f.y);
}
float fbm(vec2 p){ float v=0.0,a=0.5; for(int i=0;i<5;i++){v+=a*vnoise(p);p=p*2.03+vec2(11.0,7.0);a*=0.5;} return v; }

varying vec3 world_pos;
void vertex(){ world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }

void fragment(){
	vec2 uv = world_pos.xz * vein_scale;
	// Cracked-vein pattern: ridged fbm.
	float n = fbm(uv);
	float veins = 1.0 - smoothstep(0.0, 0.06, abs(n - 0.5));   // thin lines where n~0.5
	veins += (1.0 - smoothstep(0.0, 0.10, abs(fbm(uv*2.1+3.0) - 0.5))) * 0.5;
	// Slow pulse along the veins.
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed + n * 10.0);
	float dark = fbm(uv * 0.5) * 0.15;
	ALBEDO = base_color + dark;
	ROUGHNESS = 0.85;
	EMISSION = glow_color * veins * glow_strength * pulse;
}
