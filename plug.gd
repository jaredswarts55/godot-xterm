# SPDX-FileCopyrightText: 2021 Leroy Hopson <godot-xterm@leroy.nix.nz>
# SPDX-License-Identifier: MIT
extends "res://addons/gd-plug/plug.gd"


func _plugging():
	plug("bitwes/Gut", {commit = "aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605"})  # v9.7.1
	plug(
		"lihop/godot-pixelmatch",
		{commit = "5ed282e434c6d998a7bf63496e3b5a5261d6c605", include = ["addons/pixelmatch"]}
	)  # v2.0.0
	plug("YuriSizov/godot-editor-theme-explorer", {tag = "v2.1.1"})
	plug(
		"Zylann/godot_editor_debugger_plugin", {commit = "b0301fb58790c33ff1d839c4debddd4137ff90e9"}
	)
