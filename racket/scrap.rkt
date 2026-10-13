#lang tiny-lisp

;; Problem 1: count-evens

(define (count-evens L)
  (cond [(empty? L) 0]
        [(even? (first L))
         (+ 1 (count-evens (rest L)))]
        [else
         (count-evens (rest L))]
        ))

(define (sum L)
  (cond [(empty? L)
         0]
        [else
         (+ (first L)
            (sum (rest L)))
         ]))

;; TODO:
;; > (range 5) returns '(0 1 2 3 4)

(define (range-helper i n)
  (cond [(not (number? n))
         (error "Not an integer")]
        [(>= i n)
         '()]
        [else
          (cons i (range-helper (+ i 1) n))]
        ))
  

(define (range num)
  (range-helper 0 num))

(define (max-of-helper L largest)
  (cond [(empty? L)
         largest]
        [(> (first L) largest)
         (max-of-helper (rest L) (first L))]
        [else
          (max-of-helper (rest L) largest)]
        ))


(define (max-of L)
  (cond [(empty? L)
         (error "empty list")]
        [else
          (max-of-helper L 0)]
        ))

(define (min x y)
  (cond [(<= x y)
         x]
        [else
          y]))
         