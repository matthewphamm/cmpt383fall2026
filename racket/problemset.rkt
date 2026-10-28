#lang tiny-lisp

;; Question 1
;; returns the index location of the first occurence of x in lst using recursion. If x
;; is not in lst, then return -1, index starts at 0


;; can we use an accumulator for this question?

(define (index-of-helper x lst indx)
  (cond [(empty? lst)
         -1]
        [(equal? x (first lst))
         indx]
        [else
         (index-of-helper x (rest lst) (+ indx 1))]
        ))

(define (index-of x lst)
  (index-of-helper x lst 0))

;; Question 2
;; returns true when every element of lst1 is a member of lst2
;; the empty list is considered a subset of all other lists

;; can we use the functions to know from notes?
;; first check if every element of lst1 is in lst2 using `member?`, create a list of booleans
;; then check if false is a member in the list of booleans, if so return true otherwise false of
;; that not (very complicated)

(define (member? x L)
  (cond [(empty? L)
         #f]
        [(equal? x (first L))
         #t]
        [else
         (member? x (rest L))]
        ))

(define (my-subset-helper lst1 lst2)
  (cond [(empty? lst1)
         '()]
        [else
         (cons (member? (first lst1) lst2)
               (my-subset-helper (rest lst1) lst2))]
        ))

(define (my-subset? lst1 lst2)
  (cond [(empty? lst1)
         #t]
        [else
         (not (member? #f (my-subset-helper lst1 lst2)))]))

;; Question 3
;; returns a list that is the same as lst except all elements in lst that occur more than once
;; are removed, exact order of the elements on the returned list doesn't matter
;; basically return a unique list of lst

;; idea: if an element is not a member in the return list add it to the list otherwise continue
;;       through the given lst

(define (my-remove-duplicates-helper lst result)
  (cond [(empty? lst)
         result]
        [(not (member? (first lst) result))
         (my-remove-duplicates-helper (rest lst) (cons (first lst) result))]
        [else
         (my-remove-duplicates-helper (rest lst) result)]
        ))

(define (my-remove-duplicates lst)
  (my-remove-duplicates-helper lst '())
  )

;; Question 4

(define (make-consed x)
  (cond [(empty? x)
         x]
        [(not (list? x))
         x]
        [else
         (list 'cons
               (make-consed (first x))
               (make-consed (rest x)))]
        ))
          
;; Question 5

(define (my-map f lst)
  (cond [(empty? lst)
         '()]
        [else
         (cons (f (first lst))
               (my-map f (rest lst)))]
        ))

(define (my-filter pred? lst)
  (cond [(empty? lst)
         '()]
        [(pred? (first lst))
         (cons (first lst)
               (my-filter pred? (rest lst)))]
        [else
         (my-filter pred? (rest lst))]
        ))

;; (op a (op b (op c (op d init))))
(define (my-fold-right f init lst)
  (cond [(empty? lst)
         init]
        [else
         (f (first lst)
            (my-fold-right f init (rest lst)))]
        ))
  
;; Question 6

(define (my-filter-foldr pred? lst)
  (my-fold-right (lambda (next acc)
                   (cond [(pred? next)
                          (cons next acc)]
                         [else
                          acc]))
                 '()
                 lst))

;; Quesiton 7


