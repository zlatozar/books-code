module Lazy

type 'a BinTree =
    | Leaf of 'a
    | Node of 'a BinTree * 'a BinTree
with
    static member (^^) ((x: 'a BinTree), (y: 'a BinTree)) = Node(x, y)

let rec eqleaves t1 t2 =
    leavesof t1 = leavesof t2
and leavesof leafs =
    match leafs with
    | Leaf x        -> [x]
    | Node (t1, t2) -> leavesof t1 @ leavesof t2
