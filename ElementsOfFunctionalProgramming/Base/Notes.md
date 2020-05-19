## F# specific

- The `>>` operator composes two functions, so `x |> (g >> f)` **=** `x |> g |> f = f (g x)`.
  There's also another operator `<<` which composes in the other direction, so that
  `(f << g) x` **=** `f (g x)`, which may be more natural in some cases.

  Note that `|>` operator is more common - data could be send. `>>` only for function composition.

- `List.scan` and `List.scanBack` are analog of Haskell's `scanl/scanr`.
## Functions design

In computing, a _specification_(function type) is a description of what task a
program is to perform, while an _implementation_ is a program that satisfies the
specification. Specifications and implementations serve different purposes:
specifications are expressions of the programmer's intent (or client's
expectations) and their purpose is to be clear as possible; implementations are
expressions for execution by computer and their purpose is to be efficient
enough to execute within the time or space available. The link between the two
is the requirement that the implementations satisfies, or meets, the
specification, and the programmer may be obliged to provide a proof that this is
indeed the case. By trying to follow the approach whenever we can, the
reliability of programs can be greatly increased.

```fsharp
let myFunc : int -> int = ...
```

## Basic principles

At the heart of functional programming is the ability to introduce new datatypes
and to define functions that manipulate their values.

There are two basic views of lists, given by the type declarations:

```
listR A ::= nil | cons (A, listR A)
listL A ::= nil | snoc (listL A, A)

cons (a, x) = [a] ++ x
snoc (x, a) = x ++ [a]
```

```fsharp
let exists p l =
    let rec existsp lst =
        match lst with
        | []   -> false
        | a::x -> if p a then true
                  else existsp x
    existsp l
```
better remove `l` it is redundunt

```fsharp
let exists p =
    let rec existsp lst =
        match lst with
        | []   -> false
        | a::x -> if p a then true
                  else existsp x
    existsp
```

We notised that in `exists` breaks when first element is found.
If we revert the predicate `non p` then we will break when exist element that do not satify `p`.
In this way `forall` function is implemented: `non (exists (non p)) lst`

`let consonto x y = C cons`

```fsharp
let rec assoc newassocs oldassocs a =
    match newassocs with
    | []             -> oldassocs a
    | (a1, b1)::rest -> if a = a1 then b1
                        else assoc rest oldassocs a
```
better style is

```fsharp
let assoc newassocs oldassocs arg =
    let rec search lst =
        match lst with
        | []           -> oldassocs arg
        | (k, v)::rest -> if arg = k then v else search rest
    search newassocs
```

**The structure of a function is determined by the structure of its domain.**

In functional programming the universe of values is partitioned into
organised collections, called _types_
