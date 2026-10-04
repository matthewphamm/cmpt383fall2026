#lang racket/base

;; tiny-lisp
;;
;; This module *is* the language for `#lang tiny-lisp`. Unlike
;; `racket_restrict` (which is "racket minus one thing"), this is a
;; whitelist: the ONLY bound identifiers a `#lang tiny-lisp` program
;; gets are the ones explicitly `provide`d below. 
;;

(require (only-in racket/base
                   #%module-begin #%app #%datum #%top #%top-interaction
                   define cond else and or not quote cons list equal? 
                   + - * / <= >= < > = sqrt sin cos
                   let let* lambda
                   symbol? number? boolean? list? pair? even? odd?
                   error)
         (only-in racket/list first rest empty?))

(provide #%module-begin #%app #%datum #%top #%top-interaction
         define cond else and or not quote cons list equal? 
         + - * / <= >= < > = sqrt sin cos
         let let* lambda
         symbol? number? boolean? list? pair? even? odd?
         error
         first rest empty?)
