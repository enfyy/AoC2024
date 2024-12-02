package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"

Trend :: enum {
  unknown,
  increasing,
  decreasing,
}

//https://adventofcode.com/2024/day/2
day2 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, "\n")
  report: [dynamic]int
  next_line: for line in lines {
    report_split := strings.split(line, " ")
    for i := 0; i < len(report_split); i += 1 {
      append(&report, strconv.atoi(strings.trim(report_split[i], " \n\r")))
    }
    if is_safe(report[:]) {
      part1 += 1
    }
    if is_safe_with_one_exception(report[:]) {
      part2 += 1
    }
    clear(&report)
  }

  return
}

check_rules :: proc(prev: int, current: int, prev_trend: Trend) -> (bool, Trend) {
  diff := prev - current
  trend := prev_trend
  if diff < 0 && prev_trend != .decreasing {
    // current num is greater, meaning it must be a increasing trend
    trend = .increasing
  } else if diff > 0 && prev_trend != .increasing {
    // current num is smaller, meaning it must be a decreasing trend
    trend = .decreasing
  } else {
    return false, trend
  }
  return abs(diff) >= 1 && abs(diff) <= 3, trend
}

is_safe :: proc(report: []int) -> bool {
  trend: Trend = .unknown
  for i := 1; i < len(report); i += 1 {
    ok, new_trend := check_rules(report[i - 1], report[i], trend)
    if ok {
      trend = new_trend
    } else {
      return false
    }
  }

  return true
}

is_safe_with_one_exception :: proc(report: []int) -> bool {
  temp_slice: [dynamic]int
  for skipped_index := 0; skipped_index < len(report); skipped_index += 1 {
    defer clear(&temp_slice)
    append(&temp_slice, ..report[:skipped_index])
    append(&temp_slice, ..report[skipped_index + 1:])
    if is_safe(temp_slice[:]) {
      return true
    }
  }
  return false
}
