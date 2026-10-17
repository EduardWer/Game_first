extends Control
## Зельеварня: бросай ингредиенты в котёл, вари зелья и выполняй заказы клиентов.

const TILES := "res://tiles/"
const POTION_SHADER := preload("res://potion_game/potion_tint.gdshader")
const STAGE_SIZE := Vector2(1152, 648)
const MAX_IN_CAULDRON := 3
const MAX_LIVES := 3
const START_RECIPES := 3
const WATER_COLOR := Color(0.25, 0.45, 0.55)
const SAVE_PATH := "user://potion_game.cfg"

const INGREDIENT_ORDER := [
	"apple", "roots", "blueberries", "crystal",
	"spider_eggs", "eyeball", "beef", "onion",
	"carrot", "snowberries", "magic_dust", "blackberry",
	"feathers", "wheat", "cabbage", "coin",
]

const INGREDIENTS := {
	"apple": {"name": "Красное яблоко", "tex": "apple_red_01", "color": Color(0.85, 0.15, 0.15)},
	"roots": {"name": "Корень мандрагоры", "tex": "roots_01", "color": Color(0.55, 0.4, 0.3)},
	"blueberries": {"name": "Черника", "tex": "blueberries_01", "color": Color(0.2, 0.25, 0.7)},
	"crystal": {"name": "Аметист", "tex": "crystal_01", "color": Color(0.6, 0.4, 0.9)},
	"spider_eggs": {"name": "Паучьи яйца", "tex": "spider_eggs_01", "color": Color(0.6, 0.75, 0.2)},
	"eyeball": {"name": "Глаз тритона", "tex": "eyeball_01", "color": Color(0.9, 0.8, 0.75)},
	"beef": {"name": "Сырое мясо", "tex": "beef_01", "color": Color(0.75, 0.2, 0.25)},
	"onion": {"name": "Лук", "tex": "onion_yellow_01", "color": Color(0.85, 0.7, 0.4)},
	"carrot": {"name": "Морковь", "tex": "carrot_01", "color": Color(0.95, 0.5, 0.1)},
	"snowberries": {"name": "Снежноягодник", "tex": "snowberries_01", "color": Color(0.9, 0.85, 0.9)},
	"magic_dust": {"name": "Волшебная пыль", "tex": "magic_dust_01", "color": Color(0.3, 0.9, 0.8)},
	"blackberry": {"name": "Ежевика", "tex": "blackberry_01", "color": Color(0.3, 0.1, 0.35)},
	"feathers": {"name": "Перья", "tex": "feathers_01", "color": Color(0.8, 0.8, 0.85)},
	"wheat": {"name": "Пшеница", "tex": "wheat_grains_01", "color": Color(0.9, 0.8, 0.45)},
	"cabbage": {"name": "Капуста", "tex": "cabbage_01", "color": Color(0.5, 0.75, 0.4)},
	"coin": {"name": "Золотая монета", "tex": "gold-coin_single_01", "color": Color(1.0, 0.8, 0.2)},
}

# Порядок важен: новые рецепты открываются для заказов по очереди.
const RECIPES := [
	{"id": "heal", "name": "Зелье лечения", "items": ["apple", "roots"], "price": 10, "tex": "potion_red_01", "color": Color(0.9, 0.23, 0.23)},
	{"id": "mana", "name": "Зелье маны", "items": ["blueberries", "crystal"], "price": 12, "tex": "potion_blue_01", "color": Color(0.2, 0.4, 0.9)},
	{"id": "poison", "name": "Яд", "items": ["spider_eggs", "eyeball"], "price": 12, "tex": "potion_green_01", "color": Color(0.25, 0.8, 0.3)},
	{"id": "swift", "name": "Зелье ловкости", "items": ["wheat", "feathers"], "price": 14, "color": Color(1.0, 0.9, 0.3)},
	{"id": "frost", "name": "Ледяное зелье", "items": ["snowberries", "magic_dust"], "price": 15, "color": Color(0.55, 0.9, 1.0)},
	{"id": "strength", "name": "Зелье силы", "items": ["beef", "onion", "carrot"], "price": 18, "color": Color(1.0, 0.5, 0.08)},
	{"id": "growth", "name": "Зелье роста", "items": ["cabbage", "carrot", "wheat"], "price": 18, "color": Color(0.6, 1.0, 0.25)},
	{"id": "shadow", "name": "Зелье невидимости", "items": ["blackberry", "feathers", "magic_dust"], "price": 22, "color": Color(0.6, 0.25, 0.9)},
	{"id": "luck", "name": "Эликсир удачи", "items": ["coin", "crystal", "magic_dust"], "price": 30, "color": Color(1.0, 0.4, 0.75)},
]
const SLUDGE := {"id": "sludge", "name": "Мутная жижа", "color": Color(0.4, 0.33, 0.22)}

