namespace Chapter02

module Intcomp1Test =

    open System
    open FsUnit.Xunit
    open Xunit

    open Intcomp1

    // _________________________________________________________________________
    //                               Expressions represented in abstract syntax

    let e1 = Let("z", CstI 17, Prim("+", Var "z", Var "z"))

    // let z = 17 in
    //    (let z = 22 in 100 * z) + z
    let e2 = Let("z", CstI 17, Prim("+", Let("z", CstI 22, Prim("*", CstI 100, Var "z")), Var "z"))

    let e3 = Let("z", Prim("-", CstI 5, CstI 4), Prim("*", CstI 100, Var "z"))
    let e4 = Prim("+", Prim("+", CstI 20, Let("z", CstI 17, Prim("+", Var "z", CstI 2))), CstI 30)
    let e5 = Prim("*", CstI 2, Let("x", CstI 3, Prim("+", Var "x", CstI 4)))

    [<Fact>]
    let ``Expressions represented in abstract syntax`` () =
        run e1 |> should equal 34
        run e2 |> should equal 2217
        run e3 |> should equal 100
        run e4 |> should equal 69
        run e5 |> should equal 14

    // _________________________________________________________________________
    //                                     Some expressions with free variables

    // y + z
    let e6 = Prim("+", Var "y", Var "z")

    [<Fact>]
    let ``Simple substitution`` () =
        nsubst e6 [("z", CstI 17)]                     |> should equal (Prim ("+",Var "y",CstI 17))
        nsubst e6 [("z", Prim("-", CstI 5, CstI 4))]   |> should equal (Prim ("+",Var "y",Prim ("-",CstI 5,CstI 4)))
        nsubst e6 [("z", Prim("+", Var "z", Var "z"))] |> should equal (Prim ("+",Var "y",Prim ("+",Var "z",Var "z")))

    // (let z=22 in 5 * z) + z
    let e7 = Prim("+", Let("z", CstI 22, Prim("*", CstI 5, Var "z")), Var "z")

    [<Fact>]
    let ``Shows that only 'z' outside the Let gets substituted`` () =
        nsubst e7 [("z", CstI 100)] |> should equal (Prim ("+",Let ("z",CstI 22,Prim ("*",CstI 5,Var "z")),CstI 100))

    // let z=22*z in 5*z
    let e8 = Let("z", Prim("*", CstI 22, Var "z"), Prim("*", CstI 5, Var "z"))

    [<Fact>]
    let ``Shows that only the 'z' in the Let right hand side(RHS) gets substituted`` () =
        nsubst e8 [("z", CstI 100)] |> should equal (Let ("z",Prim ("*",CstI 22,CstI 100),Prim ("*",CstI 5,Var "z")))

    // let z=22 in y*z
    let e9 = Let("z", CstI 22, Prim("*", Var "y", Var "z"))

    [<Fact>]
    let ``Shows (wrong) capture of free variable 'z' under the Let`` () =
        nsubst e9 [("y", Var "z")] |> should equal (Let ("z",CstI 22,Prim ("*",Var "z",Var "z")))
        nsubst e9 [("z", Prim("-", CstI 5, CstI 4))] |> should equal (Let ("z",CstI 22,Prim ("*",Var "y",Var "z")))

    [<Fact>]
    let ``New version of substitution`` () =
        subst e6 [("z", CstI 17)] |> should equal (Prim ("+",Var "y",CstI 17))
        subst e6 [("z", Prim("-", CstI 5, CstI 4))] |> should equal (Prim ("+",Var "y",Prim ("-",CstI 5,CstI 4)))
        subst e6 [("z", Prim("+", Var "z", Var "z"))] |> should equal (Prim ("+",Var "y",Prim ("+",Var "z",Var "z")))

    [<Fact>]
    let ``1. Shows renaming of bound variable z`` () =
        subst e7 [("z", CstI 100)] |> should equal (Prim ("+",Let ("z1",CstI 22,Prim ("*",CstI 5,Var "z1")),CstI 100))

    [<Fact>]
    let ``2. Shows renaming of bound variable z`` () =
        subst e8 [("z", CstI 100)] |> should equal (Let ("z2",Prim ("*",CstI 22,CstI 100),Prim ("*",CstI 5,Var "z2")))

    [<Fact>]
    let ``Shows renaming of bound variable z (to z3), avoiding capture of free 'z'`` () =
        subst e9 [("y", Var "z")] |> should equal (Let ("z3",CstI 22,Prim ("*",Var "z",Var "z3")))

    [<Fact>]
    let ``Compile using index instead names`` () =
        let e = Let("z", CstI 17, Prim("+", Var "z", Var "z"))
        tcomp e [] |> should equal (TLet (TCstI 17,TPrim ("+",TVar 0,TVar 0)))

    [<Fact>]
    let ``Correctness: teval (tcomp e []) [] equals eval e []`` () =
        let t = tcomp (Let("z", CstI 17, Prim("+", Var "z", Var "z"))) []
        teval t [] |> should equal (eval (Let("z", CstI 17, Prim("+", Var "z", Var "z"))) [])

    [<Fact>]
    let ``Stack machine implementation`` () =
        reval [RCstI 10; RCstI 17; RDup; RMul; RAdd] [] |> should equal 299

    [<Fact>]
    let ``Correctness: Correctness: eval e [] equals reval (rcomp e) []`` () =
        let e = Prim("+", CstI 3, CstI 3)               // should not have Let and Var
        eval e [] |> should equal (reval (rcomp e) [])

    // Stack machine

    [<Fact>]
    let ``Compile for stack machine`` () =
        let e = Prim("+", CstI 17, CstI 12)
        scomp e [] |> should equal ([SCstI 17; SCstI 12; SAdd]) // 17 12 +

    [<Fact>]
    let ``Correctness: Correctness: eval e []  equals (seval (scomp e []) [])`` () =
        let e = Let("z", CstI 17, Prim("+", Var "z", Var "z"))
        eval e [] |> should equal (seval (scomp e []) [])    // note we always pass 'env'

    [<Fact>]
    let ``Compile for stack machine examples`` () =
        // To debug: seval [SCstI 17; SSt; SVar 0; SVar 1; SSt; SAdd; SSt; SSwap; SSt; SPop; SSt] [];;
        // Put 17 on the bottom; put 17; put 17; execute Add => [(top) 34; (bottom) 17]
        // Exchange 34 and 17 => [(top) 17; (bottom 34)] and finally drop 17
        scomp e1 [] |> should equal ([SCstI 17; SVar 0; SVar 1; SAdd; SSwap; SPop])
        scomp e2 [] |> should equal ([SCstI 17; SCstI 22; SCstI 100; SVar 1; SMul; SSwap; SPop; SVar 1; SAdd; SSwap; SPop])
        scomp e3 [] |> should equal ([SCstI 5; SCstI 4; SSub; SCstI 100; SVar 1; SMul; SSwap; SPop])
        scomp e5 [] |> should equal ([SCstI 2; SCstI 3; SVar 0; SCstI 4; SAdd; SSwap; SPop; SMul])
