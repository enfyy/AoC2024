package aoc

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:math"
import "core:strconv"

day7 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, NEWLINE)
  for line in lines {
    sections := strings.split(line, ": ")
    assert(len(sections) == 2)
    result_num := atoui(sections[0])
    numbers := strings.split(sections[1], " ")
    results: [dynamic]u64 = make([dynamic]u64, 0, 8192)
    temp: [dynamic]u64 = make([dynamic]u64, 0, 8192)

    part1 += int(run(numbers = numbers, result_num = result_num, use_concat = false, buf1 = &results, buf2 = &temp))
    part2 += int(run(numbers = numbers, result_num = result_num, use_concat = true, buf1 = &results, buf2 = &temp))
  }
  return
}

run :: proc(numbers: []string, result_num: u64, use_concat: bool, buf1, buf2: ^[dynamic]u64) -> (result: u64) {
  append(buf1, atoui(numbers[0]))
  for i in 1 ..< len(numbers) {
    b := atoui(numbers[i])
    append(buf2, ..buf1[:])
    clear(buf1)
    for a in buf2 {
      for op in Operation {
        if op == .Concat && !use_concat do continue
        next := calc(a, b, op)
        if next > result_num {
          // we can stop
        } else {
          append(buf1, next)
        }
      }
    }
    clear(buf2)
  }

  if slice.contains(buf1[:], result_num) {
    result += result_num
  }
  clear(buf1)
  return
}

Operation :: enum {
  Add,
  Mul,
  Concat,
}

calc :: proc "contextless" (a: u64, b: u64, op: Operation) -> (r: u64) {
  switch op {
  case .Add:
    r = a + b
  case .Mul:
    r = a * b
  case .Concat:
    multiplier: u64 = 1
    if b == 0 {
      multiplier = 10
    } else {
      for b / multiplier > 0 do multiplier *= 10
    }
    return a * multiplier + b
  }
  return
}

atoui :: proc(s: string) -> u64 {
  r, ok := strconv.parse_u64(s)
  assert(ok, "failed to parse u64")
  return r
}