const CUSTOMERS := [
	{"name": "Рыцарь Бодрик", "tex": "long_sword_01"},
	{"name": "Лучница Ива", "tex": "bow_loaded_01"},
	{"name": "Ниндзя Кайто", "tex": "skuriken_01"},
	{"name": "Шахтёр Грум", "tex": "pickaxe_01"},
	{"name": "Фермер Тит", "tex": "shovel_01"},
	{"name": "Самурай Рё", "tex": "katana_01"},
	{"name": "Дровосек Олаф", "tex": "axe_wood_splitting_01"},
	{"name": "Повариха Марта", "tex": "frying_pan_01"},
	{"name": "Маг Эльдар", "tex": "tome_01"},
	{"name": "Подрывник Бум", "tex": "bomb_01"},
	{"name": "Стражник Хуго", "tex": "lance_01"},
	{"name": "Писарь Феликс", "tex": "inkwell_01"},
]
const GREETINGS := [
	"Здравствуйте! Мне нужно:",
	"Скорее, пожалуйста!",
	"Говорят, у вас лучшие зелья.",
	"Только не перепутайте!",
	"Я заплачу золотом!",
	"Мне очень-очень нужно:",
]


## Жидкость в котле — эллипс поверх спрайта котла.
class Liquid extends Control:
	var color := Color(0.25, 0.45, 0.55)
	var _t := 0.0

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var s := size.x / 64.0
		var center := Vector2(32.0, 18.6) * s
		var ry := (2.6 + sin(_t * 3.0) * 0.15) * s
		draw_colored_polygon(_ellipse(center, 15.0 * s, ry, 40), color)
		var hl_center := center + Vector2((-5.0 + sin(_t * 1.3) * 2.0) * s, -0.6 * s)
		draw_colored_polygon(_ellipse(hl_center, 4.0 * s, 0.7 * s, 20), color.lightened(0.35))

	func _ellipse(c: Vector2, rx: float, ry: float, n: int) -> PackedVector2Array:
		var pts := PackedVector2Array()
		for i in n:
			var a := TAU * i / n
			pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
		return pts


## Пиксельное сердечко для жизней.
class Heart extends Control:
	const PIXELS := [".##.##.", "#######", "#######", ".#####.", "..###..", "...#..."]
	var filled := true:
		set(v):
			filled = v
			queue_redraw()

	func _draw() -> void:
		var s := size.x / 7.0
		var col := Color(0.9, 0.2, 0.25) if filled else Color(0.3, 0.18, 0.16)
		for y in PIXELS.size():
			var row: String = PIXELS[y]
			for x in row.length():
				if row[x] == "#":
					draw_rect(Rect2(x * s, y * s, s, s), col)


var _tex_cache := {}
var _session := 0

var gold := 0
var served := 0
var lives := MAX_LIVES
var unlocked := START_RECIPES
var known := {}
var cauldron: Array[String] = []
var result := {}
var order := {}
var customer := {}
var patience := 0.0
var patience_max := 1.0
var running := false
var brewing := false
var book_open := false
var best_gold := 0
var _flying := 0

var stage: Control
var fx: Control
var gold_label: Label
var served_label: Label
var hearts: Array[Heart] = []
var hover_label: Label
var cauldron_rect: TextureRect
var cauldron_base := Vector2.ZERO
var liquid: Liquid
var bubbles: CPUParticles2D
var slot_icons: Array[TextureRect] = []
var brew_btn: Button
var empty_btn: Button
var message_label: Label
var order_box: Control
var waiting_label: Label
var avatar: TextureRect
var customer_name: Label
var greeting: Label
var order_icon: TextureRect
var order_name: Label
var order_price: Label
var hint_label: Label
var patience_bar: ProgressBar
var patience_fill: StyleBoxFlat
var result_icon: TextureRect
var result_name: Label
var serve_btn: Button
var discard_btn: Button
var book_layer: Control
var book_grid: Control
var overlay: Control
var overlay_title: Label
var overlay_text: Label
var overlay_btn: Button


func _ready() -> void:
	randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	theme = _make_theme()
	_load_best()
	_build_ui()
	resized.connect(_on_resized)
	_on_resized()
	_refresh_all()
	_show_overlay("Зельеварня",
		"Клиенты заказывают зелья — вари их в котле!\n\n"
		+ "Нажимай на ингредиенты, чтобы бросить их в котёл, затем «Варить».\n"
		+ "Рецепты записываются в книгу. Новые зелья придётся открыть самому по подсказкам.\n\n"
		+ "Пробел — варить, Enter — отдать, R — книга рецептов.",
		"Открыть лавку")


func _process(delta: float) -> void:
	if not running or order.is_empty() or book_open:
		return
	patience -= delta
	_update_patience()
	if patience <= 0.0:
		_say("%s не дождался и ушёл!" % customer["name"], Color(1.0, 0.5, 0.4))
		_lose_life()
		_customer_leaves()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_SPACE:
			_on_brew()
		KEY_ENTER, KEY_KP_ENTER:
			if overlay.visible:
				_start_game()
			else:
				_on_serve()
		KEY_BACKSPACE:
			_on_empty()
		KEY_R:
			_toggle_book()
		KEY_ESCAPE:
			if book_open:
				_toggle_book()


