(in-package #:gun-janitor)

;; TODO: Make this constant time
(defmacro with-depth-function (material &body body)
  `(destructuring-bind (&key depth) (c::attributes ,material)
     (if depth
         (let ((old-depth (c::get-gpu-parameter :depth-func)))
           (unwind-protect
                (progn
                  (gl:depth-func depth)
                  ,@body)
             (gl:depth-func old-depth)))
         (progn ,@body))))

(defmacro with-material (material (&rest bindings) &body body)
  "Bind uniforms in BINDINGS before evaluating the BODY.
If the uniform doesn't exist, silently ignore the setting of it.  NOTE: This
means if the BODY sets a uniform it will be IGNORED for this render, and if a
shared material may affect the NEXT rendering call!"
  (u:with-gensyms (material-ref)
    `(let ((,material-ref ,material))
       (shadow:with-shader (c::shader ,material-ref)
         ;; TODO: This behavior here implies a policy about uniform usage for
         ;; materials, in that, using a material that doesn't define this
         ;; uniform will silently ignore the issue if you try setting it.
         ;; The todo here is figure out how to get this better described so
         ;; we can do compile time checks on uniforms.
         (progn
           ,@(loop :for (k v) :on bindings :by #'cddr
                   :collect `(when (c:uniform-ref-p ,material-ref ,k)
                               (setf (c:uniform-ref ,material-ref ,k) ,v))))
         (c::bind-material ,material-ref)
         (with-depth-function ,material-ref
           ,@body)))))

(defmethod c:on-component-initialize ((self sketch))
  (with-slots (comp::%transform) self
    (setf comp::%transform (c:component-by-type (c:actor self) 'transform))))

(defun %really-render (self)
  (u:when-let ((camera (c::active-camera (c:context self)))
               (slave (comp::slave self))
               (material (comp::material self)))

    (with-material material
        (:model (c:get-model-matrix self)
         :view (comp:view camera)
         :proj (comp:projection camera))

      ;; TODO: For now, if this uniform exists, set it up. We don't want to
      ;; unecessarily set this all the time, since it could compute work for a
      ;; lot of situations where we don't need it and as a general rule
      ;; materials might not have it. Another solution is that the user sets a
      ;; function for the normal-matrix and when it gets called it figures out
      ;; the actor and passes it in (along with the material). Need to think on
      ;; it a little bit more. Currently the function only knows of the context
      ;; and the material. Since materials are shared by different renderers,
      ;; materials can't have backreferences to their components/actors.
      (when (c:uniform-ref-p material :normal-matrix)
        (setf (c:uniform-ref material :normal-matrix)
              ;; TODO: Implement a m3:invert and reorganize this expressions
              ;; to reduce operations and not cons memory.
              (m4:rotation-to-mat3
               (m4:transpose (m4:invert
                              (m4:set-translation
                               (m4:* (comp:view camera)
                                     (c:get-model-matrix self))
                               (v3:zero)))))))
      (c:on-component-slave-render self slave))))

(defmethod c:on-component-render ((self sketch))
  (with-accessors ((render-layer render-layer)
                   (delayed-render-ref delayed-render-ref)
                   (context c:context))
      self

    ;; First thing we do is try and find the delayed-render component and
    ;; set my slot to point to it. If we don't findit, yeesh, I guess we don't
    ;; render and keep going. This is a bad hack. :)
    (unless delayed-render-ref
      (let ((actor
              (first (tags-find-actors-with-tag context
                                                :delayed-render-system))))
        (if (null actor)
            (return-from c:on-component-render nil)
            (setf delayed-render-ref
                  (c:component-by-type actor 'delayed-render)))))

    (if render-layer
        ;; add self into delayed-render and do it later.
        (%add-sketch delayed-render-ref self)
        ;; else render self right now.
        (%really-render self))))
