@tool

extends Control

const AUDIO_FILES = {
  'A': preload("res://audio/assets/alpha_a.mp3"),
  'B': preload("res://audio/assets/alpha_b.mp3"),
  'C': preload("res://audio/assets/alpha_c.mp3"),
  'D': preload("res://audio/assets/alpha_d.mp3"),
  'E': preload("res://audio/assets/alpha_e.mp3"),
  'F': preload("res://audio/assets/alpha_f.mp3"),
  'G': preload("res://audio/assets/alpha_g.mp3"),
  'H': preload("res://audio/assets/alpha_h.mp3"),
  'I': preload("res://audio/assets/alpha_i.mp3"),
  'J': preload("res://audio/assets/alpha_j.mp3"),
  'K': preload("res://audio/assets/alpha_k.mp3"),
  'L': preload("res://audio/assets/alpha_l.mp3"),
  'M': preload("res://audio/assets/alpha_m.mp3"),
  'N': preload("res://audio/assets/alpha_n.mp3"),
  'O': preload("res://audio/assets/alpha_o.mp3"),
  'P': preload("res://audio/assets/alpha_p.mp3"),
  'Q': preload("res://audio/assets/alpha_q.mp3"),
  'R': preload("res://audio/assets/alpha_r.mp3"),
  'S': preload("res://audio/assets/alpha_s.mp3"),
  'T': preload("res://audio/assets/alpha_t.mp3"),
  'U': preload("res://audio/assets/alpha_u.mp3"),
  'V': preload("res://audio/assets/alpha_v.mp3"),
  'W': preload("res://audio/assets/alpha_w.mp3"),
  'X': preload("res://audio/assets/alpha_x.mp3"),
  'Y': preload("res://audio/assets/alpha_y.mp3"),
  'Z': preload("res://audio/assets/alpha_z.mp3"),
}

@export var word: String = "Hello"
@export_tool_button("Play Word") var play_word_button = play_debug_word

func _ready():
  pass

func play_letter(c: String):
  if not c.to_upper() in AUDIO_FILES:
    return
  var player = AudioStreamPlayer.new()
  add_child(player)
  player.stream = AUDIO_FILES.get(c.to_upper())
  if player.stream:
    player.play()
    await player.finished
  player.queue_free()

func play_word(w: String):
  for c in w:
    play_letter(c)
    await get_tree().create_timer(0.05).timeout

func play_debug_word():
  play_word(word)