func _draw() -> void:
	# Стена из досок и прилавок.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.16, 0.1, 0.08))
	var x := 0.0
	var i := 0
	while x < size.x:
		var shade := 0.02 if i % 2 == 0 else 0.0
		draw_rect(Rect2(x, 0, 64, size.y), Color(0.19 + shade, 0.12 + shade, 0.09))
		draw_rect(Rect2(x, 0, 3, size.y), Color(0.11, 0.07, 0.05))
		x += 64.0
		i += 1
	var counter_y := size.y - 96.0
	draw_rect(Rect2(0, counter_y, size.x, 96), Color(0.33, 0.2, 0.12))
	draw_rect(Rect2(0, counter_y, size.x, 8), Color(0.48, 0.31, 0.18))
	draw_rect(Rect2(0, counter_y + 8, size.x, 4), Color(0.2, 0.12, 0.07))


func _on_resized() -> void:
	stage.position = ((size - STAGE_SIZE) / 2.0).floor()
	queue_redraw()


# --- Построение интерфейса ---------------------------------------------------

func _make_theme() -> Theme:
	var th := Theme.new()
	th.default_font_size = 18

	th.set_stylebox("panel", "Panel", _box(Color(0.24, 0.15, 0.1, 0.94), Color(0.52, 0.34, 0.18), 4, 8))
	th.set_stylebox("panel", "PanelContainer", _box(Color(0.24, 0.15, 0.1, 0.97), Color(0.62, 0.42, 0.2), 4, 10))
	th.set_type_variation("Slot", "Panel")
	th.set_stylebox("panel", "Slot", _box(Color(0.12, 0.08, 0.06), Color(0.36, 0.23, 0.13), 3, 6))

	th.set_stylebox("normal", "Button", _box(Color(0.56, 0.35, 0.18), Color(0.3, 0.18, 0.09), 3, 6))
	th.set_stylebox("hover", "Button", _box(Color(0.68, 0.44, 0.22), Color(0.3, 0.18, 0.09), 3, 6))
	th.set_stylebox("pressed", "Button", _box(Color(0.42, 0.26, 0.13), Color(0.3, 0.18, 0.09), 3, 6))
	th.set_stylebox("disabled", "Button", _box(Color(0.3, 0.24, 0.2), Color(0.2, 0.15, 0.12), 3, 6))
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	th.set_color("font_color", "Button", Color(1.0, 0.94, 0.8))
	th.set_color("font_hover_color", "Button", Color(1.0, 1.0, 0.9))
	th.set_color("font_pressed_color", "Button", Color(0.9, 0.82, 0.7))
	th.set_color("font_disabled_color", "Button", Color(0.55, 0.5, 0.45))
	th.set_constant("icon_max_width", "Button", 40)

	th.set_type_variation("SlotButton", "Button")
	th.set_stylebox("normal", "SlotButton", _box(Color(0.14, 0.09, 0.06), Color(0.36, 0.23, 0.13), 3, 6))
	th.set_stylebox("hover", "SlotButton", _box(Color(0.26, 0.17, 0.1), Color(0.85, 0.65, 0.3), 3, 6))
	th.set_stylebox("pressed", "SlotButton", _box(Color(0.1, 0.06, 0.04), Color(0.85, 0.65, 0.3), 3, 6))

	th.set_color("font_color", "Label", Color(0.98, 0.92, 0.8))
	th.set_color("font_outline_color", "Label", Color(0.08, 0.04, 0.02))
	th.set_constant("outline_size", "Label", 5)

	th.set_stylebox("background", "ProgressBar", _box(Color(0.1, 0.06, 0.04), Color(0.36, 0.23, 0.13), 2, 4))
	th.set_color("font_color", "ProgressBar", Color(0, 0, 0, 0))
	return th


func _box(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(6)
	return sb


func _build_ui() -> void:
	stage = Control.new()
	stage.size = STAGE_SIZE
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)

	_build_top_bar()
	_build_shelf()
	_build_cauldron()
	_build_order_panel()
	_build_result_panel()

	var book_btn := _button("Рецепты (R)", stage, Vector2(20, 572), Vector2(230, 56))
	book_btn.icon = _tex("book_01")
	book_btn.pressed.connect(_toggle_book)

	message_label = _label("", 20, stage, Vector2(270, 588), 612, HORIZONTAL_ALIGNMENT_CENTER)

	fx = Control.new()
	fx.size = STAGE_SIZE
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(fx)

	_build_book()
	_build_overlay()


