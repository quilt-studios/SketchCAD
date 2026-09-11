import std/[math, options, unittest]
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

  test "rectangular elements share validated geometry calculations":
    check rectangleArea(12.0, 8.0) == some(96.0)
    check rectanglePerimeter(12.0, 8.0) == some(40.0)
    check abs(slabVolume(12.0, 8.0, 0.2).get - 19.2) < 1.0e-12
    check abs(stripFootingVolume(20.0, 0.6, 0.3).get - 3.6) < 1.0e-12
    check abs(rectangularColumnVolume(0.4, 0.5, 3.0).get - 0.6) < 1.0e-12
    check abs(beamVolume(5.0, 0.3, 0.4).get - 0.6) < 1.0e-12
    check rectangleArea(-1.0, 8.0).isNone

  test "wall openings and finishes produce construction quantities":
    check repeatedOpeningArea(1.2, 1.5, 4) == some(7.2)
    check wallVolume(10.0, 3.0, 0.2, 5.0) == some(5.0)
    check masonryUnitCount(5.0, 0.002, 5.0) == some(2_625'u32)
    check tileCount(20.0, 0.5, 0.5, 10.0) == some(88'u32)
    check paintVolume(100.0, 10.0, 2) == some(20.0)
    check repeatedOpeningArea(1.2, 1.5, 0).isNone
    check paintVolume(100.0, 10.0, 0).isNone

  test "circular structure and drainage calculations handle boundaries":
    check abs(circularColumnVolume(1.0, 2.0).get - PI / 2.0) < 1.0e-12
    check downpipeCount(30.0, 12.0) == some(3'u32)
    check downpipeCount(10.0, 12.0) == some(2'u32)
    check circularColumnVolume(0.0, 2.0).isNone
    check downpipeCount(30.0, 0.0).isNone

  test "additional planar geometry is calculated":
    check triangleArea(8.0, 3.0) == some(12.0)
    check abs(circleArea(2.0).get - PI) < 1.0e-12
    check abs(circleCircumference(2.0).get - 2.0 * PI) < 1.0e-12
    check trapezoidArea(4.0, 8.0, 3.0) == some(18.0)
    check roomVolume(5.0, 4.0, 3.0) == some(60.0)
    check skirtingLength(5.0, 4.0, 1.0) == some(17.0)
    check triangleArea(0.0, 3.0).isNone
    check skirtingLength(5.0, 4.0, 19.0).isNone

  test "site and access quantities are calculated":
    check excavationVolume(10.0, 4.0, 2.0) == some(80.0)
    check backfillVolume(80.0, 30.0) == some(50.0)
    check rampSlopePercent(0.6, 12.0) == some(5.0)
    check abs(stairAngleDegrees(3.0, 3.0).get - 45.0) < 1.0e-12
    check handrailLength(3.0, 4.0, 2) == some(10.0)
    check backfillVolume(20.0, 21.0).isNone
    check handrailLength(3.0, 4.0, 0).isNone

  test "environmental calculations reject impossible inputs":
    check rainwaterVolume(120.0, 25.0) == some(3_000.0)
    check thermalTransmittance(5.0) == some(0.2)
    check fabricHeatLoss(100.0, 0.2, 20.0) == some(400.0)
    check ventilationFlow(150.0, 0.5) == some(75.0)
    check daylightRatio(4.0, 20.0) == some(20.0)
    check thermalTransmittance(0.0).isNone
    check daylightRatio(21.0, 20.0).isNone

  test "capacity and building services quantities are calculated":
    check occupancyCapacity(100.0, 8.0) == some(12'u32)
    check parkingSpaceCount(500.0, 25.0) == some(20'u32)
    check ceilingPanelCount(100.0, 2.4) == some(42'u32)
    check abs(reinforcementMass(1.0, 0.01).get - PI * 0.005 ^ 2 * 7850.0) < 1.0e-12
    check abs(pipeInternalVolume(0.1, 10.0).get - PI * 0.05 ^ 2 * 10.0) < 1.0e-12
    check ductSurfaceArea(0.4, 0.2, 10.0) == some(12.0)
    check occupancyCapacity(1.0, 8.0).isNone

  test "roof and envelope quantities are calculated":
    check gutterLength(12.0, 2) == some(24.0)
    check roofOverhangArea(10.0, 8.0, 1.0) == some(40.0)
    check insulationVolume(100.0, 0.2) == some(20.0)
    check gutterLength(12.0, 0).isNone
    check roofOverhangArea(10.0, 8.0, 0.0).isNone
    check insulationVolume(100.0, -0.2).isNone

  test "3D point and vector operations support CAD geometry":
    let x = point3(1.0, 0.0, 0.0).get
    let y = point3(0.0, 1.0, 0.0).get
    let endPoint = point3(3.0, 4.0, 0.0).get
    check add(x, y).get == SketchCadPoint3(x: 1.0, y: 1.0, z: 0.0)
    check subtract(x, y).get == SketchCadPoint3(x: 1.0, y: -1.0, z: 0.0)
    check scale(x, 3.0).get == SketchCadPoint3(x: 3.0, y: 0.0, z: 0.0)
    check dot(x, y) == some(0.0)
    check cross(x, y).get == SketchCadPoint3(x: 0.0, y: 0.0, z: 1.0)
    check vectorLength(endPoint) == some(5.0)
    check distance(x, endPoint) == some(sqrt(20.0))

  test "3D transformations validate degenerate inputs":
    let origin = point3(0.0, 0.0, 0.0).get
    let endpoint = point3(2.0, 4.0, 6.0).get
    let x = point3(1.0, 0.0, 0.0).get
    check normalize(origin).isNone
    check normalize(point3(0.0, 3.0, 4.0).get).get ==
      SketchCadPoint3(x: 0.0, y: 0.6, z: 0.8)
    check lerp(origin, endpoint, 0.5).get == SketchCadPoint3(x: 1.0, y: 2.0, z: 3.0)
    check lerp(origin, endpoint, 1.1).isNone
    let rotated = rotateAroundZ(x, 90.0).get
    check abs(rotated.x) < 1.0e-12
    check abs(rotated.y - 1.0) < 1.0e-12
    check point3(NaN, 0.0, 0.0).isNone

  test "3D C ABI writes caller-owned results and rejects null pointers":
    var left = SketchCadPoint3(x: 1.0, y: 2.0, z: 3.0)
    var right = SketchCadPoint3(x: 4.0, y: 5.0, z: 6.0)
    var output: SketchCadPoint3
    var scalar: cdouble
    check sketchcad_point3_add(addr left, addr right, addr output) == 1
    check output == SketchCadPoint3(x: 5.0, y: 7.0, z: 9.0)
    check sketchcad_point3_dot(addr left, addr right, addr scalar) == 1
    check scalar == 32.0
    check sketchcad_point3_normalize(addr left, nil) == 0
    check sketchcad_point3_add(nil, addr right, addr output) == 0
