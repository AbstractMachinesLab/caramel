open Erlang.Ast_helper
open Typedtree
open Types

(*
let _debug = Format.fprintf Format.std_formatter
*)
let const_to_literal const =
  let open Asttypes in
  match const with
  | Const_int int -> Const.integer (string_of_int int)
  | Const_char char -> Const.char (String.make 1 char)
  | Const_string (string, _, _) -> Const.binary string
  | Const_float str ->
      let str =
        match str.[String.length str - 1] == '.' with
        | false -> str
        | true -> str ^ "0"
      in
      Const.float str
  | Const_int32 int32 -> Const.integer (Int32.to_string int32)
  | Const_int64 int64 -> Const.integer (Int64.to_string int64)
  | Const_nativeint nint -> Const.integer (Nativeint.to_string nint)

(* NOTE: flatten down all the names bound in the parameters
 * to a single list that we can use to quickly check how to
 * normalize them in the function's body.
 *)
let rec collect_var_names pat =
  let open Erlang.Ast in
  let rec collect acc p =
    match p with
    | [] -> acc
    | p :: ps ->
        let subpats =
          match p with
          | Pattern_list pats -> collect_var_names pats
          | Pattern_tuple pats -> collect_var_names pats
          | Pattern_map pats -> pats |> List.map (fun (_, p) -> p)
          | Pattern_with_name (pattern, binding) ->
              binding :: collect_var_names [ pattern ]
          | _ -> [ p ]
        in
        collect (subpats @ acc) ps
  in
  collect [] pat

let name_in_var_names ~var_names name =
  let open Erlang.Ast in
  var_names
  |> List.exists (fun pat ->
         match pat with Pattern_binding x -> x = name | _ -> false)

let is_nested_module ~modules name =
  List.exists
    (fun Erlang.Ast.{ module_name = mn; _ } -> Atom.equal mn name)
    modules

let find_function_by_name ~functions name =
  List.find_opt
    (fun Erlang.Ast.{ fd_name; _ } -> Atom.equal fd_name name)
    functions

