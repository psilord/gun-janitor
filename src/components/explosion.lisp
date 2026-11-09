(in-package #:gun-janitor)

;; NOTE: No physics layers for this since they don't even participate in the
;; collisions.
(defun make-explosion (context prefab translation rotation render-layer
                       &key (scale (v3:ones) scale-supplied-p))
  (let* ((prefab-name (first prefab))
         (prefab-library (second prefab))
         (new-explosion
           (first (c:make-prefab-instance
                   (c::core context)
                   `((,prefab-name ,prefab-library)))))
         (sprite (c:component-by-type new-explosion 'comp:sprite))
         (sketch (c:component-by-type new-explosion 'sketch)))

    ;; We won't know render layer till we knew what exploded, so caller must
    ;; supply this.
    (setf (render-layer sketch) render-layer)

    (when scale-supplied-p
      (c:scale new-explosion scale :instant t :replace t))

    ;; Important to put on right render layer for z buffering and alpha
    ;; composition.
    (setf (v3:z translation) (dl render-layer))
    (c:translate new-explosion translation :instant t :replace t
                                           :space :inertial)

    (c:rotate new-explosion rotation :instant t :replace t)

    ;; By default explosions live a certain amount of time, we make it
    ;; equal to one period of the animation duration so it dies right
    ;; when (or just after) the animation finishes.
    (c:destroy new-explosion :ttl (comp:duration sprite))

    new-explosion))
