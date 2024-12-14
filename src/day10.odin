package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import rl "vendor:raylib"

//https://adventofcode.com/2024/day/10
day10 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, NEWLINE)
  if len(lines) == 0 do return
  bounds := [2]int{len(lines[0]), len(lines)}
  starting_positions := make([dynamic]Incomplete_Path, 0, len(input))
  get_starting_positions(lines, &starting_positions)
  paths := find_paths(lines, bounds, &starting_positions)

  reachable_summits := make(map[[2]int]map[[2]int]struct {})
  for p in paths {
    _, ok := reachable_summits[p[0]]
    if !ok {
      reachable_summits[p[0]] = make(map[[2]int]struct {})
    }
    inner := &reachable_summits[p[0]]
    inner[p[9]] = struct {}{}
  }
  for starting_pos, inner in reachable_summits {
    part1 += len(inner)
  }
  part2 = len(paths)

  return
}

Incomplete_Path :: [10]Maybe([2]int)
Path :: [10][2]int

get_starting_positions :: proc(lines: []string, buffer: ^[dynamic]Incomplete_Path) {
  for line, y in lines {
    for r, x in line do if r == '0' {
      p: Incomplete_Path = {
        0 = [2]int{x, y},
      }
      append(buffer, p)
    }
  }
}

len_of_incomplete_path :: proc(p: Incomplete_Path) -> (l: int) {
  for ; l < 10; l += 1 {
    _, ok := p[l].?
    if !ok do return
  }
  return
}

complete_path :: proc(ip: Incomplete_Path) -> (p: Path) {
  for i := 0; i < 10; i += 1 {
    pos, ok := ip[i].?
    if !ok do panic("cannot complete incomplete path")
    p[i] = pos
  }
  return
}

find_paths :: proc(input: []string, bounds: [2]int, buffer: ^[dynamic]Incomplete_Path) -> []Path {
  completed_paths := make([dynamic]Path)
  for len(buffer) > 0 {
    incomplete_path := pop_front(buffer)
    starting_pos, _ := incomplete_path[0].?
    tail_index := len_of_incomplete_path(incomplete_path) - 1
    tail_pos, _ := incomplete_path[tail_index].?
    neighbour_positions, neighbour_count := get_valid_steps_in_cardinal_directions(input, bounds, tail_pos)
    if neighbour_count == 0 {
      continue
    }

    for n, dir in neighbour_positions {
      continued_path := incomplete_path
      neighbour_position, ok := n.?
      if !ok do continue
      neighbour_height := strconv.atoi(string([]u8{input[neighbour_position.y][neighbour_position.x]}))
      continued_path[tail_index + 1] = neighbour_position
      if neighbour_height == 9 {
        append(&completed_paths, complete_path(continued_path))
      } else {
        append(buffer, continued_path)
      }
    }

  }
  return completed_paths[:]
}

@(private = "file")
Direction :: enum {
  N,
  E,
  S,
  W,
}

@(private = "file")
directions := [Direction][2]int {
  //     x   y  
  .N = {+0, -1},
  .E = {+1, +0},
  .S = {+0, +1},
  .W = {-1, +0},
}

get_valid_steps_in_cardinal_directions :: proc(
  input: []string,
  bounds: [2]int,
  pos: [2]int,
) -> (
  neighbours: [Direction]Maybe([2]int),
  count: int,
) {
  if oob(bounds, pos) do return
  height := strconv.atoi(string([]u8{input[pos.y][pos.x]}))
  for dir, i in Direction {
    step := directions[dir]
    neighbour_pos := pos + step
    if is_in_bounds(bounds, neighbour_pos) {
      neighbour_height := strconv.atoi(string([]u8{input[neighbour_pos.y][neighbour_pos.x]}))
      if height + 1 == neighbour_height {
        neighbours[dir] = neighbour_pos
        count += 1
      }
    }
  }
  return
}
