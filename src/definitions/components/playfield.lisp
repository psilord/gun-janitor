(in-package #:gun-janitor)

;; In collider-response.lisp, we simply have to know we exited the collision
;; with this component to destroy the bullets existing it. So far, this has
;; no other fields required.
(c:define-component playfield ()
  ())
