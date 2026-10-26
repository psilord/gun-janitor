(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: gun
;;
;; This fires the specified projectiles
;;;;;;;;;

(c:define-component gun ()
  ((%gamepad-id :accessor gamepad-id
                :initarg :gamepad-id
                :initform :gamepad1)
   (%emitter-transform :accessor emitter-transform
                       :initarg :emitter-transform
                       :initform nil)
   (%rotate-deadzone :accessor rotate-deadzone
                     :initarg :rotate-deadzone
                     :initform .1f0)
   (%fire-rate :accessor fire-rate
               :initarg :fire-rate
               :initform 30f0) ;; hz
   ;; Keeps track of how much time passed since we fired last.
   (%cooldown-time :accessor cooldown-time
                   :initarg :cooldown-time
                   :initform 0f0)
   ;; name of the prefab to fire from the gun.
   (%prefab :accessor prefab
            :initarg :prefab
            :initform nil)))
