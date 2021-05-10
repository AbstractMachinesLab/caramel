  $ ls *.ml
  apply.ml
  binding_on_match.ml
  funref.ml
  let_bindings.ml
  let_rec.ml
  let_shadowing.ml
  list.ml
  literals.ml
  match.ml
  match_fallthrough.ml
  names.ml
  names_primes.ml
  record_update.ml
  records.ml
  sequences.ml
  $ caramel compile apply.ml
  File "apply.ml", line 6, characters 4-8:
  Warning 10: this expression should have type unit.
  File "apply.ml", line 7, characters 4-8:
  Warning 10: this expression should have type unit.
  File "apply.ml", line 22, characters 2-6:
  Warning 21: this statement never returns (or has an unsound type.)
  File "apply.ml", line 23, characters 2-8:
  Warning 21: this statement never returns (or has an unsound type.)
  File "apply.ml", line 24, characters 2-10:
  Warning 21: this statement never returns (or has an unsound type.)
  File "apply.ml", line 25, characters 2-12:
  Warning 21: this statement never returns (or has an unsound type.)
  Compiling apply__funs.erl	OK
  Compiling apply.erl	OK
  $ cat apply.erl
  % Source code generated with Caramel.
  -module(apply).
  
  -export([abs_diff_times/3]).
  -export([f/1]).
  -export([f1/1]).
  -export([f2/2]).
  -export([f3/3]).
  -export([f4/4]).
  -export([lambda/0]).
  -export([partial_application/0]).
  -export([run/0]).
  
  -spec f(_) -> _.
  f(X) -> f(X).
  
  -spec f1(_) -> _.
  f1(X) -> f([X | []]).
  
  -spec f2(A, A) -> _.
  f2(X, Y) -> f([X | [Y | []]]).
  
  -spec f3(A, A, A) -> _.
  f3(X, Y, Z) -> f([X | [Y | [Z | []]]]).
  
  -spec f4(A, A, A, A) -> _.
  f4(W, X, Y, Z) -> f([W | [X | [Y | [Z | []]]]]).
  
  -spec run() -> integer().
  run() ->
    f1(1),
    f2(1, 2),
    f3(1, 2, 3),
    f4(1, 2, 3, 4),
    apply__funs:apply_fun().
  
  -spec lambda() -> integer().
  lambda() ->
    F = fun
      () -> 1
    end,
    F_prime = fun
      (X) -> erlang:'+'(1, X)
    end,
    F_prime_prime = fun
      (X, Y) -> erlang:'+'(erlang:'+'(1, X), Y)
    end,
    F(),
    F_prime(1),
    F_prime_prime(1, 2).
  
  -spec abs_diff_times(integer(), integer(), integer()) -> integer().
  abs_diff_times(X, Y, Z) -> erlang:'*'(erlang:abs(erlang:'-'(X, Y)), Z).
  
  -spec partial_application() -> integer().
  partial_application() ->
    F = fun
      (Caramel@1, Caramel@2) -> abs_diff_times(3, Caramel@1, Caramel@2)
    end,
    F(-1, 2).
  
  
  $ caramel compile binding_on_match.ml
  File "binding_on_match.ml", line 4, characters 57-68:
  Warning 11: this match case is unused.
  File "binding_on_match.ml", line 10, characters 50-57:
  Warning 11: this match case is unused.
  File "binding_on_match.ml", line 10, characters 68-69:
  Warning 11: this match case is unused.
  Compiling binding_on_match.erl	OK
  $ cat binding_on_match.erl
  % Source code generated with Caramel.
  -module(binding_on_match).
  -export_type([int_pair/0]).
  
  -export([match_atoms/0]).
  -export([match_list/0]).
  -export([match_record/0]).
  -export([match_tuples/0]).
  
  -type int_pair() :: #{ fst => integer()
                       , snd => integer()
                       }.
  
  -spec match_record() -> boolean().
  match_record() ->
    case #{ fst => 0
   , snd => 1
   } of
      #{ fst := Fst, snd := Snd } -> true;
      #{ fst := X } -> true
    end.
  
  -spec match_list() -> boolean().
  match_list() ->
    case [0 | [1 | []]] of
      [] -> true;
      [X | []] -> true;
      [X | Xs] -> true
    end.
  
  -spec match_tuples() -> boolean().
  match_tuples() ->
    case {1, true, <<"hello">>} of
      {X, Y, Z} -> true;
      {X, _, _} -> true;
      X -> true
    end.
  
  -spec match_atoms() -> boolean().
  match_atoms() ->
    case hello of
      X -> true
    end.
  
  
  $ caramel compile funref.ml
  Compiling funref__nested.erl	OK
  Compiling funref.erl	OK
  $ cat funref.erl
  % Source code generated with Caramel.
  -module(funref).
  
  -export([add/2]).
  -export([call_op_2/3]).
  -export([do_add/2]).
  -export([do_nested_add/2]).
  -export([f/1]).
  -export([g/0]).
  
  -spec f(fun(() -> A)) -> A.
  f(G) -> G().
  
  -spec g() -> _.
  g(_) -> f(fun g/0).
  
  -spec add(integer(), integer()) -> integer().
  add(X, Y) -> erlang:'+'(X, Y).
  
  -spec call_op_2(fun((A, B) -> C), A, B) -> C.
  call_op_2(F, X, Y) -> F(X, Y).
  
  -spec do_add(integer(), integer()) -> integer().
  do_add(X, Y) -> call_op_2(fun add/2, X, Y).
  
  -spec do_nested_add(integer(), integer()) -> integer().
  do_nested_add(X, Y) -> call_op_2(fun funref__nested:add/2, X, Y).
  
  
  $ caramel compile let_bindings.ml
  Compiling let_bindings.erl	OK
  $ cat let_bindings.erl
  % Source code generated with Caramel.
  -module(let_bindings).
  
  -export([let_ignore/0]).
  -export([let_many/0]).
  -export([let_nested/3]).
  -export([let_nested_another/1]).
  -export([let_one/0]).
  
  -spec let_one() -> integer().
  let_one() ->
    A = 1,
    A.
  
  -spec let_ignore() -> integer().
  let_ignore() ->
    1,
    2.
  
  -spec let_many() -> integer().
  let_many() ->
    A = 1,
    B = 2,
    C = 3,
    D = 4,
    erlang:'+'(erlang:'+'(erlang:'+'(A, B), C), D).
  
  -spec let_nested(fun((integer()) -> A), fun(() -> _), fun(() -> _)) -> A.
  let_nested(F, G, H) ->
    A = begin
      G(),
      B = begin
        H(),
        C = 1,
        erlang:'+'(C, 1)
      end,
      erlang:'+'(B, 1)
    end,
    F(A).
  
  -spec let_nested_another(_) -> integer().
  let_nested_another(_) ->
    One = 1,
    Three = begin
      Two = erlang:'+'(One, 1),
      erlang:'+'(Two, 1)
    end,
    Three.
  
  
  $ caramel compile list.ml
  File "list.ml", line 7, characters 9-21:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  []
  File "list.ml", line 9, characters 9-21:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  []
  File "list.ml", line 11, characters 9-26:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (_::[]|[])
  Compiling list.erl	OK
  $ cat list.erl
  % Source code generated with Caramel.
  -module(list).
  
  -export([at_2/1]).
  -export([concat/2]).
  -export([cons/2]).
  -export([empty/0]).
  -export([head/1]).
  -export([pair/1]).
  -export([tail/1]).
  
  -spec empty() -> list(_).
  empty() -> [].
  
  -spec pair(A) -> list(A).
  pair(X) -> [X | [X | []]].
  
  -spec cons(A, list(A)) -> list(A).
  cons(X, Y) -> [X | Y].
  
  -spec head(list(A)) -> A.
  head([X | _]) -> X.
  
  -spec tail(list(A)) -> list(A).
  tail([_ | X]) -> X.
  
  -spec at_2(list(A)) -> A.
  at_2([_ | [X | _]]) -> X.
  
  -spec concat(list(A), list(A)) -> list(A).
  concat(A, B) -> erlang:'++'(A, B).
  
  
  $ caramel compile literals.ml
  Compiling literals.erl	OK
  $ cat literals.erl
  % Source code generated with Caramel.
  -module(literals).
  
  -export([bool_false/0]).
  -export([bool_true/0]).
  -export([character/0]).
  -export([float/0]).
  -export([float_without_trailing_zero/0]).
  -export([integer/0]).
  -export([string/0]).
  
  -spec integer() -> integer().
  integer() -> 1.
  
  -spec float() -> float().
  float() -> 1.0.
  
  -spec float_without_trailing_zero() -> float().
  float_without_trailing_zero() -> 1.0.
  
  -spec character() -> char().
  character() -> 'c'.
  
  -spec string() -> binary().
  string() -> <<"hello">>.
  
  -spec bool_true() -> boolean().
  bool_true() -> true.
  
  -spec bool_false() -> boolean().
  bool_false() -> true.
  
  
  $ caramel compile match.ml
  File "match.ml", line 5, characters 19-41:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  0
  File "match.ml", lines 8-14, characters 2-17:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  ""
  File "match.ml", lines 19-22, characters 2-23:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  ({fst=10; snd=0}|{fst=1; snd=0})
  File "match.ml", lines 25-30, characters 2-20:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (0::0::_|0::[]|2::_)
  File "match.ml", line 28, characters 4-9:
  Warning 11: this match case is unused.
  File "match.ml", line 30, characters 4-12:
  Warning 11: this match case is unused.
  File "match.ml", lines 33-36, characters 2-28:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (0, _, _)
  File "match.ml", line 35, characters 4-14:
  Warning 11: this match case is unused.
  File "match.ml", line 36, characters 4-20:
  Warning 11: this match case is unused.
  Compiling match.erl	OK
  $ cat match.erl
  % Source code generated with Caramel.
  -module(match).
  -export_type([int_pair/0]).
  
  -export([match_atoms/0]).
  -export([match_ignore/0]).
  -export([match_int/0]).
  -export([match_list/0]).
  -export([match_record/0]).
  -export([match_str/0]).
  -export([match_tuples/0]).
  -export([match_unit/0]).
  
  -type int_pair() :: #{ fst => integer()
                       , snd => integer()
                       }.
  
  -spec match_unit() -> boolean().
  match_unit() ->
    case ok of
      ok -> true
    end.
  
  -spec match_ignore() -> boolean().
  match_ignore() ->
    case ok of
      _ -> true
    end.
  
  -spec match_int() -> boolean().
  match_int() ->
    case 1 of
      1 -> true
    end.
  
  -spec match_str() -> boolean().
  match_str() ->
    case <<"hello">> of
      <<"xavier">> -> true;
      <<"remy">> -> true;
      <<"gal">> -> true;
      <<"mike">> -> true;
      <<"robert">> -> true;
      <<"joe">> -> true
    end.
  
  -spec match_record() -> boolean().
  match_record() ->
    case #{ fst => 0
   , snd => 1
   } of
      #{ fst := 10, snd := 10 } -> true;
      #{ fst := 0 } -> true;
      #{ snd := 1 } -> true
    end.
  
  -spec match_list() -> boolean().
  match_list() ->
    case [0 | [1 | []]] of
      [] -> true;
      [1 | Xs] -> true;
      [1 | []] -> true;
      [0 | [1 | _]] -> true;
      [0 | [1 | []]] -> true
    end.
  
  -spec match_tuples() -> boolean().
  match_tuples() ->
    case {1, true, <<"hello">>} of
      {1, _, _} -> true;
      {1, true, _} -> true;
      {1, true, <<"hello">>} -> true
    end.
  
  -spec match_atoms() -> boolean().
  match_atoms() ->
    case hello of
      xavier -> true;
      joe -> true;
      _ -> false
    end.
  
  
  $ caramel compile names.ml
  File "names.ml", line 13, characters 2-13:
  Warning 10: this expression should have type unit.
  File "names.ml", line 2, characters 6-7:
  Warning 26: unused variable x.
  File "names.ml", line 17, characters 6-7:
  Warning 26: unused variable x.
  Compiling names__nested.erl	OK
  Compiling names.erl	OK
  $ cat names.erl
  % Source code generated with Caramel.
  -module(names).
  
  -export([run_local/0]).
  -export([run_nested/0]).
  -export([run_nested_ambiguous/0]).
  
  -spec run_local() -> atom
         .
  run_local() ->
    X = fun run_local/0,
    Y = atom,
    Y.
  
  -spec run_nested() -> {version, kind_of_working
          }
          .
  run_nested() ->
    names__nested:x(),
    names__nested:w().
  
  -spec run_nested_ambiguous() -> {compiler, binary()}
                    .
  run_nested_ambiguous() ->
    X = fun
      () -> 1
    end,
    names__nested:x().
  
  
  $ caramel compile records.ml
  Compiling records.erl	OK
  $ cat records.erl
  % Source code generated with Caramel.
  -module(records).
  -export_type([pair/1]).
  
  -export([flatten_first/1]).
  -export([fst/1]).
  -export([map/3]).
  -export([pair/2]).
  -export([snd/1]).
  -export([swap/1]).
  -export([swap_from_expr/2]).
  
  -type pair(A) :: #{ fst => A
                    , snd => A
                    }.
  
  -spec pair(A, A) -> pair(A).
  pair(X, Y) ->
    #{ fst => X
     , snd => Y
     }.
  
  -spec fst(pair(A)) -> A.
  fst(#{ fst := Fst }) -> Fst.
  
  -spec snd(pair(A)) -> A.
  snd(#{ snd := Snd }) -> Snd.
  
  -spec swap(pair(A)) -> pair(A).
  swap(P) ->
    #{ fst => maps:get(snd, P)
     , snd => maps:get(fst, P)
     }.
  
  -spec map(fun((A) -> B), fun((A) -> B), pair(A)) -> pair(B).
  map(F, G, #{ fst := Fst, snd := Snd }) ->
    #{ fst => F(Fst)
     , snd => G(Snd)
     }.
  
  -spec swap_from_expr(A, fun((A) -> pair(B))) -> pair(B).
  swap_from_expr(P, F) ->
    #{ fst => maps:get(snd, F(P))
     , snd => maps:get(fst, F(P))
     }.
  
  -spec flatten_first(pair(pair(pair(A)))) -> pair(A).
  flatten_first(P) ->
    #{ fst => maps:get(fst, maps:get(fst, maps:get(fst, P)))
     , snd => maps:get(snd, maps:get(fst, maps:get(fst, P)))
     }.
  
  
  $ caramel compile let_shadowing.ml
  We have found that the variable name X is being shadowed.
  
  This is currently not supported.
  \n
  [1]
  $ cat let_shadowing.erl
  cat: let_shadowing.erl: No such file or directory
  [1]

  $ caramel compile names_primes.ml
  Compiling names_primes.erl	OK
  $ cat names_primes.erl
  % Source code generated with Caramel.
  -module(names_primes).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() ->
    X = 1,
    X_prime = erlang:'+'(X, 1),
    X_prime_prime = erlang:'+'(X_prime, 2),
    X_prime_prime.
  
  
  $ caramel compile let_rec.ml
  We have found a let rec binding within a function.
  
  This is currently not supported.
  \n
  [1]
  $ cat let_rec.erl
  cat: let_rec.erl: No such file or directory
  [1]
  $ caramel compile record_update.ml
  Compiling record_update.erl	OK
  $ cat record_update.erl
  % Source code generated with Caramel.
  -module(record_update).
  -export_type([t/0]).
  
  -export([f/0]).
  
  -type t() :: #{ x => integer()
                , y => integer()
                , z => integer()
                }.
  
  -spec f() -> t().
  f() ->
    A = #{ x => 0
     , y => 0
     , z => 0
     },
    A#{ x := 2
     , y := 2
     }.
  
  
  $ caramel compile match_fallthrough.ml
  We have found a case expression that falls through to the next case, like:
  
    match x with
    | 0 | 1 -> true   <--- this branch falls through
    | _ -> false
  
  Since these patterns are not possible in Erlang, Caramel does not support them
  at the moment.
  \n
  [1]
  $ cat match_fallthrough.erl
  cat: match_fallthrough.erl: No such file or directory
  [1]
  $ caramel compile sequences.ml
  Compiling sequences.erl	OK
  $ cat sequences.erl
  % Source code generated with Caramel.
  -module(sequences).
  
  -export([direct_sequence/1]).
  -export([nested/1]).
  
  -spec direct_sequence(A) -> A.
  direct_sequence(X) ->
    X,
    X,
    X.
  
  -spec nested(A) -> A.
  nested(X) ->
    begin
      begin
        X,
        X
      end,
      X
    end,
    begin
      begin
        X,
        X
      end,
      X
    end,
    X.
  
  
