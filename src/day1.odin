package aoc

import "core:strings"
import "core:strconv"
import "core:slice"

//https://adventofcode.com/2024/day/1
day1 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, "\n")
  left, right: [dynamic]int
  right_map := make(map[int]int)
  for line in lines {
    left_right_split := strings.split(line, "   ")
    if len(left_right_split) < 2 do continue
    append(&left, strconv.atoi(left_right_split[0]))
    right_num := strconv.atoi(left_right_split[1])
    append(&right, right_num)

    item, ok := right_map[right_num]
    if !ok {
      right_map[right_num] = 1
    } else {
      right_map[right_num] = item + 1
    }
  }
  slice.sort(left[:])
  slice.sort(right[:])

  for i := 0; i < len(left); i += 1 {
    l := left[i]
    r := right[i]
    distance := abs(l - r)
    part1 += distance

    item, ok := right_map[l]
    if ok {
      part2 += l * item
    }
  }

  return
}