let rec mk_function name cases ~spec ~var_names ~modules ~functions ~module_name
    =
  (* NOTE: helper function to collect all parameters *)
  let rec params c acc =
    let acc' = mk_pattern ~var_names c.c_lhs :: acc in
    match c.c_rhs.exp_desc with
    | Texp_function { cases = [ c' ]; _ } -> params c' acc'
    | _ -> acc' |> List.rev
  in

  let mk_case case =
    (* NOTE: we'll just traverse all the expressions in this case and
     * make sure we collapse as many top-level arguments for this function.
     *)
    let rec body c var_names =
      match c.c_rhs.exp_desc with
      | Texp_function { cases = [ c' ]; _ } ->
          let pattern = mk_pattern ~var_names c'.c_lhs in
          let var_names = var_names @ collect_var_names [ pattern ] in
          body c' var_names
      | _ -> mk_expression c.c_rhs ~var_names ~modules ~functions ~module_name
    in

    let lhs = params case [] in
    let rhs = body case (var_names @ collect_var_names lhs) in
    FunDecl.case ~lhs ~guard:None ~rhs
  in

  FunDecl.mk ~name ~cases:(List.map mk_case cases) ~spec

(* NOTE: We need a universally quantified k here because this function will
 * be called with several types indexing general_pattern *)
and mk_pattern :
    type k.
    k general_pattern -> var_names:Erlang.Ast.pattern list -> Erlang.Ast.pattern
    =
 fun pat ~var_names ->
  match pat.pat_desc with
  | Tpat_var (id, _) -> Pat.bind (Names.varname_of_ident id)
  | Tpat_alias ({ pat_desc = Tpat_any; _ }, id, _) ->
      (* NOTE: this is e.g. a function argument with an annotated type *)
      Pat.bind (Names.varname_of_ident id)
  | Tpat_alias (pat, id, _) ->
      Pat.with_name
        (mk_pattern pat ~var_names)
        (Pat.bind (Names.varname_of_ident id))
  | Tpat_value t ->
      (* NOTE: type casting magic! *)
      mk_pattern ~var_names (t :> pattern)
  | Tpat_tuple tuples ->
      Erlang.Ast.Pattern_tuple (List.map (mk_pattern ~var_names) tuples)
  | Tpat_record (fields, _) ->
      Erlang.Ast.Pattern_map
        (fields
        |> List.map (fun (Asttypes.{ txt; _ }, _, pattern) ->
               ( Pat.bind (Name.atom (Names.atom_of_longident txt)),
                 mk_pattern ~var_names pattern )))
  (* FIXME: don't compare atoms like this, just refer to is_unit *)
  | Tpat_construct ({ txt; _ }, _, _) when Longident.last txt = "()" ->
      Pat.tuple []
  | Tpat_construct ({ txt; _ }, _, patterns)
    when Longident.last txt = "::" || Longident.last txt = "[]" ->
      Pat.list (List.map (mk_pattern ~var_names) patterns)
  | Tpat_construct ({ txt; _ }, _, []) ->
      Pat.const (Const.atom (Atom.lowercase (Names.atom_of_longident txt)))
  | Tpat_construct ({ txt; _ }, _, patterns) ->
      let tag =
        Erlang.Ast.Pattern_match
          (Erlang.Ast.Lit_atom (Atom.lowercase (Names.atom_of_longident txt)))
      in
      let values = List.map (mk_pattern ~var_names) patterns in
      Erlang.Ast.Pattern_tuple (tag :: values)
  | Tpat_variant (label, None, _) ->
      Pat.const (Const.atom (Atom.lowercase (Atom.mk label)))
  | Tpat_variant (label, Some expr, _) ->
      let tag = Pat.const (Const.atom (Atom.lowercase (Atom.mk label))) in
      let value = mk_pattern expr ~var_names in
      Pat.tuple [ tag; value ]
  | Tpat_constant const -> Erlang.Ast.Pattern_match (const_to_literal const)
  | Tpat_or (_, _, _) -> Error.unsupported_fallthrough_cases ()
  (* NOTE: here's where the translation of pattern
   * matching at the function level should happen. *)
  | _ -> Erlang.Ast.Pattern_ignore

and mk_bindings vbs ~var_names ~modules ~functions ~module_name =
  match vbs with
  | [ vb ] ->
      let lb_lhs = mk_pattern vb.vb_pat ~var_names in
      let lb_rhs =
        mk_expression vb.vb_expr ~var_names ~modules ~functions ~module_name
      in
      let lb_rhs =
        match lb_rhs with
        | Erlang.Ast.Expr_let (_, _) -> Erlang.Ast.Expr_seq [ lb_rhs ]
        | _ -> lb_rhs
      in
      Erlang.Ast.{ lb_lhs; lb_rhs }
  | _ -> Error.unsupported_feature `Let_and_bindings

and mk_expression exp ~var_names ~modules ~functions ~module_name =
  match exp.exp_desc with
  | Texp_constant constant ->
      let v = const_to_literal constant in
      Erlang.Ast.Expr_literal v
  | Texp_ident (_, { txt; _ }, { val_type; val_kind; _ }) -> (
      let name = Names.name_of_longident txt in
      let var_name = Names.varname_of_longident txt in
      let args, _ = Uncurry.uncurry_tarrow val_type [] in
      let arity = List.length args in

      let namespace_qualified_name n_mod n_name =
        let module_name = Atom.lowercase (Atom.concat module_name n_mod "__") in
        match is_nested_module ~modules module_name with
        | true ->
            Name.qualified ~m:(Name.atom module_name)
              ~f:(Name.atom (Atom.lowercase n_name))
        | _ ->
            Name.qualified ~m:(Name.atom n_mod)
              ~f:(Name.atom (Atom.lowercase n_name))
      in

      (* NOTE: an identifier may be a currently bound variable name or it may be a function name of 3 kinds:
         1. qualified and local, referring to a nested module
         2. qualified and external, refering to a module that is not nested
         3. unqualified, and thus refering to a function reference
      *)
      match name with
      | Erlang.Ast.Qualified_name
          { n_mod = Atom_name n_mod; n_name = Atom_name n_name } ->
          let primed_name =
            match val_kind with
            | Val_prim prim -> (
                let prim_name = prim.prim_name |> String.trim in
                match String.length prim_name > 0 with
                | true -> Atom.mk prim_name
                | false -> n_name)
            | _ -> n_name
          in
          let qualified_name = namespace_qualified_name n_mod primed_name in
          Expr.fun_ref ~arity
            (Names.ocaml_to_erlang_primitive_op
               (Name.to_string qualified_name)
               qualified_name)
      | _ ->
          if name_in_var_names ~var_names var_name then Expr.ident var_name
          else
            let unqualified_name = Name.atom (Names.atom_of_longident txt) in
            Expr.fun_ref ~arity
              (Names.ocaml_to_erlang_primitive_op
                 (Name.to_string unqualified_name)
                 unqualified_name))
  | Texp_construct ({ txt; _ }, _, _expr) when Longident.last txt = "[]" ->
      Erlang.Ast.Expr_list []
  | Texp_construct ({ txt; _ }, _, _expr) when Longident.last txt = "()" ->
      Erlang.Ast.Expr_tuple []
  | Texp_construct ({ txt; _ }, _, []) ->
      Expr.ident (Name.atom (Atom.lowercase (Names.atom_of_longident txt)))
  (* NOTE: lists are just variants :) *)
  | Texp_construct ({ txt; _ }, _, exprs) when Longident.last txt = "::" ->
      let values =
        exprs
        |> List.map (mk_expression ~var_names ~modules ~functions ~module_name)
      in
      Erlang.Ast.Expr_list values
  (* NOTE: these are actually the variants! and Texp_variant below is for
   * polymorphic ones *)
  | Texp_construct ({ txt; _ }, _, exprs) ->
      let tag =
        Expr.ident (Name.atom (Atom.lowercase (Names.atom_of_longident txt)))
      in
      let values =
        exprs
        |> List.map (mk_expression ~var_names ~modules ~functions ~module_name)
      in
      Expr.tuple (tag :: values)
  | Texp_variant (label, None) ->
      Expr.ident (Name.atom (Atom.lowercase (Atom.mk label)))
  | Texp_variant (label, Some expr) ->
      let tag = Expr.ident (Name.atom (Atom.lowercase (Atom.mk label))) in
      let value =
        mk_expression ~var_names ~modules ~functions ~module_name expr
      in
      Erlang.Ast.Expr_tuple [ tag; value ]
  | Texp_apply (expr, args) ->
      let expr_arg_types, _ = Uncurry.uncurry_tarrow expr.exp_type [] in
      let wanted_arity = List.length expr_arg_types in
      let name =
        match
          mk_expression expr ~var_names ~modules ~functions ~module_name
        with
        | Erlang.Ast.Expr_fun_ref { fref_name = n; _ } -> Expr.ident n
        | x -> x
      in
      let args =
        List.filter_map
          (function
            | _, None -> None
            | _, Some arg ->
                Some
                  (mk_expression arg ~var_names ~modules ~functions ~module_name))
          args
      in
      if wanted_arity > List.length args then
        let rec gen_names acc n =
          match n with
          | 0 -> acc
          | n ->
              gen_names
                (Name.var ("Caramel@" ^ string_of_int n) :: acc)
                (n - 1)
        in
        let outer_names = gen_names [] (wanted_arity - List.length args) in
        let lhs = List.map Pat.bind outer_names in
        let idents = List.map Expr.ident outer_names in
        let rhs = Expr.apply name (args @ idents) in
        Expr.fun_ ~cases:[ FunDecl.case ~lhs ~guard:None ~rhs ]
      else Expr.apply name args
  | Texp_record { fields; extended_expression; _ } -> (
      let fields =
        fields |> Array.to_list
        |> List.filter_map (fun (field, value) ->
               match value with
               | Kept _ -> None
               | Overridden (_, exp) ->
                   let value =
                     mk_expression exp ~var_names ~modules ~functions
                       ~module_name
                   in
                   let field =
                     Expr.map_field
                       (Expr.const (Const.atom (Atom.mk field.lbl_name)))
                       value
                   in
                   Some field)
      in

      match extended_expression with
      | None -> Expr.map fields
      | Some prior_map ->
          Expr.map_update
            (mk_expression prior_map ~var_names ~modules ~functions ~module_name)
            fields)
  | Texp_field (expr, _, { lbl_name; _ }) ->
      let name =
        let m = Atom.mk "maps" |> Name.atom in
        let f = Atom.mk "get" |> Name.atom in
        Expr.ident (Name.qualified ~m ~f)
      in
      let args =
        [
          Expr.ident (Name.atom (Atom.mk lbl_name));
          mk_expression ~var_names ~modules ~functions ~module_name expr;
        ]
      in
      Expr.apply name args
  | Texp_tuple exprs ->
      Erlang.Ast.Expr_tuple
        (exprs
        |> List.map (mk_expression ~var_names ~modules ~functions ~module_name)
        )
  | Texp_match (expr, branches, _) ->
      let expr =
        mk_expression expr ~var_names ~modules ~functions ~module_name
      in
      let branches =
        List.map
          (fun c ->
            let lhs = mk_pattern ~var_names c.c_lhs in
            let var_names = collect_var_names [ lhs ] @ var_names in
            let guard =
              match c.c_guard with
              | None -> None
              | Some expr ->
                  let expr =
                    mk_expression expr ~var_names ~modules ~functions
                      ~module_name
                  in
                  Erlang.Ast.(
                    match expr with
                    | Expr_apply { fa_name = Expr_name name; _ }
                      when Names.is_guard name ->
                        ()
                    | _ -> Error.unsupported_guard_expression ());
                  Some [ expr ]
            in
            let rhs =
              mk_expression c.c_rhs ~var_names ~modules ~functions ~module_name
            in
            FunDecl.case ~lhs:[ lhs ] ~guard ~rhs)
          branches
      in
      Erlang.Ast.Expr_case (expr, branches)
  | Texp_ifthenelse (if_cond, if_true, if_false) ->
      let expr =
        mk_expression ~var_names ~modules ~functions ~module_name if_cond
      in
      let if_true =
        FunDecl.case
          ~lhs:[ Pat.const (Const.atom (Atom.mk "true")) ]
          ~guard:None
          ~rhs:
            (mk_expression ~var_names ~modules ~functions ~module_name if_true)
      in
      let if_false =
        match if_false with
        | Some if_false ->
            [
              FunDecl.case
                ~lhs:[ Pat.const (Const.atom (Atom.mk "false")) ]
                ~guard:None
                ~rhs:
                  (mk_expression ~var_names ~modules ~functions ~module_name
                     if_false);
            ]
        | None -> []
      in
      let branches = if_true :: if_false in
      Erlang.Ast.Expr_case (expr, branches)
  | Texp_let (Recursive, _, _) ->
      Error.unsupported_let_rec_inside_of_function_body ()
  | Texp_let (Nonrecursive, vbs, expr) ->
      (* NOTE: consider flattening let-ins ?
         let rec flatten e acc =
           match e with
           | Texp_let (_, vbs, e') -> flatten e' (e :: acc)
           | _ -> (e :: acc) |> List.rev
         in
         let bindings = flatten expr [] in
      *)
      let let_binding =
        mk_bindings vbs ~var_names ~modules ~functions ~module_name
      in
      let fresh_var_names =
        collect_var_names Erlang.Ast.[ let_binding.lb_lhs ]
      in

      List.iter
        (fun name ->
          match name with
          | Erlang.Ast.Pattern_binding x ->
              if name_in_var_names ~var_names x then
                Error.unsupported_let_shadowing x
          | _ -> ())
        fresh_var_names;

      let var_names = fresh_var_names @ var_names in
      let let_expr =
        mk_expression ~var_names ~modules ~functions ~module_name expr
      in
      Erlang.Ast.Expr_let (let_binding, let_expr)
  | Texp_function { cases; _ } ->
      let f =
        mk_function ~functions ~module_name ~modules ~spec:None ~var_names
          (Atom.mk "anonymous") cases
      in
      Expr.fun_ ~cases:f.fd_cases
  | Texp_sequence (this, next) -> (
      let this_expr =
        mk_expression this ~var_names ~modules ~functions ~module_name
      in
      let next_expr =
        mk_expression next ~var_names ~modules ~functions ~module_name
      in
      match next_expr with
      | Erlang.Ast.Expr_seq exprs -> Erlang.Ast.Expr_seq (this_expr :: exprs)
      | _ -> Erlang.Ast.Expr_seq [ this_expr; next_expr ])
  | _ -> Error.unsupported_expression exp

let mk_value vb ~modules ~functions ~module_name ~typedtree =
  match (vb.vb_pat.pat_desc, vb.vb_expr.exp_desc) with
  | Tpat_var (id, _), Texp_function { cases; _ } -> (
      let fn_name = id |> Names.atom_of_ident in
      match find_function_by_name ~functions fn_name with
      | Some _ -> Error.redefining_function ~fn_name ~module_name
      | None ->
          mk_function ~module_name ~modules ~functions
            ~spec:(Typespecs.Fun.find_spec ~typedtree fn_name)
            ~var_names:[] fn_name cases)
  | _ -> Error.unsupported_top_level_module_value ()

(** Build the actual functions of an Erlang module
 *)
let mk_functions :
    module_name:Erlang.Ast.atom ->
    modules:Erlang.Ast.t list ->
    Typedtree.structure ->
    Erlang.Ast.fun_decl list =
 fun ~module_name ~modules typedtree ->
  typedtree.str_items
  |> List.fold_left
       (fun acc item ->
         match item.str_desc with
         | Tstr_value (_, vb) ->
             List.map
               (mk_value ~typedtree ~modules ~module_name ~functions:acc)
               vb
             @ acc
         | _ -> acc)
       []
  |> List.rev
