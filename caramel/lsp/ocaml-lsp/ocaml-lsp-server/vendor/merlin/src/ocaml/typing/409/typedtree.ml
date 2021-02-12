(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* Abstract syntax tree after typing *)

open Misc
open Asttypes
open Types

(* Value expressions for the core language *)

type partial = Partial | Total

type attribute = Parsetree.attribute
type attributes = attribute list

type pattern =
  { pat_desc: pattern_desc;
    pat_loc: Location.t;
    pat_extra : (pat_extra * Location.t * attribute list) list;
    pat_type: type_expr;
    mutable pat_env: Env.t;
    pat_attributes: attribute list;
   }

and pat_extra =
  | Tpat_constraint of core_type
  | Tpat_type of Path.t * Longident.t loc
  | Tpat_open of Path.t * Longident.t loc * Env.t
  | Tpat_unpack

and pattern_desc =
    Tpat_any
  | Tpat_var of Ident.t * string loc
  | Tpat_alias of pattern * Ident.t * string loc
  | Tpat_constant of constant
  | Tpat_tuple of pattern list
  | Tpat_construct of
      Longident.t loc * constructor_description * pattern list
  | Tpat_variant of label * pattern option * row_desc ref
  | Tpat_record of
      (Longident.t loc * label_description * pattern) list *
        closed_flag
  | Tpat_array of pattern list
  | Tpat_or of pattern * pattern * row_desc option
  | Tpat_lazy of pattern
  | Tpat_exception of pattern

and expression =
  { exp_desc: expression_desc;
    exp_loc: Location.t;
    exp_extra: (exp_extra * Location.t * attribute list) list;
    exp_type: type_expr;
    exp_env: Env.t;
    exp_attributes: attribute list;
   }

and exp_extra =
  | Texp_constraint of core_type
  | Texp_coerce of core_type option * core_type
  | Texp_poly of core_type option
  | Texp_newtype of string

and expression_desc =
    Texp_ident of Path.t * Longident.t loc * Types.value_description
  | Texp_constant of constant
  | Texp_let of rec_flag * value_binding list * expression
  | Texp_function of { arg_label : arg_label; param : Ident.t;
      cases : case list; partial : partial; }
  | Texp_apply of expression * (arg_label * expression option) list
  | Texp_match of expression * case list * partial
  | Texp_try of expression * case list
  | Texp_tuple of expression list
  | Texp_construct of
      Longident.t loc * constructor_description * expression list
  | Texp_variant of label * expression option
  | Texp_record of {
      fields : ( Types.label_description * record_label_definition ) array;
      representation : Types.record_representation;
      extended_expression : expression option;
    }
  | Texp_field of expression * Longident.t loc * label_description
  | Texp_setfield of
      expression * Longident.t loc * label_description * expression
  | Texp_array of expression list
  | Texp_ifthenelse of expression * expression * expression option
  | Texp_sequence of expression * expression
  | Texp_while of expression * expression
  | Texp_for of
      Ident.t * Parsetree.pattern * expression * expression * direction_flag *
        expression
  | Texp_send of expression * meth * expression option
  | Texp_new of Path.t * Longident.t loc * Types.class_declaration
  | Texp_instvar of Path.t * Path.t * string loc
  | Texp_setinstvar of Path.t * Path.t * string loc * expression
  | Texp_override of Path.t * (Path.t * string loc * expression) list
  | Texp_letmodule of
      Ident.t * string loc * Types.module_presence * module_expr * expression
  | Texp_letexception of extension_constructor * expression
  | Texp_assert of expression
  | Texp_lazy of expression
  | Texp_object of class_structure * string list
  | Texp_pack of module_expr
  | Texp_letop of {
      let_ : binding_op;
      ands : binding_op list;
      param : Ident.t;
      body : case;
      partial : partial;
    }
  | Texp_unreachable
  | Texp_extension_constructor of Longident.t loc * Path.t
  | Texp_open of open_declaration * expression

and meth =
    Tmeth_name of string
  | Tmeth_val of Ident.t

and case =
    {
     c_lhs: pattern;
     c_guard: expression option;
     c_rhs: expression;
    }

and record_label_definition =
  | Kept of Types.type_expr
  | Overridden of Longident.t loc * expression

and binding_op =
  {
    bop_op_path : Path.t;
    bop_op_name : string loc;
    bop_op_val : Types.value_description;
    bop_op_type : Types.type_expr;
    bop_exp : expression;
    bop_loc : Location.t;
  }

(* Value expressions for the class language *)

