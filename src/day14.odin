package aoc

import "core:strings"
import "core:strconv"
import "core:fmt"
import rl "vendor:raylib"

@(private = "file")
GRID_DIMENSIONS :: [2]int{101, 103}

//https://adventofcode.com/2024/day/14
day14 :: proc(input: string) -> (part1: int, part2: int) {
  input := input
  SIMULATED_SECONDS :: 100
  grid: [GRID_DIMENSIONS.y][GRID_DIMENSIONS.x]u32
  // position_to_robot_count := make(map[[2]int]int)
  robots := make([dynamic]Robot)

  for line in strings.split_lines_iterator(&input) {
    space := strings.index(line, " ")
    pos_section := line[:space][2:]
    vel_section := line[space + 1:][2:]
    pos_comma := strings.index(pos_section, ",")
    vel_comma := strings.index(vel_section, ",")
    r := Robot {
      pos = {strconv.atoi(pos_section[:pos_comma]), strconv.atoi(pos_section[pos_comma + 1:])},
      vel = {strconv.atoi(vel_section[:vel_comma]), strconv.atoi(vel_section[vel_comma + 1:])},
    }
    append(&robots, r)
  }
  simulate(robots[:], GRID_DIMENSIONS, SIMULATED_SECONDS, &grid)

  quadrant_counts := [4]u32{} // {TL, TR, BL, BR}
  for line, y in grid {
    for tile, x in line {
      if tile == 0 do continue
      quadrant_index := 0
      pos := [2]int{x, y}
      if pos.x > (GRID_DIMENSIONS.x / 2) do quadrant_index += 1
      if pos.y > (GRID_DIMENSIONS.y / 2) do quadrant_index += 2

      if pos.x != (GRID_DIMENSIONS.x / 2) && pos.y != (GRID_DIMENSIONS.y / 2) {
        quadrant_counts[quadrant_index] += tile
      }
    }
  }

  part1 = int(quadrant_counts[0] * quadrant_counts[1] * quadrant_counts[2] * quadrant_counts[3])

  // part2:
  grid = {}
  x_sequence, y_sequence: Sequence
  second_counter := 0
  SEQUENCE :: 10
  outer: for second_counter != max(int) {
    simulate(robots[:], GRID_DIMENSIONS, second_counter, &grid)
    for y in 0 ..< GRID_DIMENSIONS.y {
      for x in 0 ..< GRID_DIMENSIONS.x {
        count := grid[y][x]
        if count > 0 {
          x_sequence = continue_sequence(&x_sequence, x)
          y_sequence = continue_sequence(&y_sequence, y)
          if x_sequence.counter >= SEQUENCE || y_sequence.counter >= SEQUENCE {
            part2 = second_counter
            break outer
          }
        }
      }
    }
    second_counter += 1
    grid = {}
  }

  VISUALIZE :: false
  when VISUALIZE {
    TILE_SIZE :: 10
    window_width := GRID_DIMENSIONS.x * TILE_SIZE
    window_height := GRID_DIMENSIONS.y * TILE_SIZE
    is_playing := false
    rl.InitWindow(i32(window_width), i32(window_height), "AOC2024 DAY14")
    rl.SetTargetFPS(100)
    for !rl.WindowShouldClose() {
      defer free_all(context.temp_allocator)
      if rl.IsKeyPressed(.RIGHT) do second_counter += 1
      if rl.IsKeyPressed(.LEFT) do second_counter -= 1
      if rl.IsKeyPressed(.SPACE) do is_playing = !is_playing
      if is_playing do second_counter += 1

      simulate(robots[:], GRID_DIMENSIONS, second_counter, &position_to_robot_count)
      defer clear(&position_to_robot_count)

      rl.BeginDrawing()
      defer rl.EndDrawing()
      rl.ClearBackground(rl.WHITE)

      for y in 0 ..< GRID_DIMENSIONS.y {
        for x in 0 ..< GRID_DIMENSIONS.x {
          count, ok := position_to_robot_count[{x, y}]
          if ok && count > 0 {
            rl.DrawRectangle(i32(x * TILE_SIZE), i32(y * TILE_SIZE), TILE_SIZE, TILE_SIZE, rl.GREEN)
          } else {
            rl.DrawRectangleLines(i32(x * TILE_SIZE), i32(y * TILE_SIZE), TILE_SIZE, TILE_SIZE, rl.BLACK)
          }
        }
      }

      rl.DrawText(fmt.ctprint(second_counter), 0, 0, 30, rl.RED)
    }
  }
  return
}

Robot :: struct {
  pos: [2]int,
  vel: [2]int,
}

@(private = "file")
simulate :: proc(robots: []Robot, bounds: [2]int, seconds: int, grid: ^[GRID_DIMENSIONS.y][GRID_DIMENSIONS.x]u32) {
  for r in robots {
    total := r.pos + (seconds * r.vel)
    new_robot_pos := [2]int{(total.x % bounds.x + bounds.x) % bounds.x, (total.y % bounds.y + bounds.y) % bounds.y}
    grid[new_robot_pos.y][new_robot_pos.x] += 1
  }
}

Sequence :: struct {
  start_offset: int,
  counter:      int,
}

continue_sequence :: proc(s: ^Sequence, value: int) -> Sequence {
  if s == nil do return {start_offset = value, counter = 1}
  if s.start_offset + s.counter == value {
    return {start_offset = s.start_offset, counter = s.counter + 1}
  } else {
    return {start_offset = value, counter = 1}
  }
}
