version       = "0.1.0"
author        = "SketchCAD contributors"
description   = "Native architectural calculations for SketchCAD"
license       = "LGPL-2.1-or-later"
srcDir        = "src"

requires "nim >= 1.6.0"

task test, "Run the unit tests":
  exec "nim c -r tests/test_core.nim"
