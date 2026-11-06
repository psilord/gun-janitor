(in-package #:gun-janitor)

(defmethod c:on-component-attach ((self gun) actor)
  (declare (ignore actor))
  (with-accessors ((actor c:actor)
                   (emitter-transform emitter-transform)
                   (input-handler input-handler))
      self
    (setf emitter-transform (c:component-by-type actor 'comp:transform))))

(defmethod c:on-component-update ((self gun))
  (with-accessors ((context c:context)
                   (rotate-deadzone rotate-deadzone)
                   (fire-rate fire-rate)
                   (cooldown-time cooldown-time)
                   (emitter-transform emitter-transform)
                   (emitter emitter)
                   (depth-layer depth-layer)
                   (input-handler input-handler))
      self

    ;; TODO: Maybe move this stuff into the player controls component
    ;; and just check for "should I be shooting right now" boolean
    ;; instead.
    (let* ((gamepad-id (player-1-gamepad-id input-handler))
           (start-firing-p (c:on-button-enter context gamepad-id :a))
           (continue-firing-p (c:on-button-enabled context gamepad-id :a))
           (stop-firing-p (c:on-button-exit context gamepad-id :a))
           (firing-period (/ fire-rate))
           (delta (c:delta context)))

      ;; TODO: I could make a macro to do this syntax work, like
      ;; WITH-COMPONENT-TIMER that knows about start/continue, the
      ;; cooldown time and how much time to increment, but I think a
      ;; names registrant of a function into the component that is
      ;; called repeatedly is better since enabling and disabling from
      ;; elsewhere becomes possible. Will think about for later.
      (cond
        (start-firing-p
         (engage-emitter emitter emitter-transform
                         start-firing-p continue-firing-p stop-firing-p)
         (setf cooldown-time 0f0))

        (continue-firing-p
         (cond
           ((>= cooldown-time firing-period)

            ;; We keep track of time such that we're most accurate in time
            ;; that we next need to fire.
            (loop :while (>= cooldown-time firing-period)
                  :do (decf cooldown-time firing-period))

            (engage-emitter emitter emitter-transform
                            start-firing-p continue-firing-p stop-firing-p))

           ;; Just accumulate more physics time at the rate we're
           ;; interested in until we know we can fire again.
           (t
            (incf cooldown-time (* fire-rate
                                   ;; Conversion factor for c:delta into Hz.
                                   (/ (/ 60f0) delta)
                                   delta))))))

      ;; finally, if we also stopped firing this frame, tell the emitter
      ;; that too.
      (when stop-firing-p
        (engage-emitter emitter emitter-transform
                        start-firing-p continue-firing-p stop-firing-p)))))