func _build_top_bar() -> void:
	stage.add_child(_icon(_tex("gold-coin_pile-L_01"), Vector2(20, 8), Vector2(56, 56)))
	gold_label = _label("0", 30, stage, Vector2(82, 16))
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	gold_label.pivot_offset = Vector2(10, 20)

	var title := _label("Зельеварня", 34, stage, Vector2(0, 12), STAGE_SIZE.x, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_color", Color(0.75, 0.95, 0.6))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE

	served_label = _label("Подано: 0", 20, stage, Vector2(830, 24), 170, HORIZONTAL_ALIGNMENT_RIGHT)
	for i in MAX_LIVES:
		var h := Heart.new()
		h.position = Vector2(1020 + i * 38, 24)
		h.size = Vector2(28, 24)
		h.pivot_offset = h.size / 2.0
		stage.add_child(h)
		hearts.append(h)


func _build_shelf() -> void:
	var shelf := _panel(Rect2(20, 80, 340, 476))
	_label("Полка ингредиентов", 20, shelf, Vector2(0, 8), 340, HORIZONTAL_ALIGNMENT_CENTER)
	for row in 4:
		var plank := ColorRect.new()
		plank.color = Color(0.45, 0.29, 0.16)
		plank.position = Vector2(8, 46 + row * 82 + 72)
		plank.size = Vector2(324, 7)
		shelf.add_child(plank)
	for i in INGREDIENT_ORDER.size():
		var id: String = INGREDIENT_ORDER[i]
		var data: Dictionary = INGREDIENTS[id]
		var btn := Button.new()
		btn.theme_type_variation = "SlotButton"
		btn.focus_mode = Control.FOCUS_NONE
		btn.position = Vector2(16 + (i % 4) * 80, 44 + (i / 4) * 82)
		btn.size = Vector2(72, 72)
		btn.tooltip_text = data["name"]
		var icon := _icon(_tex(data["tex"]), Vector2(4, 4), Vector2(64, 64))
		icon.pivot_offset = Vector2(32, 32)
		btn.add_child(icon)
		btn.mouse_entered.connect(func():
			hover_label.text = data["name"]
			create_tween().tween_property(icon, "scale", Vector2(1.15, 1.15), 0.1))
		btn.mouse_exited.connect(func():
			hover_label.text = ""
			create_tween().tween_property(icon, "scale", Vector2.ONE, 0.1))
		btn.pressed.connect(_on_ingredient.bind(id, btn))
		shelf.add_child(btn)
	hover_label = _label("", 20, shelf, Vector2(0, 378), 340, HORIZONTAL_ALIGNMENT_CENTER)
	hover_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	var tip := _label("Нажми на ингредиент, чтобы бросить его в котёл (до 3 штук).",
		15, shelf, Vector2(16, 414), 308, HORIZONTAL_ALIGNMENT_CENTER)
	tip.add_theme_color_override("font_color", Color(0.8, 0.72, 0.6))


func _build_cauldron() -> void:
	var fire := CPUParticles2D.new()
	fire.position = Vector2(575, 316)
	fire.amount = 48
	fire.lifetime = 0.7
	fire.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fire.emission_rect_extents = Vector2(70, 4)
	fire.direction = Vector2.UP
	fire.spread = 12.0
	fire.gravity = Vector2(0, -60)
	fire.initial_velocity_min = 20.0
	fire.initial_velocity_max = 60.0
	fire.scale_amount_min = 5.0
	fire.scale_amount_max = 10.0
	var fire_ramp := Gradient.new()
	fire_ramp.set_color(0, Color(1.0, 0.95, 0.4))
	fire_ramp.set_color(1, Color(0.8, 0.1, 0.0, 0.0))
	fire_ramp.add_point(0.4, Color(1.0, 0.5, 0.1, 0.9))
	fire.color_ramp = fire_ramp
	stage.add_child(fire)

	cauldron_base = Vector2(447, 110)
	cauldron_rect = _icon(_tex("cauldron_01"), cauldron_base, Vector2(256, 256))
	stage.add_child(cauldron_rect)

	liquid = Liquid.new()
	liquid.size = cauldron_rect.size
	liquid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	liquid.color = WATER_COLOR
	cauldron_rect.add_child(liquid)

	bubbles = CPUParticles2D.new()
	bubbles.position = Vector2(128, 74)
	bubbles.amount = 14
	bubbles.lifetime = 1.1
	bubbles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	bubbles.emission_rect_extents = Vector2(52, 6)
	bubbles.direction = Vector2.UP
	bubbles.spread = 10.0
	bubbles.gravity = Vector2.ZERO
	bubbles.initial_velocity_min = 15.0
	bubbles.initial_velocity_max = 45.0
	bubbles.scale_amount_min = 4.0
	bubbles.scale_amount_max = 8.0
	var bubble_ramp := Gradient.new()
	bubble_ramp.set_color(0, Color.WHITE)
	bubble_ramp.set_color(1, Color(1, 1, 1, 0))
	bubbles.color_ramp = bubble_ramp
	cauldron_rect.add_child(bubbles)

	for i in MAX_IN_CAULDRON:
		var slot := Panel.new()
		slot.theme_type_variation = "Slot"
		slot.position = Vector2(467 + i * 76, 372)
		slot.size = Vector2(64, 64)
		stage.add_child(slot)
		var icon := _icon(null, Vector2(4, 4), Vector2(56, 56))
		icon.pivot_offset = Vector2(28, 28)
		slot.add_child(icon)
		slot_icons.append(icon)

	brew_btn = _button("Варить", stage, Vector2(405, 456), Vector2(170, 56))
	brew_btn.add_theme_font_size_override("font_size", 24)
	brew_btn.pressed.connect(_on_brew)
	empty_btn = _button("Вылить", stage, Vector2(587, 456), Vector2(158, 56))
	empty_btn.pressed.connect(_on_empty)


func _build_order_panel() -> void:
	var panel := _panel(Rect2(790, 80, 342, 272))
	waiting_label = _label("Ждём клиента...", 22, panel, Vector2(0, 118), 342, HORIZONTAL_ALIGNMENT_CENTER)
	waiting_label.add_theme_color_override("font_color", Color(0.75, 0.68, 0.58))

	order_box = Control.new()
	order_box.size = panel.size
	order_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(order_box)

	var avatar_bg := Panel.new()
	avatar_bg.theme_type_variation = "Slot"
	avatar_bg.position = Vector2(14, 14)
	avatar_bg.size = Vector2(100, 100)
	order_box.add_child(avatar_bg)
	avatar = _icon(null, Vector2(2, 2), Vector2(96, 96))
	avatar_bg.add_child(avatar)

	customer_name = _label("", 22, order_box, Vector2(126, 18), 206)
	greeting = _label("", 16, order_box, Vector2(126, 52), 206)
	greeting.add_theme_color_override("font_color", Color(0.85, 0.78, 0.68))

	order_icon = _icon(null, Vector2(14, 122), Vector2(64, 64))
	order_box.add_child(order_icon)
	order_name = _label("", 22, order_box, Vector2(86, 128), 246)
	order_name.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	order_price = _label("", 16, order_box, Vector2(86, 160), 246)

	hint_label = _label("", 14, order_box, Vector2(14, 192), 314)
	hint_label.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))

	patience_bar = ProgressBar.new()
	patience_bar.position = Vector2(14, 242)
	patience_bar.size = Vector2(314, 16)
	patience_bar.show_percentage = false
	patience_fill = _box(Color(0.3, 0.8, 0.3), Color(0, 0, 0, 0), 0, 4)
	patience_bar.add_theme_stylebox_override("fill", patience_fill)
	order_box.add_child(patience_bar)


