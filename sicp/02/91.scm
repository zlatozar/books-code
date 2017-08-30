; SICP exercise 2.91
;
; A univariate polynomial can be divided by another one to produce a
; polynomial quotient and a polynomial remainder. For example:
;
;   x⁵ - 1
;   ────── = x³ + x, remainder x - 1
;   x² - 1
;
; Division can be performed via long division. That is, divide the
; highest-order term of the dividend by the highest-order term of the divisor.
; The result is the first term of the quotient. Next, multiply the result by
; the divisor, subtract that from the dividend, and produce the rest of the
; answer by recursively dividing the difference by the divisor. Stop when the
; order of the divisor exceeds the order of the dividend and declare the
; dividend to be the remainder. Also, if the dividend ever becomes zero,
; return zero as both quotient and remainder.
;
; We can design a div-poly procedure on the model of add-poly and mul-poly.
; The procedure checks to see if two polys have the same variable. If so,
; div-poly strips off the variable and passes the problem to div-terms, which
; performs the division operation on term lists. div-poly finally reattaches
; the variable to the result supplied by div-terms. It is convenient to design
; div-terms to compute both the quotient and the remainder of a division.
; div-terms can take two term lists as arguments and return a list of the
; quotient term list and the remainder term list.
;
; Complete the following definition of div-terms by filling in the missing
; expressions. Use this to implement div-poly, which takes two polys as
; arguments and returns a list of quotient and remainder polys.
;
; (define (div-terms L1 L2)
;   (if (empty-termlist? L1)
;       (list (the-empty-termlist) (the-empty-termlist))
;       (let ((t1 (first-term L1))
;             (t2 (first-term L2)))
;         (if (> (order t2) (order t1))
;             (list (the-empty-termlist) L1)
;             (let ((new-c (div (coeff t1) (coeff t2)))
;                   (new-o (- (order t1) (order t2))))
;               (let ((rest-of-result
;                 <compute rest of result recursively>
;                 ))
;                 <form complete result>
;                 ))))))

; We base this on the dense representation in exercise 2.89.

; The type functions, table and coercion infrastructure.

(define (attach-tag type-tag contents)
  (cons type-tag contents))

(define (type-tag datum)
  (if (pair? datum)
      (car datum)
      (error "Bad tagged datum - TYPE-TAG" datum)))

(define (contents datum)
  (if (pair? datum)
      (cdr datum)
      (error "Bad tagged datum - CONTENTS" datum)))

