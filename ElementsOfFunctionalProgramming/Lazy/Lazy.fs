module Lazy

// Node value has lazy evaluation
type 'a BinTree =
    | Leaf of 'a Lazy
    | Node of 'a BinTree * 'a BinTree
    static member (^^) ((x: 'a BinTree), (y: 'a BinTree)) = Node(x, y)

// same as ^^
let private join ((x: 'a BinTree), (y: 'a BinTree)) = Node(x, y)

// Postpone evaluation until need
let rec (<=>) (lst1: Lazy<'a> list) (lst2: Lazy<'a> list) =
    match lst1, lst2 with
    | [], []             -> true
    | (a :: x), (b :: y) -> (a.Force() = b.Force()) && (x <=> y)
    | (_ :: _), []       -> false
    | [], (_ :: _)       -> false

let rec eqleaves t1 t2 = leavesof t1 <=> leavesof t2
and leavesof leafs =
    match leafs with
    | Leaf x       -> [x]
    | Node(t1, t2) -> (leavesof t1) @ (leavesof t2)

[<RequireQualifiedAccess>]
module LazyBinTree =

    // Expand only if needed
    type 'a LazyBinTree =
        | Leaf of 'a
        | Node of 'a LazyBinTree Lazy * 'a LazyBinTree Lazy
        static member (^^) ((x: 'a LazyBinTree Lazy), (y: 'a LazyBinTree Lazy)) = Node(x, y)

    // same as ^^
    let private join ((x: 'a LazyBinTree Lazy), (y: 'a LazyBinTree Lazy)) = Node(x, y)

    let private btreeop f g =
        let rec btfg = function
            | Leaf x        -> f x
            | Node (t1, t2) -> g (lazy btfg t1.Value, lazy btfg t2.Value)
        btfg

    let map f = btreeop (Leaf << f) join
