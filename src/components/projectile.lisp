(in-package #:gun-janitor)

;; we use this at runtime to instantiate a bullet prefab and fill in everything
;; it needs to become effective in the world.
(defun make-projectile (context prefab translation rotation
                        &key
                          (parent nil)
                          (scale (v3:ones) scale-supplied-p)
                          (destroy-ttl 2f0)
                          (direction :+y)
                          (repeat t repeat-supplied-p))
  (let* ((prefab-name (first prefab))
         (new-projectile
           (first (c:make-prefab-instance (c::core context) prefab
                                          :parent parent)))
         ;; TODO: I'm expecting the new-projectile to have components here
         ;; without having gone through the flow. BAD!
         (projectile (c:component-by-type new-projectile 'projectile)))

    ;; Set the spatial configuration
    (setf (v3:z translation) (dl (depth-layer projectile)))
    (c:translate new-projectile translation :instant t :replace t
                                            :space :inertial)
    ;; XXX This interface needs to take a quat here also
    (c:rotate new-projectile rotation :instant t :replace t)

    (when scale-supplied-p
      ;; And adjust the scale too.
      (c:scale new-projectile scale :instant t :replace t))

    (setf
     ;; Basic identification of the projectile
     (name projectile) prefab-name

     ;; Give the collider a cheesy name until I get rid of this name feature.
     (c:display-id (collider projectile)) prefab-name

     ;; Set what layer is the collider on?
     ;; TODO: When setting this, ensure I move the collider to the right
     ;; layer in the physics system.
     (comp:on-layer (collider projectile)) (physics-layer projectile)

     ;; How fast is the projectile going?
     (velocity (mover projectile)) (velocity projectile)

     ;; and, what direction is it going in?
     (direction (mover projectile)) direction)

    (when repeat-supplied-p
      (setf (comp:repeat (sprite projectile)) repeat))

    ;; By default projectiles live a certain amount of time.
    (c:destroy new-projectile :ttl destroy-ttl)

    new-projectile))
