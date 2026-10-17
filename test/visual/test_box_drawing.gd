# SPDX-FileCopyrightText: 2026 Jared Swarts
# SPDX-License-Identifier: MIT

class_name BoxDrawingTest extends RenderingTest

const CELLS := 8
const MIN_BRIGHTNESS := 0.4


func render(text: String) -> Image:
	await wait_idle_frames(5)
	subject.write(text)
	await wait_idle_frames(15)
	# A second write moves the terminal from full redraws to partial redraws,
	# which is where stale edge pixels used to appear.
	subject.write("x")
	await wait_idle_frames(15)
	return get_viewport().get_texture().get_image()


# Returns the darkest pixel along a row, across the inner cell joints of the first CELLS cells.
func darkest_across_joints(image: Image, y: int) -> float:
	var cell_width: int = int(subject.get_cell_size().x)
	var darkest := 1.0
	for x in range(cell_width, cell_width * (CELLS - 1)):
		darkest = minf(darkest, image.get_pixel(x, y).v)
	return darkest


func brightest_row(image: Image, row: int) -> int:
	var cell: Vector2 = subject.get_cell_size()
	var best_y := 0
	var best := -1.0
	for y in range(int(cell.y * row), int(cell.y * (row + 1))):
		var total := 0.0
		for x in range(0, int(cell.x * CELLS)):
			total += image.get_pixel(x, y).v
		if total > best:
			best = total
			best_y = y
	return best_y


func test_horizontal_box_line_has_no_gaps():
	var image: Image = await render("\u001b[37m" + "─".repeat(CELLS) + "\r\n")
	var y := brightest_row(image, 0)
	assert_gt(darkest_across_joints(image, y), MIN_BRIGHTNESS, "─ line is continuous at y=%d" % y)


func test_rounded_box_top_edge_has_no_gaps():
	var image: Image = await render("\u001b[37m╭" + "─".repeat(CELLS - 2) + "╮\r\n")
	var y := brightest_row(image, 0)
	assert_gt(darkest_across_joints(image, y), MIN_BRIGHTNESS, "╭─╮ edge is continuous at y=%d" % y)


func test_full_blocks_have_no_gaps():
	var image: Image = await render("\u001b[37m" + "█".repeat(CELLS) + "\r\n")
	var y: int = int(subject.get_cell_size().y / 2)
	assert_gt(darkest_across_joints(image, y), MIN_BRIGHTNESS, "█ blocks touch at y=%d" % y)


func test_partial_redraw_mode_is_available():
	assert_eq(subject.foreground_redraw_mode, Terminal.FOREGROUND_REDRAW_FULL)
	subject.foreground_redraw_mode = Terminal.FOREGROUND_REDRAW_PARTIAL
	assert_eq(subject.foreground_redraw_mode, Terminal.FOREGROUND_REDRAW_PARTIAL)
