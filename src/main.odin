package aoc

import "core:fmt"
import "core:time"

main :: proc() {
	fmt.println("===============================================================")
	fmt.println("|                     PART1 |             PART2 |  TIME       |")
	fmt.println("===============================================================")
	sw: time.Stopwatch
	for day, i in days {
		time.stopwatch_start(&sw)
		p1, p2 := day.fn(day.input)
		time.stopwatch_stop(&sw)
		fmt.printf(":: Day %d: %16s | %16s | %fms \n", i + 1, fmt.tprint(p1), fmt.tprint(p2), time.duration_milliseconds(time.stopwatch_duration(sw)))
		fmt.println("---------------------------------------------------------------")
		time.stopwatch_reset(&sw)
		free_all()
	}
}

Day :: struct {
	fn:    day_function,
	input: string,
}

day_function :: #type proc(_: string) -> (int, int)
days := [?]Day{{day1, #load("inputs/test.txt")}}

// This is just for quick copy pasting:
dayX :: proc(input: string) -> (part1: int, part2: int) {
	part1 = -1
	part2 = -1
	return
}
