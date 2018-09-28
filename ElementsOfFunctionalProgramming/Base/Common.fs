module Base.Common

let error s = failwith (sprintf "ERROR REPORT:\n%s\n" s)

let equal a b =
    a = b
