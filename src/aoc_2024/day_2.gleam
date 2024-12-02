import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(fn(report) {
    string.split(report, on: " ")
    |> list.map(fn(location) {
      let assert Ok(loc) = int.base_parse(location, 10)
      loc
    })
  })
}

pub fn pt_1(input: List(List(Int))) {
  list.count(input, is_safe)
}

fn is_safe(levels: List(Int)) -> Bool {
  is_safe_asc(levels) || is_safe_desc(levels)
}

fn is_safe_asc(levels: List(Int)) -> Bool {
  case levels {
    [a, b, ..rest] if b - a >= 1 && b - a <= 3 -> is_safe_asc([b, ..rest])
    [_] -> True
    _ -> False
  }
}

fn is_safe_desc(levels: List(Int)) -> Bool {
  case levels {
    [a, b, ..rest] if a - b >= 1 && a - b <= 3 -> is_safe_desc([b, ..rest])
    [_] -> True
    _ -> False
  }
}

pub fn pt_2(input: List(List(Int))) {
  list.count(input, fn(line) {
    list.any(list.combinations(line, list.length(line) - 1), is_safe)
  })
}
