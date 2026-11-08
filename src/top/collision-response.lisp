(in-package #:gun-janitor)

;; This code contains what happens when components of different types
;; collide and what should be done about it.

;; NOTE: We tacitly assume that the self component and the referent
;; component on the collider have HIT-POINTS and DAMAGE-POINTS as
;; available methods to get the corresponding components.

;; The protocol is that self has hit-points and reaches into other's
;; damage-points and applies other's damage, if any, to _self_. This
;; way, when two things collide and these method are called twice with
;; the arguments in different order, nothing gets processed twice.


;; ;;;;;;;;;;;;;;;
;; ship-computer <-> ship-computer, projectile
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self ship-computer) other-collider)
  (let ((other (comp:referent other-collider)))
    (format t "[~A|~A] <entered> [~A|~A]~%"
            (c:display-id (c:actor self))
            (type-of self)
            (c:display-id (c:actor other))
            (type-of other))))

;; Not used yet (maybe for grazing).
(defmethod c:on-collision-continue ((self ship-computer) other-collider)
  nil)

(defmethod c:on-collision-exit ((self ship-computer) other-collider)
  (let ((other (comp:referent other-collider)))
    (format t "[~A|~A] <exited> [~A|~A]~%"
            (c:display-id (c:actor self))
            (type-of self)
            (c:display-id (c:actor other))
            (type-of other))))

;; ;;;;;;;;;;;;;;;
;; projectile <-> projectile, ship-computer
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self projectile) other-collider)
  (let ((other (comp:referent other-collider)))
    (format t "[~A|~A] <entered> [~A|~A]~%"
            (c:display-id (c:actor self))
            (type-of self)
            (c:display-id (c:actor other))
            (type-of other))))

;; Not used yet (maybe for grazing).
(defmethod c:on-collision-continue ((self projectile) other-collider)
  nil)

(defmethod c:on-collision-exit ((self projectile) other-collider)
  (let ((other (comp:referent other-collider)))
    (format t "[~A|~A] <exited> [~A|~A]~%"
            (c:display-id (c:actor self))
            (type-of self)
            (c:display-id (c:actor other))
            (type-of other))))
