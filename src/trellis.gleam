import gleam/int
import gleam/list
import gleam/string

const vertical = "│"

const horizontal = "─"

const top_left = "┌"

const top_right = "┐"

const middle_left = "┤"

const middle_right = "├"

const middle_bottom = "┴"

const middle_top = "┬"

const bottom_left = "└"

const bottom_right = "┘"

const cross = "┼"

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
  Table(columns: List(Column(value)), rows: List(value))
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
  Table(columns: [], rows: rows)
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
  builder: Table(value),
  header header: String,
  align align: Align,
  getter getter: fn(value) -> String,
) -> Table(value) {
  let Table(columns: columns, rows: rows) = builder
  Table(columns: [Column(header, align, getter), ..columns], rows: rows)
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
  let Table(columns: columns, rows: rows) = table
  let columns = list.reverse(columns)

  let headers = list.map(columns, fn(col) { col.header })
  let aligns = list.map(columns, fn(col) { col.align })
  let values =
    list.flat_map(rows, fn(row) {
      list.map(columns, fn(col) { col.getter(row) })
    })
  let widths = calculate_widths(headers, values)

  let separator_top = make_separator(widths, True, True)
  let header_row =
    make_row(
      list.map(list.range(1, list.length(columns)), fn(_) { Center }),
      widths,
      headers,
    )
  let separator_header = make_separator(widths, True, False)

  let body_rows =
    list.map(rows, fn(row) {
      let row_values = list.map(columns, fn(col) { col.getter(row) })
      make_row(aligns, widths, row_values)
    })

  let separator_bottom = make_separator(widths, False, False)

  [separator_top, header_row, separator_header]
  |> list.append(body_rows)
  |> list.append([separator_bottom])
  |> string.join("\n")
}

/// Creates a horizontal separator line for the table
fn make_separator(columns: List(Int), is_header: Bool, is_top: Bool) -> String {
  let start = case is_top, is_header {
    True, _ -> top_left
    False, True -> middle_right
    False, False -> bottom_left
  }

  let end = case is_top, is_header {
    True, _ -> top_right
    False, True -> middle_left
    False, False -> bottom_right
  }

  let middle = case is_top, is_header {
    True, _ -> middle_top
    False, True -> cross
    False, False -> middle_bottom
  }

  let line =
    list.fold(columns, start, fn(acc, col) {
      acc <> string.repeat(horizontal, col + 2) <> middle
    })

  string.slice(line, 0, string.length(line) - 1) <> end
}

/// Creates a row in the table with properly aligned content
fn make_row(
  aligns: List(Align),
  widths: List(Int),
  values: List(String),
) -> String {
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
