package aoc

import "core:fmt"
import "core:strings"
import "core:slice"

Tile :: enum {
  Free,
  Obstacle,
  Guard,
  Visited,
}

@(private = "file")
Dir :: enum {
  Up,
  Right,
  Down,
  Left,
}

turn_90_degrees :: proc(dir: Dir) -> Dir {
  return Dir((int(dir) + 1) % len(Dir))
}

steps := [Dir][2]int {
  //        x   y  
  .Up    = {+0, -1},
  .Right = {+1, +0},
  .Down  = {+0, +1},
  .Left  = {-1, +0},
}

//https://adventofcode.com/2024/day/6
day6 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, NEWLINE)
  grid: [dynamic][dynamic]Tile
  grid_upper_bounds: [2]int = {len(lines[0]), len(lines)}
  guard_position: [2]int
  collision_positions: [dynamic]Collision_Position
  guard_direction: Dir

  for line, y in lines {
    append(&grid, make([dynamic]Tile))
    for char, x in line {
      tile: Tile
      switch char {
      case '#':
        tile = .Obstacle
      case '.':
        tile = .Free
      case '^':
        guard_direction = .Up
      case 'v':
        guard_direction = .Down
      case '>':
        guard_direction = .Right
      case '<':
        guard_direction = .Left
      case:
        panic(fmt.tprintf("unexpected character: %c", char))
      }
      if char == '^' || char == 'v' || char == '>' || char == '<' {
        guard_position = {x, y}
        tile = .Guard
      }
      append(&grid[y], tile)
    }
  }
  part1, _ = play(grid, guard_position, grid_upper_bounds, nil, &collision_positions, guard_direction)
  clear(&collision_positions)

  for line, y in grid {
    for tile, x in line {
      if tile == .Guard || tile == .Obstacle do continue
      _, is_loop := play(grid, guard_position, grid_upper_bounds, [2]int{x, y}, &collision_positions, guard_direction)
      if is_loop {
        // fmt.printfln("Placing a block at %v would produce a loop", [2]int{x, y})
        part2 += 1
      }
      clear(&collision_positions)
    }
  }

  return
}

Collision_Position :: struct {
  dir:      Dir,
  position: [2]int,
}

play :: proc(
  grid: [dynamic][dynamic]Tile,
  guard_position: [2]int,
  grid_upper_bounds: [2]int,
  placed_obstacle_position: Maybe([2]int),
  collision_positions: ^[dynamic]Collision_Position,
  guard_direction: Dir,
) -> (
  unique_visited: int,
  is_loop: bool,
) {
  guard_position := guard_position
  guard_direction := guard_direction
  pos := guard_position

  for ; pos.x < grid_upper_bounds.x && pos.x >= 0 && pos.y < grid_upper_bounds.y && pos.y >= 0;
      pos = guard_position + steps[guard_direction] {
    tile := grid[pos.y][pos.x]

    placed_obstacle_pos, ok := placed_obstacle_position.?
    if ok && pos == placed_obstacle_pos {
      tile = .Obstacle
    }

    switch tile {
    case .Obstacle:
      previous_position := Collision_Position {
        position = pos - steps[guard_direction],
        dir      = guard_direction,
      }
      //TODO: if the collision happens twice in the same position, it doesnt count
      if slice.contains(collision_positions[:], previous_position) {
        is_loop = true
        return
      } else {
        append(collision_positions, previous_position)
      }

      guard_direction = turn_90_degrees(guard_direction)

    case .Free, .Guard:
      guard_position = pos
      unique_visited += 1
      grid[pos.y][pos.x] = .Visited

    case .Visited:
      guard_position = pos
    }
  }
  return
}

@(private = "file")
print_state :: proc(grid: [dynamic][dynamic]Tile) {
  for line in grid {
    for tile in line {
      switch tile {
      case .Free:
        fmt.print(".")
      case .Obstacle:
        fmt.print("#")
      case .Visited:
        fmt.print("X")
      case .Guard:
        fmt.print("^")
      }
    }
    fmt.println()
  }
}
