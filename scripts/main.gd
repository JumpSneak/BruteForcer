extends Node2D



@onready var line_edit = $LineEdit
@onready var label = $Label
@onready var button = $Button
@onready var hashout = $hashout
@onready var brutetime = $brutetime
@onready var maxlengthsetting = $maxlengthsetting
@onready var hashin = $hashin
#charsetselection
@onready var asciisw = $charsetselection/ascii
@onready var letters = $charsetselection/letters
@onready var numbers = $charsetselection/numbers

var charset : Array
var inputhash = ""
var max_length := 6
var cancel := false
var t1 = Thread.new()

func _ready():
	_on_ascii_pressed()
	var s = ""

func _on_Button_pressed():
	if line_edit.text.length() == 64:
		label.text = "Calculating..."
		brutetime.text = ""
		button.disabled = true
		maxlengthsetting.editable = false
		cancel = false
		t1.wait_to_finish()
		t1.start(Callable(self, "bruting"))
	else:
		label.text = "INVALID INPUT, ENTER SHA-256-HASH"

func bruting():
	print(charset)
	var timezero = Time.get_unix_time_from_system()
	print("starting---")
	inputhash = line_edit.text
	for length in range(1, max_length+1):
		print(length)
		if(generate("", 0, length)):
			break
		elif length == max_length:
			print("password not found")
			label.text = "Couldn't find password"
	print("finished")
	timezero = Time.get_unix_time_from_system() - timezero
	brutetime.text = "Time: " + str(timezero) + "s"
	button.disabled = false
	maxlengthsetting.editable = true
	pass


func generate(s:String, pos:int, length:int) -> bool:
	if length == 0:
		if s.sha256_text() == inputhash:
			cancel = true
			label.text = s
			return true
		elif cancel:
			cancel = false
			label.text = ""
			return true
		else:
			return false
	else:
		for i in range(0, charset.size()):
			if generate(s + charset[i], i, length-1):
				return true
		return false




func _on_ascii_pressed():
	if t1.is_alive():
		return
	for i in asciisw.get_parent().get_children():
		i.disabled = false
	asciisw.disabled = true
	charset.resize(96)
	print("donethat")
	for i in range(96):
		charset[i] = char(i+32)

func _on_lettersonly_pressed():
	if t1.is_alive():
		return
	for i in letters.get_parent().get_children():
		i.disabled = false
	letters.disabled = true
	charset.resize(52)
	print("donethat")
	for i in range(26):
		charset[i] = char(i+97)
	for i in range(26):
		charset[i+26] = char(i+65)

func _on_numbersonly_pressed():
	if t1.is_alive():
		return
	for i in numbers.get_parent().get_children():
		i.disabled = false
	numbers.disabled = true
	charset.resize(10)
	charset = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]





#Hash Generator
func _on_hashin_text_submitted(new_text):
	if new_text != "":
		hashout.text = new_text.sha256_text()
	else:
		hashout.text = ""

func _on_hashout_focus_entered():
	DisplayServer.clipboard_set(hashout.text)

func _on_hashin_text_changed(new_text):
	if new_text != "":
		hashout.text = new_text.sha256_text()
	else:
		hashout.text = ""

func _on_line_edit_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
		line_edit.text = DisplayServer.clipboard_get()


func _on_button_2_pressed():
	cancel = true

func _on_spin_box_value_changed(value):
	max_length = value


func _on_check_button_toggled(button_pressed):
	hashin.secret = button_pressed
