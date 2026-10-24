(in-package #:gun-janitor)

;; c:define-texture have no ordering dependencies between themselves.
;; c:define-texture must come before c:define-material
;; c:define-materials have no ordering dependencies between themselves.
;; TODO: c:define-model order at this load location.
;; c:define-prefab DOES have an ordering between themselves.

(defparameter *draw-layer* (u:dict
                            #'eq
                            :background -100f0
                            :background-damage -99f0
                            :enemy-ship -.05f0
                            :enemy-explosion -.04f0
                            :enemy-bullet -.03f0
                            :player-bullet -.02f0
                            :player-explosion -.01f0
                            :player 0f0
                            :scaffold 0f0 ;; MUST stay at 0f0
                            :player-stable 98f0
                            :text-ui 99f0
                            :camera 100f0))

(defun dl (draw-layer-name)
  (u:href *draw-layer* draw-layer-name))

;; NOTE: Must be same order as the z axis layering above. Last it greatest Z,
;; first is least Z.
(defparameter *render-layer-order*
  '(:background
    :background-damage
    :enemy-ship
    :enemy-explosion
    :enemy-bullet
    :player-bullet
    :player-explosion
    :player
    :scaffold
    :player-stable
    :text-ui
    :camera))


;; the venerable player.
(c:define-prefab "player1-ship" (:library lib/main)
  "The venerable Player Ship. Controls how it looks, collides, and movement."
  (tags :tags '(:player))
  #++(explosion :name "explode04-01" :frames 15
                :scale (v3:vec 2f0 2f0 2f0))
  #++(damage-points :dp 1)
  #++(hit-points :hp 1
                 :render-layer :player-explosion
                 ;; When the player is born, they are automatically invulnerable
                 ;; for 1 second.
                 ;; TODO: NEED(!) to visualize this effect!
                 :invulnerability-timer 1f0)
  #++(player-movement :move-type :dpad-pivot
                      :pivot-prefab '(("pivot-guide" ptp)))
  #++(comp:sphere :center (v3:zero)
                  :on-layer :player
                  :referent (c:ref :self :component 'hit-points)
                  :radius 30f0)
  ("ship-body"
   (comp:sprite :spec '(metadata atlas)
                :block-alias :atlas-spritesheet
                :name "player1")
   (sketch :material 'sprite-atlas
           :render-layer :player
           :slave (c:ref :self :component 'comp:sprite))
   #++("front-gun"
       (comp:transform :translate (v3:vec 0f0 12f0 0f0))
       #++(gun :physics-layer :player-bullet
               :depth-layer :player-bullet
               :name "bullet01"
               :frames 8
               :duration .5f0
               :repeat nil))
   ("exhaust"
    (comp:transform :translate (v3:vec 0f0 -16f0 0f0))
    (comp:sprite :spec '(metadata atlas)
                 :block-alias :atlas-spritesheet
                 :name "explosion01-01" #++ "player1-exhaust-01"
                 :frames 8 #++ 2
                 ;; 1/30 for a single frame, so 1/15 for both
                 :duration .3 #++ .06f0)
    (sketch :material 'sprite-atlas
            :render-layer :player
            :slave (c:ref :self :component 'comp:sprite)))))



;; This acts like a scene, but is just a regular prefab.
(c:define-prefab "initial-scene" (:library lib/main)

  ;; The hack to implement render layers for psrites.
  (delayed-render :layer-order *render-layer-order*)
  (tags :tags '(:delayed-render-system))

  ;; level is in a plane, whose original size was (-1, -1) to (1, 1) and
  ;; will be scaled to (-240,-3600) to (240, 3600), and does not move. The scale
  ;; is 240 by 3600... the size of the background in pixels.
  (("level-0" :copy "/mesh")
   (comp:transform
    :scale (v3:vec 240f0 3600f0 1f0)
    :translate (v3:vec 0f0 0f0 (dl :background)))
   (comp:render :material 'level-0
                :slave (c:ref :self :component 'comp:mesh)))

  ;; scaffold slides down the level, carrying camera and player. The
  ;; scaffolding will hold score boards and anything that might be in
  ;; the player's space, like mines they dropped, that are dragged with
  ;; the scaffold as opposed to dropped into the universe.

  ("scaffold"
   (direction-mover :direction :+y
                    ;; put scaffold at start of level, in the middle,
                    ;; with the bottom of the level matching the bottom
                    ;; of the screen.
                    :start-pos (v3:vec 0f0 (+ -3600f0 320f0) (dl :scaffold))
                    ;; We stop when we reach the end scren.
                    :end-pos (v3:vec 0f0 (- 3600f0 320f0) (dl :scaffold))
                    :stop-radius 1f0
                    ;; We start half way up a screen and end half way
                    ;; down a screen and we want it to be 90 seconds of
                    ;; experience.
                    :velocity (* 1f0 (/ (- 7200f0 (* 320f0 2f0)) 90f0)))

   ;; a child of the scaffold.
   (("camera" :copy "/cameras/ortho")
    ;; put camera in middle of virtual screen scaffold carries
    (comp:transform :translate (v3:vec 0f0 0f0 0f0))
    (comp:camera :zoom 1.5f0))

   ;; a child of the scaffold
   (("player1" :link "/player1-ship")
    (comp:transform :translate (v3:vec 0f0 0f0 0f0)
                    :scale (v3:vec 2f0 2f0 0f0))
    (player-mover :gamepad-id :gamepad1))))
