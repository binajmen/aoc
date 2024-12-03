import gleam/bit_array
import gleam/int
import gleam/result

type Filter {
  No
  Do
  Dont
}

pub fn parse(input: String) -> BitArray {
  bit_array.from_string(input)
}

pub fn pt_1(input: BitArray) -> Int {
  parser(input, No, 0)
}

pub fn pt_2(input: BitArray) -> Int {
  parser(input, Do, 0)
}

fn parser(input: BitArray, filter: Filter, total: Int) -> Int {
  case filter, input {
    Dont, <<"do()", rest:bytes>> -> parser(rest, Do, total)
    Dont, <<_, rest:bytes>> -> parser(rest, filter, total)
    Do, <<"don't()", rest:bytes>> -> parser(rest, Dont, total)
    _, <<>> -> total
    _, <<"mul(", a:bytes-size(1), ",", b:bytes-size(1), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(1), ",", b:bytes-size(2), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(1), ",", b:bytes-size(3), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(2), ",", b:bytes-size(1), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(2), ",", b:bytes-size(2), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(2), ",", b:bytes-size(3), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(3), ",", b:bytes-size(1), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(3), ",", b:bytes-size(2), ")", rest:bytes>>
    | _, <<"mul(", a:bytes-size(3), ",", b:bytes-size(3), ")", rest:bytes>>
    -> {
      let a = bytes_to_int(a)
      let b = bytes_to_int(b)
      parser(rest, filter, total + { a * b })
    }
    _, <<_, rest:bytes>> -> parser(rest, filter, total)
    _, _ -> panic as "this should not happen"
  }
}

fn bytes_to_int(a: BitArray) -> Int {
  bit_array.to_string(a)
  |> result.unwrap("0")
  |> int.parse()
  |> result.unwrap(0)
}
