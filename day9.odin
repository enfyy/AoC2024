package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

//https://adventofcode.com/2024/day/9
day9 :: proc(input: string) -> (part1: int, part2: int) {
  sequence := strings.split(input, "")
  buf := make([dynamic]Maybe(int), 0, len(sequence))
  free_slots := make([dynamic]int, 0, len(sequence))

  // read file blocks
  is_file := true
  id := 0
  for num in sequence {
    for i in 0 ..< strconv.atoi(num) {
      if is_file {
        append(&buf, id)
      } else {
        append(&buf, nil)
        append(&free_slots, len(buf) - 1)
      }
    }
    if is_file do id += 1
    is_file = !is_file
  }

  // defrag
  for len(free_slots) > 0 {
    i := pop_front(&free_slots)
    insert := pop(&buf)
    id, ok := insert.?
    for !ok do id, ok = pop(&buf).?
    if i > 0 && i <= len(buf) {
      buf[i] = id
    } else {
      append(&buf, id)
      break
    }
  }

  // count score
  for n, i in buf {
    id, ok := n.?
    if ok do part1 += i * id
  }

  return
}

print_buf :: proc(input: []Maybe(int)) {
  for n in input {
    num, ok := n.?
    if ok {
      fmt.print(num)
    } else {
      fmt.print(".")
    }
  }
  fmt.println()
}
