(in-package #:gun-janitor)


;; ;;;;;;;;;
;; Component: ship-computer

;; This component handles things like accepting damage (which may result in
;; explosions or other behavioral changes), Invulnerability during spawning,
;; and anything else the ship (or ship-like thing) needs.
;; ;;;;;;;;;

(c:define-component ship-computer ()
  ((%spawn-invulnerable-p :accessor spawn-invulnerable-p
                          :initarg :spawn-invulnerable-p
                          :initform nil)
   (%spawn-invulnerability-time :accessor spawn-invulnerability-time
                                :initarg :spawn-invulnerability-time
                                :initform 0f0)
   ;; A reference to the damage-points component
   (%damage-points :accessor damage-points
                   :initarg :damage-points
                   :initform nil)
   ;; A reference to the hit-points component.
   (%hit-points :accessor hit-points
                :initarg :hit-points
                :initform nil)
   ;; A reference to an explosion component.
   (%explosion :accessor explosion
               :initarg :explosion
               :initform nil)))
