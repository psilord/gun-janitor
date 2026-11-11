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
                            :enemy-bullet-explosion -.07f0
                            :player-bullet-explosion -.06f0
                            :enemy -.05f0
                            :enemy-blades -.045f0
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
  (let ((chosen-layer (u:href *draw-layer* draw-layer-name)))
    (unless chosen-layer
      (error "(DL ~(~S~)): bad draw layer!" draw-layer-name))
    chosen-layer))

;; NOTE: Must be same order as the z axis layering above. Last it greatest Z,
;; first is least Z.
(defparameter *render-layer-order*
  '(:background
    :background-damage
    :enemy-bullet-explosion
    :player-bullet-explosion
    :enemy
    :enemy-blades
    :enemy-explosion
    :enemy-bullet
    :player-bullet
    :player-explosion
    :player
    :scaffold
    :player-stable
    :text-ui
    :camera))

(defun test-shot-pattern-0 (prefab)
  ;; Below is: #(#(num-shots pos-rot neg-rot slerp-short-way-p prefab) ...)
  ;; The rotation is in terms of the :direction vector.
  ;;
  ;; TODO: Implement difficulty (flags to skip entries in
  ;; pattern.)
  `#(#(1 0f0 0f0 t ,prefab)
     #(2 ,o:pi/8 ,(- o:pi/8) t ,prefab)
     #(3 ,o:pi/8 ,(- o:pi/8) t ,prefab)
     #(10 ,o:pi/2 ,(- o:pi/2) t ,prefab)))

(defun shot-pattern-0 (num-shots prefab)
  (loop :with shots = (make-array num-shots)
        :for index :from 0 :below num-shots
        :for pos-angle = (* (o:pi 1f0 16f0) index)
        :for neg-angle = (* (o:pi 1f0 -16f0) index)
        :for slerp-short-way-p = (< (+ pos-angle (abs neg-angle)) o:pi)
        :do (setf (aref shots index)
                  (vector 3
                          pos-angle
                          neg-angle
                          slerp-short-way-p
                          prefab))
        :finally (return shots)))


;; Player 1's basic shot.
(c:define-prefab "red-shot-small" (:library lib/main)
  "Player 1's Small Red Shot"
  (projectile :transform (c:ref :self :component 'comp:transform)
              :mover (c:ref :self :component 'direction-mover)
              :collider (c:ref :self :component 'comp:cuboid)
              :sprite (c:ref :self :component 'comp:sprite)
              :physics-layer :player-bullet
              :depth-layer :player-bullet
              :velocity (/ 320f0 .20f0)
              :destroy-ttl .5f0
              :damage-points (c:ref :self :component 'damage-points)
              :hit-points (c:ref :self :component 'hit-points)
              :explosion (c:ref :self :component 'explosion))
  (tags :tags '(:dangerous))
  (comp:transform :scale (v3:vec 2f0 2f0 1f0)) ;; TODO: fix plane to unit size.
  (direction-mover)
  (damage-points :dp 1)
  (hit-points :hp 1)
  (explosion :prefab '("generic-bullet-explosion" lib/main)
             :render-layer :player-bullet-explosion)
  (comp:sprite :spec '(metadata atlas)
               :block-alias :atlas-spritesheet
               :name "red-shot-small"
               :frames 1
               :duration 1f0)
  (comp:cuboid :center (v3:zero)
               ;; TODO: Visualize is broken cause I need to change properties
               ;; about the material being used during the debugging render.
               ;; :visualize t
               :on-layer :player-bullet
               :referent (c:ref :self :component 'projectile)
               :center (v3:zero)
               :minx -1f0
               :maxx 1f0
               :miny -1f0
               :maxy 1f0
               :minz -1f0
               :maxz 1f0)
  (sketch :material 'sprite-atlas
          :render-layer :player-bullet
          :slave (c:ref :self :component 'comp:sprite)))


;; the venerable player.
(c:define-prefab "player1-ship" (:library lib/main)
  "The venerable Player Ship. Controls how it looks, collides, and movement."
  (ship-computer :spawn-invulnerable-p t
                 :spawn-invulnerability-time .5f0 ;; seconds
                 :hit-points (c:ref :self :component 'hit-points)
                 :damage-points (c:ref :self :component 'damage-points)
                 :explosion (c:ref :self :component 'explosion))
  (tags :tags '(:player))
  (damage-points :dp 1)
  (hit-points :hp 1)
  (explosion :prefab '("generic-ship-explosion" lib/main)
             :render-layer :player-explosion)
  ("ship-body"
   (comp:sphere :center (v3:zero)
                :on-layer :player
                :referent (c:ref "../" :component 'ship-computer)
                :visualize t
                :radius 6f0)
   (comp:sprite :spec '(metadata atlas)
                :block-alias :atlas-spritesheet
                :name "player1")
   (sketch :material 'sprite-atlas
           :render-layer :player
           :slave (c:ref :self :component 'comp:sprite))
   ("front-gun"
    (comp:transform :translate (v3:vec 0f0 14f0 0f0)) ;; 1/2 ship hight + bullet
    (gun :input-handler (c:ref "/initial-scene" :component 'input-handler)
         :emitter (c:ref :self :component 'emitter-split-arc)
         ;; Hz (make sure evenly divisible from 120Hz
         :fire-rate 10f0)
    (emitter-split-arc :up :z
                       :direction :y
                       :radius 0f0 ;; >= 0f0, 0 means emit from origin of actor.
                       :spread-patterns
                       (shot-pattern-0 16 '(("red-shot-small" lib/main)))))
   ("exhaust"
    (comp:transform :translate (v3:vec 0f0 -16f0 0f0))
    (comp:sprite :spec '(metadata atlas)
                 :block-alias :atlas-spritesheet
                 :name "player1-exhaust-01"
                 :frames 2
                 ;; 1/30 for a single cycle, so 1/15 for each frame
                 :duration .06f0)
    (sketch :material 'sprite-atlas
            :render-layer :player
            :slave (c:ref :self :component 'comp:sprite)))))

(c:define-prefab "enemy1-ship" (:library lib/main)
  "Enemy 1. Controls how it looks, collides, and movement."
  (ship-computer :spawn-invulnerable-p nil
                 :spawn-invulnerability-time 0f0 ;; seconds
                 :hit-points (c:ref :self :component 'hit-points)
                 :damage-points (c:ref :self :component 'damage-points)
                 :explosion (c:ref :self :component 'explosion))
  (tags :tags '(:enemy))
  (damage-points :dp 1)
  (hit-points :hp 1)
  (explosion :prefab '("generic-ship-explosion" lib/main)
             :render-layer :enemy-explosion)
  ("ship-body"
   (comp:sphere :center (v3:zero)
                :on-layer :enemy
                :referent (c:ref "../" :component 'ship-computer)
                :radius 6f0)
   (comp:sprite :spec '(metadata atlas)
                :block-alias :atlas-spritesheet
                :name "helicopter-N")
   (sketch :material 'sprite-atlas
           :render-layer :enemy
           :slave (c:ref :self :component 'comp:sprite))
   ("front-gun"
    (comp:transform :translate (v3:vec 0f0 14f0 0f0)) ;; 1/2 ship hight + bullet
    (emitter-split-arc :up :z
                       :direction :y
                       :radius 0f0 ;; >= 0f0, zero mean point emission
                       :spread-patterns
                       `#(#(1 0f0 0f0 t '(("enemy-shot-small" lib/main)))))

    ;; TODO: Disable the gun, enemies fire a different way.
    #++
    (gun :emitter (c:ref :self :component 'emitter-split-arc)
         ;; Hz (make sure evenly divisible from 120Hz
         :fire-rate 6f0)
    )
   ("blades"
    (comp:transform :translate (v3:vec 0f0 0f0 0f0))
    (comp:sprite :spec '(metadata atlas)
                 :block-alias :atlas-spritesheet
                 :name "helicopter-blade-01"
                 :frames 2
                 ;; 1/30 for a single cycle, so 1/15 for each frame
                 :duration .06f0)
    (sketch :material 'sprite-atlas
            :render-layer :enemy-blades
            :slave (c:ref :self :component 'comp:sprite)))))

(c:define-prefab "generic-ship-explosion" (:library lib/main)
  "A generic explosion that can be customized when created."
  (comp:transform :scale (v3:vec 2f0 2f0 1f0))
  (comp:sprite :spec '(metadata atlas)
               :block-alias :atlas-spritesheet
               ;; TODO: When this is misnamed, the error is extremely obscure
               :name "explosion01-01"
               :frames 8
               :duration 0.5f0
               :repeat nil)
  (sketch :material 'sprite-atlas
          :render-layer nil ;; set by the instantiator of this prefab.
          :slave (c:ref :self :component 'comp:sprite)))

(c:define-prefab "generic-bullet-explosion" (:library lib/main)
  "Used for when a bullet hits something."
  (comp:transform :scale (v3:vec 2f0 2f0 1f0))
  (comp:sprite :spec '(metadata atlas)
               :block-alias :atlas-spritesheet
               ;; TODO: When this is misnamed, the error is extremely obscure
               :name "bullet-explosion01-01"
               :frames 2
               :duration .20f0
               :repeat nil)
  (sketch :material 'sprite-atlas
          :render-layer nil ;; set by the creator of this prefab.
          :slave (c:ref :self :component 'comp:sprite)))

(c:define-prefab "playfield" (:library lib/main)
  "Sandbags, one pixel beyond, the edges of the screen. They catch bullets."
  ;; TODO: Add :sandbag physics layer and make collide with player and
  ;; enemy bullet layers.
  ;; TODO: Fix the damn mesh plane to be unit sized.

  ;; TODO: Implement this component, add and put on :sandbag physics layer.
  ;; (playfield)
  (comp:cuboid :center (v3:zero)
               :visualize t
               :on-layer :scenery
               :referent nil ;; (c:ref "../" :component 'playfield)
               :minx -240f0
               :maxx 240f0
               :miny -320f0
               :maxy 320f0
               :minz -10f0
               :maxz 10f0))

;; This acts like a scene, but is just a regular prefab and the
;; initialization prefab when the game starts.
(c:define-prefab "initial-scene" (:library lib/main)

  ;; The hack to implement render layers for sprites.
  (delayed-render :layer-order *render-layer-order*)
  (tags :tags '(:delayed-render-system))

  ;; Handle asking user for which gamepad they want to use when applicable
  ;; and route the right input events to the right places.
  (input-handler)

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

   (("playfield" :link "/playfield"))

   ;; a child of the scaffold.
   (("camera" :copy "/cameras/ortho")
    ;; put camera in middle of virtual screen scaffold carries
    (comp:transform :translate (v3:vec 0f0 0f0 0f0))
    (comp:camera :zoom .5f0)) ;; 1.5 is correctly zoomed.

   ;; Test enemies for killing.
   (("enemy1" :link "/enemy1-ship")
    (comp:transform :translate (v3:vec -48f0 0f0 (dl :enemy))
                    :scale (v3:vec 2f0 2f0 1f0)))
   (("enemy2" :link "/enemy1-ship")
    (comp:transform :translate (v3:vec -96f0 0f0 (dl :enemy))
                    :scale (v3:vec 2f0 2f0 1f0)))
   (("enemy3" :link "/enemy1-ship")
    (comp:transform :translate (v3:vec -48f0 72f0 (dl :enemy))
                    :scale (v3:vec 2f0 2f0 1f0)))
   (("enemy4" :link "/enemy1-ship")
    (comp:transform :translate (v3:vec -96f0 72f0 (dl :enemy))
                    :scale (v3:vec 2f0 2f0 1f0)))

   ;; a child of the scaffold
   (("player1" :link "/player1-ship")
    (comp:transform :translate (v3:vec 0f0 0f0 (dl :player))
                    :scale (v3:vec 2f0 2f0 1f0))
    (player-mover :input-handler (c:ref "/initial-scene"
                                        :component 'input-handler)))))
