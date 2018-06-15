namespace Chapter01

module Intro2Test =

    open System
    open FsUnit.Xunit
    open Xunit

    open Intro2

    let env = [("a", 3); ("c", 78); ("baf", 666); ("b", 111)]
    let emptyenv = []

    [<Fact>]
    let ``Lookup variable`` () =
        lookup env "c" |> should equal 78

    [<Fact>]
    let ``Evaluate a constant`` () =
        let e1 = CstI 17
        eval e1 env |> should equal 17

    [<Fact>]
    let ``Evaluate a plus`` () =
        let e2 = Prim("+", CstI 3, Var "a")
        eval e2 env |> should equal 6

    [<Fact>]
    let ``Evaluate a plus with custom environment`` () =
        let e2 = Prim("+", CstI 3, Var "a")
        eval e2 [("a", 314)] |> should equal 317

    [<Fact>]
    let ``Evaluate complex expression`` () =
        let e3 = Prim("+", Prim("*", Var "b", CstI 9), Var "a")
        eval e3 env |> should equal 1002
