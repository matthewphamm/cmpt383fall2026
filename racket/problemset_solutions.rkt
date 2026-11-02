#lang racket
;; Solutions to Racket_problemset.md, questions 1-9 (the ones covered on the quiz).
;; Uses #lang racket so `curry` from the notes is available for question 8;
;; everything else sticks to recursion, first/rest/cons/cond, and fold-right.

(define (check expr actual expected)
  (cond [(equal? actual expected) (list 'ok expr)]
        [else (list 'FAIL expr 'got actual 'expected expected)]))

;; Question 1
;; i is the index of (first lst) in the original list
(define (index-of-helper x lst i)
  (cond [(empty? lst) -1]
        [(equal? x (first lst)) i]
        [else (index-of-helper x (rest lst) (+ i 1))]))

(define (index-of x lst)
  (index-of-helper x lst 0))

(check '(index-of 'a '(a 1 2 3 4))  (index-of 'a '(a 1 2 3 4))  0)
(check '(index-of 'a '(0 1 2 a a))  (index-of 'a '(0 1 2 a a))  3)
(check '(index-of 'a '(one two three four))  (index-of 'a '(one two three four))  -1)

;; Question 2
(define (my-member? x lst)
  (cond [(empty? lst) #f]
        [(equal? x (first lst)) #t]
        [else (my-member? x (rest lst))]))

(define (my-subset? lst1 lst2)
  (cond [(empty? lst1) #t]
        [else (and (my-member? (first lst1) lst2)
                   (my-subset? (rest lst1) lst2))]))

(check '(my-subset? '() '())  (my-subset? '() '())  #t)
(check '(my-subset? '() '(1 2))  (my-subset? '() '(1 2))  #t)
(check '(my-subset? '(2 1 1) '(1 2))  (my-subset? '(2 1 1) '(1 2))  #t)
(check '(my-subset? '(2 1 3) '(1 2))  (my-subset? '(2 1 3) '(1 2))  #f)
(check '(my-subset? '(a d (3 1)) '(1 a (3 d)))  (my-subset? '(a d (3 1)) '(1 a (3 d)))  #f)
(check '(my-subset? '((1) (2 2)) '((3 3 3) a (2 2) (1)))  (my-subset? '((1) (2 2)) '((3 3 3) a (2 2) (1)))  #t)

;; Question 3
(define (my-remove-duplicates lst)
  (cond [(empty? lst) '()]
        [(my-member? (first lst) (rest lst))      ; a later copy will be kept
         (my-remove-duplicates (rest lst))]
        [else (cons (first lst) (my-remove-duplicates (rest lst)))]))

(check '(my-remove-duplicates '(1 2 3 2))  (my-remove-duplicates '(1 2 3 2))  '(1 3 2))
(check '(my-remove-duplicates '(4 4 4))  (my-remove-duplicates '(4 4 4))  '(4))
(check '(my-remove-duplicates '(up up and a way way))  (my-remove-duplicates '(up up and a way way))  '(up and a way))

;; Question 4
(define (make-consed x)
  (cond [(empty? x) x]
        [(not (list? x)) x]
        [else (list 'cons
                    (make-consed (first x))
                    (make-consed (rest x)))]))

(check '(make-consed '())  (make-consed '())  '())
(check '(make-consed '(a b c))  (make-consed '(a b c))  '(cons a (cons b (cons c ()))))
(check '(make-consed '((a b) c d))  (make-consed '((a b) c d))  '(cons (cons a (cons b ())) (cons c (cons d ()))))

;; Question 5
(define (my-map f lst)
  (cond [(empty? lst) '()]
        [else (cons (f (first lst)) (my-map f (rest lst)))]))

(define (my-filter pred? lst)
  (cond [(empty? lst) '()]
        [(pred? (first lst)) (cons (first lst) (my-filter pred? (rest lst)))]
        [else (my-filter pred? (rest lst))]))

(define (my-fold-right f init lst)
  (cond [(empty? lst) init]
        [else (f (first lst) (my-fold-right f init (rest lst)))]))

(check '(my-map list '(a b c))  (my-map list '(a b c))  '((a) (b) (c)))
(check '(my-map (lambda (x) (* x x)) '(1 2 3))  (my-map (lambda (x) (* x x)) '(1 2 3))  '(1 4 9))
(check '(my-filter even? '(1 2 3 4))  (my-filter even? '(1 2 3 4))  '(2 4))
(check '(my-filter symbol? '(1 a 2 b))  (my-filter symbol? '(1 a 2 b))  '(a b))
(check '(my-fold-right + 0 '(1 2 3 4))  (my-fold-right + 0 '(1 2 3 4))  10)
(check '(my-fold-right - 0 '(1 2 3 4))  (my-fold-right - 0 '(1 2 3 4))  -2)
(check '(my-fold-right cons '() '(1 2 3))  (my-fold-right cons '() '(1 2 3))  '(1 2 3))

;; Question 6
(define (fold-right op init lst)   ; as defined in the notes
  (cond [(empty? lst) init]
        [else (op (first lst) (fold-right op init (rest lst)))]))

(define (my-filter2 pred? lst)
  (fold-right (lambda (next acc)
                (cond [(pred? next) (cons next acc)]
                      [else acc]))
              '()
              lst))

(check '(my-filter2 even? '(1 2 3 4))  (my-filter2 even? '(1 2 3 4))  '(2 4))
(check '(my-filter2 odd? '())  (my-filter2 odd? '())  '())

;; Question 7
;; Currying turns a function that takes several inputs into a chain of
;; functions that each take ONE input. Instead of (f x y), you call ((f x) y):
;; (f x) returns a new function that is waiting for y. This lets you supply
;; arguments one at a time, e.g. to make specialized functions like add5.
(define (curry2 f)
  (lambda (x)
    (lambda (y)
      (f x y))))

(define curried-add (curry2 +))
(define add5 (curried-add 5))        ; a function still waiting for y
(check '(add5 10)  (add5 10)  15)
(check '(((curry2 cons) 'a) '(b c))  (((curry2 cons) 'a) '(b c))  '(a b c))
(check '(my-map ((curry2 *) 2) '(1 2 3))  (my-map ((curry2 *) 2) '(1 2 3))  '(2 4 6))

;; Question 8
;; a)
(define (M x) (x x))                 ; call x on itself
(define (I x) x)                     ; identity
(define (K x) (lambda (y) x))        ; constant function that always returns x
(define (S3 x y z) ((x z) (y z)))
(define S (curry S3))                ; curried S, as in the notes

(check '(I 4)  (I 4)  4)
(check '(M list)  (M list)  (list list))
(check '((K 'pizza) 'ignored)  ((K 'pizza) 'ignored)  'pizza)
(check '(S3 (lambda (n) (lambda (m) (+ n m))) (lambda (n) (* 2 n)) 3)  (S3 (lambda (n) (lambda (m) (+ n m))) (lambda (n) (* 2 n)) 3)  9)

;; b) I = S K K, because ((S K K) a) = ((K a) (K a)) = a
(define (I2 a) ((S K K) a))

(check '(I2 4)  (I2 4)  4)
(check '(I2 '(a b c))  (I2 '(a b c))  '(a b c))

;; Question 9
(define (evaluate expr)
  (cond [(number? expr) expr]
        [else
         (let* ([left  (evaluate (first expr))]
                [op    (second expr)]
                [right (evaluate (third expr))])
           (cond [(or (equal? left 'error) (equal? right 'error)) 'error] ; pass errors up
                 [(equal? op '+) (+ left right)]
                 [(equal? op '-) (- left right)]
                 [(equal? op '*) (* left right)]
                 [(and (equal? op '/) (= right 0)) 'error]
                 [(equal? op '/) (/ left right)]
                 [else (error "unknown operator:" op)]))]))

(check '(evaluate '(1 + 2))  (evaluate '(1 + 2))  3)
(check '(evaluate '((1 + 2) * 3))  (evaluate '((1 + 2) * 3))  9)
(check '(evaluate '((1 + 2) * (3 - 4)))  (evaluate '((1 + 2) * (3 - 4)))  -3)
(check '(evaluate '((5 - 1) / 0))  (evaluate '((5 - 1) / 0))  'error)
(check '(evaluate '(((5 - 1) / 0) + 1))  (evaluate '(((5 - 1) / 0) + 1))  'error)
(check '(evaluate '(8 / 2))  (evaluate '(8 / 2))  4)
