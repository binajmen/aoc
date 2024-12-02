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
  list.count(input, fn(levels) { is_safe(levels, 0) })
}

fn is_safe(levels: List(Int), tolerance: Int) -> Bool {
  is_safe_asc(levels, tolerance) || is_safe_desc(levels, tolerance)
}

fn is_safe_asc(levels: List(Int), tolerance: Int) -> Bool {
  case levels {
    [a, b, ..rest] if b - a >= 1 && b - a <= 3 ->
      is_safe_asc([b, ..rest], tolerance)
    [a, b, ..rest] if tolerance > 0 ->
      is_safe_asc([a, ..rest], tolerance - 1)
      || is_safe_asc([b, ..rest], tolerance - 1)
    [_] -> True
    _ -> False
  }
}

fn is_safe_desc(levels: List(Int), tolerance: Int) -> Bool {
  case levels {
    [a, b, ..rest] if a - b >= 1 && a - b <= 3 ->
      is_safe_desc([b, ..rest], tolerance)
    [a, b, ..rest] if tolerance > 0 ->
      is_safe_desc([a, ..rest], tolerance - 1)
      || is_safe_desc([b, ..rest], tolerance - 1)
    [_] -> True
    _ -> False
  }
}

pub fn pt_2(input: List(List(Int))) {
  list.count(input, fn(levels) { is_safe(levels, 1) })
}
