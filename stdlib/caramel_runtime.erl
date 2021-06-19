-module(caramel_runtime).

-export([
         binary_concat/2,
         pipe/2,
         recv/0,
         recv/1
        ]).

%% @doc this function is used in `Caramel_runtime` to expose both an indefinite
%% wait and a bounded wait.
recv() -> recv(infinity).
recv(Timeout) ->
  receive Msg -> {some, Msg}
  after Timeout -> none
  end.

binary_concat(A, B) when is_binary(A) and is_binary(B) ->
  << (A)/binary, (B)/binary >>.

pipe(A, B) -> B(A).