(define table (make-hash))
(define (put op type item) (hash-set! table (list op type) item))
(define (get op type) (hash-ref table (list op type) #f))

(define (put-coercion from to op) (put 'coerce (list from to) op))
(define (get-coercion from to) (get 'coerce (list from to)))

; The type tower, supetype, supertype?, raise and project:

(put 'supertype 'integer 'rational)
(put 'supertype 'rational 'scheme-number)
(put 'supertype 'scheme-number 'real)

(define (supertype type)
  (get 'supertype type))

(define (supertype? a b)
  (let ((super (supertype a)))
    (cond ((equal? super b) #t)
          ((not super) #f)
          (else (supertype? super b)))))

(define (same-type? a b) (equal? (type-tag a) (type-tag b)))

(define (raise a) (apply-generic 'raise a))
(define (project a) (apply-generic 'project a))

(define (projectable? a) (get 'project (list (type-tag a))))
(define (raisable? a) (get 'raise (list (type-tag a))))

; Now a simplification procedure. It will be called simplify instead of drop,
; because drop is already reserved:

(define (simplify x)
  (cond ((not (projectable? x)) x)
        ((equ? (raise (project x)) x) (simplify (project x)))
        (else x)))

; Now the generic arithmemtic procedures.

(define (add x y) (apply-generic 'add x y))
(define (sub x y) (apply-generic 'sub x y))
(define (mul x y) (apply-generic 'mul x y))
(define (div x y) (apply-generic 'div x y))
(define (neg x) (apply-generic 'neg x))
(define (equ? x y) (apply-generic 'equ? x y))
(define (square-root x) (apply-generic 'square-root x))
(define (sine x) (apply-generic 'sine x))
(define (cosine x) (apply-generic 'cosine x))
(define (arctangent x y) (apply-generic 'arctangent x y))
(define (=zero? x) (apply-generic '=zero? x))
(define (square x) (mul x x))

; The simplification table:

(define (simplifiable? op)
  (get 'simplifiable op))

(put 'simplifiable 'add #t)
(put 'simplifiable 'sub #t)
(put 'simplifiable 'mul #t)
(put 'simplifiable 'div #t)
(put 'simplifiable 'neg #t)
(put 'simplifiable 'square-root #t)
(put 'simplifiable 'sine #t)
(put 'simplifiable 'cosine #t)
(put 'simplifiable 'arctangent #t)
(put 'simplifiable 'real-part #t)
(put 'simplifiable 'imag-part #t)
(put 'simplifiable 'magnitude #t)
(put 'simplifiable 'angle #t)

; Integers:

(let ()
  (define (tag x) (attach-tag 'integer x))
  (put 'add '(integer integer) (lambda (x y) (tag (+ x y))))
  (put 'sub '(integer integer) (lambda (x y) (tag (- x y))))
  (put 'mul '(integer integer) (lambda (x y) (tag (* x y))))
  (put 'neg '(integer) (lambda (x) (tag (- x))))
  (put 'equ? '(integer integer) =)
  (put '=zero? '(integer) zero?)
  (put 'raise '(integer) (lambda (n) (make-rational n 1)))
  (put 'make 'integer
       (lambda (n) (if (exact-integer? n)
                       (tag n)
                       (error "Attempted to make an integer with a non-integer" n)))))

(define (make-integer n) ((get 'make 'integer) n))

; Rational numbers:

(let ()
  (define (numer x) (car x))
  (define (denom x) (cdr x))
  (define (make-rat n d)
    (if (and (exact-integer? n) (exact-integer? d))
        (let ((g (gcd n d)))
          (cons (/ n g) (/ d g)))
        (error "Cannot construct a rational with non-exact numbers" n d)))

  (define (add-rat x y)
    (make-rat (+ (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (sub-rat x y)
    (make-rat (- (* (numer x) (denom y))
                 (* (numer y) (denom x)))
              (* (denom x) (denom y))))
  (define (mul-rat x y)
    (make-rat (* (numer x) (numer y))
              (* (denom x) (denom y))))
  (define (div-rat x y)
    (make-rat (* (numer x) (denom y))
              (* (denom x) (numer y))))
  (define (neg-rat x)
    (make-rat (- (numer x)) (denom x)))
  (define (=zero?-rat x)
    (zero? (numer x)))
  (define (raise-rat r)
    (make-real (exact->inexact (/ (numer r) (denom r)))))
  (define (project-rat r)
    (make-integer (truncate (/ (numer r) (denom r)))))

  (define (tag x) (attach-tag 'rational x))
  (put 'numer '(rational) numer)
  (put 'denom '(rational) denom)
  (put 'raise '(rational) raise-rat)
  (put 'project '(rational) project-rat)
  (put '=zero? '(rational) =zero?-rat)
  (put 'add '(rational rational) (lambda (x y) (tag (add-rat x y))))
  (put 'sub '(rational rational) (lambda (x y) (tag (sub-rat x y))))
  (put 'mul '(rational rational) (lambda (x y) (tag (mul-rat x y))))
  (put 'div '(rational rational) (lambda (x y) (tag (div-rat x y))))
  (put 'neg '(rational) (lambda (x) (tag (neg-rat x))))
  (put 'equ? '(rational rational) equal?)
  (put 'make 'rational (lambda (n d) (tag (make-rat n d)))))

(define (make-rational n d) ((get 'make 'rational) n d))
(define (numer r) (apply-generic 'numer r))
(define (denom r) (apply-generic 'denom r))

; Real numbers:

(let ()
  (define (tag x) (attach-tag 'real x))
  (put 'add '(real real) (lambda (x y) (tag (+ x y))))
  (put 'sub '(real real) (lambda (x y) (tag (- x y))))
  (put 'mul '(real real) (lambda (x y) (tag (* x y))))
  (put 'div '(real real) (lambda (x y) (tag (/ x y))))
  (put 'neg '(real) (lambda (x) (tag (- x))))
  (put 'sine '(real) (lambda (x) (tag (sin x))))
  (put 'cosine '(real) (lambda (x) (tag (cos x))))
  (put 'square-root '(real) (lambda (x) (tag (sqrt x))))
  (put 'arctangent '(real real) (lambda (x y) (tag (atan x y))))
  (put 'project '(real) (lambda (x) (make-rational (inexact->exact (truncate x)) 1)))
  (put 'equ? '(real real) =)
  (put '=zero? '(real) zero?)
  (put 'make 'real (lambda (x) (tag x))))

(define (make-real n) ((get 'make 'real) n))

; The polynomial package:

(let ()
  (define (make-poly variable term-list)
    (cons variable term-list))
  (define (variable p) (car p))
  (define (term-list p) (cdr p))

  (define (same-variable? v1 v2)
    (and (variable? v1) (variable? v2) (eq? v1 v2)))
  (define (variable? x) (symbol? x))

  (define (adjoin-term term term-list)
    (let ((term-list-order (- (length term-list) 1))
          (term-order (order term)))
      (cond ((=zero? (coeff term)) term-list)
            ((= term-list-order term-order)
             (cons (add (coeff term) (car term-list))
                   (cdr term-list)))
            ((< term-order term-list-order)
             (cons (car term-list) (adjoin-term term (cdr term-list))))
            ((> term-order term-list-order)
             (adjoin-term term (cons (make-integer 0) term-list))))))

  (define (the-empty-termlist) '())
  (define (first-term term-list) (make-term (- (length term-list) 1) (car term-list)))
  (define (rest-terms term-list) (cdr term-list))
  (define (empty-termlist? term-list) (null? term-list))

  (define (make-term order coeff) (list order coeff))
  (define (order term) (car term))
  (define (coeff term) (cadr term))

  (define (add-terms L1 L2)
    (cond ((empty-termlist? L1) L2)
          ((empty-termlist? L2) L1)
          (else
            (let ((t1 (first-term L1)) (t2 (first-term L2)))
              (cond ((> (order t1) (order t2))
                     (adjoin-term t1 (add-terms (rest-terms L1) L2)))
                    ((< (order t1) (order t2))
                     (adjoin-term t2 (add-terms L1 (rest-terms L2))))
                    (else
                      (adjoin-term
                        (make-term (order t1) (add (coeff t1) (coeff t2)))
                        (add-terms (rest-terms L1) (rest-terms L2)))))))))
  (define (mul-terms L1 L2)
    (if (empty-termlist? L1)
        (the-empty-termlist)
        (add-terms (mul-term-by-all-terms (first-term L1) L2)
                   (mul-terms (rest-terms L1) L2))))
  (define (mul-term-by-all-terms t1 L)
    (if (empty-termlist? L)
        (the-empty-termlist)
        (let ((t2 (first-term L)))
          (adjoin-term (make-term (+ (order t1) (order t2)) (mul (coeff t1) (coeff t2)))
                       (mul-term-by-all-terms t1 (rest-terms L))))))
  (define (sub-terms L1 L2)
    (add-terms L1 (neg-terms L2)))

  (define (div-terms L1 L2)
    (if (empty-termlist? L1)
        (list (the-empty-termlist) (the-empty-termlist))
        (let ((t1 (first-term L1))
              (t2 (first-term L2)))
          (if (> (order t2) (order t1))
              (list (the-empty-termlist) L1)
              (let* ((new-c (div (coeff t1) (coeff t2)))
                     (new-o (- (order t1) (order t2)))
                     (term (make-term new-o new-c))
                     (multiplier (adjoin-term term (the-empty-termlist)))
                     (rest-of-result (div-terms (sub-terms L1 (mul-terms multiplier L2))
                                                L2))
                     (result-quotient (car rest-of-result))
                     (result-remainder (cadr rest-of-result)))
                (list (adjoin-term term result-quotient) result-remainder))))))
  (define (neg-terms L)
    (map-terms neg L))

  (define (map-terms proc L)
    (if (empty-termlist? L)
        (the-empty-termlist)
        (let ((first (first-term L))
              (rest (rest-terms L)))
          (adjoin-term (make-term (order first) (proc (coeff first)))
                       (map-terms proc rest)))))

  (define (add-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (make-poly (variable p1)
                 (add-terms (term-list p1)
                            (term-list p2)))
      (error "Polynomials not in same var - ADD-POLY" (list p1 p2))))
  (define (mul-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (make-poly (variable p1)
                 (mul-terms (term-list p1)
                            (term-list p2)))
      (error "Polynomials not in same var - MUL-POLY" (list p1 p2))))
  (define (div-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (map (lambda (term-list) (make-poly (variable p1) term-list))
           (div-terms (term-list p1)
                      (term-list p2)))
      (error "Polynomials not in same var - DIV-POLY" (list p1 p2))))
  (define (sub-poly p1 p2)
    (if (same-variable? (variable p1) (variable p2))
      (make-poly (variable p1)
                 (sub-terms (term-list p1)
                            (term-list p2)))
      (error "Polynomials not in same var - SUB-POLY" (list p1 p2))))
  (define (neg-poly p)
    (make-poly (variable p)
               (neg-terms (term-list p))))

  (define (make-const p n)
    (tag (make-poly (variable p)
                    (adjoin-term (make-term 0 (make-integer n))
                                 (the-empty-termlist)))))

  (define (tag p) (attach-tag 'polynomial p))
  (put 'add '(polynomial polynomial) (lambda (p1 p2) (tag (add-poly p1 p2))))
  (put 'sub '(polynomial polynomial) (lambda (p1 p2) (tag (sub-poly p1 p2))))
  (put 'mul '(polynomial polynomial) (lambda (p1 p2) (tag (mul-poly p1 p2))))
  (put 'div '(polynomial polynomial) (lambda (p1 p2) (map tag (div-poly p1 p2))))
  (put '=zero? '(polynomial) (lambda (p) (empty-termlist? (term-list p))))
  (put 'neg '(polynomial) (lambda (p) (tag (neg-poly p))))

  (put 'add '(integer polynomial) (lambda (n p) (add (make-const p n) (tag p))))
  (put 'mul '(integer polynomial) (lambda (n p) (mul (make-const p n) (tag p))))
  (put 'add '(polynomial integer) (lambda (p n) (add (make-integer n) (tag p))))
  (put 'mul '(polynomial integer) (lambda (p n) (mul (make-integer n) (tag p))))

  (put 'make 'polynomial (lambda (var terms) (tag (make-poly var terms)))))

(define (make-polynomial var terms)
  ((get 'make 'polynomial) var terms))

; apply-generic with some coercion:

(define (apply-generic op . args)
  (define (applicable? args)
    (get op (map type-tag args)))

  (define (apply-generic-failed)
    (error "No method for these types - APPLY-GENERIC" (list op (map type-tag args))))

  (define (all-of-same-type? args)
    (define (check rest)
      (cond ((null? rest) #t)
            ((same-type? (car args) (car rest)) (check (cdr rest)))
            (else #f)))
    (check args))

  (define (of-same-type-and-raisable? args)
    (and (all-of-same-type? args)
         (raisable? (car args))))

  (define (coercable-to-same-type? args)
    (and (= (length args) 2)
         (let ((type-a (type-tag (car args)))
               (type-b (type-tag (cadr args))))
           (or (supertype? type-a type-b)
               (supertype? type-b type-a)))))

  (define (coerce-to-same-type args)
    (and (= (length args) 2)
         (let* ((a (car args))
                (b (cadr args))
                (type-a (type-tag a))
                (type-b (type-tag b)))
           (cond ((same-type? a b) (list a b))
                 ((supertype? type-a type-b) (coerce-to-same-type (list (raise a) b)))
                 ((supertype? type-b type-a) (coerce-to-same-type (list a (raise b))))
                 (else #f)))))

  (define (attempt-coercion args)
    (let ((number-of-arguments (length args)))
      (cond ((of-same-type-and-raisable? args) (try (map raise args)))
            ((coercable-to-same-type? args) (try (coerce-to-same-type args)))
            (else (apply-generic-failed)))))

  (define (try args)
    (if (applicable? args)
        (let ((result (apply (get op (map type-tag args)) (map contents args))))
          (if (simplifiable? op)
              (simplify result)
              result))
        (attempt-coercion args)))

  (try args))
