import gleam/int
import gleam/list
import gleam/option
import gleam/string

import trellis/column.{type Align, type Column, Center, Column, Left, Right}
import trellis/style

/// A type representing a formatted table with headers and rows of data
/// 
/// ## Example
/// 
/// ```gleam
/// let table = 
///   table([user1, user2, user3])
///   |> with("Name", Left, { 
///     use user <- param
///     user.name 
///   })
///   |> with("Age", Right, {
///     use user <- param
///     user.age |> int.to_string
///   })
/// ```
pub type Table(value) {
  Table(columns: List(Column(value)), rows: List(value), style: style.Style)
}

// Helper type to store cell content split into lines
type CellContent {
  CellContent(lines: List(String), width: Int, height: Int)
}

/// Creates a new table with the given rows of data
pub fn table(data rows: List(value)) -> Table(value) {
  Table(columns: [], rows: rows, style: style.Line)
}

/// Set the style of the table
pub fn style(
  table table: Table(value),
  style style: style.Style,
) -> Table(value) {
  Table(..table, style:)
}

/// Helper function to wrap a function for use in column definitions
/// 
/// This is a utility function that can make column definitions more readable
/// when used with partial application
pub fn param(f: fn(a) -> b) -> fn(a) -> b {
  f
}

/// Adds a new column to the table definition
pub fn with(
  table table: Table(value),
  column column: Column(value),
) -> Table(value) {
  let Table(columns:, rows: _, style: _) = table
  Table(..table, columns: [column, ..columns])
}

fn cell_content(text: String, width width: option.Option(Int)) -> CellContent {
  let newline_splits = string.split(text, on: "\n")

  let lines = case width {
    option.Some(width) -> {
      list.flat_map(newline_splits, fn(line) { wrap_text(line, width) })
    }
    option.None -> newline_splits
  }

  let content_width =
    list.fold(lines, 0, fn(acc, line) { int.max(acc, string.length(line)) })

  let final_width = case width {
    option.Some(max) -> int.min(content_width, max)
    option.None -> content_width
  }

  CellContent(lines: lines, width: final_width, height: list.length(lines))
}

/// Calculates the required width for each column based on content
/// 
/// Takes into account both header width and the maximum width of values
/// in each column to determine the appropriate column widths
fn calculate_widths(
  headers: List(String),
  values: List(String),
  widths: List(option.Option(Int)),
) -> List(Int) {
  let header_cells = list.map2(headers, widths, cell_content)

  let columns = list.sized_chunk(values, list.length(headers))
  let transposed_columns = list.transpose(columns)

  let min_column_widths =
    list.map(transposed_columns, fn(col_values) {
      list.fold(col_values, 0, fn(acc, val) {
        int.max(acc, calculate_min_width(val))
      })
    })

  let value_cells =
    list.map2(transposed_columns, widths, fn(col_values, width) {
      list.map(col_values, fn(value) { cell_content(value, width) })
    })

  use #(header, max_width), #(column_cells, min_width) <- list.map2(
    list.zip(header_cells, widths),
    list.zip(value_cells, min_column_widths),
  )

  let natural_width =
    list.fold(column_cells, header.width, fn(acc, cell) {
      int.max(acc, cell.width)
    })

  let width = int.max(natural_width, min_width)

  case max_width {
    option.Some(max_width) -> int.max(min_width, int.min(width, max_width))
    option.None -> width
  }
}

fn make_multi_line_row(
  style style: style.Style,
  aligns aligns: List(Align),
  widths widths: List(Int),
  cell_contents cell_contents: List(CellContent),
) -> List(String) {
  let vertical = style.style(style: style).vertical

  let max_height =
    list.fold(cell_contents, 0, fn(acc, cell) { int.max(acc, cell.height) })

  list.range(0, max_height - 1)
  |> list.map(fn(line_num) {
    let parts =
      list.map2(list.zip(aligns, widths), cell_contents, fn(tup, cell) {
        #(tup.0, tup.1, cell)
      })

    let line_parts =
      list.map(parts, fn(part) {
        let #(align, width, cell) = part

        let content =
          list.index_fold(cell.lines, "", fn(acc, line, i) {
            case line_num == i {
              True -> line
              _ -> acc
            }
          })

        let padded = case align {
          Left -> pad_right(content, width)
          Right -> pad_left(content, width)
          Center -> pad_center(content, width)
        }
        " " <> padded <> " "
      })

    vertical <> string.join(line_parts, vertical) <> vertical
  })
}

