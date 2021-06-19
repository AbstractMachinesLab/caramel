external recv_with_timeout : int -> 'a = "recv"

external recv_and_wait : unit -> 'a = "recv"

external ( ^ ) : string -> string -> string = "binary_concat"

external ( |> ) : 'a -> ('a -> 'b) -> 'b = "pipe"
