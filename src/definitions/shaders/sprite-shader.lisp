(in-package #:gun-janitor.shader)

;; Here is a sprite shader, regularly from umbra, but I needed some
;; modification to discard texels with very low alpha values.

(defstruct sprite-data
  (sampler :sampler-2d :accessor sampler)
  (index :int :accessor index))

(defstruct spritesheet-data
  (pos (:ivec2 2048) :accessor pos)
  (size (:ivec2 2048) :accessor size))

;; TODO: Figure out why atlas-spritesheet MUST have that name in the args.
(defun make-vertex-data ((sprite sprite-data)
                         (atlas-spritesheet spritesheet-data))
  (let* ((tex-size (.xyxy (texture-size (sampler sprite) 0)))
         (size (aref (size atlas-spritesheet) (index sprite)))
         (a (aref (pos atlas-spritesheet) (index sprite)))
         (b (+ a size))
         (vertpos (vec4 (* size 0.5) (* size -0.5)))
         (uv (/ (vec4 a b) tex-size)))
    (case gl-vertex-id
      (0 (values (.xy vertpos) (.zy uv)))
      (1 (values (.zy vertpos) (.xy uv)))
      (2 (values (.xw vertpos) (.zw uv)))
      (otherwise (values (.zw vertpos) (.xw uv))))))

;; TODO: Figure out why atlas-spritesheet MUST have that name in the args.
(defun sprite/v (&uniforms
                 (model :mat4)
                 (view :mat4)
                 (proj :mat4)
                 (sprite sprite-data)
                 (atlas-spritesheet spritesheet-data :ssbo :std-430))
  (mvlet* ((pos uv (make-vertex-data sprite atlas-spritesheet)))
    (values (* proj view model (vec4 pos 0 1))
            uv)))

(defun sprite/f ((uv :vec2)
                 &uniforms
                 (sprite sprite-data)
                 (opacity :float))
  (let ((color (texture (sampler sprite) uv)))
    (vec4 (.rgb color) (* (.a color) opacity))))

(define-shader atlas-shdr (:primitive :triangle-strip)
  (:vertex (sprite/v))
  (:fragment (sprite/f :vec2)))


;; Back to our regularly scheduled package!
(in-package #:gun-janitor)