func _build_result_panel() -> void:
	var panel := _panel(Rect2(790, 366, 342, 190))
	_label("Готовое зелье", 20, panel, Vector2(0, 10), 342, HORIZONTAL_ALIGNMENT_CENTER)
	var bg := Panel.new()
	bg.theme_type_variation = "Slot"
	bg.position = Vector2(18, 48)
	bg.size = Vector2(104, 104)
	panel.add_child(bg)
	result_icon = _icon(null, Vector2(4, 4), Vector2(96, 96))
	result_icon.pivot_offset = Vector2(48, 48)
	bg.add_child(result_icon)
	result_name = _label("", 20, panel, Vector2(134, 52), 196)
	serve_btn = _button("Отдать", panel, Vector2(134, 112), Vector2(92, 44))
	serve_btn.pressed.connect(_on_serve)
	discard_btn = _button("Выбросить", panel, Vector2(230, 112), Vector2(100, 44))
	discard_btn.add_theme_font_size_override("font_size", 15)
	discard_btn.pressed.connect(_on_discard)


func _build_book() -> void:
	book_layer = _fullscreen_layer()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	book_layer.add_child(center)
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(780, 560)
	center.add_child(panel)
	panel.add_child(_icon(_tex("tome_01"), Vector2(16, 6), Vector2(48, 48)))
	var title := _label("Книга рецептов", 28, panel, Vector2(0, 12), 780, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	var close := _button("Закрыть", panel, Vector2(644, 12), Vector2(120, 40))
	close.pressed.connect(_toggle_book)
	book_grid = Control.new()
	book_grid.position = Vector2(20, 64)
	book_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(book_grid)


func _build_overlay() -> void:
	overlay = _fullscreen_layer()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(600, 0)
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 40)
	overlay_title.add_theme_color_override("font_color", Color(0.75, 0.95, 0.6))
	box.add_child(overlay_title)

	var potions := HBoxContainer.new()
	potions.alignment = BoxContainer.ALIGNMENT_CENTER
	for tex_name in ["potion_red_01", "potion_blue_01", "cauldron_01", "potion_green_01", "empty_potion_bottle"]:
		var icon := TextureRect.new()
		icon.texture = _tex(tex_name)
		icon.custom_minimum_size = Vector2(64, 64)
		potions.add_child(icon)
	box.add_child(potions)

	overlay_text = Label.new()
	overlay_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_text.custom_minimum_size = Vector2(552, 0)
	box.add_child(overlay_text)

	overlay_btn = Button.new()
	overlay_btn.focus_mode = Control.FOCUS_NONE
	overlay_btn.custom_minimum_size = Vector2(240, 56)
	overlay_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	overlay_btn.add_theme_font_size_override("font_size", 24)
	overlay_btn.pressed.connect(_start_game)
	box.add_child(overlay_btn)


func _fullscreen_layer() -> Control:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.6)
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.visible = false
	add_child(layer)
	return layer


func _panel(rect: Rect2) -> Panel:
	var p := Panel.new()
	p.position = rect.position
	p.size = rect.size
	stage.add_child(p)
	return p


