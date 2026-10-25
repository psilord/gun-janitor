(in-package #:gun-janitor)

;; we use this at runtime to instantiate a bullet prefab and fill in everything
;; it needs to become effective in the world.
(defun make-projectile (context translation rotation
                        &key
                          (parent nil)
                          (scale (v3:ones))
                          (destroy-ttl 2f0)
                          (direction :+y)
                          (prefab-name "projectile")
                          (prefab-library 'lib/main)
                          (name "blue-shot-small")
                          (frames 1)
                          (duration 1 duration-supplied-p)
                          (repeat t repeat-supplied-p)
                          (render-layer nil))
  (let* ((new-projectile
           (first (c:make-prefab-instance
                   (c::core context)
                   `((,prefab-name ,prefab-library))
                   :parent parent)))
         ;; TODO: I'm expecting the new-projectile to have components here
         ;; without having gone through the flow. BAD!
         (projectile (c:component-by-type new-projectile 'projectile))
         #++ (hit-points (c:component-by-type new-projectile 'hit-points))
         (sketch (c:component-by-type new-projectile 'sketch)))

    ;; Set the spatial configuration
    (setf (v3:z translation) (dl (depth-layer projectile)))
    (c:translate new-projectile translation :instant t :replace t
                                            :space :inertial)
    ;; XXX This interface needs to take a quat here also
    (c:rotate new-projectile rotation :instant t :replace t)
    ;; And adjust the scale too.
    (c:scale new-projectile scale :instant t :replace t)
    (setf
     ;; Basic identification of the projectile
     (name projectile) name
     (frames projectile) frames
     ;; Give the collider a cheesy name until I get rid of this name feature.
     (c:display-id (collider projectile)) name

     ;; Set what layer is the collider on?
     ;; TODO: When setting this, ensure I move the collider to the right
     ;; layer in the physics system.
     (comp:on-layer (collider projectile)) (physics-layer projectile)
     ;; How fast is the projectile going?
     (velocity (mover projectile)) (velocity projectile)
     ;; Tell the sprite what it should be rendering
     ;; TODO: make NAME and FRAMES public for sprite component.
     (comp:name (sprite projectile)) name
     (comp:frames (sprite projectile)) frames
     ;; and, what direction is it going in?
     (direction (mover projectile)) direction)

    (when duration-supplied-p
      (setf (comp:duration (sprite projectile)) duration))

    (when repeat-supplied-p
      (setf (comp:repeat (sprite projectile)) repeat))

    (setf (render-layer sketch) render-layer
          #++ (render-layer hit-points) #++ render-layer)

    ;; By default projectiles live a certain amount of time.
    (c:destroy new-projectile :ttl destroy-ttl)
    new-projectile))
