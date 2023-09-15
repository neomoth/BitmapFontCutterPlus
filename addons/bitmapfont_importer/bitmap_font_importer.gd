@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name() -> String:
	return "anidemdex.bitmapfont.importer"

func _get_visible_name() -> String:
	return "Weird BitMapFont"

func _get_recognized_extensions() -> PackedStringArray:
	return ["png"]

func _get_save_extension() -> String:
	return "fontdata"

func _get_resource_type() -> String:
	return "FontFile"

func _get_preset_count() -> int:
	return Presets.size()

func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Presets.DEFAULT:
			return "Defatul"
		_:
			printerr("UNKNOW_PRESET")
			return "Unknow"

func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return [
				{
					"name": "gliph_size",
					"default_value": Vector2i(8, 8),
					"property_hint": PROPERTY_HINT_LINK
				},
				{
					"name": "first_character",
					"default_value": 32
				},
				{
					"name": "spacing",
					"default_value": 1
				},
				{
					"name":"monospaced",
					"default_value": false
				}]
		_:
			return []

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true


func _get_import_order() -> int:
	return 0

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> Error:
	var image := Image.new()
	var error:Error = image.load(source_file)
	if error != OK:
		return error
	
	var gliph_size:Vector2i = options.get("gliph_size", Vector2i.ZERO)
	
	if gliph_size.x <= 0 or gliph_size.y <= 0:
		return ERR_INVALID_PARAMETER
	
	var monospaced:bool = options.get("monospaced", false)
	var first_char:int = options.get("first_character", 32)
	var width:int = image.get_width()
	var height:int = image.get_height()
	var tx = width / gliph_size.x
	var ty = width / gliph_size.y
	
	var font := FontFile.new()
	var char_iterator = 0
	
	for y in range(ty):
		for x in range(tx+1):
			var line := 0
			var character_width := gliph_size.x
			
			if not monospaced:
				var char_found := false
				
				for xx in range(0, gliph_size.x):
					if char_found: break
					
					for yy in range(0, gliph_size.y):
						var pixel := image.get_pixel(x*gliph_size.x + xx, y*gliph_size.y + yy)
						if pixel.a != 0:
							line = xx
							character_width -= xx
							char_found = true
							break
				
				char_found = false
				for xx in range(0, gliph_size.x):
					if char_found: break
					
					for yy in range(0, gliph_size.y):
						var pixel := image.get_pixel(x*gliph_size.x + gliph_size.x - xx - 1, y*gliph_size.y + yy)
						if pixel.a != 0:
							character_width -= xx
							char_found = true
							break
				var size := Vector2i(x*gliph_size.x+line, y*gliph_size.y)
				font.set_texture_image(char_iterator + first_char, size, char_iterator, image)
	
	return ResourceSaver.save(font, "%s.%s" % [save_path, _get_save_extension()])
