module Tests

open FsUnit.Xunit
open Xunit

open Lazy

[<Fact>]
let ``Check if leafs are equal`` () =
    eqleaves (Leaf 6 ^^ (Leaf 3 ^^ Leaf 9)) (Leaf 6 ^^ (Leaf 3 ^^ Leaf 9))
    |> should be True
