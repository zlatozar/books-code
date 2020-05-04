module IOMonad

let replicate n x =
    let rec aux count acc =
        if count = 0 then acc
        else aux (count - 1) (x::acc)
    aux n []

/// Imperative function should be wrapped and become lazy
type io<'a> =
    IO of (unit -> 'a)

//________________________________________________________
//                                          Implementation

/// Forces the evaluation of an IO action
let run : 'a io -> 'a =
    fun (IO thunk) -> thunk ()

/// Ctr-D to exit
let rec forever (ma: unit io) =
    IO (fun () -> run ma
                  run (forever ma)
                  ())

let unit : 'a -> 'a io  =
    fun a -> IO (fun () -> a)

let bind : 'a io -> ('a -> 'b io) -> 'b io =
    fun io_a fn_io ->
        IO (fun () -> let a = run io_a in
                      run (fn_io a))

let (>>=) = bind

let (>>) ma mb =
    ma >>= fun _ -> mb

/// Kleisli function composition
let (>=>) f1 f2 arg =
    f1 arg >>= f2

let map fn ma =
    // ma >>= fun a -> unit (fn a)
    ma >>= (unit << fn)

/// Converts an output function into a monadic output IO action
let liftOut : ('a -> unit) -> ('a -> unit io) =
    fun output_fn a -> IO (fun () -> output_fn a)

/// Converts an input function into a monadic input IO action
let liftIn : (unit -> 'a) -> 'a io =
    IO

let sequence mlist =
    let mcons p q =
        p >>= fun x ->
            q >>= fun y ->
                unit (x::y)

    List.foldBack mcons mlist (unit [])

let sequence_ mlist =
    List.foldBack (>>) mlist (unit ())

let replicateM_ n ma =
    sequence_ (replicate n ma)

let replicateM n ma =
    sequence (replicate n ma)

let mapM_: ('a -> unit io) -> 'a list -> unit io =
    fun fn alst -> sequence_ (List.map fn alst)

let mapM : ('a -> 'b io) -> 'a list -> ('b list) io =
    fun fn alst -> sequence (List.map fn alst)

//________________________________________________________
//                                 Primitive IO functions

open System

let printStr = liftOut (printfn "%s")
let printInt = liftOut (printfn "%i")
let printChar = liftOut (printfn "%c")

let readStr = liftIn (Console.ReadLine)
let readChar = liftIn (fun () -> Console.ReadKey().KeyChar)
