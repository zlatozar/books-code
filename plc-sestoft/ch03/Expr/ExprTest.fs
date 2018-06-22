module ExprTest

open System
open FsUnit.Xunit
open Xunit

open Absyn
open Expr

// _________________________________________________________________________
//                               Expressions represented in abstract syntax

let e1 = Let("z", CstI 17, Prim("+", Var "z", Var "z"))
let e2 = Let("z", CstI 17, Prim("+", Let("z", CstI 22, Prim("*", CstI 100, Var "z")), Var "z"))
let e3 = Let("z", Prim("-", CstI 5, CstI 4), Prim("*", CstI 100, Var "z"))

[<Fact>]
let ``From abstract syntax to concreat`` () =
    fmt e1 |> should equal "let z = 17 in z+z end"
    fmt e2 |> should equal "let z = 17 in let z = 22 in 100*z end+z end"
    fmt e3 |> should equal "let z = 5-4 in 100*z end"
