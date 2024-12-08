import gleam/dict.{type Dict}
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

pub type Direction {
  Up
  Left
  Bottom
  Right
}

pub type Step {
  Step(String, Set(Direction))
}

pub type Coordinate =
  #(Int, Int)

pub type Map =
  Dict(Coordinate, Step)

pub fn parse(input: String) -> Map {
  string.split(input, "\n")
  |> list.index_map(fn(line, row) {
    string.to_graphemes(line)
    |> list.index_map(fn(char, col) { #(#(row, col), Step(char, set.new())) })
  })
  |> list.flatten()
  |> dict.from_list()
}

pub fn pt_1(map: Map) {
  let guard_coord = find_guard(map)
  let assert Ok(path) = walk(map, guard_coord, Up)

  dict.values(path)
  |> list.count(fn(step) {
    case step {
      Step("X", _) -> True
      Step("O", _) -> True
      _ -> False
    }
  })
}

pub fn pt_2(map: Map) {
  let guard_coord = find_guard(map)

  dict.fold(map, 0, fn(cycles, coord, step) {
    case step {
      Step(".", _) -> {
        let path =
          dict.insert(map, coord, Step("#", set.new()))
          |> walk(guard_coord, Up)
        case path {
          Ok(_) -> cycles
          Error("cycle") -> cycles + 1
          Error(_) -> panic as "should not happen"
        }
      }
      _ -> cycles
    }
  })
}

fn find_guard(map: Map) {
  dict.to_list(map)
  |> list.fold_until(#(0, 0), fn(guard, cell) {
    case cell {
      #(coord, Step("^", _)) -> Stop(coord)
      _ -> Continue(guard)
    }
  })
}

fn walk(map: Map, coord: Coordinate, dir: Direction) -> Result(Map, String) {
  let map =
    dict.upsert(map, coord, fn(step) {
      case step {
        Some(Step(_, dirs)) -> Step("X", set.insert(dirs, dir))
        None -> panic as "out of map"
      }
    })

  let next_coord = next_coordinate(coord, dir)
  let next_step = dict.get(map, next_coord)
  case next_step {
    Ok(Step("#", _)) -> walk(map, coord, rotate(dir))
    Ok(Step(_, dirs)) ->
      case set.contains(dirs, dir) {
        True -> Error("cycle")
        False -> walk(map, next_coord, dir)
      }
    Error(_) -> Ok(map)
  }
}

fn detect_cycle(map: Map, coord: Coordinate, dir: Direction) -> String {
  let map = updade_step(map, coord, dir, "X")
  let next_coord = next_coordinate(coord, dir)
  let next_step = dict.get(map, next_coord)
  case next_step {
    Ok(Step("#", _)) -> detect_cycle(map, coord, rotate(dir))
    Ok(Step(_, dirs)) -> {
      case set.contains(dirs, dir) {
        True -> "O"
        False -> detect_cycle(map, next_coord, dir)
      }
    }
    Error(_) -> "X"
  }
}

fn updade_step(map: Map, coord: Coordinate, dir: Direction, foot: String) -> Map {
  dict.upsert(map, coord, fn(step) {
    case step {
      Some(Step("O", dirs)) -> Step("O", set.insert(dirs, dir))
      Some(Step(_, dirs)) -> Step(foot, set.insert(dirs, dir))
      None -> panic as "out of boundaries"
    }
  })
}

fn next_coordinate(coord: Coordinate, dir: Direction) {
  case dir {
    Up -> #(coord.0 - 1, coord.1)
    Right -> #(coord.0, coord.1 + 1)
    Bottom -> #(coord.0 + 1, coord.1)
    Left -> #(coord.0, coord.1 - 1)
  }
}

fn rotate(dir: Direction) {
  case dir {
    Up -> Right
    Right -> Bottom
    Bottom -> Left
    Left -> Up
  }
}
