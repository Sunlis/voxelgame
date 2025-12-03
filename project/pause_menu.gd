extends MarginContainer

class_name PauseMenu

signal resume

@onready var pages: PaginatedTabContainer = %pages
@onready var main: Control = %main
@onready var options: Control = %options

@onready var resume_btn: Button = %resume_btn
@onready var options_btn: Button = %options_btn
@onready var quit_btn: Button = %quit_btn
@onready var back_btn: Button = %back_btn

func _ready():
  pages.current_tab = 0
  resume_btn.pressed.connect(func():
    resume.emit())
  options_btn.pressed.connect(func():
    options.visible = true)
  quit_btn.pressed.connect(func():
    Global.request_quit())
  back_btn.pressed.connect(func():
    main.visible = true)
