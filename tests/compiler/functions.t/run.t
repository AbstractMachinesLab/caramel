  $ ls *.ml *.mli *.re *.rei
  annotated.ml
  basic.ml
  basic.re
  guard_unsupported.ml
  guards.ml
  hello_joe.ml
  ignored_arguments.ml
  labeled_arguments.ml
  multiple_clauses.ml
  partial_functions.ml
  pattern_aliases.ml
  qualified_calls.ml
  qualified_calls_helper.ml
  redefine.ml
  references.ml
  sequencing.ml
  uncurry.ml
  uncurry.mli
  uncurry.re
  uncurry.rei

  $ caramel compile annotated.ml
  Compiling annotated.erl	OK
  $ cat annotated.erl
  % Source code generated with Caramel.
  -module(annotated).
  
  -export([a/1]).
  
  -spec a(integer()) -> integer().
  a(X_17) -> X_17.
  
  

  $ caramel compile basic.ml
  Compiling basic.erl	OK
  $ cat basic.erl
  % Source code generated with Caramel.
  -module(basic).
  
  -export([combine/2]).
  -export([ignore/0]).
  -export([pair/2]).
  
  -spec pair(A, B) -> {A, B}.
  pair(X_17, Y_18) -> {X_17, Y_18}.
  
  -spec combine({A, B}, {C, D}) -> {{A, C}, {B, D}}.
  combine({A_21, B_22}, {C_23, D_24}) -> {{A_21, C_23}, {B_22, D_24}}.
  
  -spec ignore() -> ok.
  ignore() -> ok.
  
  
  $ caramel compile basic.re
  Compiling basic.erl	OK
  $ caramel compile hello_joe.ml
  Compiling hello_joe.erl	OK
  $ cat hello_joe.erl
  % Source code generated with Caramel.
  -module(hello_joe).
  
  -export([hello/0]).
  
  -spec hello() -> ok.
  hello() ->
    Text_17 = <<"hello, joe!">>,
    io:format(<<"~p">>, [Text_17 | []]).
  
  

  $ caramel compile ignored_arguments.ml
  Compiling ignored_arguments.erl	OK
  $ cat ignored_arguments.erl
  % Source code generated with Caramel.
  -module(ignored_arguments).
  
  -export([fst/1]).
  -export([left/2]).
  -export([right/2]).
  -export([snd/1]).
  
  -spec left(A, _) -> A.
  left(L_17, _) -> L_17.
  
  -spec right(_, B) -> B.
  right(_, R_21) -> R_21.
  
  -spec fst({A, _}) -> A.
  fst({A_25, _}) -> A_25.
  
  -spec snd({_, B}) -> B.
  snd({_, B_29}) -> B_29.
  
  

  $ caramel compile labeled_arguments.ml
  Compiling labeled_arguments.erl	OK
  $ cat labeled_arguments.erl
  % Source code generated with Caramel.
  -module(labeled_arguments).
  
  -export([concat/2]).
  -export([run/0]).
  
  -spec concat(binary(), binary()) -> binary().
  concat(A_17, B_18) -> caramel_runtime:binary_concat(A_17, B_18).
  
  -spec run() -> boolean().
  run() ->
    S1_21 = concat(<<"ocaml">>, <<"erlang">>),
    S2_22 = concat(<<"erlang">>, <<"ocaml">>),
    erlang:'=:='(S1_21, S2_22).
  
  

  $ caramel compile multiple_clauses.ml
  File "multiple_clauses.ml", line 1, characters 22-34:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  false
  Compiling multiple_clauses.erl	OK
  $ cat multiple_clauses.erl
  % Source code generated with Caramel.
  -module(multiple_clauses).
  
  -export([iff_using_function/1]).
  -export([iff_using_headers/3]).
  -export([iff_using_if/3]).
  -export([iff_using_match/3]).
  
  -spec iff_using_headers(boolean(), A, _) -> A.
  iff_using_headers(true, F_17, _) -> F_17.
  
  -spec iff_using_function({boolean(), A, A}) -> A.
  iff_using_function({false, _, F_22}) -> F_22;
  iff_using_function({true, F_23, _}) -> F_23.
  
  -spec iff_using_if(boolean(), fun(() -> A), fun(() -> A)) -> A.
  iff_using_if(Cond_27, T_28, F_29) ->
    case Cond_27 of
      true -> T_28();
      false -> F_29()
    end.
  
  -spec iff_using_match(boolean(), A, A) -> A.
  iff_using_match(T_32, F_33, G_34) ->
    case T_32 of
      true -> F_33;
      false -> G_34
    end.
  
  

  $ caramel compile partial_functions.ml
  File "partial_functions.ml", line 1, characters 9-21:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  []
  File "partial_functions.ml", line 3, characters 9-23:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  []
  File "partial_functions.ml", line 5, characters 11-20:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (_::_::_|[])
  File "partial_functions.ml", line 7, characters 9-26:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (_::[]|[])
  File "partial_functions.ml", line 9, characters 9-31:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (_::_::[]|_::[]|[])
  Compiling partial_functions.erl	OK
  $ cat partial_functions.erl
  % Source code generated with Caramel.
  -module(partial_functions).
  
  -export([at_2/1]).
  -export([at_3/1]).
  -export([head/1]).
  -export([one_el/1]).
  -export([tail/1]).
  
  -spec head(list(A)) -> A.
  head([X_17 | _]) -> X_17.
  
  -spec tail(list(A)) -> list(A).
  tail([_ | Xs_21]) -> Xs_21.
  
  -spec one_el(list(A)) -> A.
  one_el([X_25 | []]) -> X_25.
  
  -spec at_2(list(A)) -> A.
  at_2([_ | [X_29 | _]]) -> X_29.
  
  -spec at_3(list(A)) -> A.
  at_3([_ | [_ | [X_33 | _]]]) -> X_33.
  
  

  $ caramel compile pattern_aliases.ml
  File "pattern_aliases.ml", line 1, characters 15-49:
  Warning 8: this pattern-matching is not exhaustive.
  Here is an example of a case that is not matched:
  (_::_::_|[])
  Compiling pattern_aliases.erl	OK
  $ cat pattern_aliases.erl
  % Source code generated with Caramel.
  -module(pattern_aliases).
  
  -export([with_alias/1]).
  
  -spec with_alias(list(boolean())) -> list(boolean()).
  with_alias([X_17 | []] = L_18) ->
    case X_17 of
      true -> L_18;
      false -> []
    end.
  
  
  $ caramel compile qualified_calls_helper.ml qualified_calls.ml 
  Compiling qualified_calls_helper__nested.erl	OK
  Compiling qualified_calls_helper.erl	OK
  Compiling qualified_calls__nested.erl	OK
  Compiling qualified_calls.erl	OK
  $ cat qualified_calls*.erl
  % Source code generated with Caramel.
  -module(qualified_calls).
  
  -export([add/1]).
  -export([add_twice/1]).
  -export([call_nested/1]).
  -export([call_other/1]).
  -export([call_other_nested/1]).
  -export([double/2]).
  
  -spec add(A) -> A.
  add(X_17) -> X_17.
  
  -spec double(fun((A) -> A), A) -> A.
  double(F_20, X_21) -> F_20(F_20(X_21)).
  
  -spec add_twice(A) -> A.
  add_twice(X_24) -> double(fun add/1, X_24).
  
  -spec call_nested(boolean()) -> ok.
  call_nested(X_31) -> qualified_calls__nested:f(X_31).
  
  -spec call_other(_) -> ok.
  call_other(X_34) -> qualified_calls_helper:f(X_34).
  
  -spec call_other_nested(_) -> ok.
  call_other_nested(X_38) -> qualified_calls_helper__nested:f(X_38).
  
  
  % Source code generated with Caramel.
  -module(qualified_calls__nested).
  
  -export([f/1]).
  
  -spec f(boolean()) -> ok.
  f(X_27) ->
    case X_27 of
      true -> ok;
      false -> ok
    end.
  
  
  % Source code generated with Caramel.
  -module(qualified_calls_helper).
  
  -export([f/1]).
  
  -spec f(_) -> ok.
  f(_x_17) -> ok.
  
  
  % Source code generated with Caramel.
  -module(qualified_calls_helper__nested).
  
  -export([f/1]).
  
  -spec f(_) -> ok.
  f(_x_19) -> ok.
  
  

  $ caramel compile sequencing.ml
  Compiling sequencing.erl	OK
  $ cat sequencing.erl
  % Source code generated with Caramel.
  -module(sequencing).
  
  -export([run/0]).
  
  -spec run() -> ok.
  run() ->
    A_17 = 1,
    B_18 = 2,
    begin
      io:format(<<"Hello there\n">>, []),
      io:format(<<"Today we are adding ~p and ~p\n">>, [A_17 | [B_18 | []]]),
      io:format(<<"Here we go: ~p\n">>, [erlang:'+'(A_17, B_18) | []]),
      io:format(<<"*micdrop*">>, [])
    end.
  
  

  $ caramel compile uncurry.mli uncurry.ml 
  Compiling uncurry.erl	OK
  $ cat uncurry.erl
  % Source code generated with Caramel.
  -module(uncurry).
  -export_type([defer/1]).
  -export_type([ignore/0]).
  
  -export([add/2]).
  -export([add_really_slow/1]).
  -export([add_slow/2]).
  -export([ignore/1]).
  
  -type ignore() :: fun((ok) -> ok).
  
  -type defer(A) :: fun((ok) -> A).
  
  -spec ignore(_, ok) -> ok.
  ignore(_x_18, ok) -> ok.
  
  -spec add(integer(), _) -> integer().
  add(X_23, Y_24) -> erlang:'+'(X_23, X_23).
  
  -spec add_slow(integer(), integer(), ok) -> integer().
  add_slow(X_27, Y_28, ok) -> erlang:'+'(X_27, Y_28).
  
  -spec add_really_slow(integer(), ok, integer(), ok) -> integer().
  add_really_slow(X_32, ok, Y_33, ok) -> erlang:'+'(X_32, Y_33).
  
  

  $ caramel compile uncurry.rei uncurry.re
  Compiling uncurry.erl	OK

  $ caramel compile redefine.ml
  We have found 2 definitions of the function: f in module redefine.
  
  This is currently not supported.
  \n
  [1]
  $ cat redefine.erl
  cat: redefine.erl: No such file or directory
  [1]
  $ caramel compile references.ml
  Compiling references.erl	OK
  $ cat references.erl
  % Source code generated with Caramel.
  -module(references).
  
  -export([operator/1]).
  -export([transorm/1]).
  
  -spec operator(_) -> integer().
  operator(_) -> lists:foldl(fun erlang:'+'/2, 1, [1 | [2 | [3 | []]]]).
  
  -spec transorm(_) -> list(char()).
  transorm(_) ->
    Transforms_53 = [fun binary:first/1 | [fun binary:last/1 | []]],
    lists:map(fun
    (G_70) -> G_70(<<"Hello World">>)
  end, Transforms_53).
  
  
  $ caramel compile guards.ml
  Compiling guards.erl	OK
  $ cat guards.erl
  % Source code generated with Caramel.
  -module(guards).
  
  -export([f/1]).
  
  -spec f(integer()) -> integer().
  f(X_50) ->
    case X_50 of
      Y_51 when is_number(Y_51) -> 3;
      Y_52 when erlang:is_binary(Y_52) -> 3;
      Y_53 when erlang:'>'(Y_53, 3) -> 3;
      Y_54 when erlang:'=<'(Y_54, 3) -> 3;
      _ -> 4
    end.
  
  
  $ caramel compile guard_unsupported.ml
  We have found a guard expression that is not one of the allowlisted Erlang BIFs.
  
  This is currently not supported.
  \n
  [1]
  $ cat guard_unsupported.erl
  cat: guard_unsupported.erl: No such file or directory
  [1]
