open Erlang.Ast_helper
open Typedtree
open Types

module Type_var_names = struct
  let last_char : char ref = ref 'a'

  let table : (Types.type_expr, char) Hashtbl.t = Hashtbl.create 1024

  let reset () = last_char := 'a'

  let find t =
    match Hashtbl.find_opt table t with
    | None ->
        Hashtbl.add table t !last_char;
        let ret = String.make 1 !last_char in
        last_char := Char.chr (Char.code !last_char + 1);
        ret
    | Some v -> String.make 1 v
end

module Fun = struct
  let rec mk_type_expr : Types.type_expr -> Erlang.Ast.type_expr =
   fun type_expr ->
    match type_expr.desc with
    | Tarrow (_, param, out, _) ->
        let args = [ mk_type_expr param ] in
        let return = mk_type_expr out in
        Type.fun_ ~args ~return
    | Tconstr (p, args, _) ->
        let name, args = Names.type_name_of_path p ~args in
        let args = List.map mk_type_expr args in
        Type.apply ~name ~args
    | Ttuple els ->
        let parts = els |> List.map mk_type_expr in
        Type.tuple parts
    | Tlink t -> mk_type_expr (Btype.repr t)
    | Tvar (Some name) -> Type.var (Name.var ("_" ^ name))
    | Tvar None -> Type.var (Name.var (Type_var_names.find type_expr))
    | Tnil -> Type.apply ~name:(Name.atom (Atom.mk "list")) ~args:[]
    | Tvariant { row_fields; _ } ->
        let row_field_to_type_expr = function
          | Rpresent (Some texpr) -> [ mk_type_expr texpr ]
          | Rpresent None -> []
          | Reither (_, args, _, _) -> List.map mk_type_expr args
          | _ ->
              Format.fprintf Format.std_formatter
                "Tried to build a type expr for an odd variant constructor!\n%!";
              Printtyp.type_expr Format.std_formatter type_expr;
              Format.fprintf Format.std_formatter "\n%!";
              Printtyp.raw_type_expr Format.std_formatter type_expr;
              Format.fprintf Format.std_formatter "\n%!";
              Error.unsupported_feature `Absent_polymorphic_variants
        in

        let row_field_to_constr (name, args) =
          let name = Const.atom (Atom.lowercase (Atom.mk name)) in
          let args = row_field_to_type_expr args in
          match args with
          | [] -> Type.const name
          | _ -> Type.tuple (Type.const name :: args)
        in

        List.map row_field_to_constr row_fields |> Type.variant
    | Tpoly (_, _)
    | Tfield (_, _, _, _)
    | Tsubst _ | Tunivar _ | Tobject _ | Tpackage _ ->
        Format.fprintf Format.std_formatter
          "Tried to build a type expr for an unsupported feature!\n%!";
        Printtyp.type_expr Format.std_formatter type_expr;
        Format.fprintf Format.std_formatter "\n%!";
        Printtyp.raw_type_expr Format.std_formatter type_expr;
        Format.fprintf Format.std_formatter "\n%!";
        Error.unsupported_feature `Type_constructs

  let mk_spec : Types.value_description -> Erlang.Ast.type_expr option =
   fun { val_type; _ } ->
    Type_var_names.reset ();
    match Uncurry.from_type_expr val_type with
    | `Uncurried (args, return) ->
        let args = List.map mk_type_expr args in
        let return = mk_type_expr return in
        let fun_ = Type.fun_ ~args ~return in
        let clean_fun = Type.clean_unbound_named_vars fun_ in
        Some clean_fun
    | `Not_a_function -> None

  let find_spec :
      typedtree:Typedtree.structure ->
      Erlang.Ast.atom ->
      Erlang.Ast.type_expr option =
   fun ~typedtree name ->
    match
      List.filter_map
        (function
          | Types.Sig_value (id, vd, _) -> (
              let type_name = Names.atom_of_ident id in
              match Atom.equal type_name name with
              | true -> mk_spec vd
              | false -> None)
          | _ -> None)
        typedtree.str_type
    with
    | [ x ] -> Some x
    | _ -> None
end

let rec is_unit (t : Types.type_expr) =
  match t.desc with
  | Tconstr (p, _, _) -> Path.same p Predef.path_unit
  | Tlink t' -> is_unit (Btype.repr t')
  | _ -> false

let is_opaque_in_signature type_decl signature =
  match signature with
  | None -> Type.type_
  | Some sign ->
      List.fold_left
        (fun kind sig_item ->
          match sig_item with
          | Sig_type (name, { type_manifest = None; _ }, _, _)
            when Ident.name name = Ident.name type_decl.typ_id ->
              Type.opaque
          | _ -> kind)
        Type.type_ sign

