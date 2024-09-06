extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	install_effect(RichTextPulse.new())
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _process_custom_fx(char_fx : CharFXTransform) -> bool:
	var color = char_fx.env.get("color1", char_fx.color)
	
	var height = char_fx.env.get("height", 0.0)
	var freq = char_fx.env.get("freq", 2.0)
	
	var sinedTime = (sin(char_fx.elapsed_time * freq) + 1.0) / 2.0
	var y_off = sinedTime * height
	color.a = 1.0
	char_fx.color = char_fx.color.lerp(color, sinedTime)
	char_fx.offset = Vector2(0, -1) * y_off
	return true
