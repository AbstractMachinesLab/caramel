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
  pipe.ml
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
  a(X) -> X.
  
  

  $ caramel compile basic.ml
  Compiling basic.erl	OK
  $ cat basic.erl
  % Source code generated with Caramel.
  -module(basic).
  
  -export([combine/2]).
  -export([ignore/0]).
  -export([pair/2]).
  
  -spec pair(A, B) -> {A, B}.
  pair(X, Y) -> {X, Y}.
  
  -spec combine({A, B}, {C, D}) -> {{A, C}, {B, D}}.
  combine({A, B}, {C, D}) -> {{A, C}, {B, D}}.
  
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
    Text = <<"hello, joe!">>,
    io:format(<<"~p">>, [Text | []]).
  
  

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
  left(L, _) -> L.
  
  -spec right(_, B) -> B.
  right(_, R) -> R.
  
  -spec fst({A, _}) -> A.
  fst({A, _}) -> A.
  
  -spec snd({_, B}) -> B.
  snd({_, B}) -> B.
  
  

  $ caramel compile labeled_arguments.ml
  Compiling labeled_arguments.erl	OK
  $ cat labeled_arguments.erl
  % Source code generated with Caramel.
  -module(labeled_arguments).
  
  -export([concat/2]).
  -export([run/0]).
  
  -spec concat(binary(), binary()) -> binary().
  concat(A, B) -> caramel_runtime:binary_concat(A, B).
  
  -spec run() -> boolean().
  run() ->
    S1 = concat(<<"ocaml">>, <<"erlang">>),
    S2 = concat(<<"erlang">>, <<"ocaml">>),
    erlang:'=:='(S1, S2).
  
  

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
  iff_using_headers(true, F, _) -> F.
  
  -spec iff_using_function({boolean(), A, A}) -> A.
  iff_using_function({false, _, F}) -> F;
  iff_using_function({true, F, _}) -> F.
  
  -spec iff_using_if(boolean(), fun(() -> A), fun(() -> A)) -> A.
  iff_using_if(Cond, T, F) ->
    case Cond of
      true -> T();
      false -> F()
    end.
  
  -spec iff_using_match(boolean(), A, A) -> A.
  iff_using_match(T, F, G) ->
    case T of
      true -> F;
      false -> G
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
  head([X | _]) -> X.
  
  -spec tail(list(A)) -> list(A).
  tail([_ | Xs]) -> Xs.
  
  -spec one_el(list(A)) -> A.
  one_el([X | []]) -> X.
  
  -spec at_2(list(A)) -> A.
  at_2([_ | [X | _]]) -> X.
  
  -spec at_3(list(A)) -> A.
  at_3([_ | [_ | [X | _]]]) -> X.
  
  

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
  with_alias([X | []] = L) ->
    case X of
      true -> L;
      false -> []
    end.
  
  
  $ caramel compile pipe.ml
  Compiling pipe.erl	OK
  $ cat pipe.erl
  % Source code generated with Caramel.
  -module(pipe).
  
  -export([main/1]).
  -export([print_int/1]).
  -export([subtract/2]).
  
  -spec print_int(_) -> ok.
  print_int(Number) -> io:format(<<"~0tp~n">>, [Number | []]).
  
  -spec subtract(integer(), integer()) -> integer().
  subtract(X, Y) -> erlang:'-'(Y, X).
  
  -spec main(_) -> ok.
  main(_) ->
    Divide = fun
      (X, Y) -> erlang:'div'(Y, X)
    end,
    caramel_runtime:pipe(caramel_runtime:pipe(caramel_runtime:pipe(10, subtract(2)), Divide(4)), fun print_int/1).
  
  

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
  add(X) -> X.
  
  -spec double(fun((A) -> A), A) -> A.
  double(F, X) -> F(F(X)).
  
  -spec add_twice(A) -> A.
  add_twice(X) -> double(fun add/1, X).
  
  -spec call_nested(boolean()) -> ok.
  call_nested(X) -> qualified_calls__nested:f(X).
  
  -spec call_other(_) -> ok.
  call_other(X) -> qualified_calls_helper:f(X).
  
  -spec call_other_nested(_) -> ok.
  call_other_nested(X) -> qualified_calls_helper__nested:f(X).
  
  
  % Source code generated with Caramel.
  -module(qualified_calls__nested).
  
  -export([f/1]).
  
  -spec f(boolean()) -> ok.
  f(X) ->
    case X of
      true -> ok;
      false -> ok
    end.
  
  
  % Source code generated with Caramel.
  -module(qualified_calls_helper).
  
  -export([f/1]).
  
  -spec f(_) -> ok.
  f(_x) -> ok.
  
  
  % Source code generated with Caramel.
  -module(qualified_calls_helper__nested).
  
  -export([f/1]).
  
  -spec f(_) -> ok.
  f(_x) -> ok.
  
  

  $ caramel compile sequencing.ml
  Compiling sequencing.erl	OK
  $ cat sequencing.erl
  % Source code generated with Caramel.
  -module(sequencing).
  
  -export([run/0]).
  
  -spec run() -> ok.
  run() ->
    A = 1,
    B = 2,
    begin
      io:format(<<"Hello there\n">>, []),
      io:format(<<"Today we are adding ~p and ~p\n">>, [A | [B | []]]),
      io:format(<<"Here we go: ~p\n">>, [erlang:'+'(A, B) | []]),
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
  ignore(_x, ok) -> ok.
  
  -spec add(integer(), _) -> integer().
  add(X, Y) -> erlang:'+'(X, X).
  
  -spec add_slow(integer(), integer(), ok) -> integer().
  add_slow(X, Y, ok) -> erlang:'+'(X, Y).
  
  -spec add_really_slow(integer(), ok, integer(), ok) -> integer().
  add_really_slow(X, ok, Y, ok) -> erlang:'+'(X, Y).
  
  

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
    Transforms = [fun binary:first/1 | [fun binary:last/1 | []]],
    lists:map(fun
    (G) -> G(<<"Hello World">>)
  end, Transforms).
  
  
  $ caramel compile guards.ml
  Compiling guards.erl	OK
  $ cat guards.erl
  % Source code generated with Caramel.
  -module(guards).
  
  -export([f/1]).
  
  -spec f(integer()) -> integer().
  f(X) ->
    case X of
      Y when is_number(Y) -> 3;
      Y when erlang:is_binary(Y) -> 3;
      Y when erlang:'>'(Y, 3) -> 3;
      Y when erlang:'=<'(Y, 3) -> 3;
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
