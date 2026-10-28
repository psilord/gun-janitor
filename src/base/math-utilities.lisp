(in-package #:gun-janitor)

(defun quantize-xy-vector-to-8-way (vec)
  "We expect the VEC to be a vec3 whose Z component will be ignored.
Return two values: The first is a a normalized vector that is, wrt the
inertial space, one of 8 directions on a compass. The second value is a
symbol representing that direction, like :E, :NE, :N, :NW, :W, :SE, :S,
:SE. If a zero vector is apssed in, the second return value is NIL."

  (v3:with-components ((l vec))
    (let* ((angle (atan ly lx))
           (angle (if (minusp angle)
                      (+ o:pi (- o:pi (abs angle)))
                      angle)))
      ;; TODO: Optimize this a little, like make specific vectors in
      ;; vorigin that represent these normalized directions instead of
      ;; always computing them here.
      (cond
        ((v3:zero-p vec)
         (values v3:+zero+ nil))
        ;; east
        ((or (>= angle o:15pi/8) (< angle o:pi/8))
         (values v3:+right+ :e))
        ;; north east
        ((and (>= angle o:pi/8) (< angle o:3pi/8))
         (values (v3:normalize (v3:+ v3:+up+ v3:+right+)) :ne))
        ;; north
        ((and (>= angle o:3pi/8) (< angle o:5pi/8))
         (values v3:+up+ :n))
        ;; north west
        ((and (>= angle o:5pi/8) (< angle o:7pi/8))
         (values (v3:normalize (v3:+ v3:+up+ v3:+left+)) :nw))
        ;; west
        ((and (>= angle o:7pi/8) (< angle o:9pi/8))
         (values v3:+left+ :w))
        ;; south west
        ((and (>= angle o:9pi/8) (< angle o:11pi/8))
         (values (v3:normalize (v3:+ v3:+left+ v3:+down+)) :sw))
        ;; south
        ((and (>= angle o:11pi/8) (< angle o:13pi/8))
         (values v3:+down+ :s))
        ;; south east
        ((and (>= angle o:13pi/8) (< angle o:15pi/8))
         (values (v3:normalize (v3:+ v3:+right+ v3:+down+)) :se))))))
