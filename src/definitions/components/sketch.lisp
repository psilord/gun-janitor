(in-package #:gun-janitor)

(defclass render-sort ()
  ((%render-layer :accessor render-layer
                  :initarg :render-layer
                  ;; NIL means draw right now.
                  :initform nil)))

;; This is effectively the render component but instead of rendering itself it
;; sketches a reference of itself into a hash table in another components keyed
;; by the render-layer. Then, when that other component is forced to execute
;; after this one, it actually performs the render in the right order.
(c:define-component sketch (comp:render render-sort)
  ((%delayed-render-ref :accessor delayed-render-ref
                        :initarg :delayed-render-ref
                        :initform nil)))
