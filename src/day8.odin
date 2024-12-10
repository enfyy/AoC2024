package aoc

import "core:fmt"
import "core:strings"
import "core:slice"
import sa "core:container/small_array"
import la "core:math/linalg"

//https://adventofcode.com/2024/day/8
day8 :: proc(input: string) -> (part1: int, part2: int) {
  grid := strings.split(input, NEWLINE)
  assert(len(grid) > 0, "empty input")
  bounds := [2]int{len(grid[0]), len(grid)}
  positions: Antenna_Positions
  used_frequencies := Alphanumeric_Set{}
  unique_positions_p1 := make(map[[2]int]struct {})
  unique_positions_p2 := make(map[[2]int]struct {})
  pairs := make([dynamic][2][2]int, 0, 16)

  for line, y in grid do for tile, x in line {
    if is_antenna(tile) {
      append(&positions[tile], [2]int{x, y})
      used_frequencies += {tile}
    }
  }

  for frequency in used_frequencies {
    antennas := positions[frequency]
    // build antenna pairs
    for i in 0 ..< len(antennas) do for j := i + 1; j < len(antennas); j += 1 {
      append(&pairs, [2][2]int{antennas[i], antennas[j]})
    }

    for pair in pairs {
      a, b := pair[0], pair[1]
      step := b - a

      antinode_positions := [2][2]int{a + 2 * step, a - step}
      for pos in antinode_positions {
        if !oob(bounds, pos) {
          if _, exists := unique_positions_p1[pos]; !exists {
            part1 += 1
            unique_positions_p1[pos] = struct {}{}
          }
        }
      }

      dirs := [2]int{-1, 1}
      for dir in dirs {
        for pos := a; !oob(bounds, pos); pos += dir * step {
          if _, exists := unique_positions_p2[pos]; !exists {
            // fmt.printfln("antinode at : %v", pos)
            part2 += 1
            unique_positions_p2[pos] = struct {}{}
          }
        }
      }

    }

    clear(&pairs)
  }
  return
}

Antenna_Positions :: [123][dynamic][2]int

// also includes some special characters at the ranges: [58..63], [91..96]
// but not '.' so it should be fine
Alphanumeric_Set :: bit_set['0' ..= 'z']

is_antenna :: #force_inline proc "contextless" (char: rune) -> bool {
  return char > 47 && !(char >= 58 && char <= 63) || (char >= 91 && char <= 96) && char < 123
}

oob :: #force_inline proc "contextless" (bounds: [2]int, pos: [2]int) -> bool {
  return !(pos.x >= 0 && pos.x < bounds.x && pos.y >= 0 && pos.y < bounds.y)
}