and class_expr =
    {
     cl_desc: class_expr_desc;
     cl_loc: Location.t;
     cl_type: Types.class_type;
     cl_env: Env.t;
     cl_attributes: attribute list;
    }

and class_expr_desc =
    Tcl_ident of Path.t * Longident.t loc * core_type list
  | Tcl_structure of class_structure
  | Tcl_fun of
      arg_label * pattern * (Ident.t * expression) list
      * class_expr * partial
  | Tcl_apply of class_expr * (arg_label * expression option) list
  | Tcl_let of rec_flag * value_binding list *
                  (Ident.t * expression) list * class_expr
  | Tcl_constraint of
      class_expr * class_type option * string list * string list * Concr.t
    (* Visible instance variables, methods and concrete methods *)
  | Tcl_open of open_description * class_expr

and class_structure =
  {
   cstr_self: pattern;
   cstr_fields: class_field list;
   cstr_type: Types.class_signature;
   cstr_meths: Ident.t Meths.t;
  }

and class_field =
   {
    cf_desc: class_field_desc;
    cf_loc: Location.t;
    cf_attributes: attribute list;
  }

and class_field_kind =
  | Tcfk_virtual of core_type
  | Tcfk_concrete of override_flag * expression

and class_field_desc =
    Tcf_inherit of
      override_flag * class_expr * string option * (string * Ident.t) list *
        (string * Ident.t) list
    (* Inherited instance variables and concrete methods *)
  | Tcf_val of string loc * mutable_flag * Ident.t * class_field_kind * bool
  | Tcf_method of string loc * private_flag * class_field_kind
  | Tcf_constraint of core_type * core_type
  | Tcf_initializer of expression
  | Tcf_attribute of attribute

(* Value expressions for the module language *)

and module_expr =
  { mod_desc: module_expr_desc;
    mod_loc: Location.t;
    mod_type: Types.module_type;
    mod_env: Env.t;
    mod_attributes: attribute list;
   }

and module_type_constraint =
  Tmodtype_implicit
| Tmodtype_explicit of module_type

and module_expr_desc =
    Tmod_ident of Path.t * Longident.t loc
  | Tmod_structure of structure
  | Tmod_functor of Ident.t * string loc * module_type option * module_expr
  | Tmod_apply of module_expr * module_expr * module_coercion
  | Tmod_constraint of
      module_expr * Types.module_type * module_type_constraint * module_coercion
  | Tmod_unpack of expression * Types.module_type

and structure = {
  str_items : structure_item list;
  str_type : Types.signature;
  str_final_env : Env.t;
}

and structure_item =
  { str_desc : structure_item_desc;
    str_loc : Location.t;
    str_env : Env.t
  }

and structure_item_desc =
    Tstr_eval of expression * attributes
  | Tstr_value of rec_flag * value_binding list
  | Tstr_primitive of value_description
  | Tstr_type of rec_flag * type_declaration list
  | Tstr_typext of type_extension
  | Tstr_exception of type_exception
  | Tstr_module of module_binding
  | Tstr_recmodule of module_binding list
  | Tstr_modtype of module_type_declaration
  | Tstr_open of open_declaration
  | Tstr_class of (class_declaration * string list) list
  | Tstr_class_type of (Ident.t * string loc * class_type_declaration) list
  | Tstr_include of include_declaration
  | Tstr_attribute of attribute

and module_binding =
    {
     mb_id: Ident.t;
     mb_name: string loc;
     mb_presence: module_presence;
     mb_expr: module_expr;
     mb_attributes: attribute list;
     mb_loc: Location.t;
    }

and value_binding =
  {
    vb_pat: pattern;
    vb_expr: expression;
    vb_attributes: attributes;
    vb_loc: Location.t;
  }

and module_coercion =
    Tcoerce_none
  | Tcoerce_structure of (int * module_coercion) list *
                         (Ident.t * int * module_coercion) list
  | Tcoerce_functor of module_coercion * module_coercion
  | Tcoerce_primitive of primitive_coercion
  | Tcoerce_alias of Env.t * Path.t * module_coercion

and module_type =
  { mty_desc: module_type_desc;
    mty_type : Types.module_type;
    mty_env : Env.t;
    mty_loc: Location.t;
    mty_attributes: attribute list;
   }

and module_type_desc =
    Tmty_ident of Path.t * Longident.t loc
  | Tmty_signature of signature
  | Tmty_functor of Ident.t * string loc * module_type option * module_type
  | Tmty_with of module_type * (Path.t * Longident.t loc * with_constraint) list
  | Tmty_typeof of module_expr
  | Tmty_alias of Path.t * Longident.t loc

