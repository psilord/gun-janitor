(in-package #:gun-janitor)

(c:define-component emitter-split-arc ()
  (;; Waiting from one step of the pattern to the next step.
   (%step-cooldown-time :accessor step-cooldown-time
                        :initarg :step-cooldown-time
                        :initform 1f0)

   ;; prefab API.
   ;; The index of the pattern from the spread-patterns we're executing.
   (%step-idx :accessor step-idx
              :initarg :step-idx
              :initform 0)
   (%emitter-transform :accessor emitter-transform
                       :initarg :emitter-transform
                       :initform nil)
   (%up :accessor up
        :initarg :up
        :initform :z)
   (%direction :accessor direction
               :initarg :direction
               :initform v3:+zero+)
   (%radius :accessor radius
            :initarg :radius
            :initform 0f0)
   (%spread-patterns :accessor spread-patterns
                     :initarg :spread-patterns
                     :initform #(1 0f0 0f0))
   ))
