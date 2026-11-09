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

(defun self-collision-response (self other)
  "This figures out how SELF component should assign damage to itself
and/or respond when OTHER component has collided with it. When A and B
collide first, A collides with B and then B collides with A. This
function is always from the point of view of A--and hence is called in
both C:ON-COLLISION-ENTER methods for a single collision!"

  ;; First, gather self's hit-point and other's damage-point component.
  (let* ((context (c:context self)) ;; all contexts are identical.
         (self-actor (c:actor self))
         (other-actor (c:actor other))
         (self-hit-points
           (c:component-by-type self-actor 'hit-points))
         (other-damage-points
           (c:component-by-type other-actor 'damage-points)))

    ;; Then, subtract the other damage-points from self's hit-points,
    ;; clamping at zero.
    (decf (hp self-hit-points) (dp other-damage-points))
    (when (< (hp self-hit-points) 0)
      (setf (hp self-hit-points) 0))

    ;; Then, if self's hit-points are actually zero, spawn an
    ;; explosion at self's coordinate in the universe and destroy
    ;; self's actor.
    (when (zerop (hp self-hit-points))
      (let* ((self-explosion
               (c:component-by-type self-actor 'explosion))
             (self-transform
               (c:component-by-type self-actor 'comp:transform))
             (current-rotation
               (c:get-rotation self :space :model))
             (world-spawn-point
               (c:transform-point self-transform v3:+zero+)))

        (make-explosion context (prefab self-explosion)
                        world-spawn-point
                        current-rotation
                        (render-layer self-explosion)))

      ;; And finally, destroy myself.
      (c:destroy self-actor))))

(defmethod c:on-collision-enter ((self ship-computer) other-collider)
  (let ((other (comp:referent other-collider)))
    #++(format t "[~A|~A] <entered> [~A|~A]~%"
               (c:display-id (c:actor self))
               (type-of self)
               (c:display-id (c:actor other))
               (type-of other))
    (self-collision-response self other)))

;; Not used yet (maybe for grazing).
(defmethod c:on-collision-continue ((self ship-computer) other-collider)
  nil)

(defmethod c:on-collision-exit ((self ship-computer) other-collider)
  #++(let ((other (comp:referent other-collider)))
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
    #++(format t "[~A|~A] <entered> [~A|~A]~%"
               (c:display-id (c:actor self))
               (type-of self)
               (c:display-id (c:actor other))
               (type-of other))
    (self-collision-response self other)))

;; Not used yet (maybe for grazing).
(defmethod c:on-collision-continue ((self projectile) other-collider)
  nil)

(defmethod c:on-collision-exit ((self projectile) other-collider)
  #++(let ((other (comp:referent other-collider)))
       (format t "[~A|~A] <exited> [~A|~A]~%"
               (c:display-id (c:actor self))
               (type-of self)
               (c:display-id (c:actor other))
               (type-of other))))
