## Some useful F# tricks

- Define functions to select from tuple

```fsharp
let depth (Pic(d, _, _)) = d
let width (Pic(_, w, _)) = w
let linesof (Pic(_, _, sl)) = sl
```

- Represent 2D objects as list and use `map` to manipulate them.

- Overlay

First, however, we need to decide how the overlaying can be done. Roughly speaking, it
will involve taking an appropriate row from each picture and splicing the characters of
one row into an appropriate place in the other row, displacing any characters already
there.
