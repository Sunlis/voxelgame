class_name VideoOptionsMenu
extends Control

@onready var anti_aliasing_control : ListOptionControl = %AntiAliasingControl
@onready var occlusion_culling_control : ListOptionControl = %OcclusionCullingControl
@onready var shadow_control: ListOptionControl = %ShadowControl

func _ready() -> void:
	anti_aliasing_control.setting_changed.connect(_on_anti_aliasing_setting_changed)
	occlusion_culling_control.setting_changed.connect(_on_occlusion_culling_setting_changed)
	shadow_control.setting_changed.connect(_on_shadow_setting_changed)
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _preselect_resolution(window : Window) -> void:
	%ResolutionControl.value = window.size

func _update_resolution_options_enabled(window : Window) -> void:
	if OS.has_feature("web"):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionControl.editable = true
		%ResolutionControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window) -> void:
	%FullscreenControl.value = AppSettings.is_fullscreen(window)
	_preselect_resolution(window)
	%VSyncControl.value = AppSettings.get_vsync(window)
	_update_resolution_options_enabled(window)

func _on_fullscreen_control_setting_changed(value) -> void:
	var window : Window = get_window()
	AppSettings.set_fullscreen_enabled(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value) -> void:
	AppSettings.set_resolution(value, get_window(), false)

func _on_v_sync_control_setting_changed(value) -> void:
	AppSettings.set_vsync(value, get_window())

func _on_anti_aliasing_setting_changed(value) -> void:
	print('changing anti aliasing to %d' % value)
	RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), value)
	print(get_viewport().msaa_3d)

func _on_occlusion_culling_setting_changed(value) -> void:
	print('changing occlusion culling to %d' % value)
	if value == 0:
		get_viewport().use_occlusion_culling = false
	else:
		get_viewport().use_occlusion_culling = true
		RenderingServer.viewport_set_occlusion_culling_build_quality(value - 1)

func _on_shadow_setting_changed(value) -> void:
	print('changing shadow quality to %d' % value)
	
	var shadow_atlas_sizes = {
		0: 1024,
		1: 2048,
		2: 4096,
		3: 8192,
	}
	RenderingServer.directional_shadow_atlas_set_size(
		shadow_atlas_sizes.get(value, 1024), true)
	RenderingServer.viewport_set_positional_shadow_atlas_size(
		get_viewport().get_viewport_rid(), shadow_atlas_sizes.get(value, 1024))
	
	var soft_shadow_filters = {
		0: 0, # Hard (Fastest)
		1: 2, # Soft Low (Fast)
		2: 3, # Soft Medium (Average)
		3: 5, # Soft Ultra (Slowest)
	}
	RenderingServer.directional_soft_shadow_filter_set_quality(
		soft_shadow_filters.get(value, 0))
	RenderingServer.positional_soft_shadow_filter_set_quality(
		soft_shadow_filters.get(value, 0))
