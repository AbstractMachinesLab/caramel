open Erlang.Ast_helper

let erlang = Name.atom (Atom.mk "erlang")

let guards =
  [
    Name.atom (Atom.mk "!");
    Name.atom (Atom.mk "*");
    Name.atom (Atom.mk "+");
    Name.atom (Atom.mk "++");
    Name.atom (Atom.mk "-");
    Name.atom (Atom.mk "--");
    Name.atom (Atom.mk "/");
    Name.atom (Atom.mk "/=");
    Name.atom (Atom.mk ":=");
    Name.atom (Atom.mk "=/=");
    Name.atom (Atom.mk "=:=");
    Name.atom (Atom.mk "=<");
    Name.atom (Atom.mk "==");
    Name.atom (Atom.mk ">");
    Name.atom (Atom.mk ">=");
    Name.atom (Atom.mk "is_atom");
    Name.atom (Atom.mk "is_binary");
    Name.atom (Atom.mk "is_bitstring");
    Name.atom (Atom.mk "is_boolean");
    Name.atom (Atom.mk "is_float");
    Name.atom (Atom.mk "is_integer");
    Name.atom (Atom.mk "is_list");
    Name.atom (Atom.mk "is_map");
    Name.atom (Atom.mk "is_number");
    Name.atom (Atom.mk "is_pid");
    Name.atom (Atom.mk "is_port");
    Name.atom (Atom.mk "is_process_alive");
    Name.atom (Atom.mk "is_reference");
    Name.atom (Atom.mk "is_tuple");
    Name.atom (Atom.mk "is_tuple");
  ]
  |> List.concat_map (fun f -> [ f; Name.qualified ~m:erlang ~f ])

let is_guard guard = List.mem guard guards

let translation_table : (Erlang.Ast.name, Erlang.Ast.name) Hashtbl.t =
  let h = Hashtbl.create 1024 in
  [ (("list", "length"), ("erlang", "length")) ]
  |> List.iter (fun ((m1, n1), (m2, n2)) ->
         let k =
           Name.qualified
             ~m:(Name.atom (Atom.mk m1))
             ~f:(Name.atom (Atom.mk n1))
         in
         let v =
           Name.qualified
             ~m:(Name.atom (Atom.mk m2))
             ~f:(Name.atom (Atom.mk n2))
         in
         Hashtbl.add h k v);
  h

let translate n =
  match Hashtbl.find_opt translation_table n with Some m -> m | None -> n

exception Unsupported_empty_identifier

let prime x = Str.global_replace (Str.regexp_string "'") "_prime" x

let varname_of_ident i =
  i |> Ident.unique_name |> prime |> Name.var |> translate

let varname_of_longident i =
  i |> Longident.last |> prime |> Name.var |> translate

let atom_of_ident i = i |> Ident.name |> Atom.mk |> Atom.lowercase

let atom_of_longident x =
  x |> Longident.last |> Atom.mk |> Atom.lowercase |> Atom.lowercase

let name_of_ident i =
  i |> Ident.name |> Atom.mk |> Atom.lowercase |> Name.atom |> translate

let name_of_path p =
  p |> Path.name |> Atom.mk |> Atom.lowercase |> Name.atom |> translate

let name_of_longident x =
  match x |> Longident.flatten |> List.rev with
  | [] -> Error.unsupported_empty_identifier ()
  | [ x ] -> Name.var x
  | n_name :: mods ->
      let module_name =
        mods |> List.rev |> String.concat "__" |> Atom.mk |> Atom.lowercase
        |> Name.atom
      in
      let n_name = Atom.mk n_name |> Atom.lowercase |> Name.atom in
      Name.qualified ~m:module_name ~f:n_name |> translate

let ocaml_to_erlang_type t =
  match t with
  | "string" -> Name.atom (Atom.mk "binary")
  | "int" -> Name.atom (Atom.mk "integer")
  | "bool" -> Name.atom (Atom.mk "boolean")
  | "option" ->
      Name.qualified
        ~m:(Name.atom (Atom.mk "option"))
        ~f:(Name.atom (Atom.mk "t"))
  | "result" ->
      Name.qualified
        ~m:(Name.atom (Atom.mk "result"))
        ~f:(Name.atom (Atom.mk "t"))
  | u -> Name.atom (Atom.mk u)

let type_name_of_parts ~args parts =
  match List.rev parts with
  | [] -> Error.unsupported_empty_identifier ()
  | [ x ] -> (ocaml_to_erlang_type x, args)
  | n_name :: mods -> (
      let n_mod =
        mods |> List.rev |> String.concat "__" |> String.lowercase_ascii
      in
      let module_name = Atom.mk n_mod |> Atom.lowercase in
      match (n_mod, n_name) with
      | _, x when x = "option" || x = "result" ->
          ( Name.qualified
              ~m:(Atom.mk x |> Atom.lowercase |> Name.atom)
              ~f:(Name.atom (Atom.mk "t")),
            args )
      | "erlang", "pid" ->
          ( Name.qualified ~m:(Name.atom module_name)
              ~f:(Name.atom (Atom.mk "pid")),
            [] )
      | _, _ ->
          ( Name.qualified ~m:(Name.atom module_name)
              ~f:(Atom.mk n_name |> Atom.lowercase |> Name.atom),
            args ))

let type_name_of_path ~args p =
  match Path.flatten p with
  | `Contains_apply -> Error.unsupported_path p
  | `Ok (id, parts) ->
      let name = id |> Ident.name |> ocaml_to_erlang_type |> Name.to_string in
      type_name_of_parts ~args (name :: parts)

let longident_to_type_name ~args x =
  x |> Longident.flatten |> type_name_of_parts ~args

let to_erl_op t =
  Name.qualified
    ~m:(Name.atom (Atom.mk "erlang"))
    ~f:(Atom.mk t |> Atom.lowercase |> Name.atom)

let ocaml_to_erlang_primitive_op t f =
  match t with
  | "!" | "++" | "-" | "--" | "<" | ">" | "*" | "+" -> to_erl_op t
  | "/" -> to_erl_op "div"
  | "mod" -> to_erl_op "rem"
  | "+." | "~+" | "~+." -> to_erl_op "+"
  | "-." | "~-" | "~-." -> to_erl_op "-"
  | "*." -> to_erl_op "*"
  | "/." -> to_erl_op "/"
  | "^" ->
      Name.qualified
        ~m:(Name.atom (Atom.mk "caramel_runtime"))
        ~f:(Name.atom (Atom.mk "binary_concat"))
  | "!=" | "<>" -> to_erl_op "=/="
  | "not" -> to_erl_op "not"
  | "&&" -> to_erl_op "and"
  | "||" -> to_erl_op "or"
  | ">=" -> to_erl_op ">="
  | "<=" -> to_erl_op "=<"
  | "=" -> to_erl_op "=:="
  | "==" -> to_erl_op "=="
  | "@" -> to_erl_op "++"
  | "land" -> to_erl_op "band"
  | "lor" -> to_erl_op "bor"
  | "lxor" -> to_erl_op "bxor"
  | "lnot" -> to_erl_op "bnot"
  | "lsl" -> to_erl_op "bsl"
  | "asr" -> to_erl_op "bsr"
  | _ -> f |> translate
