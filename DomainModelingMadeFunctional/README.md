This directory contains code samples related to the book "Domain Modeling Made Functional"

## Organization

* `OrderTaking` contains the workflow as part of a complete bounded context.
    - version 1 of the implementation without side effects
    - version 2 with side effects
* `/src/OrderTakingEvolved` contains the workflow (final version) after the changes in the Evolution chapter.
    - version 3 of the implementation

## Getting started

After downloading this code, do the following:

* Run `dotnet build` to download all the NuGet packages and compile the project

## Additional articles

https://increment.com/software-architecture/primer-on-functional-architecture/

https://habr.com/post/337880/

https://fsharpforfunandprofit.com/posts/recipe-part3/

https://fsharpforfunandprofit.com/posts/elevated-world/

https://fsharpforfunandprofit.com/posts/serializating-your-domain-model/

## Additional videos

https://www.youtube.com/watch?v=vDe-4o8Uwl8

https://www.youtube.com/watch?v=mEFbjt_87TU

https://www.youtube.com/watch?v=ez9GWESKG4I&list=PLJfcKimCUDGtGyKzHcHOeliv5j3uSJR0W&index=2&t=0s

https://www.youtube.com/watch?v=KkzvQSuYd5I

## To remember

**Business logic** is a pure function (deterministic)!
No side effects - it doesn't talk to DB or web services, it doesn't throw exceptions.
