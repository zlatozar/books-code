(* Abstract syntax for micro-SQL, very simple SQL SELECT statements *)

module Absyn

// Use grammar.txt for reference

type Constant =
  | CstI of int                         (* Integer constant               *)
  | CstB of bool                        (* Boolean constant               *)
  | CstS of string                      (* String constant                *)

type Stmt =
  | Select of Expr list                 (* fields are expressions         *)
            * string list               (* FROM ...                       *)

and Columns =
  | Column of string                    (* A column name: c               *)
  | TableColumn of string * string      (* A qualified column: t.c        *)

and Expr =
  | Star
  | Cst of Constant                     (* Constant                       *)
  | ColumnExpr of Columns               (* Columns                        *)
  | Prim of string * Expr list          (* Built-in function              *)
