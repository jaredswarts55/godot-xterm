# SPDX-FileCopyrightText: 2026 Jared Swarts
# SPDX-License-Identifier: MIT

extends TerminalTest


func cursor_column_after(text: String) -> int:
	subject.write(text)
	return subject.get_cursor_pos().x


func test_ascii_is_one_column():
	assert_eq(cursor_column_after("abc"), 3)


func test_emoji_are_two_columns():
	var params := {
		"\U01F600": "GRINNING FACE",
		"\U01F972": "SMILING FACE WITH TEAR (Unicode 13)",
		"\U01FAE8": "SHAKING FACE (Unicode 15)",
		"\U01FAE9": "FACE WITH BAGS UNDER EYES (Unicode 16)",
		"✅": "WHITE HEAVY CHECK MARK",
	}
	for text in params:
		subject.write("\r")
		assert_eq(cursor_column_after(text), 2, params[text])


func test_cjk_is_two_columns_each():
	assert_eq(cursor_column_after("中文"), 4)


func test_combining_mark_takes_no_column():
	assert_eq(cursor_column_after("éx"), 2)


func test_box_drawing_is_one_column_each():
	assert_eq(cursor_column_after("╭─╮│╰╯█"), 7)


func test_private_use_is_one_column():
	assert_eq(cursor_column_after(""), 2)


func test_utf8_bytes_match_string():
	var text := "a\U01F600中─"
	var from_bytes: Object = autofree(Terminal.new())
	add_child(from_bytes)
	from_bytes.size = subject.size
	from_bytes.write(text.to_utf8_buffer())
	assert_eq(from_bytes.get_cursor_pos(), Vector2i(cursor_column_after(text), 0))
	assert_eq(from_bytes.get_cursor_pos(), Vector2i(6, 0))
