(* Abstract syntax for micro-ML, a functional language *)

module Absyn

type Expr =
  | CstI of int
  | CstB of bool
  | Var of string
  | Let of string * Expr * Expr
  | Prim of string * Expr * Expr
  | If of Expr * Expr * Expr
  | Letfun of string * string * Expr * Expr    // (f, x, fBody, letBody)
  | Call of Expr * Expr
