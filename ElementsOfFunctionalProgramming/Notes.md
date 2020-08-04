## Generic project structure in F#

```
-- Common
      |_src
      |  |_ test
      |       |_ ProgramTest.fs
      |
      |_ Core
      |    |_ test
      |    |    |_ FileTest.fs
      |    |
      |    |_ File.fs
      |           module ModuleName
      |
      |           // declare all needed types
      |
      |           [<RequireQualifiedAccess>]
      |           module ModuleName
      |               // define all operations
      |
      |_ SomeOtherModule
      |
      |_ Program.fs
      |
      |_ Makefile
           build:
           test:
           repl:

-- Library1
....
-- LibraryN
-- MainProject

-- Project.sln
-- Readme.md
-- LICENSE
-- .gitignore
-- .gitattributes
```
