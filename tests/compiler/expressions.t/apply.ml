module Funs = struct
  let apply_fun () =
    let a () = 1 in
    let b () = 2 in
    let c x = x + 1 in
    a ();
    b ();
    c 0
end

let rec f x = f x

let f1 x = f [ x ]

let f2 x y = f [ x; y ]

let f3 x y z = f [ x; y; z ]

let f4 w x y z = f [ w; x; y; z ]

let run () =
  f1 1;
  f2 1 2;
  f3 1 2 3;
  f4 1 2 3 4;
  Funs.apply_fun ()

let lambda () =
  let f () = 1 in
  let f' x = 1 + x in
  let f'' x y = 1 + x + y in
  let _ = f () in
  let _ = f' 1 in
  f'' 1 2

let abs_diff_times x y z = (Erlang.abs (x - y)) * z

let partial_application () =
  let f = abs_diff_times 3 in
  f (-1) 2
