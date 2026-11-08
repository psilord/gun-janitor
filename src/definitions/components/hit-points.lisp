(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: hit-points
;;
;; Manage a number of hit-points for something and destroy my actor if I fall
;; to zero or below.
;;;;;;;;;

(c:define-component hit-points ()
  ((%hp :accessor hp
        :initarg :hp
        :initform 1)))
