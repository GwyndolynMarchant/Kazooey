extends Node

var dialog_lines = [
	"First line of test dialog.",
	"And then another!",
	"We keep testing them, woohoo...",
	"And more! Just so many lines of dialog",
	"Wowee.....",
	"And this is a big one. A big line of dialog."
]

var i = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
var t_delta = 0

signal speak_line()

func _process(delta):
	t_delta += delta
	if t_delta > 5 and i <= dialog_lines.size():
		t_delta -= 5;
		print(dialog_lines[i])
		emit_signal("speak_line", dialog_lines[i])
		i += 1
	
