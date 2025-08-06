extends CanvasLayer
class_name FullscreenLayer

@export var image_display:ImageDisplay
@export var video_player:InteractiveVideoPlayer
@export var background:ColorRect

var cur_player:InteractiveVideoPlayer

func _ready() -> void:
	hide()
	background.color = ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")
	image_display.hide()
	video_player.hide()
	image_display.fullscreen = true
	video_player.fullscreen = true
	image_display.fullscreen_requested.connect(unfullscreen)
	video_player.fullscreen_requested.connect(unfullscreen_video)
	GameSettings.settings_changed.connect(update_theme)
	setup()

func setup() -> void:
	await GameSettings.await_loaded()
	update_theme()

func update_theme() -> void:
	var th := GameSettings.get_current_theme()
	var th1 = ResourceLoader.load(th.theme_file) as Theme
	image_display.theme = th1
	video_player.theme = th1

func display_image(im:String) -> void:
	Beeper.beep()
	image_display.set_image(im)
	show()
	image_display.show()
	video_player.hide()
	video_player.stop()

func display_video(vid:InteractiveVideoPlayer) -> void:
	cur_player = vid
	Beeper.beep()
	video_player.force_pause()
	ProgramStatus.set_focused_video_player(video_player)
	show()
	image_display.hide()
	video_player.show()
	if video_player.video_playback.path != vid.video_playback.path:
		video_player.assign_video(vid.video_playback.path)
		await video_player.video_playback.video_loaded
	video_player.video_playback.seek_frame(vid.video_playback.current_frame)
	if vid.was_playing:
		video_player.force_play()

func unfullscreen_video(vid:InteractiveVideoPlayer) -> void:
	Beeper.beep()
	video_player.force_pause()
	ProgramStatus.set_focused_video_player(cur_player)
	cur_player.video_playback.seek_frame(vid.video_playback.current_frame)
	if vid.was_playing:
		cur_player.force_play()
	hide()

func unfullscreen(_arg) -> void:
	Beeper.beep()
	video_player.force_pause()
	hide()
