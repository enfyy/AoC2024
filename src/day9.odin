package aoc

import "core:strings"
import "core:strconv"
import "core:slice"

//https://adventofcode.com/2024/day/9
day9 :: proc(input: string) -> (part1: int, part2: int) {
  sequence := strings.split(input, "")
  buf := make([dynamic]Maybe(int), 0, len(sequence))
  free_slots := make([dynamic]int, 0, len(sequence))
  free_ranges := make([dynamic][2]int, 0, len(sequence))
  file_ranges := make(map[int]File_Range) // id -> range

  // read file blocks
  is_file := true
  id := 0
  for num in sequence {
    count := strconv.atoi(num)
    if is_file {
      if count > 0 do file_ranges[id] = File_Range {
        id    = id,
        range = [2]int{len(buf), len(buf) + count},
      }
      for i in 0 ..< count do append(&buf, id)

      id += 1
    } else {
      if count > 0 do append(&free_ranges, [2]int{len(buf), len(buf) + count})
      for i in 0 ..< count {
        append(&buf, nil)
        append(&free_slots, len(buf) - 1)
      }
    }

    is_file = !is_file
  }
  buf2 := make([]Maybe(int), len(buf))
  copy_slice(buf2, buf[:])

  // defrag (part1)
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

  // defrag (part2)
  i_cba_to_avoid_allocations := make([dynamic]File_Range, len(file_ranges))
  for k, v in file_ranges do i_cba_to_avoid_allocations[k] = v
  #reverse for file_range, index in i_cba_to_avoid_allocations {
    if index == 0 do continue
    file_range := i_cba_to_avoid_allocations[file_range.id]
    if len(free_ranges) == 0 do break

    for free_range, free_range_index in free_ranges {
      free_size := free_range[1] - free_range[0]
      file_size := file_range.range[1] - file_range.range[0]
      if free_range[1] > file_range.range[0] {
        break
      }

      if file_size <= free_size {
        for i in free_range[0] ..< free_range[0] + file_size {
          buf2[i] = file_range.id
        }
        for i in file_range.range[0] ..< file_range.range[1] {
          buf2[i] = nil
        }
        if free_size > file_size {
          free_ranges[free_range_index] = [2]int{free_range[0] + file_size, free_range[1]}
        } else {
          ordered_remove(&free_ranges, free_range_index)
        }
        break
      }
    }
  }

  // count score
  for n, i in buf2 {
    id, ok := n.?
    if ok do part2 += i * id
  }

  return
}

File_Range :: struct {
  id:    int,
  range: [2]int,
}
