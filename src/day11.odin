package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

//https://adventofcode.com/2024/day/11
day11 :: proc(input: string) -> (part1: int, part2: int) {
  nums := strings.split(input, " ")
  stones := make(map[int]int)
  for num in nums do stones[strconv.atoi(num)] = 1
  for i in 0 ..< 75 {
    previous: map[int]int
    for k, v in stones do previous[k] = v
    stones = nil

    for stone, num in previous {
      split, a, b := blink(stone)
      stones[a] += 1 * num
      if split do stones[b] += 1 * num
    }

    if i == 24 do for k, v in stones do part1 += v
  }

  for k, v in stones do part2 += v
  return
}

blink :: proc(stone: int) -> (split: bool, a: int, b: int) {
  if stone == 0 do return false, 1, 0

  digits := count_digits(stone)
  if digits % 2 == 0 {
    a, b := split_int(stone)
    return true, a, b
  }
  return false, stone * 2024, 0
}

count_digits :: proc(n: int) -> int {
  n := n
  if n == 0 do return 1

  count := 0
  for n > 0 {
    n /= 10
    count += 1
  }
  return count
}

// thx, chat gpt
split_int :: proc(rock: int) -> (int, int) {
  digits := count_digits(rock)
  num_left := rock
  n := 1
  for i in 0 ..< digits / 2 {
    num_left /= 10
    n *= 10
  }

  num_right := rock - num_left * n
  return num_left, num_right
}
