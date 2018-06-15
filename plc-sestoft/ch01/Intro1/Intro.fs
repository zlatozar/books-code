(* Representing object language expressions using recursive datatypes *)

namespace Chapter01

module Intro1 =

    type Expr =
        | CstI of int
        | Prim of string * Expr * Expr

    (* Evaluating expressions using recursive functions *)

    let rec eval (e: Expr) :int =
        match e with
        | CstI i            -> i
        | Prim("+", e1, e2) -> eval e1 + eval e2
        | Prim("*", e1, e2) -> eval e1 * eval e2
        | Prim("-", e1, e2) -> eval e1 - eval e2
        | Prim _            -> failwith "unknown primitive"

    (* Changing the meaning of subtraction *)

    let rec evalm (e: Expr) :int =
        match e with
        | CstI i            -> i
        | Prim("+", e1, e2) -> evalm e1 + evalm e2
        | Prim("*", e1, e2) -> evalm e1 * evalm e2
        | Prim("-", e1, e2) -> let res = evalm e1 - evalm e2
                               if res < 0 then 0 else res
        | Prim _            -> failwith "unknown primitive"
