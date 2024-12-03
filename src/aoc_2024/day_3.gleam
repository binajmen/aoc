import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let matches = regexp.scan(re, input)

  list.fold(matches, 0, fn(total, match) {
    let regexp.Match(_, submatches) = match
    let assert [Some(left), Some(right)] = submatches
    let assert Ok(left) = int.parse(left)
    let assert Ok(right) = int.parse(right)
    total + { left * right }
  })
}

type Condition {
  Do
  Dont
}

pub fn pt_2(input: String) {
  let assert Ok(re) =
    regexp.from_string("(mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\))")
  let matches = regexp.scan(re, input)
  handle_matches(matches, Do, 0)
}

fn handle_matches(matches: List(Match), condition: Condition, total: Int) {
  case matches {
    [] -> total
    _ -> {
      let assert [match, ..rest] = matches
      let regexp.Match(_, submatches) = match

      case submatches {
        [_, Some(left), Some(right)] -> {
          case condition {
            Do -> {
              let assert Ok(left) = int.parse(left)
              let assert Ok(right) = int.parse(right)
              handle_matches(rest, condition, total + { left * right })
            }
            Dont -> handle_matches(rest, condition, total)
          }
        }
        [Some("do()")] -> handle_matches(rest, Do, total)
        [Some("don't()")] -> handle_matches(rest, Dont, total)
        _ -> handle_matches(rest, condition, total)
      }
    }
  }
}
