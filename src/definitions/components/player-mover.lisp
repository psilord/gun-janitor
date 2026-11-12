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
   (%input-handler :accessor input-handler
                   :initarg :input-handler
                   :initform nil)
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
   ;; the origin of the scaffold that the ship may not exit. Prolly
   ;; should find a better way to clip the ship so it stays onscreen and
   ;; automatically accounts for where weapons might be placed.
   (%region-cuboid :accessor region-cuboid
                   :initarg :region-cuboid
                   :initform (c:make-region-cuboid
                              (v3:vec 0f0 0f0 0f0)
                              ;; screen width, adjusted for ship size
                              ;; (including any weapon placements on the ship)
                              (+ -240f0 24f0) (- 240f0 24f0)
                              ;; screen height, adjusted for ship size
                              ;; (including any weapon placements on the ship)
                              ;;
                              ;; TODO: The 26 is because the front gun
                              ;; is 2 units infront of the ship and we
                              ;; need to catch when it leaves the
                              ;; playfield. I dunno yet how to make this
                              ;; better.
                              (+ -320f0 24f0) (- 320f0 26f0)
                              -10f0 10f0))))
