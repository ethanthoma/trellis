import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import trellis/style

import trellis.{Center, Left, Right}

pub fn main() {
  print_row_test()
  io.println("✅ Done!")
}

pub type Row {
  Row(name: String, age: Int, happy: Bool)
}

pub fn print_row_test() {
  let data = {
    use _ <- list.map(list.range(0, 10))

    let assert Ok(name) = names |> list.shuffle |> list.first
    let age = int.random(80)
    let happy = int.random(2) |> int.is_even

    Row(name:, age:, happy:)
  }

  trellis.table(data:)
  |> trellis.style(style.Round)
  |> trellis.with("name", Left, {
    use Row(name:, age: _, happy: _) <- trellis.param
    name
  })
  |> trellis.with("the person's age", Center, {
    use Row(name: _, age:, happy: _) <- trellis.param
    age |> int.to_string
  })
  |> trellis.with("senior", Right, {
    use Row(name: _, age:, happy: _) <- trellis.param
    { age >= 65 } |> bool.to_string
  })
  |> trellis.with("happy", Right, {
    use Row(name: _, age: _, happy:) <- trellis.param
    case happy {
      True -> "Happy"
      False -> "Not Happy"
    }
  })
  |> trellis.to_string
  |> io.println
}

pub const names = [
  "Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Isabella", "Mason",
  "Sophia", "William", "Mia", "James", "Charlotte", "Benjamin", "Amelia",
]
