module Lazy

#nowarn "40"

// Tip: Use Seq when you want to take when it is needed.
//      Use 'lazy' when you want to postpone execution until the very end.

// Lazy is called Thunk in some languages

let cond ((b, t, f): bool * (unit->'a) * (unit->'a)) :'a =
    if b then t() else f()

let rec factorial (n: int) :int =
    cond (n <= 0, (fun () -> 1), (fun () -> n * factorial (n - 1)))

let cond2 ((b, t, f): bool * 'a Lazy * 'a Lazy) :'a =
    if b then t.Force() else f.Force()

let rec factorial2 (n: int) :int =
    cond2 (n <= 0, lazy 1, lazy (n * factorial2 (n - 1)))

// Node value has lazy evaluation
type 'a BinTree =
    | Leaf of 'a Lazy
    | Node of 'a BinTree * 'a BinTree
    static member (^^) ((x: 'a BinTree), (y: 'a BinTree)) = Node(x, y)

// Postpone evaluation until needed
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

let (|SeqEmpty|SeqCons|) (xs: 'a seq) =
    if Seq.isEmpty xs then SeqEmpty
    else SeqCons(Seq.head xs, Seq.tail xs)

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


module LList =

    open Base.Combinator

    // All functions assume that list is lazy. In F# this is Sequence

    let map f x = Seq.map f x
    let accumulate = Seq.fold

    let head sq = Seq.head sq
    let tail sq = Seq.tail sq

    // let cons x ys = Seq.delay (fun () -> Seq.append (Seq.singleton x) ys)
    let cons x ys = Seq.append (Seq.singleton x) ys
    let consonto llst a = C cons llst a

    let revonto llst1 llst2 = accumulate (C cons) llst1 llst2
    let rev llst = revonto Seq.empty llst

    let filter = Seq.filter

    let nil = Seq.isEmpty

    let exists p x = not (nil (filter p x))

    let (<%>) x y = revonto y (rev x)

    let rec reduce f acc sq =
        match sq with
        | SeqEmpty       -> acc
        | SeqCons(x, xs) -> f x (reduce f acc xs)

    let (<%%>) x y = reduce cons y x

    // Here is how to model 1::2::3::(from 4)

    let rec from i = seq {
        yield i
        yield! from (i + 1)
    }

    // eager 'cons'
    let rec from1 i = cons i (Seq.delay (fun () -> from1(i + 1)))

    // 'cons' is lazy
    let rec from2 i = Seq.delay (fun () -> cons i (from2(i + 1)))

    let nat = from 1

module Sieve =

    open Base.Bool
    open LList

    let multipleof a b = (b % a = 0)
    let sift a x = LList.filter (non (multipleof a)) x

    // fun sieve (a :: x) = a :: sieve (sift a x)
    let rec sieve sq =
        Seq.delay (fun () -> let p = Seq.head sq
                             cons p (sieve (sift p (Seq.tail sq))))

    // Seq.cache should be used to avoid recalculate values every time
    let rec sieve2 sq =
        Seq.cache (Seq.delay (fun () -> let p = Seq.head sq
                                        cons p (sieve (sift p (Seq.tail sq)))))

    let primes = sieve2 (Seq.initInfinite (fun n -> n + 2))

module Hamming =

    // How to visualize

    // {1} ----∪-->--->--S₂--.---S₂----∪-->--->--S₂₃--.---S₂₃----∪-->--->--S₂₃₅--.--->S₂₃₅
    //     /               \       /                \         /                 \
    //     \______*2_______/       \______*3________/         \_______*5________/
    //       ---<----<---            ---<----<---                ---<----<---

    //                                                        1 --->--\
    //                                                                 \
    //                                       start/end  --->---> S ----::-----> S
    // .-->-- map *2 -->------>--------\         /                      |
    // |                             merge3 ->--/                      /   |
    // .-->-- map *3 -->--\            /                              /    | calculate next
    // |                 merge2 --->--/                              /     |
    // .-->-- map *5 -->--/                                         /      V
    //  \                                                          /
    //   \__________<__________<__________<_________<_____________/

    open Base.Int
    open LList

    let rec merge2 (xs: seq<int>) (ys: seq<int>) =
        let (a, x) = (head xs, tail xs)
        let (b, y) = (head ys, tail ys)

        if a < b then
            seq { yield a; yield! merge2 x ys }
        elif a > b then
            seq { yield b; yield! merge2 xs y }
        else
            seq { yield a; yield! merge2 x y }

    let merge3 (x, y, z) = merge2 x (merge2 y z)

    let rec hamming :seq<int> = seq {
        yield 1
        yield! merge3 (map (times 2) hamming,
                       map (times 3) hamming,
                       map (times 5) hamming)
    }
