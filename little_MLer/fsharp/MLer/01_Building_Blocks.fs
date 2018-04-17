module ch01

    type seasoning = 
        | Salt 
        | Pepper

    // Recursive union type
    type num = 
        | Zero 
        | One_more_than of num

    // 'ignore' disables warning
    One_more_than
      (One_more_than
         (One_more_than
            (One_more_than(Zero)))) |> ignore

    // NOTE:   
    //
    // What is an element of this new type? It is Zero!
    //
    // It is recursive type definition. One_more_than could contains Zero or
    // One_more_than but Zero can't - it is just a Zero. That's why you CAN'T do:
    //
    // Zero(One_more_than (Zero))  // an error

    type 'a open_faced_sandwich =
      | Bread of 'a
      | Slice of 'a open_faced_sandwich

    // ATTENTION: Everything that you use for definition should be defined before that.

    // THE FIRST MORAL

    // When a type contains lots of values, the type definition refers to itself.
    // Use 'a with type to define shapes (represents many different types). 
