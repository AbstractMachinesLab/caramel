  $ ls *.ml *.mli
  empty.ml
  functors.ml
  include.ml
  let_open.ml
  nested.ml
  no_exports.ml
  no_exports.mli
  sig.ml
  sig.mli
  sig_dep.ml
  simple_nested.ml
  $ caramel compile *.mli *.ml 
  Compiling functors.erl	OK
  Compiling include__a.erl	OK
  Compiling include.erl	OK
  Compiling let_open__a.erl	OK
  Compiling nested__a__c.erl	OK
  Compiling nested__a.erl	OK
  Compiling nested__b.erl	OK
  Compiling sig.erl	OK
  Compiling simple_nested__a.erl	OK
  Compiling simple_nested__b.erl	OK
  Compiling simple_nested.erl	OK
  $ echo $?
  0
  $ cat *.erl
  % Source code generated with Caramel.
  -module(functors).
  
  -export([run/0]).
  
  -spec run() -> intadd:t().
  run() ->
    Zero_45 = empty(),
    One_46 = concat(Zero_45, 1),
    Two_47 = intadd:'<+>'(One_46, 1),
    Two_47.
  
  
  % Source code generated with Caramel.
  -module(include).
  
  -export([f/0]).
  -export([run/0]).
  
  -spec run() -> integer().
  run() -> f().
  
  
  % Source code generated with Caramel.
  -module(include__a).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(let_open__a).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(nested__a).
  
  -export([a/0]).
  
  -spec a() -> boolean().
  a() -> true.
  
  
  % Source code generated with Caramel.
  -module(nested__a__c).
  
  -export([c/0]).
  
  -spec c() -> boolean().
  c() -> true.
  
  -spec internal_c() -> boolean().
  internal_c() -> true.
  
  
  % Source code generated with Caramel.
  -module(nested__b).
  
  -export([b/2]).
  
  -spec b(boolean(), boolean()) -> boolean().
  b(X_33, Y_34) -> erlang:'and'(X_33, Y_34).
  
  
  % Source code generated with Caramel.
  -module(sig).
  
  -export([inc/1]).
  
  -spec inc(integer()) -> integer().
  inc(X_17) -> erlang:'+'(X_17, 1).
  
  -spec hidden() -> ok.
  hidden() -> ok.
  
  -spec secret() -> ok.
  secret() -> ok.
  
  
  % Source code generated with Caramel.
  -module(simple_nested).
  
  -export([run/0]).
  
  -spec run() -> integer().
  run() -> erlang:'+'(simple_nested__a:f(), simple_nested__b:f()).
  
  
  % Source code generated with Caramel.
  -module(simple_nested__a).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() -> 0.
  
  
  % Source code generated with Caramel.
  -module(simple_nested__b).
  
  -export([f/0]).
  
  -spec f() -> integer().
  f() -> 2.
  
  -spec g() -> ok.
  g() -> ok.
  
  