(* Keep primitive type information for type-based lambda-code specialization *)
and primitive_coercion =
  {
    pc_desc: Primitive.description;
    pc_type: type_expr;
    pc_env: Env.t;
    pc_loc : Location.t;
  }

and signature = {
  sig_items : signature_item list;
  sig_type : Types.signature;
  sig_final_env : Env.t;
}

and signature_item =
  { sig_desc: signature_item_desc;
    sig_env : Env.t; (* BINANNOT ADDED *)
    sig_loc: Location.t }

and signature_item_desc =
    Tsig_value of value_description
  | Tsig_type of rec_flag * type_declaration list
  | Tsig_typesubst of type_declaration list
  | Tsig_typext of type_extension
  | Tsig_exception of type_exception
  | Tsig_module of module_declaration
  | Tsig_modsubst of module_substitution
  | Tsig_recmodule of module_declaration list
  | Tsig_modtype of module_type_declaration
  | Tsig_open of open_description
  | Tsig_include of include_description
  | Tsig_class of class_description list
  | Tsig_class_type of class_type_declaration list
  | Tsig_attribute of attribute

and module_declaration =
    {
     md_id: Ident.t;
     md_name: string loc;
     md_presence: module_presence;
     md_type: module_type;
     md_attributes: attribute list;
     md_loc: Location.t;
    }

and module_substitution =
    {
     ms_id: Ident.t;
     ms_name: string loc;
     ms_manifest: Path.t;
     ms_txt: Longident.t loc;
     ms_attributes: attributes;
     ms_loc: Location.t;
    }

and module_type_declaration =
    {
     mtd_id: Ident.t;
     mtd_name: string loc;
     mtd_type: module_type option;
     mtd_attributes: attribute list;
     mtd_loc: Location.t;
    }

and 'a open_infos =
    {
     open_expr: 'a;
     open_bound_items: Types.signature;
     open_override: override_flag;
     open_env: Env.t;
     open_loc: Location.t;
     open_attributes: attribute list;
    }

and open_description = (Path.t * Longident.t loc) open_infos

and open_declaration = module_expr open_infos

and 'a include_infos =
    {
     incl_mod: 'a;
     incl_type: Types.signature;
     incl_loc: Location.t;
     incl_attributes: attribute list;
    }

and include_description = module_type include_infos

and include_declaration = module_expr include_infos

and with_constraint =
    Twith_type of type_declaration
  | Twith_module of Path.t * Longident.t loc
  | Twith_typesubst of type_declaration
  | Twith_modsubst of Path.t * Longident.t loc

and core_type =
(* mutable because of [Typeclass.declare_method] *)
  { mutable ctyp_desc : core_type_desc;
    mutable ctyp_type : type_expr;
    ctyp_env : Env.t; (* BINANNOT ADDED *)
    ctyp_loc : Location.t;
    ctyp_attributes: attribute list;
   }

and core_type_desc =
    Ttyp_any
  | Ttyp_var of string
  | Ttyp_arrow of arg_label * core_type * core_type
  | Ttyp_tuple of core_type list
  | Ttyp_constr of Path.t * Longident.t loc * core_type list
  | Ttyp_object of object_field list * closed_flag
  | Ttyp_class of Path.t * Longident.t loc * core_type list
  | Ttyp_alias of core_type * string
  | Ttyp_variant of row_field list * closed_flag * label list option
  | Ttyp_poly of string list * core_type
  | Ttyp_package of package_type

and package_type = {
  pack_path : Path.t;
  pack_fields : (Longident.t loc * core_type) list;
  pack_type : Types.module_type;
  pack_txt : Longident.t loc;
}

and row_field = {
  rf_desc : row_field_desc;
  rf_loc : Location.t;
  rf_attributes : attributes;
}

and row_field_desc =
    Ttag of string loc * bool * core_type list
  | Tinherit of core_type

and object_field = {
  of_desc : object_field_desc;
  of_loc : Location.t;
  of_attributes : attributes;
}

and object_field_desc =
  | OTtag of string loc * core_type
  | OTinherit of core_type

and value_description =
  { val_id: Ident.t;
    val_name: string loc;
    val_desc: core_type;
    val_val: Types.value_description;
    val_prim: string list;
    val_loc: Location.t;
    val_attributes: attribute list;
    }

and type_declaration =
  { typ_id: Ident.t;
    typ_name: string loc;
    typ_params: (core_type * variance) list;
    typ_type: Types.type_declaration;
    typ_cstrs: (core_type * core_type * Location.t) list;
    typ_kind: type_kind;
    typ_private: private_flag;
    typ_manifest: core_type option;
    typ_loc: Location.t;
    typ_attributes: attribute list;
   }

