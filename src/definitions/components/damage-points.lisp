(in-package #:gun-janitor)

;; ;;;;;;;;;
;; Component: damage-points
;;
;; We describe an amount of damage that we give to something under appropriate
;; conditions during a collision. No need for any methods since this is only a
;; repository of information consulted by the game as it is needed for each
;; appropriate actor that has it.
;; ;;;;;;;;;

(c:define-component damage-points ()
  ((%dp :accessor dp
        :initarg :dp
        :initform 1)))
