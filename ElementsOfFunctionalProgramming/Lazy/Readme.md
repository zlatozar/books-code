## F# notes

- Prefer LazyList over Sequence, because of pattern matching and automatic caching

## When to use lazy programming?

- Lazy evaluation is performant (and correct) only when correctly mixed with
  referential transparency. If the state of your variables is constantly
  changing, you can forget about memoization, and suddenly lazy evaluation
  becomes slower than doing it eagerly.

## Misc.

- Evaluation is the process of getting the root meaning of a piece of code.

- The reason so few compilers support lazy evaluation is that it makes writing
  an imperative, OOP-style compiler tricky.

- A lazy compiler can be much more efficient if it makes smart choices. For lazy
  evaluation to be efficient, it needs to use memoization. In other words, it
  needs to keep a dictionary where the key is the name of the variable, and the
  value is the result of the evaluation. When it encounters an already evaluated
  variable, it can simply look up the value in the dictionary.

- With lazy compilers, `if`s are not primitives (built into the compiler) but
  instead a part of the standard library of the language.
