;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

;;; Copyright (c) 2008, Matthew Swank
;;; All rights reserved.

(asdf:defsystem :study-kanren
  :depends-on (#:alexandria)

  :serial t
  :components  ((:file "packages")

                ;; miniKanren
                (:file "impl/mini-kanren" :depends-on ("packages"))
                (:file "impl/mini-kanren-lib" :depends-on ("impl/mini-kanren"))

                ;; To test miniKanren implementation and book code
                (:file "tools/test" :depends-on ("packages"))

                ;; Functions defined in book
                (:file "book-code" :depends-on ("impl/mini-kanren"))
                (:file "book-code-test" :depends-on ("book-code"))

                ;; Lectures notes
                (:file "study-kanren/lec01" :depends-on ("tools/test" "book-code"))
                (:file "study-kanren/lec02" :depends-on ("tools/test" "book-code"))

                ))
