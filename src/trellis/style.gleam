pub type Style {
  Line
  Round
}

@internal
pub type StyleGuide {
  StyleGuide(
    vertical: String,
    horizontal: String,
    top_left: String,
    top_middle: String,
    top_right: String,
    middle_left: String,
    middle_right: String,
    bottom_left: String,
    bottom_middle: String,
    bottom_right: String,
    cross: String,
  )
}

const line_style = StyleGuide(
  vertical: "│",
  horizontal: "─",
  top_left: "┌",
  top_middle: "┬",
  top_right: "┐",
  middle_left: "┤",
  middle_right: "├",
  bottom_left: "└",
  bottom_middle: "┴",
  bottom_right: "┘",
  cross: "┼",
)

const round_style = StyleGuide(
  vertical: "│",
  horizontal: "─",
  top_left: "╭",
  top_middle: "┬",
  top_right: "╮",
  middle_left: "┤",
  middle_right: "├",
  bottom_left: "╰",
  bottom_middle: "┴",
  bottom_right: "╯",
  cross: "┼",
)

pub fn style(style style: Style) {
  case style {
    Line -> line_style
    Round -> round_style
  }
}
