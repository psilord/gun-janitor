(in-package #:gun-janitor)

;; upon attaching, this component will store find the transform component
;; on the actor to which it has been attached and keep a direct reference to it.
(defmethod c:on-component-attach ((self player-mover) actor)
  (declare (ignore actor))
  (with-accessors ((actor c:actor) (transform transform)) self
    (setf transform (c:component-by-type actor 'comp:transform))))

(defun get-deadzone-corrected-gamepad-analog (self deadzone input)
  "Return an unclipped unquantized movement-vector relating to the analog stick
displacement taking the deadzone size into consideration."
  (with-accessors ((context c:context)
                   (translate-deadzone translate-deadzone)) self
    (u:mvlet* ((lx ly (c:get-gamepad-analog context deadzone input))
               (movement-vec (v3:vec lx ly 0f0))
               (len-movement-vec (v3:length movement-vec))
               ;; If movement vec is more than 1 length, mormalize it.
               (movement-vec
                (if (> len-movement-vec 1f0)
                    (v3:normalize movement-vec)
                    movement-vec))
               ;; if movement vec is in deadzeon, zero it.
               (movement-vec
                (if (< len-movement-vec translate-deadzone)
                    (v3:zero)
                    movement-vec)))
      movement-vec)))

(defun quantize-analog-movement-vector-to-8-way (analog-movement-vec)
  "We expect the ANALOG-MOVEMENT-VECTOR to be a vec3 with X, Y, 0f0 for its
components. Return a vector that is, wrt the local space, one of 8 directions
usually observed from a dpad. The vector should be of magnitude 1."

  (v3:with-components ((l analog-movement-vec))
    (let* ((angle (atan ly lx))
           (angle (if (minusp angle)
                      (+ o:pi (- o:pi (abs angle)))
                      angle)))
      ;; TODO: Optimize this alittle, maybe add new nw, ne, se, sw directions
      ;; into the v3 constants.
      (cond
        ((v3:zero-p analog-movement-vec)
         v3:+zero+)
        ;; east
        ((or (>= angle o:15pi/8) (< angle o:pi/8))
         v3:+right+)
        ;; north east
        ((and (>= angle o:pi/8) (< angle o:3pi/8))
         (v3:normalize (v3:+ v3:+up+ v3:+right+)))
        ;; north
        ((and (>= angle o:3pi/8) (< angle o:5pi/8))
         v3:+up+)
        ;; north west
        ((and (>= angle o:5pi/8) (< angle o:7pi/8))
         (v3:normalize (v3:+ v3:+up+ v3:+left+)))
        ;; west
        ((and (>= angle o:7pi/8) (< angle o:9pi/8))
         v3:+left+)
        ;; south west
        ((and (>= angle o:9pi/8) (< angle o:11pi/8))
         (v3:normalize (v3:+ v3:+left+ v3:+down+)))
        ;; south
        ((and (>= angle o:11pi/8) (< angle o:13pi/8))
         v3:+down+)
        ;; south east
        ((and (>= angle o:13pi/8) (< angle o:15pi/8))
         (v3:normalize (v3:+ v3:+right+ v3:+down+)))))))

(defmethod c:on-component-update ((self player-mover))
  (with-accessors ((context c:context) (max-velocity max-velocity)
                   (translate-deadzone translate-deadzone)
                   (region-cuboid region-cuboid)
                   (gamepad-id gamepad-id))
      self

    (let* (;; First, read the dpad signals.
           (left (c:on-button-enabled context gamepad-id :left))
           (right (c:on-button-enabled context gamepad-id :right))
           (up (c:on-button-enabled context gamepad-id :up))
           (down (c:on-button-enabled context gamepad-id :down))
           (dpad-movement-vec
             (v3:+ (v3:+ (if left v3:+left+ v3:+zero+)
                         (if right v3:+right+ v3:+zero+))
                   (v3:+ (if up v3:+up+ v3:+zero+)
                         (if down v3:+down+ v3:+zero+))))
           ;; Then read the half-speed button.
           (speed-control
             (if (c:on-button-enabled context gamepad-id :left-shoulder)
                 .5f0
                 1f0))
           ;; Then, read the left analog stick
           (analog-movement-vec
             (get-deadzone-corrected-gamepad-analog
              self :radial-scaled `(,gamepad-id :left-stick)))
           (analog-movement-vec
             (quantize-analog-movement-vector-to-8-way analog-movement-vec)))

      ;; KEEP GOING: Quantize the analog-movement-vec, and complete
      ;; the computation of the dpad movement-vec

      (let* (;; Mix the dpad and analog-stick vectors. Normally only one
             ;; will be used at a time, but if both are, attempt to let
             ;; the player do it.

             (final-movement-vec
               (v3:+ dpad-movement-vec analog-movement-vec))

             (final-movement-vec
               (if (v3:= final-movement-vec v3:+zero+)
                   v3:+zero+
                   (v3:normalize final-movement-vec)))

             (final-movement-vec
               (v3:scale final-movement-vec
                         (* max-velocity
                            speed-control
                            (c:frame-time context))))

             (current-translation (c:get-translation self))
             (clipped-move (c:clip-movement-vector
                            final-movement-vec current-translation
                            region-cuboid)))


        ;; place myself where I should go.
        (c:translate self clipped-move :space :inertial))

      )))
