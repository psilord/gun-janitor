(in-package #:gun-janitor)

(defmethod c:on-component-render ((self delayed-render))
  (with-accessors ((sketch-table sketch-table)
                   (layer-order layer-order))
      self

    (dolist (layer layer-order)
      (let ((sketches (u:href sketch-table layer)))
        (loop :for sketch :in sketches
              :do (when (c:actor sketch) ;; <- TODO: Big Damn Hack.
                    (%really-render sketch)))))
    (clrhash sketch-table)))

(defun %add-sketch (delayed-render sketch)
  (push sketch (u:href (sketch-table delayed-render) (render-layer sketch))))
