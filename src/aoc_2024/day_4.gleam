import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string

type Coord =
  #(Int, Int)

type Grid =
  Dict(Coord, String)

type Direction {
  Right
  BottomRight
  Bottom
  BottomLeft
  Left
  TopLeft
  Top
  TopRight
}

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
  let compass = [
    #(Right, #(#(0, 1), #(0, 2), #(0, 3))),
    #(BottomRight, #(#(1, 1), #(2, 2), #(3, 3))),
    #(Bottom, #(#(1, 0), #(2, 0), #(3, 0))),
    #(BottomLeft, #(#(1, -1), #(2, -2), #(3, -3))),
    #(Left, #(#(0, -1), #(0, -2), #(0, -3))),
    #(TopLeft, #(#(-1, -1), #(-2, -2), #(-3, -3))),
    #(Top, #(#(-1, 0), #(-2, 0), #(-3, 0))),
    #(TopRight, #(#(-1, 1), #(-2, 2), #(-3, 3))),
  ]

  dict.fold(grid, 0, fn(acc, coord, value) {
    case value {
      "X" -> {
        acc
        + list.fold(compass, 0, fn(total, deltas) {
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
  deltas: #(Direction, #(#(Int, Int), #(Int, Int), #(Int, Int))),
) {
  let #(row, col) = coord
  let #(direction, #(m, a, s)) = deltas
  case
    dict.get(grid, #(row + m.0, col + m.1)),
    dict.get(grid, #(row + a.0, col + a.1)),
    dict.get(grid, #(row + s.0, col + s.1))
  {
    Ok("M"), Ok("A"), Ok("S") -> {
      io.debug(coord)
      io.debug(direction)
      1
    }
    _, _, _ -> 0
  }
}

pub fn pt_2(input: Dict(#(Int, Int), String)) {
  todo as "part 2 not implemented"
}
