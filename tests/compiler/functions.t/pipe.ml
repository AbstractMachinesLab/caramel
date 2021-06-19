let print_int number = Io.format "~0tp~n" [ number ]

let subtract x y = y - x
let main _ =
  let divide x y = y / x in
  10 |> subtract 2 |> divide 4 |> print_int
