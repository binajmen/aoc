import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

pub fn parse(input: String) -> Grid {
  string.split(input, "\n")
  |> list.index_map(fn(line, row) {
    string.to_graphemes(line)
    |> list.index_map(fn(char, col) { #(#(row, col), char) })
  })
  |> list.flatten()
  |> dict.from_list()
}

pub fn pt_1(grid: Grid) {
  let directions = [
    #(#(0, 1), #(0, 2), #(0, 3)),
    #(#(1, 1), #(2, 2), #(3, 3)),
    #(#(1, 0), #(2, 0), #(3, 0)),
    #(#(1, -1), #(2, -2), #(3, -3)),
    #(#(0, -1), #(0, -2), #(0, -3)),
    #(#(-1, -1), #(-2, -2), #(-3, -3)),
    #(#(-1, 0), #(-2, 0), #(-3, 0)),
    #(#(-1, 1), #(-2, 2), #(-3, 3)),
  ]

  dict.fold(grid, 0, fn(acc, coord, value) {
    case value {
      "X" -> {
        acc
        + list.fold(directions, 0, fn(total, deltas) {
          total + is_xmas(grid, coord, deltas)
        })
      }
      _ -> acc
    }
  })
}

fn is_xmas(
  grid: Grid,
  coord: Coord,
  deltas: #(#(Int, Int), #(Int, Int), #(Int, Int)),
) {
  let #(row, col) = coord
  let #(m, a, s) = deltas
  case
    dict.get(grid, #(row + m.0, col + m.1)),
    dict.get(grid, #(row + a.0, col + a.1)),
    dict.get(grid, #(row + s.0, col + s.1))
  {
    Ok("M"), Ok("A"), Ok("S") -> 1
    _, _, _ -> 0
  }
}

pub fn pt_2(grid: Grid) {
  let directions = [
    #(#(-1, 1), #(1, 1), #(-1, -1), #(1, -1)),
    #(#(1, 1), #(1, -1), #(-1, -1), #(-1, 1)),
    #(#(1, -1), #(-1, -1), #(-1, 1), #(1, 1)),
    #(#(-1, -1), #(-1, 1), #(1, 1), #(1, -1)),
  ]

  dict.fold(grid, 0, fn(acc, coord, value) {
    case value {
      "A" -> {
        acc
        + list.fold(directions, 0, fn(total, deltas) {
          total + is_x_mas(grid, coord, deltas)
        })
      }
      _ -> acc
    }
  })
}

fn is_x_mas(
  grid: Grid,
  coord: Coord,
  deltas: #(#(Int, Int), #(Int, Int), #(Int, Int), #(Int, Int)),
) {
  let #(row, col) = coord
  let #(m1, m2, s1, s2) = deltas
  case
    dict.get(grid, #(row + m1.0, col + m1.1)),
    dict.get(grid, #(row + m2.0, col + m2.1)),
    dict.get(grid, #(row + s1.0, col + s1.1)),
    dict.get(grid, #(row + s2.0, col + s2.1))
  {
    Ok("M"), Ok("M"), Ok("S"), Ok("S") -> 1
    _, _, _, _ -> 0
  }
}