and type_kind =
    Ttype_abstract
  | Ttype_variant of constructor_declaration list
  | Ttype_record of label_declaration list
  | Ttype_open

and label_declaration =
    {
     ld_id: Ident.t;
     ld_name: string loc;
     ld_mutable: mutable_flag;
     ld_type: core_type;
     ld_loc: Location.t;
     ld_attributes: attribute list;
    }

and constructor_declaration =
    {
     cd_id: Ident.t;
     cd_name: string loc;
     cd_args: constructor_arguments;
     cd_res: core_type option;
     cd_loc: Location.t;
     cd_attributes: attribute list;
    }

and constructor_arguments =
  | Cstr_tuple of core_type list
  | Cstr_record of label_declaration list

and type_extension =
  {
    tyext_path: Path.t;
    tyext_txt: Longident.t loc;
    tyext_params: (core_type * variance) list;
    tyext_constructors: extension_constructor list;
    tyext_private: private_flag;
    tyext_loc: Location.t;
    tyext_attributes: attribute list;
  }

and type_exception =
  {
    tyexn_constructor: extension_constructor;
    tyexn_loc: Location.t;
    tyexn_attributes: attribute list;
  }

and extension_constructor =
  {
    ext_id: Ident.t;
    ext_name: string loc;
    ext_type: Types.extension_constructor;
    ext_kind: extension_constructor_kind;
    ext_loc: Location.t;
    ext_attributes: attribute list;
  }

and extension_constructor_kind =
    Text_decl of constructor_arguments * core_type option
  | Text_rebind of Path.t * Longident.t loc

and class_type =
    {
     cltyp_desc: class_type_desc;
     cltyp_type: Types.class_type;
     cltyp_env: Env.t;
     cltyp_loc: Location.t;
     cltyp_attributes: attribute list;
    }

and class_type_desc =
    Tcty_constr of Path.t * Longident.t loc * core_type list
  | Tcty_signature of class_signature
  | Tcty_arrow of arg_label * core_type * class_type
  | Tcty_open of open_description * class_type

and class_signature = {
    csig_self: core_type;
    csig_fields: class_type_field list;
    csig_type: Types.class_signature;
  }

and class_type_field = {
    ctf_desc: class_type_field_desc;
    ctf_loc: Location.t;
    ctf_attributes: attribute list;
  }

and class_type_field_desc =
  | Tctf_inherit of class_type
  | Tctf_val of (string * mutable_flag * virtual_flag * core_type)
  | Tctf_method of (string * private_flag * virtual_flag * core_type)
  | Tctf_constraint of (core_type * core_type)
  | Tctf_attribute of attribute

and class_declaration =
  class_expr class_infos

and class_description =
  class_type class_infos

and class_type_declaration =
  class_type class_infos

and 'a class_infos =
  { ci_virt: virtual_flag;
    ci_params: (core_type * variance) list;
    ci_id_name: string loc;
    ci_id_class: Ident.t;
    ci_id_class_type: Ident.t;
    ci_id_object: Ident.t;
    ci_id_typehash: Ident.t;
    ci_expr: 'a;
    ci_decl: Types.class_declaration;
    ci_type_decl: Types.class_type_declaration;
    ci_loc: Location.t;
    ci_attributes: attribute list;
   }

(* Auxiliary functions over the a.s.t. *)

let iter_pattern_desc f = function
  | Tpat_alias(p, _, _) -> f p
  | Tpat_tuple patl -> List.iter f patl
  | Tpat_construct(_, _, patl) -> List.iter f patl
  | Tpat_variant(_, pat, _) -> may f pat
  | Tpat_record (lbl_pat_list, _) ->
      List.iter (fun (_, _, pat) -> f pat) lbl_pat_list
  | Tpat_array patl -> List.iter f patl
  | Tpat_or(p1, p2, _) -> f p1; f p2
  | Tpat_lazy p -> f p
  | Tpat_exception p -> f p
  | Tpat_any
  | Tpat_var _
  | Tpat_constant _ -> ()

let map_pattern_desc f d =
  match d with
  | Tpat_alias (p1, id, s) ->
      Tpat_alias (f p1, id, s)
  | Tpat_tuple pats ->
      Tpat_tuple (List.map f pats)
  | Tpat_record (lpats, closed) ->
      Tpat_record (List.map (fun (lid, l,p) -> lid, l, f p) lpats, closed)
  | Tpat_construct (lid, c,pats) ->
      Tpat_construct (lid, c, List.map f pats)
  | Tpat_array pats ->
      Tpat_array (List.map f pats)
  | Tpat_lazy p1 -> Tpat_lazy (f p1)
  | Tpat_exception p1 -> Tpat_exception (f p1)
  | Tpat_variant (x1, Some p1, x2) ->
      Tpat_variant (x1, Some (f p1), x2)
  | Tpat_or (p1,p2,path) ->
      Tpat_or (f p1, f p2, path)
  | Tpat_var _
  | Tpat_constant _
  | Tpat_any
  | Tpat_variant (_,None,_) -> d

