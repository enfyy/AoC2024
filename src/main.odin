package aoc

import "core:fmt"
import "core:time"
import "core:strings"
import "core:strconv"

procs := [?]Day_Proc{day1}
Day_Proc :: #type proc(_: string) -> (int, int)

main :: proc() {
  mapped_inputs := map_inputs()
  fmt.println("===============================================================")
  fmt.println("|                    PART1 |             PART2 |  TIME        |")
  fmt.println("===============================================================")
  sw: time.Stopwatch
  for day_proc, i in procs {
    index := i + 1
    time.stopwatch_start(&sw)
    input, ok := mapped_inputs[index]
    if ok {
      p1, p2 := day_proc(input)
      time.stopwatch_stop(&sw)
      fmt.printfln(
        ":: Day %d: %16s | %16s | %fms",
        index,
        fmt.tprint(p1),
        fmt.tprint(p2),
        time.duration_milliseconds(time.stopwatch_duration(sw)),
      )
    } else {
      fmt.printfln(":: Day %d -- !! INPUT NOT FOUND !! (expected path: ../inputs/%d.txt)", index, index)
    }
    fmt.println("---------------------------------------------------------------")
    time.stopwatch_reset(&sw)
    free_all()
  }
}

map_inputs :: proc() -> map[int]string {
  inputs := #load_directory("../inputs")
  result := make(map[int]string)
  for input in inputs {
    splits, err := strings.split(input.name, ".")
    if len(splits) < 2 do continue
    num, ok := strconv.parse_int(splits[0])
    if !ok do continue
    result[num] = string(input.data)
  }

  return result
}
