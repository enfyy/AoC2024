package aoc

import "core:strings"
import "core:fmt"

@(private = "file")
Dir :: enum {
  N,
  NE,
  E,
  SE,
  S,
  SW,
  W,
  NW,
}

@(private = "file")
all_directions := [Dir][2]int {
  //      y   x  
  .N  = {-1, +0},
  .NE = {-1, +1},
  .E  = {+0, +1},
  .SE = {+1, +1},
  .S  = {+1, +0},
  .SW = {+1, -1},
  .W  = {+0, -1},
  .NW = {-1, -1},
}

//https://adventofcode.com/2024/day/4
day4 :: proc(input: string) -> (part1: int, part2: int) {
  lines := strings.split(input, NEWLINE)
  max_x := len(lines[0])
  max_y := len(lines)

  for y in 0 ..< max_y {
    next_char: for x in 0 ..< max_x {
      if lines[y][x] == 'X' {
        for dir in Dir {
          step := all_directions[dir]
          x_pos: [2]int = {y, x}
          m_pos := x_pos + 1 * step
          a_pos := x_pos + 2 * step
          s_pos := x_pos + 3 * step
          oob := !(s_pos[0] >= 0 && s_pos[0] < max_y && s_pos[1] >= 0 && s_pos[1] < max_x)
          if oob do continue

          the_word_spells_MAS :=
            lines[m_pos[0]][m_pos[1]] == 'M' && lines[a_pos[0]][a_pos[1]] == 'A' && lines[s_pos[0]][s_pos[1]] == 'S'
          if the_word_spells_MAS {
            part1 += 1
          }
        }
      } else if lines[y][x] == 'A' {
        a_pos: [2]int = {y, x}
        step_TL_BR: [2]int = {+1, +1}
        step_BL_TR: [2]int = {+1, -1}

        tl_pos := a_pos - step_TL_BR
        br_pos := a_pos + step_TL_BR
        bl_pos := a_pos - step_BL_TR
        tr_pos := a_pos + step_BL_TR

        positions := [][2]int{tl_pos, br_pos, bl_pos, tr_pos}
        for pos in positions {
          in_bounds := pos[0] >= 0 && pos[0] < max_y && pos[1] >= 0 && pos[1] < max_x
          if !in_bounds do continue next_char
        }

        word_1 := transmute(string)[]u8 {
          lines[tl_pos[0]][tl_pos[1]],
          lines[a_pos[0]][a_pos[1]],
          lines[br_pos[0]][br_pos[1]],
        }
        word_2 := transmute(string)[]u8 {
          lines[bl_pos[0]][bl_pos[1]],
          lines[a_pos[0]][a_pos[1]],
          lines[tr_pos[0]][tr_pos[1]],
        }

        if (word_1 == "SAM" || word_1 == "MAS") && (word_2 == "SAM" || word_2 == "MAS") {
          part2 += 1
        }
      }
    }
  }

  return
}
