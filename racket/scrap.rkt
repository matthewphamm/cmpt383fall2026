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

(define (member? x L)
  (cond [(empty? L)
         #f]
        [(equal? x (first L))
         #t]
        [else
          (member? x (rest L))]
        ))

;; remove-all, remove-first, remove-last, or remove-index at a certain index in a list
(define (length-acc L acc)
  (cond [(empty? L)
         acc]
        [else
          (length-acc (rest L)
                      (+ 1 acc))]
        ))


(define (length2 L)
  (length-acc L 0))

(define (map f L)
  (cond [(empty? L)
         '()]
        [else
         (cons (f (first L))
               (map f (rest L)))]
        ))

(define (filter pred? L)
  (cond [(empty? L)
         '()]
        [(pred? (first L))
         (cons (first L)
               (filter pred? (rest L)))]
        [else
         (filter pred? (rest L))]))

#;(define (all pred? L)
  (cond [(empty? L)
         #t]
        [else
         (and (pred? (first L))
              (all pred? (rest L)))]))

#;(define (all pred? L)
    (equal? L
            (filter pred? L)))

;; important as in the quiz it can ask us to write it in a single line instead of multi line
;; try to start thinking of this idea of a single line code

(define (negate pred?)
  (lambda (x) (not (pred? x))))

(define (none pred? L)
  (all (negate pred?) L))

(define (all pred? L)
  (empty? (filter (negate pred?) L)))

;; (op a (op b (op c (op d init))))
(define (foldr op init L)
  (cond [(empty? L)
         init]
        [else
         (op (first L) 
            (foldr op init (rest L)))]))

(define (length3 L)
  (foldr (lambda (next acc) (+ acc 1))
         0
         L))

(define (member2? x L)
  (foldr (lambda (next acc) (or (equal? x next) acc))
         #f
         L))

(define (map2 f L)
  (foldr (lambda (next acc)
           (cons (f next)
                 acc))
         '()
         L))

(define (filter2 pred? L)
  (foldr (lambda (next acc)
           (cond [(pred? next)
                  (cons next acc)]
                 [else
                  acc]))
         '()
         L))

(define (append2 A B)
  (foldr cons
         B
         A))

(define (concat list-of-lists)
  (cond [(empty? list-of-lists)
         '()]
        [else
         (append2 (first list-of-lists)
                 (concat (rest list-of-lists)))]
        ))

;; suppose I have an insert-sorted function use foldr to call this function or something (could be on the quiz)

(define (insertion-sort L)
  (foldr insert-sorted
         '()
         L))

(define (insert-sorted x L)
  (cond [(empty? L)
         (list x)]
        [(<= x (first L))
         (cons x L)]
        [else
         (cons (first L)
               (insert-sorted x (rest L)))]
        ))

(define (quicksort L)
  (cond [(<= (length2 L) 1)
         L]
        [else
         (let* [(pivot (first L))
                (smalls (filter (lambda (n) (< n pivot))
                                (rest L)))
                (bigs (filter (lambda (n) (>= n pivot))
                              (rest L)))]
           (concat (list (quicksort smalls)
                         (list pivot)
                         (quicksort bigs))))]))

(define (flatten L)
  (cond [(empty? L)
         '()]
        [(list? (first L))
         (append2 (flatten (first L))
                  (flatten (rest L)))]
        [else
         (cons (first L)
               (flatten (rest L)))]))

(define (deep-sum L)
  (sum (flatten L)))

(define (deep-member? x L)
  (member? x (flatten L)))

(define (compose f g)
  (lambda (x) (f (g x))))

;; identity function
(define (I x) x)

;; (compose d I)
;; (lambda (x) (d (I x))
;; (lambda (x) (d x))

(define (compose-all fns)
  (foldr compose
         I
         fns
         ))

#; (define (pipeline fns)
     (compose-all (reverse fns)))

#; (define (I z) (S3 K K z))

;; Question: what is (S3 I I z)?

;; Example: the flip function
(define (flip f)
  (lambda (x y) (f y x)))

;; (define bus (flip -))
;; (bus 1 4)
;; > 3

;; (define fcons (flip cons))
;; (fcons '(b c d) 'a)
;; > '(a b c d)
                         