extends AudioStreamPlayer

class_name Kazooey

export(String) var Kazooey_root_dir = ""
export(String) var Speaker_voice_box = ""

var bag = Directory.new()
var bag_pocket = ""
var bag_open = false

func _d_print(s: String):
	if OS.is_debug_build(): print(s)

func _open_bag():
	bag_pocket = "res://%sbag/%s" % [Kazooey_root_dir, Speaker_voice_box]
	_d_print("Chosen pocket: %s" % bag_pocket)
	bag_open = (bag.open(bag_pocket) == OK)
	return bag_open

func _count_bag():
	if bag_open:
		bag.list_dir_begin()
		var n = 0
		var file = bag.get_next()
		var regex = RegEx.new()
		regex.compile("(\\d*.wav)")
		while file != "":
			var file_parse = regex.search(file)
			if file_parse:
				if file == file_parse.get_string():
					n += 1
			file = bag.get_next()
		return n
	else:
		return -1

var rng = RandomNumberGenerator.new()

func _select_chirp(last: int, count: int):
	rng.randomize()
	var select = last;
	while (select == last): select = rng.randi_range(1, count)
	if bag.open(bag_pocket) == OK:
		bag.list_dir_begin()
		var file = bag.get_next()
		while (file != ""):
			if file == "%d.wav" % select:
				return select
			else:
				file = bag.get_next()
	return -1

func _word_count_dialog(script_line: String):
	var regex = RegEx.new()
	regex.compile("([\\w|']+\\W?)")
	var result = regex.search_all(script_line)
	return result.size()

func _play_chirp(chirp_file: String):
	self.stream = load(chirp_file)
	self.play()

func speak(line: String):
	n_waiting = _word_count_dialog(line)

func shut_up():
	n_waiting = 0
	self.stop()

func _test_functions():
	# Testing each function with test data
	var N_WAV = 18
	var TEST_POCKET = "res://bag/crow"
	
	var t_name = "Test_Bag_Open"
	var t_passed = _open_bag()
	if t_passed: print("%s: PASSED" % t_name)
	else:
		print ("%s: FAILED\n\tCould not open folder" % t_name)
		print ("\n\tExpected:%s\n\tReceived:%s" % [ TEST_POCKET, bag_pocket ])
	
	t_name = "Test_Count_Bag"
	var n = _count_bag()
	if n == N_WAV: print("%s: PASSED" % t_name)
	elif n == -1: print("%s: FAILED\n\tCould not open folder" % t_name)
	else: print("%s: FAILED\n\tExpected n: %d, Returned n: %d"
		% [t_name, N_WAV, n])
	
	t_name = "Test_Select_Chirp"
	t_passed = true
	for i in range(1,50):
		var n_old = n
		n = _select_chirp(n_old, N_WAV)
		if n == n_old or n < 1 or n > N_WAV: t_passed = false
	if t_passed: print("%s: PASSED" % t_name)
	else: print("%s: FAILED" % t_name)
	
	t_name = "Test_Word_Count_Dialog"
	var d_lines = [
		["This is a test", 4],
		["Another test", 2],
		["More strings to test things!", 5],
		["What about hyphen-words?", 4],
		["This isn't five words...", 4]
	]
	t_passed = true
	for line in d_lines:
		n = _word_count_dialog(line[0])
		if n != line[1]: t_passed = false
	if t_passed: print("%s: PASSED" % t_name)
	else: print("%s: FAILED" % t_name)
	
	"""
	t_name = "Test_Play_Chirp"
	t_passed = true
	var wav_samples = [
		"1.wav",
		"2.wav",
		"5.wav",
		"16.wav"
	]
	t_passed = true
	for wav in wav_samples:
		#print("Test Playing...")
		var wav_path = "%s/%s" % [bag_pocket, wav]
		play_chirp(wav_path)
		#print("\t%s" % wav_path)
	print("%s: PASSED IF 4 CROWS" % t_name)
	"""

var n_waiting = 0
var n_samples = 0
var select_n = 1

func _ready():
	if _open_bag():
		n_samples = _count_bag()
		_d_print("Total samples in bag %s: %d" % [Speaker_voice_box, n_samples])
	else:
		_d_print("ERROR: Couldn't open bag.")

func _process(_delta):
	if self.playing and self.get_playback_position() < self.stream.get_length(): pass
	elif n_waiting == 0: pass
	else:
		_d_print("Total samples: %d" % n_samples)
		select_n = _select_chirp(select_n, n_samples)
		_d_print("Selected sample: %d" % select_n)
		_play_chirp("%s/%d.wav" % [bag_pocket, select_n])
		n_waiting -= 1
