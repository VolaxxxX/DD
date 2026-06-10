extends CanvasLayer
# Full-screen vignette + film grain on top of everything. Autoloaded as "PostFX".

func _ready() -> void:
	layer = 50
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = ShaderMaterial.new()
	(rect.material as ShaderMaterial).shader = _make_shader()
	add_child(rect)

func _make_shader() -> Shader:
	var s := Shader.new()
	s.code = """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;
uniform float vignette = 0.55;
uniform float grain    = 0.06;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

void fragment() {
	vec4 col = texture(screen_tex, SCREEN_UV);
	vec2 d = SCREEN_UV - vec2(0.5);
	float v = smoothstep(0.85, 0.25, length(d));
	col.rgb *= mix(1.0 - vignette, 1.0, v);
	float g = (hash(SCREEN_UV * 600.0 + TIME) - 0.5) * grain;
	col.rgb += g;
	COLOR = col;
}
"""
	return s
