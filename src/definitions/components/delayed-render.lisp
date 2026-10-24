(in-package #:gun-janitor)

;; This component is executed after the above in the type graph.
;; It renders everything in the right order and then clears the layer-table
;; for the next frame's work. This goes on ONE actor in the world, and it is
;; found by the sketch component when needed.
(c:define-component delayed-render ()
  ((%sketch-table :reader sketch-table
                  :initform (u:dict #'eq))
   (%layer-order :accessor layer-order
                 :initarg :layer-order)))
