import std/[options, unittest]
import ../src/sketchcad_core

suite "SketchCAD architectural core":
  test "fence spacing never exceeds maximum":
    check fenceBayCount(6_000.0, 1_500.0) == some(4'u32)
    check fenceBayCount(6_001.0, 1_500.0) == some(5'u32)
    check fenceBayCount(0.0, 1_500.0).isNone
    check fencePostCount(6_001.0, 1_500.0) == some(6'u32)

  test "balcony railing includes corners and end posts":
    check railingPostCount(3_500.0, 1_600.0, 900.0) == some(9'u32)

  test "stair dimensions are calculated":
    check stairStep(3_000.0, 2_700.0, 15).get == (going: 200.0, rise: 180.0)
    check comfortableStairCount(2_700.0) == some(15'u32)

  test "roof rafter length is calculated":
    check roofRafterLength(8_000.0, 3_000.0).get == 5_000.0
    check gableRoofArea(10_000.0, 8_000.0, 3_000.0).get == 100_000_000.0

  test "quantities reject impossible input and round purchasing units up":
    check wallNetArea(10.0, 3.0, 4.0) == some(26.0)
    check wallNetArea(10.0, 3.0, 31.0).isNone
    check materialUnitCount(26.0, 5.0, 10.0) == some(6'u32)
    check rampLength(0.6, 0.05) == some(12.0)
