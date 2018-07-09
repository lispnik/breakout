(defsystem #:breakout
  :description "Breakout game"
  :author "Matthew Kennedy <burnsidemk@gmail.com>"
  :license "LLGPL2.1"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria #:sdl2)
  :components ((:file "package")
               (:file "breakout")))
