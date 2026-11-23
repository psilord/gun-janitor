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

;; TODO: decide if colony's collision system should always collide the
;; referent against the referent instead of the referent against he actor.

(defun dump-collision (event-type self-referent self-collider
                       other-referent other-collider)
  (format t "[~A|~A] ~(~S~) [~A|~A]~%"
          (c:display-id (c:actor self-collider))
          (type-of self-referent)
          event-type ;; :enter :exit :continue
          (c:display-id (c:actor other-collider))
          (type-of other-referent)))

(defun self-accept-damage (self-referent self-collider
                           other-referent other-collider)
  "This figures out how SELF component should assign damage to itself
and/or respond when OTHER component has collided with it. When A and B
collide first, A collides with B and then B collides with A. This
function is always from the point of view of A--and hence is called in
both C:ON-COLLISION-ENTER methods for a single collision!"

  (declare (ignore other-collider))

  ;; First, gather self's hit-point and other's damage-point component.
  (let* ((context (c:context self-collider)) ;; all contexts are identical.
         (self-actor (c:actor self-collider))
         (self-hit-points (hit-points self-referent))
         (other-damage-points (damage-points other-referent)))

    ;; Then, subtract the other damage-points from self's hit-points,
    ;; clamping at zero.
    (decf (hp self-hit-points) (dp other-damage-points))
    (when (< (hp self-hit-points) 0)
      (setf (hp self-hit-points) 0))

    ;; Then, if self's hit-points are actually zero, spawn an
    ;; explosion at self's coordinate in the universe and destroy
    ;; self's actor.
    (when (zerop (hp self-hit-points))
      (let* ((self-explosion (explosion self-referent))
             (self-transform
               (c:component-by-type self-actor 'comp:transform))
             (current-rotation
               (c:get-rotation self-transform :space :model))
             (world-spawn-point
               (c:transform-point self-transform v3:+zero+)))

        (make-explosion context (prefab self-explosion)
                        world-spawn-point
                        current-rotation
                        (render-layer self-explosion)))

      ;; And finally, destroy myself.
      (c:destroy self-actor))))

;; NOTE: c:on-collision-map to allow access to internal collision structures
;; for a component like say if it wanted to know that A is in collisions with
;; B C D E F G ... Z all at the same time.


;; ;;;;;;;;;;;;;;;
;; ship-computer <-> ship-computer
;;
;; Ship is hit by ship.
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent ship-computer)
                                 (self-collider c:component)
                                 (other-referent ship-computer)
                                 (other-collider c:component))
  (self-accept-damage self-referent self-collider
                      other-referent other-collider))

(defmethod c:on-collision-continue ((self-referent ship-computer)
                                    (self-collider c:component)
                                    (other-referent ship-computer)
                                    (other-collider c:component))
  ;; Not used yet (maybe for grazing).
  nil)

(defmethod c:on-collision-exit ((self-referent ship-computer)
                                (self-collider c:component)
                                (other-referent ship-computer)
                                (other-collider c:component))
  nil)

;; ;;;;;;;;;;;;;;;
;; projectile <-> ship-computer
;;
;; Projectile is hit by shipp.
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent projectile)
                                 (self-collider c:component)
                                 (other-referent ship-computer)
                                 (other-collider c:component))
  (self-accept-damage self-referent self-collider
                      other-referent other-collider))

(defmethod c:on-collision-continue ((self-referent projectile)
                                    (self-collider c:component)
                                    (other-referent ship-computer)
                                    (other-collider c:component))
  ;; Not used yet (maybe for grazing).
  nil)

(defmethod c:on-collision-exit ((self-referent projectile)
                                (self-collider c:component)
                                (other-referent ship-computer)
                                (other-collider c:component))
  nil)


;; ;;;;;;;;;;;;;;;
;; ship-computer <-> projectile
;;
;; Ship is hit by projectile.
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent ship-computer)
                                 (self-collider c:component)
                                 (other-referent projectile)
                                 (other-collider c:component))
  (self-accept-damage self-referent self-collider
                      other-referent other-collider))

(defmethod c:on-collision-continue ((self-referent ship-computer)
                                    (self-collider c:component)
                                    (other-referent projectile)
                                    (other-collider c:component))
  ;; Not used yet (maybe for grazing).
  nil)

(defmethod c:on-collision-exit ((self-referent ship-computer)
                                (self-collider c:component)
                                (other-referent projectile)
                                (other-collider c:component))
  nil)


;; ;;;;;;;;;;;;;;;
;; projectile <-> projectile
;;
;; Two bullets (enemy and player) collide.
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent projectile)
                                 (self-collider c:component)
                                 (other-referent projectile)
                                 (other-collider c:component))
  nil)

(defmethod c:on-collision-continue ((self-referent projectile)
                                    (self-collider c:component)
                                    (other-referent projectile)
                                    (other-collider c:component))
  nil)

(defmethod c:on-collision-exit ((self-referent projectile)
                                (self-collider c:component)
                                (other-referent projectile)
                                (other-collider c:component))
  nil)


;; ;;;;;;;;;;;;;;;
;; projectile <-> playfield
;;
;; Projectile is hit by playfield.
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent projectile)
                                 (self-collider c:component)
                                 (other-referent playfield)
                                 (other-collider c:component))
  nil)

(defmethod c:on-collision-continue ((self-referent projectile)
                                    (self-collider c:component)
                                    (other-referent playfield)
                                    (other-collider c:component))
  nil)

(defmethod c:on-collision-exit ((self-referent projectile)
                                (self-collider c:component)
                                (other-referent playfield)
                                (other-collider c:component))
  ;; projectile destroys itself as it leaves the playfield.
  (c:destroy (c:actor self-collider)))

;; ;;;;;;;;;;;;;;;
;; playfield <-> projectile
;;
;; Playfield is hit by projectile
;; ;;;;;;;;;;;;;;;

(defmethod c:on-collision-enter ((self-referent playfield)
                                 (self-collider c:component)
                                 (other-referent projectile)
                                 (other-collider c:component))
  nil)

(defmethod c:on-collision-continue ((self-referent playfield)
                                    (self-collider c:component)
                                    (other-referent projectile)
                                    (other-collider c:component))
  nil)

(defmethod c:on-collision-exit ((self-referent playfield)
                                (self-collider c:component)
                                (other-referent projectile)
                                (other-collider c:component))
  nil)