let rec mk_type_expr core_type =
  match core_type.ctyp_desc with
  | Ttyp_any -> Some Type.any
  | Ttyp_var var_name -> Some (Type.var (Name.var var_name))
  (* NOTE: OCaml works with functions from one type to another, and supports
   * multiargument functions via currying or tuples.
   *
   * Erlang doesn't, so we'll squash the function type into a single function
   * with multiple arguments instead.
   *)
  | Ttyp_arrow (_, param, out) ->
      let rec args t acc =
        match t.ctyp_desc with
        | Ttyp_arrow (_, p, t') -> args t' (p :: acc)
        | _ -> t :: acc
      in
      let args = args out [ param ] |> List.filter_map mk_type_expr in
      let return = List.hd args in
      let args = List.rev (List.tl args) in
      Some (Type.fun_ ~args ~return)
  (* NOTE: this allows us to export type aliases that may have been made
   * opaque, such as `type opaque = string`, as `-type opaque() :: string().`
   *
   * It is also used for application of type constructors: `type a = string list`
   * gets compiled to `-type a() :: list(string()).`
   *)
  | Ttyp_constr (_, { txt; _ }, args) ->
      let name, args = Names.longident_to_type_name ~args txt in
      let args = List.filter_map mk_type_expr args in
      Some (Type.apply ~args ~name)
  | Ttyp_tuple els ->
      let parts = List.filter_map mk_type_expr els in
      Some (Type.tuple parts)
  | Ttyp_variant (rows, _closed, _labels) ->
      let rec all_rows rs acc =
        match rs with
        | [] -> acc |> List.rev
        | r :: rs' -> (
            match r.rf_desc with
            | Ttag ({ txt; _ }, _, core_types) ->
                let name = Const.atom (Atom.lowercase (Atom.mk txt)) in
                let args = core_types |> List.filter_map mk_type_expr in
                let variant =
                  match args with
                  | [] -> Type.const name
                  | _ -> Type.tuple (Type.const name :: args)
                in
                all_rows rs' (variant :: acc)
            | Tinherit { ctyp_desc = Ttyp_constr (_, { txt; _ }, args); _ } ->
                let name, args = Names.longident_to_type_name ~args txt in
                let args = List.filter_map mk_type_expr args in
                let t = Type.apply ~name ~args in
                all_rows rs' (t :: acc)
            | _ -> all_rows rs' acc)
      in
      let constructors = all_rows rows [] in
      Some (Type.variant constructors)
  (* NOTE: these are two core type constructors that are essentially "links"
   * to follow.
   *
   * The second one `Ttyp_poly (strings, core_typ)` seemed to appear in records.
   *)
  | Ttyp_poly (_names, follow) -> mk_type_expr follow
  | Ttyp_alias (follow, _) -> mk_type_expr follow
  | Ttyp_object _ | Ttyp_class _ | Ttyp_package _ ->
      Error.unsupported_feature `Type_objects_and_packages

let mk_record labels =
  let mk_field Typedtree.{ ld_id; ld_type; _ } =
    let rf_name = Names.atom_of_ident ld_id in
    let rf_type =
      match mk_type_expr ld_type with Some t -> t | None -> Type.any
    in
    Type.map_field ~presence:Mandatory (Type.const (Const.atom rf_name)) rf_type
  in
  let fields = List.map mk_field labels in
  Type.map fields

let mk_abstract name params type_decl core_type signature =
  match mk_type_expr core_type with
  | Some expr ->
      let kind = is_opaque_in_signature type_decl signature in
      Some (Type.mk ~name ~params ~expr ~kind)
  | None -> None

let mk_type_params params =
  params
  |> List.filter_map (fun (core_type, _) ->
         match core_type.ctyp_desc with
         | Ttyp_var name -> Some (Name.var name)
         | _ -> None)

let mk_type type_decl ~signature =
  let name = Names.atom_of_ident type_decl.typ_id in
  let params = mk_type_params type_decl.typ_params in
  let params = List.map Type.var params in
  match type_decl.typ_kind with
  (* NOTE: turns out that "abstract" here means "only structure, no names!"
   * so this branch will generate the appropriate types for tuples, aliases
   * and actual abstract types.
   * *)
  | Ttype_abstract -> (
      match type_decl.typ_manifest with
      | Some abs -> mk_abstract name params type_decl abs signature
      | None ->
          let expr =
            Type.apply ~args:[] ~name:(Name.atom (Atom.mk "reference"))
          in
          Some (Type.mk ~name ~params ~expr ~kind:Opaque))
  | Ttype_record labels ->
      let expr = mk_record labels in
      Some (Type.mk ~name ~params ~expr ~kind:Type)
  | Ttype_variant constructors ->
      let mk_constr Typedtree.{ cd_id; cd_args; _ } =
        let args =
          match cd_args with
          | Cstr_tuple core_types -> core_types |> List.filter_map mk_type_expr
          | Cstr_record labels -> [ mk_record labels ]
        in
        let name = Const.atom (Names.atom_of_ident cd_id) in
        match args with
        | [] -> Type.const name
        | _ -> Type.tuple (Type.const name :: args)
      in
      let constructors = List.map mk_constr constructors in
      Some (Type.mk ~name ~params ~expr:(Type.variant constructors) ~kind:Type)
  | Ttype_open -> Some (Type.mk ~name ~params ~expr:Type.any ~kind:Type)

(** Build the types of an Erlang module.
 *)
let mk_types :
    Typedtree.structure -> Types.signature option -> Erlang.Ast.type_decl list =
 fun typedtree signature ->
  typedtree.str_items
  |> List.concat_map (fun item ->
         match item.str_desc with Tstr_type (_, tys) -> tys | _ -> [])
  |> List.filter_map (mk_type ~signature)
