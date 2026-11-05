(in-package #:gun-janitor)

(c:define-component input-handler ()
  ((%player-1-gamepad-id :accessor player-1-gamepad-id
                         :initarg :player-1-gamepad-id
                         :initform nil)))
