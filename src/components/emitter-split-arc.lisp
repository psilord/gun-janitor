(in-package #:gun-janitor)

(defmethod c:on-component-attach ((self emitter-split-arc) actor)
  (declare (ignore actor))
  (with-accessors ((actor c:actor)
                   (emitter-transform emitter-transform))
      self
    (setf emitter-transform (c:component-by-type actor 'comp:transform))))

(defun ensure-positive (value)
  "If VALUE is positive return it. Otherwise return 1 in the same type as the
VALUE."
  (if (plusp value)
      value
      (typecase value
        (integer 1)
        (rational 1/1)
        (single-float 1f0)
        (double-float 1d0)
        (real 1f0))))

(defun fire-the-pattern-step (self emitter-transform pattern-step)
  (with-accessors ((context c:context))
      self

    (let* ((current-rotation (c:get-rotation self :space :model))
           (world-spawn-point
             (c:transform-point emitter-transform v3:+zero+))

           (num-shots (aref pattern-step 0))
           ;; arc-pos is counterclockwise rotation from dir in radians
           (arc-pos (aref pattern-step 1))
           ;; arm-neg is clockwise rotation from dir in radians
           (arc-neg (aref pattern-step 2))
           ;; slerp interpolant from arc-po to arc-neg.
           (arc-interp (float (/ (ensure-positive (1- num-shots))) 1f0))
           ;; First, copy and rotate the current-rotation to the
           ;; arc-pos rotation.
           (start-rotation
             (q:rotate current-rotation
                       (q:orient :local (up self) arc-pos)))
           ;; Then, make the end rotation.
           (end-rotation
             (q:rotate current-rotation
                       (q:orient :local (up self) arc-neg))))

      ;; put this into a loop which slerps a transform and calls
      ;; make-projectile.
      (loop :for shot-idx :from 0 :below num-shots
            :for delta-arc = (* arc-interp shot-idx)
            :do
               (let ((slerped-rotation
                       (q:slerp start-rotation end-rotation delta-arc)))
                 ;; TODO: Implement radius.
                 (make-projectile context
                                  (prefab self)
                                  world-spawn-point
                                  slerped-rotation))))))

;; The GUN uses this to tell the emitter what state it should be in. The emitter
;; decides if it can achieve it.
(defmethod engage-emitter ((self emitter-split-arc) emitter-transform
                           start-firing-p continue-firing-p stop-firing-p)
  (with-accessors ((spread-patterns spread-patterns)
                   (step-idx step-idx))
      self

    (when (or start-firing-p continue-firing-p)
      (fire-the-pattern-step self emitter-transform
                             (aref spread-patterns step-idx)))
    (if stop-firing-p
        (setf step-idx 0)
        (setf step-idx (mod (1+ step-idx) (length spread-patterns))))))
