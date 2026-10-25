(in-package #:gun-janitor)


(defmethod c:on-component-attach ((self direction-mover) actor)
  (declare (ignore actor))
  (with-accessors ((actor c:actor) (transform transform)) self
    (setf transform (c:component-by-type actor 'comp:transform))))

(defmethod c:on-component-physics-update ((self direction-mover))
  (with-accessors ((context c:context)
                   (transform transform)
                   (velocity velocity)
                   (direction direction))
      self
    ;; TODO: Figure out why I need this when physics is faster. It
    ;; appears I can compute a physics frame before transform components
    ;; are attached?
    (when transform

      ;; Set myself to the start-pos if any.
      (unless (start-init-p self)
        (u:when-let ((spos (start-pos self)))
          (c:translate transform (start-pos self) :space :inertial))
        (setf (start-init-p self) T))

      (when (moving-p self)
        ;; compute the vector we need to move by
        (let* ((local (comp:local transform))
               (self-pos (m4:get-translation local))
               (movement-vec
                 (let* ((x (m4:rotation-axis-to-vec3 local :x))
                        (y (m4:rotation-axis-to-vec3 local :y))
                        (z (m4:rotation-axis-to-vec3 local :z))
                        (a (v3:normalize
                            (if (symbolp direction)
                                (ecase direction
                                  (:+x x)
                                  (:-x (v3:negate x))
                                  (:+y y)
                                  (:-y (v3:negate y))
                                  (:+z z)
                                  (:-z (v3:negate z)))
                                direction)))
                        (move-delta (* velocity (c:delta context))))
                   (v3:scale a move-delta))))

          ;; If we far away, keep moving, when we reach the endpoint, then
          ;; fixate ourselves to the endpoint.
          ;;
          ;; TODO: This can overshoot and not stop if the radius is less
          ;; than the displacement or the movement never reaches near
          ;; enough the end-pos or otherwise snap in visually annoying
          ;; ways. This implies that I should do this a very different
          ;; way--like say using a pamarametric line mover.

          (if (end-pos self)
              (let ((goal-delta (v3:- (end-pos self) self-pos)))
                (if (<= (v3:length goal-delta) (stop-radius self))
                    (progn
                      ;; snap exactly to the endpoint and stop moving.
                      (c:translate transform goal-delta :space :inertial)
                      (setf (moving-p self) nil))
                    ;; otheriwse, just move more.
                    (c:translate transform movement-vec :space :inertial)))
              ;; otherwise, just move more.
              (c:translate transform movement-vec :space :inertial))

          )))))
