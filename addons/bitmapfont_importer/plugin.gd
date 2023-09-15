@tool
extends EditorPlugin

const _BMPFontImporter = preload("res://addons/bitmapfont_importer/bitmap_font_importer.gd")

var font_importer:_BMPFontImporter

func _enter_tree() -> void:
	font_importer = _BMPFontImporter.new()
	add_import_plugin(font_importer)
	pass


func _exit_tree() -> void:
	remove_import_plugin(font_importer)
	font_importer = null
	pass
