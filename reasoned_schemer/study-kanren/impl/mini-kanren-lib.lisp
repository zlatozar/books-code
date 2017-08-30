;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: MINI-KANREN; Base: 10 -*-

;;; Copyright (c) 2008, Matthew Swank
;;; All rights reserved.

(in-package :mini-kanren)

(defmacro choice-case (key-term &body cases)
  (let ((kt-name (gensym)))
    `(fresh (,kt-name)
       (== ,key-term ,kt-name)
       (conde ,@(mapcar (lambda (case)
                          (destructuring-bind (keys &rest clauses) case
                            (cond ((eql keys 'else)
                                   clauses)
                                  ((consp keys)
                                   (if (cdr keys)
                                       `((conde ,@(mapcar (lambda (key)
                                                            `(== ,kt-name ',key))
                                                          keys))
                                         ,@clauses)
                                       `((== ,kt-name ',(car keys))
                                         ,@clauses)))
                                  (t `((== ,kt-name ',keys)
                                       ,@clauses)))))
                        cases)))))

(defun map-choice (fun &rest bindings)
  (labels ((compose-bindings (relation bindings)
             (if (some #'null bindings)
                 relation
                 (let ((terms (mapcar #'car bindings)))
                   (compose-bindings (conde (relation)
                                            ((apply fun terms)))
                                     (mapcar #'cdr bindings))))))
    (compose-bindings +fail+ bindings)))

(defun permute-binary-relation (relation)
  (lambda (a b)
    (conde ((funcall relation a b))
           ((funcall relation b a)))))

(defun make-binary-relation (mapping)
  (lambda (a b)
    (map-choice (lambda (a1 b1)
                  (fresh ()
                    (== a a1)
                    (== b b1)))
                (mapcar #'first mapping)
                (mapcar #'second mapping))))

;; This needs to confirm that compile time evaluation is possible:
;; mapping is a quoted list, n is a number, etc

#+ (or)
(define-compiler-macro make-nary-relation (n mapping)
  (let* ((maps (loop :for x :from 0 :below n
                  :collect `',(mapcar (lambda (list)
                                        (nth x list))
                                      mapping)))
         (args (loop :for x :from 0 :below n
                  :collect (gensym)))
         (args1 (loop :for x :from 0 :below n
                   :collect (gensym)))
         (sequence (mapcar (lambda (a a1)
                             `(== ,a ,a1))
                           args
                           args1)))
    `(lambda ,args
       (map-choice (lambda ,args1
                     (fresh ()
                       ,@sequence))
                   ,@maps))))

(defun make-nary-relation (n mapping)
  (let ((maps (loop :for x :from 0 :below n
                 :collect (mapcar (lambda (list)
                                    (nth x list))
                                  mapping))))
    (lambda (&rest args)
      (unless (= (length args) n)
        (error "invalid number of arguments"))
      (apply #'map-choice
             (lambda (&rest args1)
               (let ((sequence nil))
                 (map nil (lambda (a a1)
                            (unless sequence
                              (setf sequence (== a a1)))
                            ;; we don't want to capture the binding
                            ;; (this should be a fold)
                            (let ((seq sequence))
                              (setf sequence (fresh () seq (== a a1)))))
                      args
                      args1)
                 sequence))
             maps))))

(defun permute-ternary-relation (relation)
  (lambda (a b c)
    (conde ((funcall relation a b c))
           ((funcall relation a c b))
           ((funcall relation c b a))
           ((funcall relation b a c))
           ((funcall relation c a b))
           ((funcall relation b c a)))))

(defun make-ternary-relation (mapping)
  (lambda (a b c)
    (map-choice (lambda (a1 b1 c1)
                  (fresh ()
                    (== a a1)
                    (== b b1)
                    (== c c1)))
                (mapcar #'first mapping)
                (mapcar #'second mapping)
                (mapcar #'third mapping))))
