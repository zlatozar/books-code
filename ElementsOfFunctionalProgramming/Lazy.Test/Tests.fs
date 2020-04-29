module Tests

open FsUnit.Xunit
open Xunit

open Lazy

[<Fact>]
let ``Check elements are equal`` () =
    [lazy (0 + 1); lazy (0 + 2); lazy (0 + 3)] <=> [lazy (0 + 1); lazy (0 + 3); lazy (0 + 3)] |> should be False

[<Fact>]
let ``Check if leafs are equal`` () =
    eqleaves (Leaf (lazy (3 + 3)) ^^ (Leaf (lazy (1 + 2)) ^^ Leaf (lazy (6 + 3))))
             (Leaf (lazy (2 + 3)) ^^ (Leaf (lazy (1 + 2)) ^^ Leaf (lazy (6 + 3)))) |> should be False

[<Fact>]
let ``Lazy check if element exist`` () =
    [1; 2; 42; 3; 4; 5]
    |> Seq.ofList
    |> LList.exists (fun x -> x > 42)
    |> should be True


[<Fact>]
let ``Check lazy list appending`` () =
    (Seq.ofList [1; 2]) <%> (Seq.ofList [4; 5])
    |> should equal (Seq.ofList [1; 2; 4; 5])
