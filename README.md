# trellis

A simple Gleam library for pretty printing tabular data!

[![Package Version](https://img.shields.io/hexpm/v/trellis)](https://hex.pm/packages/trellis)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/trellis/)

```sh
gleam add trellis@2
```
```gleam
import trellis
import trellis/column.{Left, Right}
import trellis/style

pub fn main() {
  let names = ["Michael", "Vitor", "Ellen"]

  let data = {
    use _ <- list.map(list.range(0, 10))

    let assert Ok(name) = names |> list.shuffle |> list.first
    let age = int.random(80)
    let happy = int.random(2) |> int.is_even

    Row(name:, age:, happy:)
  }

  trellis.table(data:)
  |> trellis.style(style.Round)
  |> trellis.with(
    column.new("name")
    |> column.align(Left)
    |> column.render({
      use Row(name:, age: _, happy: _) <- trellis.param
      name
    }),
  )
  |> trellis.with(
    column.new("the person's age")
    |> column.render({
      use Row(name: _, age:, happy: _) <- trellis.param
      age |> int.to_string
    }),
  )
  |> trellis.with(
    column.new("senior")
    |> column.align(Right)
    |> column.render({
      use Row(name: _, age:, happy: _) <- trellis.param
      { age >= 65 } |> bool.to_string
    }),
  )
  |> trellis.with(
    column.new("happy")
    |> column.align(Right)
    |> column.render({
      use Row(name: _, age: _, happy:) <- trellis.param
      case happy {
        True -> "Happy"
        False -> "Not Happy"
      }
    }),
  )
  |> trellis.to_string
  |> io.println
}
```

The output looks like:
<pre><code style="font-family: monospace;" class="language-plaintext">
╭───────────┬──────────────────┬────────┬───────────╮
│   name    │ the person's age │ senior │   happy   │
├───────────┼──────────────────┼────────┼───────────┤
│ Michael   │        16        │  False │ Not Happy │
│ Vitor     │        54        │  False │     Happy │
│ Ellen     │        63        │  False │ Not Happy │
│ Ellen     │        19        │  False │ Not Happy │
│ Vitor     │        28        │  False │     Happy │
│ Michael   │        59        │  False │ Not Happy │
│ Ellen     │        60        │  False │     Happy │
│ Vitor     │        60        │  False │ Not Happy │
│ Michael   │        74        │   True │     Happy │
│ Vitor     │        12        │  False │     Happy │
│ Ellen     │        16        │  False │     Happy │
╰───────────┴──────────────────┴────────┴───────────╯
</code></pre>

Further documentation can be found at <https://hexdocs.pm/trellis>.

## Development

```sh
nix develop # start dev shell
gleam run   # Run the project
gleam test  # Run the tests
```
