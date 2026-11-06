(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: gun
;;
;; This fires the specified projectiles
;;;;;;;;;

(c:define-component gun ()
  ((%input-handler :accessor input-handler
                   :initarg :input-handler
                   :initform nil)

   ;; The actor's transform which identifies the direction the mitter uses.
   (%emitter-transform :accessor emitter-transform
                       :initarg :emitter-transform
                       :initform nil)
   ;; The emitter component that does the emitting of the bullets.
   (%emitter :accessor emitter
             :initarg :emitter
             :initform nil)
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
