(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Move something in a straight line along a specified
;; cardinal axis or a vector. This is not a sophisticated component and has
;; problems like overshoot for the end-pos.
;;;;;;;;;

(c:define-component direction-mover ()
  ((%direction :accessor direction
               :initarg :direction
               ;; NOTE: may be :+y :-y :+x :-x :+z :-z or a vec3
               :initform :+y)
   ;; This is in relation to the parent of the object having this component.
   ;; if not defined, don't initially set the translate of the transform.
   (%start-pos :accessor start-pos
               :initarg :start-pos
               :initform nil)
   ;; This is in relation to the parent of the object having this component.
   ;; if not defined, don't stop moving.
   (%end-pos :accessor end-pos
             :initarg :end-pos
             :initform nil)
   ;; Did we initialize the transform to the start point yet?
   (%start-init-p :accessor start-init-p
                  :initarg :start-init-p
                  :initform nil)
   ;; Should we be moving?
   (%moving-p :accessor moving-p
              :initarg :moving-p
              :initform t)
   ;; When we get this close, stop moving and fixate to end-pos
   (%stop-radius :accessor stop-radius
                 :initarg :stop-radius
                 :initform 1f0)
   ;; The transform we'll be affecting.
   (%transform :accessor transform
               :initarg :transform
               :initform nil)
   (%velocity :accessor velocity
              :initarg :velocity
              :initform 0f0)))
