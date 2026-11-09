(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: explosion
;;
;; Describe an explosion.
;;;;;;;;;

(c:define-component explosion ()
  ((%prefab :accessor prefab
            :initarg :prefab
            :initform nil)
   (%render-layer :accessor render-layer
                  :initarg :render-layer
                  :initform nil)))
