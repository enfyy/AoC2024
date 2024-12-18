package aoc

import "core:fmt"
import "core:strings"
import "core:strconv"

BUTTON_OFFSET :: len("Button A: X+")
PRIZE_OFFSET :: len("Prize: X=")
BUTTON_SEP :: ", Y+"
PRIZE_SEP :: ", Y="

//https://adventofcode.com/2024/day/13
day13 :: proc(input: string) -> (part1: int, part2: int) {
  input := input
  claw_machines := make([dynamic]Claw_Machine)
  parse_machines(&input, &claw_machines)
  p1, p2: i64

  for cm, i in claw_machines {
    do_cool_math(cm.a_step, cm.b_step, cm.prize, &p1)
    do_cool_math(cm.a_step, cm.b_step, cm.prize + {10000000000000, 10000000000000}, &p2)
  }

  part1 = int(p1)
  part2 = int(p2)
  return
}

/*
  (X1 * A) + (X2 * B) = PRIZE           (X1 * A) + (X2 * B) = PRIZE
  X1 * A = PRIZE - (X2 * B)             X2 * B = PRIZE - (X1 * A)
  X1 = ((PRIZE - (X2 * B)) / A)         X2 = ((PRIZE - (X1 * A)) / B)
  
  3*X1 + X2 = TOKEN_COST 
  X1 <= 100
  X2 <= 100
*/
do_cool_math :: proc(a, b, prize: [2]i64, result: ^i64) {
  den := a.x * b.y - a.y * b.x
  if den == 0 do return

  y := ((prize.y * a.x) - (a.y * prize.x)) / den
  x := (prize.x - b.x * y) / a.x

  if (a.x * x + b.x * y == prize.x && a.y * x + b.y * y == prize.y) {
    result^ += x * 3 + y
  }
}

Claw_Machine :: struct {
  prize:  [2]i64,
  a_step: [2]i64,
  b_step: [2]i64,
}

parse_machines :: proc(input: ^string, ressult: ^[dynamic]Claw_Machine) {
  for machine in strings.split_iterator(input, DOUBLE_NEWLINE) {
    sections := strings.split(machine, NEWLINE)
    assert(len(sections) == 3, "unexpected input")
    a_button, b_button, prize := sections[0][BUTTON_OFFSET:], sections[1][BUTTON_OFFSET:], sections[2][PRIZE_OFFSET:]
    a_split := strings.split(a_button, BUTTON_SEP)
    b_split := strings.split(b_button, BUTTON_SEP)
    prize_split := strings.split(prize, PRIZE_SEP)
    append(
      ressult,
      Claw_Machine {
        a_step = [2]i64{atoi64(a_split[0]), atoi64(a_split[1])},
        b_step = [2]i64{atoi64(b_split[0]), atoi64(b_split[1])},
        prize = [2]i64{atoi64(prize_split[0]), atoi64(prize_split[1])},
      },
    )
  }
}

atoi64 :: proc(s: string) -> i64 {
  v, _ := strconv.parse_i64(s)
  return v
}
