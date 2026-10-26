(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: projectile
;;
;; This describes a projectile (bullet, damaging shrapnel, etc) and its
;; API to set it up when it spawns.
;;;;;;;;;

(c:define-component projectile ()
  ((%name :accessor name
          :initarg :name
          :initform nil)
   (%velocity :accessor velocity
              :initarg :velocity
              :initform 0f0)
   (%frames :accessor frames
            :initarg :frames
            :initform 0)
   (%physics-layer :accessor physics-layer
                   :initarg :physics-layer
                   :initform nil)
   (%transform :accessor transform
               :initarg :transform
               :initform nil)
   (%depth-layer :accessor depth-layer
                 :initarg :depth-layer
                 :initform nil)
   (%collider :accessor collider
              :initarg :collider
              :initform nil)
   (%mover :accessor mover
           :initarg :mover
           :initform nil)
   (%sprite :accessor sprite
            :initarg :sprite
            :initform nil)
   (%destroy-ttl :accessor destroy-ttl
                 :initarg :destroy-ttl)))
