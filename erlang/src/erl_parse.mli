val module_from_file :
  string -> (Erl_ast.structure, [> `Parser_error of string ]) result
val terms_from_file :
  string -> (Erl_ast.expr list, [> `Parser_error of string ]) result