func _label(text: String, font_size: int, parent: Node, pos: Vector2, width := 0.0,
		align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.position = pos
	if width > 0.0:
		l.custom_minimum_size.x = width
		l.horizontal_alignment = align
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(l)
	return l


func _button(text: String, parent: Node, pos: Vector2, btn_size: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.position = pos
	b.size = btn_size
	parent.add_child(b)
	return b


func _icon(tex: Texture2D, pos: Vector2, icon_size: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.position = pos
	r.size = icon_size
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func _tex(tex_name: String) -> Texture2D:
	if not _tex_cache.has(tex_name):
		_tex_cache[tex_name] = load(TILES + tex_name + ".png")
	return _tex_cache[tex_name]


func _show_potion(rect: TextureRect, recipe: Dictionary) -> void:
	if recipe.has("tex"):
		rect.texture = _tex(recipe["tex"])
		rect.material = null
	else:
		rect.texture = _tex("potion_red_01")
		var mat := ShaderMaterial.new()
		mat.shader = POTION_SHADER
		mat.set_shader_parameter("liquid", recipe["color"])
		rect.material = mat


# --- Игровой процесс -----------------------------------------------------------

func _start_game() -> void:
	_session += 1
	gold = 0
	served = 0
	lives = MAX_LIVES
	unlocked = START_RECIPES
	known = {}
	for i in START_RECIPES:
		known[RECIPES[i]["id"]] = true
	cauldron.clear()
	result = {}
	order = {}
	brewing = false
	running = true
	overlay.visible = false
	liquid.color = WATER_COLOR
	_say("Лавка открыта! Ждём первого клиента.")
	_refresh_all()
	_next_customer(0.8)


func _next_customer(delay: float) -> void:
	var session := _session
	order = {}
	_update_order_ui()
	await get_tree().create_timer(delay).timeout
	if session != _session or not running:
		return
	var recipe: Dictionary = RECIPES.slice(0, unlocked).pick_random()
	# Свежеоткрытые рецепты заказывают чаще, чтобы игрок их изучил.
	if unlocked > START_RECIPES and randf() < 0.35:
		recipe = RECIPES[unlocked - 1]
	customer = CUSTOMERS.pick_random()
	patience_max = maxf(22.0, 50.0 - served * 1.5)
	if not known.has(recipe["id"]):
		patience_max += 15.0
	patience = patience_max
	order = recipe
	_update_order_ui()
	order_box.modulate.a = 0.0
	order_box.position.x = 40.0
	var tw := create_tween().set_parallel()
	tw.tween_property(order_box, "modulate:a", 1.0, 0.3)
	tw.tween_property(order_box, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _customer_leaves() -> void:
	order = {}
	_update_buttons()
	if running:
		_next_customer(1.4)


func _on_ingredient(id: String, from: Control) -> void:
	if not running or brewing:
		return
	if cauldron.size() >= MAX_IN_CAULDRON:
		_say("Котёл полон! Вари или вылей.", Color(1.0, 0.7, 0.4))
		return
	cauldron.append(id)
	_flying += 1
	_update_buttons()
	var session := _session

	var fly := _icon(_tex(INGREDIENTS[id]["tex"]), Vector2.ZERO, Vector2(64, 64))
	fly.pivot_offset = Vector2(32, 32)
	fx.add_child(fly)
	var start := from.global_position + Vector2(4, 4) - fx.global_position
	var end := cauldron_rect.global_position + Vector2(128, 70) - Vector2(32, 32) - fx.global_position
	var peak := (start + end) / 2.0 + Vector2(0, -180)
	var tw := create_tween()
	var arc := func(t: float) -> void:
		fly.position = start.lerp(peak, t).lerp(peak.lerp(end, t), t)
	tw.tween_method(arc, 0.0, 1.0, 0.5)
	tw.parallel().tween_property(fly, "rotation", TAU, 0.5)
	tw.parallel().tween_property(fly, "scale", Vector2(0.5, 0.5), 0.5).set_ease(Tween.EASE_IN)
	await tw.finished
	fly.queue_free()
	_flying -= 1
	if session != _session:
		return
	_splash(INGREDIENTS[id]["color"])
	_update_slots()
	_update_liquid()
	_update_buttons()


func _on_brew() -> void:
	if not running or brewing or _flying > 0:
		return
	if cauldron.is_empty():
		_say("Котёл пуст — добавь ингредиенты!", Color(1.0, 0.7, 0.4))
		return
	if not result.is_empty():
		_say("Сначала отдай или выбрось готовое зелье.", Color(1.0, 0.7, 0.4))
		return
	brewing = true
	_update_buttons()
	var session := _session
	bubbles.speed_scale = 3.0
	var tw := create_tween()
	for i in 10:
		var dx := 6.0 if i % 2 == 0 else -6.0
		tw.tween_property(cauldron_rect, "position", cauldron_base + Vector2(dx, -2.0 * (i % 3)), 0.07)
	tw.tween_property(cauldron_rect, "position", cauldron_base, 0.07)
	await tw.finished
	bubbles.speed_scale = 1.0
	brewing = false
	if session != _session:
		return

	var recipe := _match_recipe(cauldron)
	cauldron.clear()
	result = recipe
	_update_slots()
	_splash(recipe["color"], 40)
	liquid.color = recipe["color"]
	create_tween().tween_property(liquid, "color", WATER_COLOR, 1.5).set_delay(0.4)
	result_icon.scale = Vector2.ZERO
	create_tween().tween_property(result_icon, "scale", Vector2.ONE, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if recipe["id"] == "sludge":
		_say("Получилась мутная жижа... Такого рецепта нет.", Color(0.8, 0.7, 0.5))
	elif not known.has(recipe["id"]):
		known[recipe["id"]] = true
		_say("Новый рецепт открыт: %s!" % recipe["name"], Color(0.6, 1.0, 0.6))
		_float_text("Новый рецепт!", Vector2(575, 150), Color(0.6, 1.0, 0.6))
	else:
		_say("Сварено: %s" % recipe["name"])
	_refresh_all()


func _on_serve() -> void:
	if not running or brewing or result.is_empty() or order.is_empty():
		return
	if result["id"] == order["id"]:
		var price: int = order["price"]
		var tip := int(ceil(price * 0.5 * patience / patience_max))
		gold += price + tip
		served += 1
		_float_text("+%d" % (price + tip), Vector2(960, 120), Color(1.0, 0.85, 0.3))
		var gold_tw := create_tween()
		gold_tw.tween_property(gold_label, "scale", Vector2(1.4, 1.4), 0.1)
		gold_tw.tween_property(gold_label, "scale", Vector2.ONE, 0.2)
		var text := "%s доволен! +%d золотых (чаевые %d)" % [customer["name"], price + tip, tip]
		if served % 3 == 0 and unlocked < RECIPES.size():
			unlocked += 1
			text += "\nСлава о лавке растёт — теперь просят %s!" % RECIPES[unlocked - 1]["name"]
		_say(text, Color(0.7, 1.0, 0.6))
	else:
		_say("Это не %s! %s уходит в гневе." % [order["name"], customer["name"]], Color(1.0, 0.5, 0.4))
		_lose_life()
	result = {}
	_refresh_all()
	_customer_leaves()


func _on_discard() -> void:
	if result.is_empty() or brewing:
		return
	result = {}
	_refresh_all()


func _on_empty() -> void:
	if not running or brewing or _flying > 0 or cauldron.is_empty():
		return
	cauldron.clear()
	_splash(liquid.color, 24)
	_update_slots()
	_update_liquid()
	_update_buttons()
	_say("Котёл вылит.")


func _match_recipe(items: Array[String]) -> Dictionary:
	var sorted := []
	sorted.append_array(items)
	sorted.sort()
	for recipe in RECIPES:
		var need: Array = recipe["items"].duplicate()
		need.sort()
		if need == sorted:
			return recipe
	return SLUDGE


func _lose_life() -> void:
	lives -= 1
	_update_hearts()
	if lives >= 0 and lives < hearts.size():
		var h := hearts[lives]
		var tw := create_tween()
		tw.tween_property(h, "scale", Vector2(1.6, 1.6), 0.1)
		tw.tween_property(h, "scale", Vector2.ONE, 0.25)
	if lives <= 0:
		_game_over()


func _game_over() -> void:
	running = false
	_session += 1
	order = {}
	var record := ""
	if gold > best_gold:
		best_gold = gold
		_save_best()
		record = "\nНовый рекорд!"
	_refresh_all()
	_show_overlay("Лавка закрыта!",
		"Клиенты разочарованы, но вы старались.\n\nПодано зелий: %d\nЗаработано золота: %d\nОткрыто рецептов: %d из %d\nРекорд: %d%s"
		% [served, gold, known.size(), RECIPES.size(), best_gold, record],
		"Начать заново")


func _show_overlay(title: String, text: String, button: String) -> void:
	book_open = false
	book_layer.visible = false
	overlay_title.text = title
	overlay_text.text = text
	overlay_btn.text = button
	overlay.visible = true


func _toggle_book() -> void:
	if overlay.visible:
		return
	book_open = not book_open
	book_layer.visible = book_open
	if book_open:
		_fill_book()


func _fill_book() -> void:
	for child in book_grid.get_children():
		child.queue_free()
	for i in RECIPES.size():
		var recipe: Dictionary = RECIPES[i]
		var is_known := known.has(recipe["id"])
		var is_ordered := i < unlocked
		var entry := Panel.new()
		entry.theme_type_variation = "Slot"
		entry.position = Vector2((i % 3) * 250, (i / 3) * 156)
		entry.size = Vector2(240, 146)
		book_grid.add_child(entry)

		var icon := _icon(null, Vector2(8, 8), Vector2(64, 64))
		_show_potion(icon, recipe)
		if not is_known:
			icon.modulate = Color(0, 0, 0, 0.7)
		entry.add_child(icon)
		var title: String = recipe["name"] if is_known or is_ordered else "???"
		var name_label := _label(title, 16, entry, Vector2(78, 6), 154)
		if is_known:
			name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		_label("%d зол." % recipe["price"], 14, entry, Vector2(78, 64))

		var items: Array = recipe["items"]
		for j in items.size():
			var cell := Panel.new()
			cell.theme_type_variation = "Slot"
			cell.position = Vector2(8 + j * 50, 88)
			cell.size = Vector2(46, 46)
			entry.add_child(cell)
			# Для незнакомых, но уже заказываемых зелий показываем первый ингредиент как подсказку.
			if is_known or (is_ordered and j == 0):
				var ing: Dictionary = INGREDIENTS[items[j]]
				cell.add_child(_icon(_tex(ing["tex"]), Vector2(3, 3), Vector2(40, 40)))
				cell.tooltip_text = ing["name"]
			else:
				_label("?", 24, cell, Vector2(0, 6), 46, HORIZONTAL_ALIGNMENT_CENTER)


func _splash(color: Color, amount := 18) -> void:
	var p := CPUParticles2D.new()
	p.position = cauldron_rect.position + Vector2(128, 70)
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.8
	p.direction = Vector2.UP
	p.spread = 50.0
	p.gravity = Vector2(0, 500)
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 240.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 8.0
	p.color = color
	fx.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)


func _float_text(text: String, pos: Vector2, color: Color) -> void:
	var l := _label(text, 28, fx, pos - Vector2(120, 0), 240, HORIZONTAL_ALIGNMENT_CENTER)
	l.add_theme_color_override("font_color", color)
	var tw := create_tween().set_parallel()
	tw.tween_property(l, "position:y", pos.y - 70.0, 1.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 1.2).set_delay(0.4)
	tw.chain().tween_callback(l.queue_free)


func _say(text: String, color := Color(0.98, 0.92, 0.8)) -> void:
	message_label.text = text
	message_label.add_theme_color_override("font_color", color)


# --- Обновление интерфейса -----------------------------------------------------

func _refresh_all() -> void:
	gold_label.text = str(gold)
	served_label.text = "Подано: %d" % served
	_update_hearts()
	_update_slots()
	_update_liquid()
	_update_result()
	_update_order_ui()
	_update_buttons()


func _update_hearts() -> void:
	for i in hearts.size():
		hearts[i].filled = i < lives


func _update_slots() -> void:
	for i in slot_icons.size():
		var icon := slot_icons[i]
		var had := icon.texture != null
		icon.texture = _tex(INGREDIENTS[cauldron[i]]["tex"]) if i < cauldron.size() else null
		if icon.texture != null and not had:
			icon.scale = Vector2.ZERO
			create_tween().tween_property(icon, "scale", Vector2.ONE, 0.25) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_liquid() -> void:
	var target := WATER_COLOR
	if not cauldron.is_empty():
		var sum := Color(0, 0, 0)
		for id in cauldron:
			sum += INGREDIENTS[id]["color"]
		var avg := Color(sum.r / cauldron.size(), sum.g / cauldron.size(), sum.b / cauldron.size())
		target = WATER_COLOR.lerp(avg, 0.8)
	create_tween().tween_property(liquid, "color", target, 0.4)
	bubbles.color = target.lightened(0.3)


func _update_result() -> void:
	if result.is_empty():
		result_icon.texture = _tex("empty_potion_bottle")
		result_icon.material = null
		result_icon.modulate = Color(1, 1, 1, 0.35)
		result_name.text = "Пусто"
	else:
		_show_potion(result_icon, result)
		result_icon.modulate = Color.WHITE
		result_name.text = result["name"]


func _update_order_ui() -> void:
	order_box.visible = not order.is_empty()
	waiting_label.visible = order.is_empty() and running
	if order.is_empty():
		return
	avatar.texture = _tex(customer["tex"])
	customer_name.text = customer["name"]
	greeting.text = GREETINGS[absi(hash(customer["name"] + order["id"])) % GREETINGS.size()]
	_show_potion(order_icon, order)
	order_name.text = order["name"]
	order_price.text = "Награда: %d зол. + чаевые" % order["price"]
	if known.has(order["id"]):
		hint_label.text = ""
	else:
		var items: Array = order["items"]
		hint_label.text = "Рецепт неизвестен! Ингредиентов: %d, среди них — %s." \
			% [items.size(), INGREDIENTS[items[0]]["name"]]
	_update_patience()


func _update_patience() -> void:
	var ratio := clampf(patience / patience_max, 0.0, 1.0)
	patience_bar.value = ratio * 100.0
	patience_fill.bg_color = Color(0.9, 0.25, 0.2).lerp(Color(0.35, 0.85, 0.3), ratio)


func _update_buttons() -> void:
	brew_btn.disabled = not running or brewing or cauldron.is_empty() or not result.is_empty() or _flying > 0
	empty_btn.disabled = not running or brewing or cauldron.is_empty() or _flying > 0
	serve_btn.disabled = not running or brewing or result.is_empty() or order.is_empty()
	discard_btn.disabled = brewing or result.is_empty()


# --- Рекорд ---------------------------------------------------------------------

func _load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_gold = int(cfg.get_value("score", "best_gold", 0))


func _save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best_gold", best_gold)
	cfg.save(SAVE_PATH)
