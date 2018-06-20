(* Abstract syntax for the simple expression language *)

module Absyn

type Expr =
  | CstI of int
  | Var of string
  | Let of string * Expr * Expr
  | Prim of string * Expr * Expr
