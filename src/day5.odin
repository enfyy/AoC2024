package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

@(private = "file")
must_come_before: map[int][dynamic]int
@(private = "file")
must_come_after: map[int][dynamic]int

//https://adventofcode.com/2024/day/5
day5 :: proc(input: string) -> (part1: int, part2: int) {
  sections := strings.split(input, DOUBLE_NEWLINE)
  rule_section := sections[0]
  page_section := sections[1]
  i_dont_make_the_rules(rule_section)

  pages := strings.split(page_section, NEWLINE)
  next_page: for page in pages {
    sequence := make([dynamic]int, 0, len(page) - 1)
    for num in strings.split(page, ",") do append(&sequence, strconv.atoi(num))
    middle_num := sequence[(len(sequence) - 1) / 2]

    for i in 0 ..< len(sequence) {
      num := sequence[i]
      rules_before := must_come_before[num]
      rules_after := must_come_after[num]
      nums_before := sequence[:i]
      nums_after := sequence[i + 1:]

      for n, ii in nums_before {
        if slice.contains(rules_before[:], n) {
          part2 += fix_sequence(sequence[:])
          continue next_page
        }
      }

      for n, ii in nums_after {
        if slice.contains(rules_after[:], n) {
          part2 += fix_sequence(sequence[:])
          continue next_page
        }
      }
    }
    part1 += middle_num
  }

  return
}

fix_sequence :: proc(seq: []int) -> int {
  compare :: proc(a, b: int) -> slice.Ordering {
    if slice.contains(must_come_before[a][:], b) {
      return .Less
    } else if slice.contains(must_come_after[a][:], b) {
      return .Greater
    } else {
      return .Equal
    }
  }
  slice.sort_by_cmp(seq, compare)
  return seq[(len(seq) - 1) / 2]
}

i_dont_make_the_rules :: proc(rule_section: string) {
  must_come_before = make(map[int][dynamic]int)
  must_come_after = make(map[int][dynamic]int)
  rule_lines := strings.split(rule_section, NEWLINE)
  for line in rule_lines {
    split := strings.split(line, "|")
    l := strconv.atoi(split[0])
    r := strconv.atoi(split[1])
    {
      list, ok := must_come_before[l]
      if !ok {
        list = make([dynamic]int)
        must_come_before[l] = list
      }
      append(&must_come_before[l], r)
    }
    {
      list, ok := must_come_after[r]
      if !ok {
        list = make([dynamic]int)
        must_come_after[r] = list
      }
      append(&must_come_after[r], l)
    }
  }
  return
}
