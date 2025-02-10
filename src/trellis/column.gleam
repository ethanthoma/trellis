import gleam/option

/// A type representing a column in the table with header, alignment, and value getter
pub type Column(value) {
  Column(
    header: String,
    align: Align,
    width: option.Option(Int),
    getter: fn(value) -> String,
  )
}

/// Alignment options for column content
pub type Align {
  Left
  Right
  Center
}

/// Creates a new column with the given header text. The column is initially centered
/// with no width constraint and an empty getter function.
/// 
/// ## Example
/// 
/// ```gleam
/// let name_col = column.new(header: "Name")
/// ```
pub fn new(header header: String) -> Column(value) {
  Column(header:, align: Center, width: option.None, getter: fn(_) { "" })
}

/// Sets the alignment for the column's content. Content can be aligned left,
/// right, or center.
/// 
/// ## Example
/// 
/// ```gleam
/// column.new(header: "Age")
/// |> column.align(Right)
/// ```
pub fn align(column column: Column(value), align align: Align) -> Column(value) {
  Column(..column, align:)
}

/// Sets the function used to extract a string value from a row for this column.
/// The getter function should take a value of the type passed into the table and return a string.
/// 
/// ## Example
/// 
/// ```gleam 
/// column.new(header: "Name")
/// |> column.render(fn(user) { user.name })
/// ```
pub fn render(
  column column: Column(value),
  getter getter: fn(any) -> String,
) -> Column(any) {
  Column(..column, getter:)
}

/// Sets a maximum width for the column in characters. Content longer than this
/// width will be wrapped automatically. The column will never be smaller than
/// the longest word in its content.
/// 
/// ## Example
/// 
/// ```gleam
/// column.new(header: "Description") 
/// |> column.wrap(width: 40)
/// ```
pub fn wrap(column column: Column(value), width width: Int) -> Column(value) {
  Column(..column, width: option.Some(width))
}
