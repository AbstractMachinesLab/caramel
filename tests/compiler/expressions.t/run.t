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
  
  -export([f/1]).
  -export([f1/1]).
  -export([f2/2]).
  -export([f3/3]).
  -export([f4/4]).
  -export([lambda/0]).
  -export([run/0]).
  
  -spec f(_) -> _.
  f(X_29) -> f(X_29).
  
  -spec f1(_) -> _.
  f1(X_32) -> f([X_32 | []]).
  
  -spec f2(A, A) -> _.
  f2(X_35, Y_36) -> f([X_35 | [Y_36 | []]]).
  
  -spec f3(A, A, A) -> _.
  f3(X_39, Y_40, Z_41) -> f([X_39 | [Y_40 | [Z_41 | []]]]).
  
  -spec f4(A, A, A, A) -> _.
  f4(W_44, X_45, Y_46, Z_47) -> f([W_44 | [X_45 | [Y_46 | [Z_47 | []]]]]).
  
  -spec run() -> integer().
  run() ->
    f1(1),
    f2(1, 2),
    f3(1, 2, 3),
    f4(1, 2, 3, 4),
    apply__funs:apply_fun().
  
  -spec lambda() -> integer().
  lambda() ->
    F_53 = fun
      () -> 1
    end,
    F_prime_55 = fun
      (X_57) -> erlang:'+'(1, X_57)
    end,
    F_prime_prime_58 = fun
      (X_60, Y_61) -> erlang:'+'(erlang:'+'(1, X_60), Y_61)
    end,
    F_53(),
    F_prime_55(1),
    F_prime_prime_58(1, 2).
  
  
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
      #{ fst := Fst_20, snd := Snd_21 } -> true;
      #{ fst := X_22 } -> true
    end.
  
  -spec match_list() -> boolean().
  match_list() ->
    case [0 | [1 | []]] of
      [] -> true;
      [X_26 | []] -> true;
      [X_27 | Xs_28] -> true
    end.
  
  -spec match_tuples() -> boolean().
  match_tuples() ->
    case {1, true, <<"hello">>} of
      {X_32, Y_33, Z_34} -> true;
      {X_35, _, _} -> true;
      X_36 -> true
    end.
  
  -spec match_atoms() -> boolean().
  match_atoms() ->
    case hello of
      X_40 -> true
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
  f(G_22) -> G_22().
  
  -spec g() -> _.
  g(_) -> f(fun g/0).
  
  -spec add(integer(), integer()) -> integer().
  add(X_27, Y_28) -> erlang:'+'(X_27, Y_28).
  
  -spec call_op_2(fun((A, B) -> C), A, B) -> C.
  call_op_2(F_31, X_32, Y_33) -> F_31(X_32, Y_33).
  
  -spec do_add(integer(), integer()) -> integer().
  do_add(X_36, Y_37) -> call_op_2(fun add/2, X_36, Y_37).
  
  -spec do_nested_add(integer(), integer()) -> integer().
  do_nested_add(X_40, Y_41) -> call_op_2(fun funref__nested:add/2, X_40, Y_41).
  
  
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
    A_17 = 1,
    A_17.
  
  -spec let_ignore() -> integer().
  let_ignore() ->
    1,
    2.
  
  -spec let_many() -> integer().
  let_many() ->
    A_24 = 1,
    B_25 = 2,
    C_26 = 3,
    D_27 = 4,
    erlang:'+'(erlang:'+'(erlang:'+'(A_24, B_25), C_26), D_27).
  
  -spec let_nested(fun((integer()) -> A), fun(() -> _), fun(() -> _)) -> A.
  let_nested(F_31, G_32, H_33) ->
    A_34 = begin
      G_32(),
      B_35 = begin
        H_33(),
        C_36 = 1,
        erlang:'+'(C_36, 1)
      end,
      erlang:'+'(B_35, 1)
    end,
    F_31(A_34).
  
  -spec let_nested_another(_) -> integer().
  let_nested_another(_) ->
    One_39 = 1,
    Three_40 = begin
      Two_41 = erlang:'+'(One_39, 1),
      erlang:'+'(Two_41, 1)
    end,
    Three_40.
  
  
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
  pair(X_20) -> [X_20 | [X_20 | []]].
  
  -spec cons(A, list(A)) -> list(A).
  cons(X_23, Y_24) -> [X_23 | Y_24].
  
  -spec head(list(A)) -> A.
  head([X_27 | _]) -> X_27.
  
  -spec tail(list(A)) -> list(A).
  tail([_ | X_31]) -> X_31.
  
  -spec at_2(list(A)) -> A.
  at_2([_ | [X_35 | _]]) -> X_35.
  
  -spec concat(list(A), list(A)) -> list(A).
  concat(A_39, B_40) -> erlang:'++'(A_39, B_40).
  
  
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
      [1 | Xs_35] -> true;
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
    X_16 = fun run_local/0,
    Y_17 = atom,
    Y_17.
  
  -spec run_nested() -> {version, kind_of_working
          }
          .
  run_nested() ->
    names__nested:x(),
    names__nested:w().
  
  -spec run_nested_ambiguous() -> {compiler, binary()}
                    .
  run_nested_ambiguous() ->
    X_30 = fun
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
  pair(X_20, Y_21) ->
    #{ fst => X_20
     , snd => Y_21
     }.
  
  -spec fst(pair(A)) -> A.
  fst(#{ fst := Fst_24 }) -> Fst_24.
  
  -spec snd(pair(A)) -> A.
  snd(#{ snd := Snd_28 }) -> Snd_28.
  
  -spec swap(pair(A)) -> pair(A).
  swap(P_32) ->
    #{ fst => maps:get(snd, P_32)
     , snd => maps:get(fst, P_32)
     }.
  
  -spec map(fun((A) -> B), fun((A) -> B), pair(A)) -> pair(B).
  map(F_35, G_36, #{ fst := Fst_37, snd := Snd_38 }) ->
    #{ fst => F_35(Fst_37)
     , snd => G_36(Snd_38)
     }.
  
  -spec swap_from_expr(A, fun((A) -> pair(B))) -> pair(B).
  swap_from_expr(P_42, F_43) ->
    #{ fst => maps:get(snd, F_43(P_42))
     , snd => maps:get(fst, F_43(P_42))
     }.
  
  -spec flatten_first(pair(pair(pair(A)))) -> pair(A).
  flatten_first(P_46) ->
    #{ fst => maps:get(fst, maps:get(fst, maps:get(fst, P_46)))
     , snd => maps:get(snd, maps:get(fst, maps:get(fst, P_46)))
     }.
  
  
  $ caramel compile let_shadowing.ml
  Compiling let_shadowing.erl	OK
  $ cat let_shadowing.erl
  % Source code generated with Caramel.
  -module(let_shadowing).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() ->
    X_17 = 1,
    X_18 = erlang:'+'(X_17, 2),
    X_18.
  
  

  $ caramel compile names_primes.ml
  Compiling names_primes.erl	OK
  $ cat names_primes.erl
  % Source code generated with Caramel.
  -module(names_primes).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() ->
    X_17 = 1,
    X_prime_18 = erlang:'+'(X_17, 1),
    X_prime_prime_19 = erlang:'+'(X_prime_18, 2),
    X_prime_prime_19.
  
  
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
    A_21 = #{ x => 0
     , y => 0
     , z => 0
     },
    A_21#{ x := 2
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
  direct_sequence(X_17) ->
    X_17,
    X_17,
    X_17.
  
  -spec nested(A) -> A.
  nested(X_20) ->
    begin
      begin
        X_20,
        X_20
      end,
      X_20
    end,
    begin
      begin
        X_20,
        X_20
      end,
      X_20
    end,
    X_20.
  
  
