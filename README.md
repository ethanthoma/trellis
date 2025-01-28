# trellis

A simple Gleam library for pretty printing tabular data!

[![Package Version](https://img.shields.io/hexpm/v/trellis)](https://hex.pm/packages/trellis)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/trellis/)

```sh
gleam add trellis@1
```
```gleam
import trellis

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
```

The output looks like:
<pre><code style="font-family: monospace;" class="language-plaintext">
┌──────────┬──────────────────┬────────┬───────────┐
│   name   │ the person's age │ senior │   happy   │
├──────────┼──────────────────┼────────┼───────────┤
│ Mia      │        67        │   True │     Happy │
│ Noah     │        35        │  False │     Happy │
│ Isabella │        17        │  False │ Not Happy │
│ Amelia   │        74        │   True │     Happy │
│ James    │        62        │  False │ Not Happy │
│ William  │        58        │  False │ Not Happy │
│ Benjamin │        6         │  False │ Not Happy │
│ Isabella │        3         │  False │     Happy │
│ Liam     │        24        │  False │     Happy │
│ Mia      │        45        │  False │     Happy │
│ James    │        22        │  False │     Happy │
└──────────┴──────────────────┴────────┴───────────┘
</code></pre>

Further documentation can be found at <https://hexdocs.pm/trellis>.

## Development

```sh
nix develop # start dev shell
gleam run   # Run the project
gleam test  # Run the tests
```
