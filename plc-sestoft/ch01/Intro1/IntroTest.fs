namespace Chapter01

module Intro1Test =

    open System
    open FsUnit.Xunit
    open Xunit

    open Intro1

    [<Fact>]
    let ``Evaluate constant`` () =
        eval (CstI 17) |> should equal 17

    [<Fact>]
    let ``Evaluate minus`` () =
        eval (Prim("-", CstI 3, CstI 4)) |> should equal -1

    [<Fact>]
    let ``Evaluate complex expression`` () =
        eval (Prim("+", Prim("*", CstI 7, CstI 9), CstI 10)) |> should equal 73

    [<Fact>]
    let ``Chage the meaning of subtraction`` () =
        evalm (Prim("-", CstI 10, CstI 27)) |> should equal 0
