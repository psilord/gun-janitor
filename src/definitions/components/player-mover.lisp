(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: player-mover
;;
;; First we need a component that allows the player to move around.
;; We're going to left the left joystick place the player and the right one
;; orient the player.
;; ;;;;;;;;;

(c:define-component player-mover ()
  (;; which gamepad to use for a player-mover instance.
   (%gamepad-id :accessor gamepad-id
                :initarg :gamepad-id
                :initform :gamepad1)
   (%transform :accessor transform
               :initarg :transform
               :initform nil)
   (%max-velocity :accessor max-velocity
                  :initarg :max-velocity
                  :initform 300f0)
   (%translate-deadzone :accessor translate-deadzone
                        :initarg :translate-deadzone
                        :initform .1f0)
   ;; We just hack in a boundary cube you can't go outside of. This is in the
   ;; local space of the actor to which this component is attached.
   ;; The format is minx, maxx, miny, maxy, minz, maxz.
   ;;
   ;; TODO: The min/max constants describe one screen size centered at
   ;; the origin of the scaffold that the ship may not exit.
   (%region-cuboid :accessor region-cuboid
                   :initarg :region-cuboid
                   :initform (c:make-region-cuboid
                              (v3:vec 0f0 0f0 0f0)
                              -240f0 240f0 -320f0 320f0 -10f0 10f0))))
