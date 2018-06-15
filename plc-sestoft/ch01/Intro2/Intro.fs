(* Evaluating simple expressions with variables *)
namespace Chapter01

module Intro2 =

    (* Association lists map object language variables to their values *)

    let rec lookup env x =
        match env with
        | []        -> failwith (x + " not found")
        | (y, v)::r -> if x=y then v else lookup r x

    (* Object language expressions with variables *)

    type Expr =
        | CstI of int
        | Var of string
        | Prim of string * Expr * Expr

    (* Evaluation within an environment *)

    let rec eval e (env: (string * int) list) :int =
        match e with
        | CstI i            -> i
        | Var x             -> lookup env x
        | Prim("+", e1, e2) -> eval e1 env + eval e2 env
        | Prim("*", e1, e2) -> eval e1 env * eval e2 env
        | Prim("-", e1, e2) -> eval e1 env - eval e2 env
        | Prim _            -> failwith "unknown primitive"
