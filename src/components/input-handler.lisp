(in-package #:gun-janitor)

(defun read-integer-in-range-safe (minval maxval)
  (loop
    (format t ";; Enter an integer in inclusive range [~D-~D]: " minval maxval)
    (finish-output)
    (with-standard-io-syntax
      (let* ((*read-eval* nil)
             (line (read-line)) ;; TODO: Not entirely robust.
             (val (parse-integer line :junk-allowed t)))
        (if (and val
                 (integerp val)
                 (>= val minval)
                 (<= val maxval))
            (return val)
            (format t ";; Invalid input. Try again.~%"))))))

(defmethod c:on-component-attach ((self input-handler) actor)
  (with-accessors ((context c:context)
                   (player-1-gamepad-id player-1-gamepad-id))
      self

    (format t "number entered: ~A~%" (read-line))
    (let* ((gamepads (c:get-gamepads
                      (c::input-data
                       (c::core context))))
           (num-gamepads (length gamepads)))
      (cond
        ((zerop num-gamepads)
         (format t "ERROR: GUN-JANITOR requires a gamepad at this time.~%"))
        ((= num-gamepads 1)
         (let* ((gpad (first gamepads))
                (id (c:gamepad-id gpad))
                (name (c:gamepad-name gpad)))
           (format t "Player 1 is using gamepad: ~(~S~) [~S]~%" id name)
           (setf player-1-gamepad-id id)))
        ((> num-gamepads 1)
         (format t ";; ###################################################~%")
         (format t ";;                Available gamepads                  ~%")
         (format t ";; ---------------------------------------------------~%")
         (loop :for gpad :in gamepads
               :for idx :from 0 :by 1
               :do (let* ((id (c:gamepad-id gpad))
                          (name (c:gamepad-name gpad)))
                     (format t ";; ~A: (~(~S~)) [~S]~%" idx id name)))
         (format t ";; ###################################################~%")
         (format t ";;~%")
         (format t ";; Player 1: Please choose a gamepad by number...~%")
         (let* ((gpad-choice (read-integer-in-range-safe 0 (1- num-gamepads)))
                (gpad (nth gpad-choice gamepads))
                (id (c:gamepad-id gpad))
                (name (c:gamepad-name gpad)))
           (format t ";; Player chose gamepad: ~(~S~) [~S]~%" id name)
           (setf player-1-gamepad-id id)))))))
