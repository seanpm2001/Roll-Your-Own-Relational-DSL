#lang racket
(provide (all-defined-out))
(require typed/"unify.rkt")

(define-type State (Pair Subst Integer))
(define-type Stream (Rec S (U Null (Pair State S) (-> () S))))
(define-type Goal (-> State Stream))

(: == (-> Term Term Goal))
(define (== u v)
  (lambda (s/c)
    (let ((s (unify u v (car s/c))))
      (if s (list (cons s (cdr s/c))) `()))))
(: call/fresh (-> (-> Var Goal) Goal))
(define (call/fresh f)
  (lambda (s/c)
    (let ((c (cdr s/c)))
      ((f c) (cons (car s/c) (+ 1 c))))))
(: disj (-> Goal Goal Goal))
(define (disj g1 g2) (lambda (s/c) ($-append (g1 s/c) (g2 s/c))))
(: conj (-> Goal Goal Goal))
(define (conj g1 g2) (lambda (s/c) ($-append-map g2 (g1 s/c))))
(: $-append (-> Stream Stream Stream))
(define ($-append $1 $2)
  (cond
    ((procedure? $1) (lambda () ($-append $2 ($1))))
    ((null? $1) $2)
    (else (cons (car $1) ($-append (cdr $1) $2)))))
(: $-append-map (-> Goal Stream Stream))
(define ($-append-map g $)
  (cond
    ((procedure? $) (lambda () ($-append-map g ($))))
    ((null? $) `())
    (else ($-append (g (car $)) ($-append-map g (cdr $))))))
(: call/empty-state (-> Goal Stream))
(define (call/empty-state g) (g `(,(Some '()) . 0)))