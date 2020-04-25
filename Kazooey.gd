# Kazooey is a small AudioSteamPlayer that is used to generate character voices
# from a sound bank. When told to speak a string, it will determine the number
# of words needed and randomly select chirps (samples) from a pocket
# (subdirectory) in its bag (named directory).

extends AudioStreamPlayer

class_name Kazooey

# To use Kazooey, it must first have its root directory set. This is necessary
# for projects where you might have multiple libraries or tools in subfolders,
# etc. Then you must set which pocket of the bag this instance
# will draw from

export(String) var Kazooey_root_dir = ""
export(String) var Speaker_pocket = ""

# Local variables for navigating Kazooey's bag
var bag = Directory.new()
var bag_pocket = ""
var bag_open = false
var bag_n = 0

# Debug print function
func _d_print(s: String):
	if OS.is_debug_build(): print(s)

# Helper function to open Kazooey's bag. Necessary for Kazooey to start
# processing files. Returns whether it was successful.
func _open_bag():
	bag_pocket = "res://%sbag/%s" % [Kazooey_root_dir, Speaker_pocket]
	_d_print("Chosen pocket: %s" % bag_pocket)
	bag_open = (bag.open(bag_pocket) == OK)
	return bag_open

# Helper function to determine how many samples are in the selected pocket
# of Kazooey's bag.
func _count_bag():
	if bag_open:
		bag.list_dir_begin()
		bag_n = 0
		var file = bag.get_next()
		var regex = RegEx.new()
		regex.compile("(\\d*.wav)")
		while file != "":
			var file_parse = regex.search(file)
			if file_parse:
				if file == file_parse.get_string():
					bag_n += 1
			file = bag.get_next()
		return bag_n
	else:
		return -1

# Random number generator used for selecting samples
var rng = RandomNumberGenerator.new()

# Helper function to determine which chirp should be used next. Must be
# provided with the index of the last chirp used and the total number of
# chirps in the folder
func _select_chirp(last: int):
	rng.randomize()
	var select = last;
	
	# Continuously select new numbers until one that isn't the last
	# number is selected. Includes a clause in case you only have one sample
	# that makes sure that is the only selected sample
	while bag_n > 1 and select == last:
		select = rng.randi_range(1, bag_n)
	if bag.open(bag_pocket) == OK:
		bag.list_dir_begin()
		var file = bag.get_next()
		while (file != ""):
			if file == "%d.wav" % select:
				return select
			else:
				file = bag.get_next()
	return -1

# Helper function to count how many chirps should be made from a single
# line of dialog. Follows the chirp-per-word method.
func _word_count_dialog(script_line: String):
	var regex = RegEx.new()
	regex.compile("([\\w|']+\\W?)")
	var result = regex.search_all(script_line)
	return result.size()

# Helper function to play a chirp using the base AudioStreamPlayer
func _play_chirp(chirp_file: String):
	self.stream = load(chirp_file)
	self.play()

# Tells Kazooey to speak the provided line of dialog. Kazooey will immediately
# stop whatever it was previously speaking, and queue up a new number of
# chirps.
func speak(line: String):
	self.stop()
	n_waiting = _word_count_dialog(line)

# Tells Kazooey to immediately stop speaking. Any remaining chirps are
# removed, causing complete silence.
func shut_up():
	n_waiting = 0
	self.stop()

# Used to unit-test other functions
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
		n = _select_chirp(n_old)
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

# Initializes Kazooey 
func _ready():
	if _open_bag():
		_count_bag()
		_d_print("Total samples in bag %s: %d" % [Speaker_pocket, bag_n])
	else:
		_d_print("ERROR: Couldn't open bag.")

var select_n = 1	# Last selected variable
var n_waiting = 0	# Number of chirps waiting to be emitted

# Every frame, checks to see if a chirp is playing, and if so, if the chirp
# is done yet. If the chirp is done and chirps are remaining to be played,
# selects a new one and plays it.
func _process(_delta):
	if self.playing and self.get_playback_position() < self.stream.get_length():
		pass
	elif n_waiting == 0: pass
	else:
		_d_print("Total samples: %d" % bag_n)
		select_n = _select_chirp(select_n)
		_d_print("Selected sample: %d" % select_n)
		_play_chirp("%s/%d.wav" % [bag_pocket, select_n])
		n_waiting -= 1
