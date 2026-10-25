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
   ;; name and frames of projectile to fire.
   (%name :accessor name
          :initarg :name
          :initform "blue-shot-small")
   (%frames :accessor frames
            :initarg :frames
            :initform 1)
   (%duration :accessor duration
              :initarg :duration
              :initform 1)
   ;; Hrm, this one here is a bit funny. It mesans I shoudl really break up my
   ;; different projectiles into prefabs as opposed to collapsing the code
   ;; together and parameterizing their construction.
   (%repeat :accessor repeat
            :initarg :repeat
            :initform t)))
