package aoc

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

//https://adventofcode.com/2024/day/12
day12 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, NEWLINE)
  bounds := [2]int{len(lines[0]), len(lines)}
  pos_to_region_id := make(map[[2]int]Region_Id)
  region_id_counter := 0
  regions := make([dynamic]Region)
  to_check := make([dynamic][2]int)
  checked := make(map[[2]int]struct {})

  for line, y in lines {
    for char, x in line {
      pos := [2]int{x, y}
      current_region_id, belongs_to_a_region := pos_to_region_id[pos]
      if belongs_to_a_region do continue

      current_region_id = Region_Id(region_id_counter)
      append(&regions, Region{positions = make([dynamic][2]int), plant = char})
      region := &regions[len(regions) - 1]
      region_id_counter += 1
      pos_to_region_id[pos] = current_region_id
      append(&to_check, pos)

      for len(to_check) > 0 {
        pos_to_check := pop_front(&to_check)
        _, already_checked := checked[pos_to_check]
        if already_checked do continue
        checked[pos_to_check] = struct {}{}
        append(&region.positions, pos_to_check)

        neighbour_positions, neighbour_count := get_neighbours_with_same_plant(lines, bounds, pos_to_check)
        for n in neighbour_positions {
          neighbour_position, ok := n.?;if !ok do continue
          pos_to_region_id[neighbour_position] = current_region_id
          append(&to_check, neighbour_position)
        }
      }
      clear(&checked)
    }
  }

  fence_pieces := make([dynamic]Fence_Piece)
  for region, region_id in regions {
    area := len(region.positions)
    perim := 0
    for pos in region.positions {
      for dir, i in Direction {
        step := directions[dir]
        neighbour_pos := pos + step

        if is_in_bounds(bounds, neighbour_pos) {
          neighbour_region_id, ok := pos_to_region_id[neighbour_pos]
          assert(ok, "neighbour has no region assigned")
          if neighbour_region_id != region_id {
            perim += 1
            append(&fence_pieces, Fence_Piece{dir = dir, pos = pos})
          }
        } else {
          perim += 1
          append(&fence_pieces, Fence_Piece{dir = dir, pos = pos})
        }
      }
    }
    sides := calculate_sides(&fence_pieces)

    // fmt.printfln("(P1): A region of %c plants with price %d * %d = %d.", region.plant, area, perim, area * perim)
    // fmt.printfln("(P2): A region of %c plants with price %d * %d = %d.", region.plant, area, sides, area * sides)

    part1 += area * perim
    part2 += area * sides
    clear(&fence_pieces)
  }

  // visualize(lines, bounds, pos_to_region_id)
  return
}

Region :: struct {
  positions: [dynamic][2]int,
  plant:     rune,
}

Region_Id :: int

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

get_neighbours_with_same_plant :: proc(
  input: []string,
  bounds: [2]int,
  pos: [2]int,
) -> (
  neighbours: [Direction]Maybe([2]int),
  count: int,
) {
  if oob(bounds, pos) do return
  plant := input[pos.y][pos.x]
  for dir, i in Direction {
    step := directions[dir]
    neighbour_pos := pos + step
    if is_in_bounds(bounds, neighbour_pos) {
      neighbour_plant := input[neighbour_pos.y][neighbour_pos.x]
      if plant == neighbour_plant {
        neighbours[dir] = neighbour_pos
        count += 1
      }
    }
  }
  return
}

Fence_Piece :: struct {
  dir: Direction,
  pos: [2]int,
}

Fence :: struct {
  dir:         Direction,
  pos:         int, // the coordinate that all pieces of the fence share
  upper_bound: int,
  lower_bound: int,
}

calculate_sides :: proc(pieces: ^[dynamic]Fence_Piece) -> (sides: int) {
  for len(pieces) > 0 {
    piece := pop_front(pieces)
    is_horizontal := piece.dir == .N || piece.dir == .S
    is_vertical := !is_horizontal
    fence := Fence {
      dir         = piece.dir,
      pos         = is_vertical ? piece.pos.x : piece.pos.y,
      upper_bound = is_vertical ? piece.pos.y : piece.pos.x,
      lower_bound = is_vertical ? piece.pos.y : piece.pos.x,
    }
    sides += 1

    fence_building_loop: for {
      for added_piece, piece_index in pieces {
        if added_piece.dir != fence.dir do continue
        if is_vertical && added_piece.pos.x != fence.pos do continue
        if is_horizontal && added_piece.pos.y != fence.pos do continue

        switch {
        case is_vertical &&
             added_piece.pos.y == fence.upper_bound + 1,
             is_horizontal &&
             added_piece.pos.x == fence.upper_bound + 1:
          fence.upper_bound += 1

        case is_vertical &&
             added_piece.pos.y == fence.lower_bound - 1,
             is_horizontal &&
             added_piece.pos.x == fence.lower_bound - 1:
          fence.lower_bound -= 1

        case:
          continue
        }
        unordered_remove(pieces, piece_index)
        continue fence_building_loop
      }
      break
    }
  }
  return
}

visualize :: proc(lines: []string, bounds: [2]int, regions: map[[2]int]Region_Id) {
  colors := map[Region_Id]rl.Color {
    0 = rl.RED,
    1 = rl.BLUE,
    2 = rl.GREEN,
    3 = rl.ORANGE,
    4 = rl.YELLOW,
    5 = rl.VIOLET,
    6 = rl.PINK,
    7 = rl.LIME,
    8 = rl.PINK,
    9 = rl.BROWN,
  }
  TILE_SIZE :: 40
  window_width := bounds[0] * TILE_SIZE
  window_height := bounds[1] * TILE_SIZE

  rl.InitWindow(i32(window_width), i32(window_height), "AOC2024 DAY12")
  rl.SetTargetFPS(30)
  for !rl.WindowShouldClose() {
    defer free_all(context.temp_allocator)
    rl.BeginDrawing()
    defer rl.EndDrawing()
    rl.ClearBackground(rl.WHITE)

    for line, y in lines {
      for char, x in line {
        text := fmt.ctprint(rune(lines[y][x]))
        // if text != "R" do continue
        text_width := rl.MeasureText(text, 20)
        rl.DrawText(text, i32(x * TILE_SIZE) + 20 - (text_width / 2), i32(y * TILE_SIZE) + 10, 20, rl.BLACK)

        region_id, ok := regions[[2]int{x, y}]
        if ok {
          region_text1 := fmt.ctprint(x, y)
          region_text_width1 := rl.MeasureText(region_text1, 12)
          rl.DrawText(region_text1, i32(x * TILE_SIZE) + 30 - (text_width / 2), i32(y * TILE_SIZE) + 28, 12, rl.BLACK)

          color, yes := colors[region_id]
          if yes {
            rl.DrawRectangleLines(i32(x * TILE_SIZE), i32(y * TILE_SIZE), TILE_SIZE, TILE_SIZE, color)
          }
        }
      }
    }
  }
}
