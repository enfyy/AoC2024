package aoc

import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
import "core:strconv"

//https://adventofcode.com/2024/day/3
day3 :: proc(input: string) -> (part1: int, part2: int) {
  // FUCK REGEX :)
  lex := Lexer {
    input         = input,
    current_state = neutral_state,
  }
  for lex.current_state != nil {
    lex.current_state = lex.current_state(&lex)
  }
  part1 = lex.result_1
  part2 = lex.result_2
  return
}

//------------------------------------------------------------------------------------------

Lexer :: struct {
  input:                   string,
  current_offset:          int,
  last_rune_size_in_bytes: int,
  token_start_offset:      int,
  current_state:           State_Function,
  first_digit_complete:    bool,
  disabled:                bool,
  result_1:                int,
  result_2:                int,
}

RUNE_EOF: rune : -1

State_Function :: #type proc(lexer: ^Lexer) -> State_Function

neutral_state :: proc(lexer: ^Lexer) -> State_Function {
  char := lexer_next(lexer)
  if char == RUNE_EOF {
    return nil
  }
  if char == 'm' {
    if lexer_accept(lexer, 'u') {
      if lexer_accept(lexer, 'l') {
        if lexer_accept(lexer, '(') {
          return first_digit_state
        }
      }
    }
  } else if char == 'd' {
    if lexer_accept(lexer, 'o') {
      if lexer_accept(lexer, '(') {
        if lexer_accept(lexer, ')') {
          lexer.disabled = false
        }
      } else if lexer_accept(lexer, 'n') {
        if lexer_accept(lexer, '\'') {
          if lexer_accept(lexer, 't') {
            lexer.disabled = true
          }
        }
      }
    }
  }
  lexer_ignore(lexer)
  return neutral_state
}

first_digit_state :: proc(lexer: ^Lexer) -> State_Function {
  char := lexer_next(lexer)
  if is_digit(char) {
    return digit_or_comma_state
  }

  lexer_backup(lexer)
  return neutral_state
}

second_digit_state :: proc(lexer: ^Lexer) -> State_Function {
  char := lexer_next(lexer)
  if is_digit(char) {
    return digit_or_closing_parenthesis_state
  }

  lexer_backup(lexer)
  return neutral_state
}

digit_or_comma_state :: proc(lexer: ^Lexer) -> State_Function {
  char := lexer_next(lexer)

  if is_digit(char) {
    if lexer_length(lexer) == 7 {   // mul( and three digits  
      if lexer_accept(lexer, ',') {
        return second_digit_state
      } else {
        return neutral_state
      }
    }
    return digit_or_comma_state
  } else if char == ',' {
    return second_digit_state
  }

  lexer_backup(lexer)
  return neutral_state
}

digit_or_closing_parenthesis_state :: proc(lexer: ^Lexer) -> State_Function {
  char := lexer_next(lexer)

  if is_digit(char) {
    if lexer_length(lexer) == 7 {   // mul( and three digits  
      if lexer_accept(lexer, ',') {
        return second_digit_state
      } else {
        return neutral_state
      }
    }
    return digit_or_closing_parenthesis_state
  } else if char == ')' {
    lexer_emit(lexer)
    return neutral_state
  }

  lexer_backup(lexer)
  return neutral_state
}

is_digit :: proc(r: rune) -> bool {
  return '0' <= r && r <= '9'
}

lexer_emit :: proc(lexer: ^Lexer) {
  expression := lexer_scanned(lexer)
  nums := strings.split(expression[4:len(expression) - 1], ",") // strip away 'mul' and parenthesis
  assert(len(nums) == 2, "spliting the expression failed")
  multiplication_result := strconv.atoi(nums[0]) * strconv.atoi(nums[1])
  lexer.result_1 += multiplication_result
  if !lexer.disabled {
    lexer.result_2 += multiplication_result
  }
  lexer.token_start_offset = lexer.current_offset
}

lexer_accept :: proc(lexer: ^Lexer, r: rune) -> bool {
  if lexer_next(lexer) == r {
    return true
  } else {
    lexer_backup(lexer)
    return false
  }
}

lexer_backup :: proc(lexer: ^Lexer) {
  lexer.current_offset -= lexer.last_rune_size_in_bytes
}

lexer_next :: proc(lexer: ^Lexer) -> (r: rune) {
  if lexer.current_offset >= len(lexer.input) {
    lexer.last_rune_size_in_bytes = 0
    return RUNE_EOF
  }

  r, lexer.last_rune_size_in_bytes = utf8.decode_rune_in_string(lexer.input[lexer.current_offset:])
  lexer.current_offset += lexer.last_rune_size_in_bytes

  return
}

lexer_ignore :: proc(lexer: ^Lexer) {
  lexer.token_start_offset = lexer.current_offset
}

lexer_scanned :: proc(lexer: ^Lexer) -> string {
  return lexer.input[lexer.token_start_offset:lexer.current_offset]
}

lexer_length :: proc(lexer: ^Lexer) -> int {
  return lexer.current_offset - lexer.token_start_offset
}
