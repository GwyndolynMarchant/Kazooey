extends Node

class_name Kazooey

export(int) var Length
export(String) var Kazooey_root_dir

func pull_from_bag(voice_box):
	var bag_dir = Directory.new()
	
	if bag_dir.open("res://%sbig/%s" % [Kazooey_root_dir, voice_box]) == OK:
		print("Found folder.")
	else:
		print("Didn't find folder.")

func enumerate_dialog(script_line):
	var regex = RegEx.new()
	regex.compile("([\\w|']+\\W?)")
	var result = regex.search_all(script_line)
	return result.size()

func speak(line):
	var n = enumerate_dialog(line)
	print("%d words in sentence '%s'" % [n, line])
	
