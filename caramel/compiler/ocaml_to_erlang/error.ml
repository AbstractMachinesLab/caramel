open Erlang.Ast_helper

exception Unsupported_feature

exception Unsupported_top_level_module_value

exception Unsupported_expression

let ppf = Format.err_formatter

let file_a_bug =
  {| If you think this is a bug, please file an issue here: https://github.com/AbstractMachinesLab/caramel/issues/new |}

let unsupported_fallthrough_cases () =
  Format.fprintf ppf
    {|We have found a case expression that falls through to the next case, like:

  match x with
  | 0 | 1 -> true   <--- this branch falls through
  | _ -> false

Since these patterns are not possible in Erlang, Caramel does not support them
at the moment.
\n
|};
  exit 1

let unsupported_let_rec_inside_of_function_body () =
  Format.fprintf ppf
    {|We have found a let rec binding within a function.

This is currently not supported.
\n
|};
  exit 1

let unsupported_guard_expression () =
  Format.fprintf ppf
    {|We have found a guard expression that is not one of the allowlisted Erlang BIFs.

This is currently not supported.
\n
|};
  exit 1

let redefining_function ~fn_name ~module_name =
  Format.fprintf ppf
    {|We have found 2 definitions of the function: %s in module %s.

This is currently not supported.
\n
|}
    (Atom.to_string fn_name)
    (Atom.to_string module_name);
  exit 1

let referenced_undeclared_function name =
  Format.fprintf ppf "Referencing undeclared function: %s" (Atom.to_string name);
  Format.fprintf ppf "\n\n%s" file_a_bug;
  exit 1

let unsupported_path path =
  Format.fprintf ppf "We have found an unsupported path: ";
  Path.print ppf path;
  Format.fprintf ppf "\n\n%s" file_a_bug;
  exit 1

let unsupported_empty_identifier () =
  Format.fprintf ppf
    {|It appears we have found an empty identifier! This seems like a bug in the
translation process. Could you please report this here?

https://github.com/AbstractMachinesLab/caramel/issues/new

Thank you!
\n
|};
  exit 1

let unsupported_top_level_module_value () =
  Format.fprintf ppf
    {|While OCaml allows you to define module-level variables,
these are not valid declarations at the module-leve in Erlang.

Caramel could have translated them into a function, so that `let x = 1` became
`x() -> 1` in Erlang, an every instance of `x` would become `x()`.

Unfortunately this will not guarantee the preservation of the semantics during translation :(

For example, if `let x = print_string "hello"; 1` was translated to Erlang, it
would be translated to `x() -> io:format("~p", ["hello"]), 1.`

Now the side-effect of printing would occur every time you use the variable `x`.

You can, however, turn your constants into a function of a unit, so that
`let x = 1` becomes `let x () = `.

Caramel will happily and safely compile that.
\n
|};
  exit 1

let unsupported_feature feature =
  Format.fprintf ppf "Unsupported feature: %s -- %s\n"
    (match feature with
    | `Absent_polymorphic_variants ->
        "polymorphic variant constriants for absence"
    | `Type_constructs ->
        "Type subsitution, universal quantification, objects, or packs"
    | `Uncurryable_functions ->
        "Functions that can not be curried (although this feels more like a \
         bug in Caramel!)"
    | `Type_objects_and_packages -> "Object-oriented OCaml and Packs"
    | `Record_update -> "Record updates"
    | `Let_and_bindings -> "let-and bindings")
    file_a_bug;
  exit 1

let unsupported_expression expr =
  let open Typedtree in
  Format.fprintf ppf "Unsupported expression: %s -- %s\n"
    (match expr.exp_desc with
    | Texp_try _ -> "Texp_try"
    | Texp_setfield _ -> "Texp_setfield"
    | Texp_array _ -> "Texp_array"
    | Texp_while _ -> "Texp_while"
    | Texp_for _ -> "Texp_for"
    | Texp_send _ -> "Texp_send"
    | Texp_new _ -> "Texp_new"
    | Texp_instvar _ -> "Texp_instvar"
    | Texp_setinstvar _ -> "Texp_setinstvar"
    | Texp_override _ -> "Texp_override"
    | Texp_letmodule _ -> "Texp_letmodule"
    | Texp_letexception _ -> "Texp_letexception"
    | Texp_assert _ -> "Texp_assert"
    | Texp_lazy _ -> "Texp_lazy"
    | Texp_object _ -> "Texp_object"
    | Texp_pack _ -> "Texp_pack"
    | Texp_letop _ -> "Texp_letop"
    | Texp_unreachable -> "Texp_unreachable"
    | Texp_extension_constructor _ -> "Texp_extension_constructor"
    | Texp_open _ -> "Texp_open"
    | _ -> "<hm, this was empty? please do open an issue>")
    file_a_bug;
  exit 1
