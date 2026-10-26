(in-package #:gun-janitor)

(defmethod c:on-component-attach ((self gun) actor)
  (declare (ignore actor))
  (with-accessors ((actor c:actor) (emitter-transform emitter-transform)) self
    (setf emitter-transform (c:component-by-type actor 'comp:transform))))

(defun fire-a-projectile (self)
  (with-accessors ((context c:context)
                   (rotate-deadzone rotate-deadzone)
                   (fire-rate fire-rate)
                   (cooldown-time cooldown-time)
                   (emitter-transform emitter-transform)
                   (gamepad-id gamepad-id))
      self

    (let* ((current-rotation (c:get-rotation self :space :model))
           (world-spawn-point
             (c:transform-point emitter-transform v3:+zero+)))

      ;; TODO: Implement an, which a gun controls, that actually
      ;; decides how to implement the firing.
      (make-projectile context
                       (prefab self)
                       world-spawn-point
                       current-rotation))))

(defmethod c:on-component-update ((self gun))
  (with-accessors ((context c:context)
                   (rotate-deadzone rotate-deadzone)
                   (fire-rate fire-rate)
                   (cooldown-time cooldown-time)
                   (emitter-transform emitter-transform)
                   (depth-layer depth-layer)
                   (gamepad-id gamepad-id))
      self

    ;; TODO: Maybe move this stuff into the player controls component
    ;; and just check for "should I be shooting right now" boolean
    ;; instead.
    (let ((start-firing-p (c:on-button-enter context gamepad-id :a))
          (continue-firing-p (c:on-button-enabled context gamepad-id :a))
          (firing-period (/ fire-rate)))

      ;; TODO: I could make a macro to do this syntax work, like
      ;; WITH-COMPONENT-TIMER that knows about start/continue, the
      ;; cooldown time and how much time to increment, but I think a
      ;; names registrant of a function into the component that is
      ;; called repeatedly is better since enabling and disabling from
      ;; elsewhere becomes possible. Will think about for later.
      (cond
        (start-firing-p
         (fire-a-projectile self)
         (setf cooldown-time 0f0))

        (continue-firing-p
         (cond
           ((>= cooldown-time firing-period)

            ;; We keep track of time such that we're most accurate in time
            ;; that we next need to fire.
            (loop :while (>= cooldown-time firing-period)
                  :do (decf cooldown-time firing-period))

            (fire-a-projectile self))

           ;; Just accumulate more physics time at the rate we're
           ;; interested in until we know we can fire again.
           (t
            (incf cooldown-time (* fire-rate (c:delta context))))))))))
