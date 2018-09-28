## F# specific

The `>>` operator composes two functions, so `x |> (g >> f)` **=** `x |> g |> f = f (g x)`.
There's also another operator `<<` which composes in the other direction, so that
`(f << g) x` **=** `f (g x)`, which may be more natural in some cases.

Note that `|>` operator is more common - data could be send. `>>` only for function composition.

## Basic principles

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