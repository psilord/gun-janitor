(in-package #:gun-janitor)

(c:define-material v-letter
  (:shader shd:unlit-texture
   :profiles (x:u-mvp)
   :uniforms
   ((:tex.sampler1 'v-letter)
    (:mix-color (v4:ones)))))

(c:define-material v-letter-invert
  (:shader shd:unlit-texture-invert
   :profiles (x:u-mvp)
   :uniforms
   ((:tex.sampler1 'v-letter)
    (:mix-color (v4:ones)))))

(c:define-material bkgnd-test
  (:shader shd:unlit-texture
   :profiles (x:u-mvp)
   :uniforms
   ((:tex.sampler1 'bkgnd-test)
    (:mix-color (v4:ones)))))

(c:define-material level-0
  (:shader shd:unlit-texture
   :profiles (x:u-mvp)
   :uniforms
   ((:tex.sampler1 'level-0)
    (:mix-color (v4:ones)))))

(c:define-material sprite-atlas
  (:profiles (x:u-mvp)
   :shader gun-janitor.shader:atlas-shdr
   :attributes (:depth :lequal)
   :uniforms ((:sprite.sampler 'sprite-atlas)
              (:sprite.index 0)
              (:opacity 1.0))
   :blocks ((:block-name :atlas-spritesheet
             :storage-type :buffer
             :block-alias :atlas-spritesheet
             :binding-policy :manual))))
