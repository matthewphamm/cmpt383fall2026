#lang racket
;; CMPT 383 Quiz 3 (Racket), Summer 2026 -- solutions

;; course version of fold-right (see demo2.rkt)
(define (fold-right op init lst)
  (if (empty? lst)
      init
      (op (first lst)
          (fold-right op init (rest lst)))))

;; Q1
(define (almost-last lst)
  (cond [(or (empty? lst) (empty? (rest lst))) 'none]
        [(empty? (rest (rest lst))) (first lst)]
        [else (almost-last (rest lst))]))

;; Q2
(define (drop-if pred? lst)
  (fold-right (lambda (next acc)
                (if (pred? next)
                    acc
                    (cons next acc)))
              '()
              lst))

;; Q3 answers
;; ((first (rest (list rest first))) '(3 5 1 2))            => 3
;; (map (lambda (x) (if (list? x) x (list x))) '(a (b) c (d e)))
;;                                                          => '((a) (b) (c) (d e))
;; (map (lambda (x) (cons (length x) x)) (map list '(a b c)))
;;                                                          => '((1 a) (1 b) (1 c))
;; (filter (lambda (x) (or (symbol? x) (number? x)))
;;         (list 1 2 'three 'four '(2 3)))                  => '(1 2 three four)
;; (reverse (map (lambda (x) (cons x (list x))) (reverse '(a b c))))
;;                                                          => '((a a) (b b) (c c))
;; (fold-right (lambda (x y) y) 0 '(1 2 3 4))               => 0
;; (fold-right equal? 3 '(3 3 3))                           => #f
;;    (equal? 3 (equal? 3 (equal? 3 3))) = (equal? 3 (equal? 3 #t)) = (equal? 3 #f)
;; (apply cons (reverse '((a) (2))))                        => '((2) a)
;;    (cons '(2) '(a))
;; (M symbol?)                                              => #f
;;    (symbol? symbol?)
;; ((lambda (b) ((lambda (a) (- b a)) 5)) 1)                => -4
;; (equal? (+c 2 3) 5)                                      => #f  (official answer)

(module+ test
  (require rackunit)
  (define (M x) (x x))
  (check-equal? (almost-last '()) 'none)
  (check-equal? (almost-last '(a)) 'none)
  (check-equal? (almost-last '(a b)) 'a)
  (check-equal? (almost-last '(a b c)) 'b)
  (check-equal? (almost-last '(a b c d)) 'c)
  (check-equal? (drop-if even? '(1 2 3 4 5)) '(1 3 5))
  (check-equal? ((first (rest (list rest first))) '(3 5 1 2)) 3)
  (check-equal? (map (lambda (x) (if (list? x) x (list x))) '(a (b) c (d e))) '((a) (b) (c) (d e)))
  (check-equal? (map (lambda (x) (cons (length x) x)) (map list '(a b c))) '((1 a) (1 b) (1 c)))
  (check-equal? (filter (lambda (x) (or (symbol? x) (number? x))) (list 1 2 'three 'four '(2 3))) '(1 2 three four))
  (check-equal? (reverse (map (lambda (x) (cons x (list x))) (reverse '(a b c)))) '((a a) (b b) (c c)))
  (check-equal? (fold-right (lambda (x y) y) 0 '(1 2 3 4)) 0)
  (check-equal? (fold-right equal? 3 '(3 3 3)) #f)
  (check-equal? (apply cons (reverse '((a) (2)))) '((2) a))
  (check-equal? (M symbol?) #f)
  (check-equal? ((lambda (b) ((lambda (a) (- b a)) 5)) 1) -4))
