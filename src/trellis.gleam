import gleam/int
import gleam/list
import gleam/string

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

/// A type representing a column in the table with header, alignment, and value getter
pub type Column(value) {
  Column(header: String, align: Align, getter: fn(value) -> String)
}

/// Alignment options for column content
pub type Align {
  Left
  Right
  Center
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
  header header: String,
  align align: Align,
  getter getter: fn(value) -> String,
) -> Table(value) {
  let Table(columns:, rows: _, style: _) = table
  Table(..table, columns: [Column(header, align, getter), ..columns])
}

/// Calculates the required width for each column based on content
/// 
/// Takes into account both header width and the maximum width of values
/// in each column to determine the appropriate column widths
fn calculate_widths(headers: List(String), values: List(String)) -> List(Int) {
  let lengths = list.sized_chunk(values, list.length(headers))

  list.map2(headers, list.transpose(lengths), fn(header, col_values) {
    let max_value_length =
      list.fold(col_values, 0, fn(acc, val) { int.max(acc, string.length(val)) })
    int.max(string.length(header), max_value_length)
  })
}

/// Converts the table to a formatted string representation
/// 
/// Creates a string with Unicode box-drawing characters, properly aligned content,
/// and separators between header and rows
pub fn to_string(table: Table(value)) -> String {
  let Table(columns:, rows:, style:) = table
  let columns = list.reverse(columns)

  let headers = list.map(columns, fn(col) { col.header })
  let aligns = list.map(columns, fn(col) { col.align })
  let values =
    list.flat_map(rows, fn(row) {
      list.map(columns, fn(col) { col.getter(row) })
    })
  let widths = calculate_widths(headers, values)

  let separator_top =
    make_separator(style:, widths:, is_header: True, is_top: True)
  let header_row =
    make_row(
      style,
      list.map(list.range(1, list.length(columns)), fn(_) { Center }),
      widths,
      headers,
    )
  let separator_header =
    make_separator(style:, widths:, is_header: True, is_top: False)

  let body_rows =
    list.map(rows, fn(row) {
      let row_values = list.map(columns, fn(col) { col.getter(row) })
      make_row(style, aligns, widths, row_values)
    })

  let separator_bottom =
    make_separator(style:, widths:, is_header: False, is_top: False)

  [separator_top, header_row, separator_header]
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

/// Creates a row in the table with properly aligned content
fn make_row(
  style: style.Style,
  aligns: List(Align),
  widths: List(Int),
  values: List(String),
) -> String {
  let vertical = style.style(style:).vertical

  let row =
    {
      use #(align, width), value <- list.map2(
        {
          use align, width <- list.map2(aligns, widths)
          #(align, width)
        },
        values,
      )
      let padded = case align {
        Left -> pad_right(value, width)
        Right -> pad_left(value, width)
        Center -> pad_center(value, width)
      }
      " " <> padded <> " "
    }
    |> string.join(vertical)

  vertical <> row <> vertical
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