(* List the identifiers bound by a pattern or a let *)

let idents = ref([]: (Ident.t * string loc * Types.type_expr) list)

let rec bound_idents pat =
  match pat.pat_desc with
  | Tpat_var (id,s) -> idents := (id,s,pat.pat_type) :: !idents
  | Tpat_alias(p, id, s) ->
      bound_idents p; idents := (id,s,pat.pat_type) :: !idents
  | Tpat_or(p1, _, _) ->
      (* Invariant : both arguments binds the same variables *)
      bound_idents p1
  | d -> iter_pattern_desc bound_idents d

let pat_bound_idents_full pat =
  idents := [];
  bound_idents pat;
  let res = !idents in
  idents := [];
  res

let pat_bound_idents_with_loc p =
  List.map (fun (id,loc,_ty) -> id, loc) (pat_bound_idents_full p)

let pat_bound_idents pat =
  List.map (fun (id,_,_) -> id) (pat_bound_idents_full pat)

let rev_let_bound_idents_with_loc bindings =
  idents := [];
  List.iter (fun vb -> bound_idents vb.vb_pat) bindings;
  let res = !idents in idents := []; res

let let_bound_idents_with_loc pat_expr_list =
  List.rev(rev_let_bound_idents_with_loc pat_expr_list)

let rev_let_bound_idents pat =
  List.map (fun (id,_,_) -> id) (rev_let_bound_idents_with_loc pat)

let let_bound_idents pat =
  List.map (fun (id,_,_) -> id) (let_bound_idents_with_loc pat)

let alpha_var env id = List.assoc id env

let rec alpha_pat env p = match p.pat_desc with
| Tpat_var (id, s) -> (* note the ``Not_found'' case *)
    {p with pat_desc =
     try Tpat_var (alpha_var env id, s) with
     | Not_found -> Tpat_any}
| Tpat_alias (p1, id, s) ->
    let new_p =  alpha_pat env p1 in
    begin try
      {p with pat_desc = Tpat_alias (new_p, alpha_var env id, s)}
    with
    | Not_found -> new_p
    end
| d ->
    {p with pat_desc = map_pattern_desc (alpha_pat env) d}

let mkloc = Location.mkloc
let mknoloc = Location.mknoloc

let split_pattern pat =
  let combine_pattern_desc_opts ~into p1 p2 =
    match p1, p2 with
    | None, None -> None
    | Some p, None
    | None, Some p ->
        Some p
    | Some p1, Some p2 ->
        (* The third parameter of [Tpat_or] is [Some _] only for "#typ"
           patterns, which we do *not* expand. Hence we can put [None] here. *)
        Some { into with pat_desc = Tpat_or (p1, p2, None) }
  in
  let rec split_pattern pat =
    match pat.pat_desc with
    | Tpat_or (p1, p2, None) ->
        let vals1, exns1 = split_pattern p1 in
        let vals2, exns2 = split_pattern p2 in
        combine_pattern_desc_opts ~into:pat vals1 vals2,
        (* We could change the pattern type for exception patterns to
           [Predef.exn], but it doesn't really matter. *)
        combine_pattern_desc_opts ~into:pat exns1 exns2
    | Tpat_exception p ->
        None, Some p
    | _ ->
        Some pat, None
  in
  split_pattern pat

(* Merlin specific *)

type functor_parameter =
  | Unit
  | Named of Ident.t option * string option loc * module_type

let unpack_functor_me me =
  match me.mod_desc with
  | Tmod_functor (_, _, None, me) -> Unit, me
  | Tmod_functor (id, str, Some mty, me) ->
    Named (Some id, { str with txt = Some str.txt }, mty), me
  | _ -> invalid_arg "Typedtree.unpack_functor_me (merlin)"

let unpack_functor_mty mty =
  match mty.mty_desc with
  | Tmty_functor (_, _, None, mty) -> Unit, mty
  | Tmty_functor (id, str, Some mty, mty2) ->
    Named (Some id, { str with txt = Some str.txt }, mty), mty2
  | _ -> invalid_arg "Typedtree.unpack_functor_mty (merlin)"