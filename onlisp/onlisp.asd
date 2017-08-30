;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl-user)

(asdf:defsystem #:onlisp
  :version "1.0"
  :maintainer "Zlatozar Zhelyazkov"
  :description "Code from Paul Graham's 'On Lisp'"
  :serial t
  :components ((:file "package")
               (:file "macros" :depends-on ("package"))
               (:file "functions" :depends-on ("macros"))))