/// Converts the table to a formatted string representation
/// 
/// Creates a string with Unicode box-drawing characters, properly aligned content,
/// and separators between header and rows
pub fn to_string(table: Table(value)) -> String {
  let Table(columns: columns, rows: rows, style: style) = table
  let columns = list.reverse(columns)

  let headers = list.map(columns, fn(column) { column.header })
  let aligns = list.map(columns, fn(column) { column.align })
  let max_widths = list.map(columns, fn(column) { column.width })

  let values =
    list.flat_map(rows, fn(row) {
      list.map(columns, fn(col) { col.getter(row) })
    })

  let widths = calculate_widths(headers, values, max_widths)

  let separator_top =
    make_separator(style:, widths:, is_header: True, is_top: True)
  let separator_header =
    make_separator(style:, widths:, is_header: True, is_top: False)
  let separator_bottom =
    make_separator(style:, widths:, is_header: False, is_top: False)

  let header_cells = list.map2(headers, max_widths, cell_content)
  let header_rows =
    make_multi_line_row(
      style:,
      aligns: list.map(list.range(1, list.length(columns)), fn(_) { Center }),
      widths:,
      cell_contents: header_cells,
    )

  let body_rows =
    list.flat_map(rows, fn(row) {
      let cell_contents =
        list.map2(columns, max_widths, fn(col, w) {
          cell_content(col.getter(row), w)
        })

      make_multi_line_row(style:, aligns:, widths:, cell_contents:)
    })

  [separator_top]
  |> list.append(header_rows)
  |> list.append([separator_header])
  |> list.append(body_rows)
  |> list.append([separator_bottom])
  |> string.join("\n")
}

/// Creates a horizontal separator line for the table
fn make_separator(
  style style: style.Style,
  widths widths: List(Int),
  is_header is_header: Bool,
  is_top is_top: Bool,
) -> String {
  let style.StyleGuide(
    top_left:,
    top_middle:,
    top_right:,
    middle_left:,
    middle_right:,
    bottom_left:,
    bottom_middle:,
    bottom_right:,
    cross:,
    horizontal:,
    vertical: _,
  ) = style.style(style:)

  let #(start, middle, end) = case is_top, is_header {
    True, _ -> #(top_left, top_middle, top_right)
    False, True -> #(middle_right, cross, middle_left)
    False, False -> #(bottom_left, bottom_middle, bottom_right)
  }

  let line =
    widths
    |> list.fold(start, fn(acc, col) {
      acc <> string.repeat(horizontal, col + 2) <> middle
    })

  string.slice(line, 0, string.length(line) - 1) <> end
}

/// Left-pads a string with spaces to reach the specified width
fn pad_left(text: String, width: Int) -> String {
  let padding = width - string.length(text)
  string.repeat(" ", padding) <> text
}

/// Right-pads a string with spaces to reach the specified width
fn pad_right(text: String, width: Int) -> String {
  let padding = width - string.length(text)
  text <> string.repeat(" ", padding)
}

/// Centers a string by padding both sides with spaces to reach the specified width
fn pad_center(text: String, width: Int) -> String {
  let padding = width - string.length(text)
  let left = padding / 2
  let right = padding - left
  string.repeat(" ", left) <> text <> string.repeat(" ", right)
}

fn wrap_text(text: String, max_width: Int) -> List(String) {
  let min_width = calculate_min_width(text)

  let effective_width = int.max(max_width, min_width)

  case string.length(text) <= effective_width {
    True -> [text]
    False -> {
      let words = string.split(text, on: " ")
      do_wrap(words: words, max_width: effective_width, current: "", lines: [])
    }
  }
}

fn do_wrap(
  words words: List(String),
  max_width max_width: Int,
  current current: String,
  lines lines: List(String),
) -> List(String) {
  case words {
    [] ->
      case current {
        "" -> list.reverse(lines)
        _ -> list.reverse([string.trim(current), ..lines])
      }
    [word, ..rest] -> {
      let with_space = case current {
        "" -> word
        _ -> current <> " " <> word
      }

      case string.length(with_space) <= max_width {
        True -> do_wrap(rest, max_width, with_space, lines)
        False ->
          case current {
            "" -> do_wrap(rest, max_width, word, lines)
            _ ->
              do_wrap([word, ..rest], max_width, "", [
                string.trim(current),
                ..lines
              ])
          }
      }
    }
  }
}

fn calculate_min_width(text: String) -> Int {
  string.split(text, on: " ")
  |> list.fold(0, fn(acc, word) { int.max(acc, string.length(word)) })
}
