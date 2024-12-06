import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

type Graph =
  Dict(Int, List(Int))

type Manuals =
  List(Manual)

type Manual =
  List(Int)

pub fn parse(input: String) -> #(Graph, Manuals) {
  let assert [graph, manuals] = string.split(input, "\n\n")
  let graph =
    string.split(graph, "\n")
    |> list.fold(dict.new(), fn(dict, order) {
      let assert [parent, child] = string.split(order, "|")
      let parent = parse_int(parent)
      let child = parse_int(child)
      dict.upsert(dict, parent, fn(cur) {
        case cur {
          Some(cur) -> [child, ..cur]
          None -> [child]
        }
      })
    })
  let manuals =
    string.split(manuals, "\n")
    |> list.map(fn(update) {
      string.split(update, ",")
      |> list.map(parse_int)
    })
  #(graph, manuals)
}

pub fn pt_1(input: #(Graph, Manuals)) -> Int {
  let #(graph, manuals) = input
  let assert [manual, ..] = manuals
  let res = top_sort(graph, manual)

  list.filter(manuals, fn(manual) { is_ordered(graph, manual) })
  |> list.fold(0, fn(total, manual) { total + extract_middle(manual) })
}

pub fn pt_2(input: #(Graph, Manuals)) -> Int {
  let #(graph, manuals) = input
  let assert [manual, ..] = manuals
  let res = top_sort(graph, manual)

  list.filter(manuals, fn(manual) { !is_ordered(graph, manual) })
  |> list.map(fn(manual) { top_sort(graph, manual) })
  |> list.fold(0, fn(total, manual) { total + extract_middle(manual) })
}

fn build_graph(graph: Graph, manual: Manual) -> Graph {
  dict.filter(graph, fn(node, _) { list.contains(manual, node) })
  |> dict.map_values(fn(_, children) {
    list.filter(children, fn(node) { list.contains(manual, node) })
  })
}

fn is_ordered(graph: Graph, manual: Manual) -> Bool {
  let sorted = top_sort(graph, manual)
  list.map2(manual, sorted, fn(a, b) { a == b })
  |> list.fold(True, fn(is_ordered, is_equal) { is_equal && is_ordered })
}

fn top_sort(graph: Graph, manual: Manual) -> Manual {
  let graph = build_graph(graph, manual)
  let #(_, result) =
    list.fold(manual, #([], []), fn(result, node) {
      let #(visited, stack) = result
      case list.contains(visited, node) {
        True -> result
        False -> dfs(graph, node, visited, stack)
      }
    })
  result |> list.unique()
}

fn dfs(
  graph: Graph,
  node: Int,
  visited: Manual,
  stack: Manual,
) -> #(Manual, Manual) {
  let visited = [node, ..visited]
  let children = dict.get(graph, node)
  let #(visited, stack) = case children {
    Ok([]) | Error(_) -> {
      #(visited, [node, ..stack])
    }
    Ok(children) -> {
      list.fold(children, #(visited, stack), fn(progress, node) {
        let #(visited, stack) = progress
        case list.contains(visited, node) {
          True -> {
            #(visited, stack)
          }
          False -> {
            dfs(graph, node, visited, stack)
          }
        }
      })
    }
  }
  #(visited, [node, ..stack])
}

fn extract_middle(manual: Manual) -> Int {
  let length = list.length(manual) / 2
  let assert Ok(middle) = list.drop(manual, length) |> list.first()
  middle
}

fn parse_int(str: String) -> Int {
  let assert Ok(n) = int.parse(str)
  n
}
