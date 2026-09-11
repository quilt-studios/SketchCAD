## Native architectural calculations used while SketchCAD migrates its C++ core to Nim.

import std/[math, options]
import ./cad_geometry

export cad_geometry

proc isFinitePositive(value: float64): bool {.inline.} =
  classify(value) notin {fcNan, fcInf, fcNegInf} and value > 0.0

proc intervalCount(length, maximumSpacing: float64): Option[uint32] =
  if not isFinitePositive(length) or not isFinitePositive(maximumSpacing):
    return none(uint32)
  let intervals = ceil(length / maximumSpacing)
  if intervals > float64(high(uint32)):
    return none(uint32)
  some(uint32(intervals))

proc fenceBayCount*(length, maximumSpacing: float64): Option[uint32] =
  ## Returns the equal fence-bay count needed not to exceed maximumSpacing.
  intervalCount(length, maximumSpacing)

proc fencePostCount*(length, maximumSpacing: float64): Option[uint32] =
  ## Includes both end posts.
  let bays = intervalCount(length, maximumSpacing)
  if bays.isNone or bays.get == high(uint32):
    return none(uint32)
  some(bays.get + 1'u32)

proc railingPostCount*(width, depth, maximumSpacing: float64): Option[uint32] =
  ## Calculates posts around the three guarded sides of a rectangular balcony.
  let front = intervalCount(width, maximumSpacing)
  let side = intervalCount(depth, maximumSpacing)
  if front.isNone or side.isNone:
    return none(uint32)
  let count = uint64(front.get) + uint64(side.get) * 2'u64 + 1'u64
  if count > uint64(high(uint32)):
    return none(uint32)
  some(uint32(count))

proc stairStep*(totalRun, totalRise: float64; steps: uint32): Option[tuple[going, rise: float64]] =
  ## Calculates the going and rise of a straight stair.
  if classify(totalRun) in {fcNan, fcInf, fcNegInf} or
      classify(totalRise) in {fcNan, fcInf, fcNegInf} or
      totalRun <= 0.0 or totalRise <= 0.0 or steps == 0:
    return none(tuple[going, rise: float64])
  some((going: totalRun / float64(steps), rise: totalRise / float64(steps)))

proc comfortableStairCount*(totalRise: float64; preferredRise = 175.0): Option[uint32] =
  ## Chooses a whole step count closest to a preferred riser height.
  if not isFinitePositive(totalRise) or not isFinitePositive(preferredRise):
    return none(uint32)
  let count = round(totalRise / preferredRise)
  if count < 1.0 or count > float64(high(uint32)):
    return none(uint32)
  some(uint32(count))

proc roofRafterLength*(span, rise: float64): Option[float64] =
  ## Calculates a symmetric roof's rafter length from its span and rise.
  if classify(span) in {fcNan, fcInf, fcNegInf} or
      classify(rise) in {fcNan, fcInf, fcNegInf} or span <= 0.0 or rise <= 0.0:
    return none(float64)
  some(sqrt((span / 2.0) ^ 2 + rise ^ 2))

proc roofPitchDegrees*(span, rise: float64): Option[float64] =
  ## Calculates the pitch of a symmetric roof in degrees.
  if not isFinitePositive(span) or not isFinitePositive(rise):
    return none(float64)
  some(arctan2(rise, span / 2.0) * 180.0 / PI)

proc gableRoofArea*(length, span, rise: float64): Option[float64] =
  ## Returns the combined area of both roof planes, excluding overhangs.
  let rafter = roofRafterLength(span, rise)
  if not isFinitePositive(length) or rafter.isNone:
    return none(float64)
  some(2.0 * length * rafter.get)

proc wallNetArea*(length, height, openingsArea: float64): Option[float64] =
  ## Returns wall surface after subtracting doors and windows.
  if not isFinitePositive(length) or not isFinitePositive(height) or
      classify(openingsArea) in {fcNan, fcInf, fcNegInf} or openingsArea < 0.0:
    return none(float64)
  let gross = length * height
  if openingsArea > gross:
    return none(float64)
  some(gross - openingsArea)

proc materialUnitCount*(area, coveragePerUnit: float64; wastePercent = 10.0): Option[uint32] =
  ## Rounds purchasable material units up after applying a waste allowance.
  if not isFinitePositive(area) or not isFinitePositive(coveragePerUnit) or
      classify(wastePercent) in {fcNan, fcInf, fcNegInf} or wastePercent < 0.0:
    return none(uint32)
  let units = ceil(area * (1.0 + wastePercent / 100.0) / coveragePerUnit)
  if units > float64(high(uint32)):
    return none(uint32)
  some(uint32(units))

proc rampLength*(rise, maximumGradient: float64): Option[float64] =
  ## Calculates horizontal run where gradient is rise divided by run.
  if not isFinitePositive(rise) or not isFinitePositive(maximumGradient):
    return none(float64)
  some(rise / maximumGradient)

proc rectangleArea*(length, width: float64): Option[float64] =
  ## Calculates the area of a rectangular building element.
  if not isFinitePositive(length) or not isFinitePositive(width):
    return none(float64)
  let result = length * width
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc rectanglePerimeter*(length, width: float64): Option[float64] =
  ## Calculates the perimeter of a rectangular room or slab.
  if not isFinitePositive(length) or not isFinitePositive(width):
    return none(float64)
  let result = 2.0 * (length + width)
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc rectangularVolume(length, width, height: float64): Option[float64] =
  let footprint = rectangleArea(length, width)
  if footprint.isNone or not isFinitePositive(height):
    return none(float64)
  let result = footprint.get * height
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc slabVolume*(length, width, thickness: float64): Option[float64] =
  ## Calculates concrete volume for a rectangular slab.
  rectangularVolume(length, width, thickness)

proc wallVolume*(length, height, thickness, openingsArea: float64): Option[float64] =
  ## Calculates net wall volume after subtracting openings.
  let area = wallNetArea(length, height, openingsArea)
  if area.isNone or not isFinitePositive(thickness):
    return none(float64)
  let result = area.get * thickness
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc repeatedOpeningArea*(width, height: float64; count: uint32): Option[float64] =
  ## Calculates the total area of equally sized doors or windows.
  let area = rectangleArea(width, height)
  if area.isNone or count == 0:
    return none(float64)
  let result = area.get * float64(count)
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc unitsForQuantity(quantity, coveragePerUnit, wastePercent: float64): Option[uint32] =
  if not isFinitePositive(quantity) or not isFinitePositive(coveragePerUnit) or
      classify(wastePercent) in {fcNan, fcInf, fcNegInf} or wastePercent < 0.0:
    return none(uint32)
  let units = ceil(quantity * (1.0 + wastePercent / 100.0) / coveragePerUnit)
  if classify(units) in {fcNan, fcInf, fcNegInf} or units > float64(high(uint32)):
    return none(uint32)
  some(uint32(units))

proc masonryUnitCount*(wallVolume, unitVolume: float64; wastePercent = 5.0): Option[uint32] =
  ## Estimates whole bricks or blocks by volume.
  unitsForQuantity(wallVolume, unitVolume, wastePercent)

proc tileCount*(area, tileLength, tileWidth: float64; wastePercent = 10.0): Option[uint32] =
  ## Estimates whole rectangular tiles, including a waste allowance.
  let tileArea = rectangleArea(tileLength, tileWidth)
  if tileArea.isNone:
    return none(uint32)
  unitsForQuantity(area, tileArea.get, wastePercent)

proc paintVolume*(area, coveragePerLitre: float64; coats: uint32): Option[float64] =
  ## Calculates paint volume for a number of complete coats.
  if not isFinitePositive(area) or not isFinitePositive(coveragePerLitre) or coats == 0:
    return none(float64)
  let result = area * float64(coats) / coveragePerLitre
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc stripFootingVolume*(length, width, depth: float64): Option[float64] =
  ## Calculates concrete volume for a continuous strip footing.
  rectangularVolume(length, width, depth)

proc rectangularColumnVolume*(width, depth, height: float64): Option[float64] =
  ## Calculates the volume of a rectangular column.
  rectangularVolume(width, depth, height)

proc beamVolume*(length, width, height: float64): Option[float64] =
  ## Calculates the volume of a rectangular beam.
  rectangularVolume(length, width, height)

proc circularColumnVolume*(diameter, height: float64): Option[float64] =
  ## Calculates the volume of a circular column.
  if not isFinitePositive(diameter) or not isFinitePositive(height):
    return none(float64)
  let result = PI * (diameter / 2.0) ^ 2 * height
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc downpipeCount*(roofPerimeter, maximumSpacing: float64): Option[uint32] =
  ## Calculates evenly spaced roof downpipes with at least two outlets.
  let intervals = intervalCount(roofPerimeter, maximumSpacing)
  if intervals.isNone:
    return none(uint32)
  some(max(2'u32, intervals.get))

proc triangleArea*(base, height: float64): Option[float64] =
  ## Calculates the area of a triangle.
  if not isFinitePositive(base) or not isFinitePositive(height):
    return none(float64)
  some(base * height / 2.0)

proc circleArea*(diameter: float64): Option[float64] =
  ## Calculates circular area from its diameter.
  if not isFinitePositive(diameter):
    return none(float64)
  some(PI * (diameter / 2.0) ^ 2)

proc circleCircumference*(diameter: float64): Option[float64] =
  ## Calculates circular circumference from its diameter.
  if not isFinitePositive(diameter):
    return none(float64)
  some(PI * diameter)

proc trapezoidArea*(parallelA, parallelB, height: float64): Option[float64] =
  ## Calculates the area between two positive parallel edges.
  if not isFinitePositive(parallelA) or not isFinitePositive(parallelB) or
      not isFinitePositive(height):
    return none(float64)
  some((parallelA + parallelB) * height / 2.0)

proc roomVolume*(length, width, height: float64): Option[float64] =
  ## Calculates the internal volume of a rectangular room.
  rectangularVolume(length, width, height)

proc skirtingLength*(length, width, doorwayWidth: float64): Option[float64] =
  ## Calculates room skirting after subtracting doorway widths.
  let perimeter = rectanglePerimeter(length, width)
  if perimeter.isNone or classify(doorwayWidth) in {fcNan, fcInf, fcNegInf} or
      doorwayWidth < 0.0 or doorwayWidth > perimeter.get:
    return none(float64)
  some(perimeter.get - doorwayWidth)

proc excavationVolume*(length, width, depth: float64): Option[float64] =
  ## Calculates bulk excavation volume.
  rectangularVolume(length, width, depth)

proc backfillVolume*(excavation, occupiedVolume: float64): Option[float64] =
  ## Calculates backfill after subtracting buried construction.
  if not isFinitePositive(excavation) or
      classify(occupiedVolume) in {fcNan, fcInf, fcNegInf} or
      occupiedVolume < 0.0 or occupiedVolume > excavation:
    return none(float64)
  some(excavation - occupiedVolume)

proc rampSlopePercent*(rise, run: float64): Option[float64] =
  ## Expresses a ramp gradient as a percentage.
  if not isFinitePositive(rise) or not isFinitePositive(run):
    return none(float64)
  some(rise / run * 100.0)

proc stairAngleDegrees*(totalRun, totalRise: float64): Option[float64] =
  ## Calculates the inclination of a stair flight.
  if not isFinitePositive(totalRun) or not isFinitePositive(totalRise):
    return none(float64)
  some(arctan2(totalRise, totalRun) * 180.0 / PI)

proc handrailLength*(totalRun, totalRise: float64; sides: uint32): Option[float64] =
  ## Calculates sloped handrail length for one or more stair sides.
  if not isFinitePositive(totalRun) or not isFinitePositive(totalRise) or sides == 0:
    return none(float64)
  some(hypot(totalRun, totalRise) * float64(sides))

proc rainwaterVolume*(roofArea, rainfallMillimetres: float64): Option[float64] =
  ## Returns captured rainwater in litres (one millimetre over one m² is one litre).
  if not isFinitePositive(roofArea) or not isFinitePositive(rainfallMillimetres):
    return none(float64)
  some(roofArea * rainfallMillimetres)

proc thermalTransmittance*(thermalResistance: float64): Option[float64] =
  ## Calculates U-value as the reciprocal of total thermal resistance.
  if not isFinitePositive(thermalResistance):
    return none(float64)
  some(1.0 / thermalResistance)

proc fabricHeatLoss*(area, uValue, temperatureDifference: float64): Option[float64] =
  ## Calculates steady-state transmission heat loss in watts.
  if not isFinitePositive(area) or not isFinitePositive(uValue) or
      not isFinitePositive(temperatureDifference):
    return none(float64)
  some(area * uValue * temperatureDifference)

proc ventilationFlow*(roomVolume, airChangesPerHour: float64): Option[float64] =
  ## Calculates required ventilation flow in cubic metres per hour.
  if not isFinitePositive(roomVolume) or not isFinitePositive(airChangesPerHour):
    return none(float64)
  some(roomVolume * airChangesPerHour)

proc daylightRatio*(windowArea, floorArea: float64): Option[float64] =
  ## Returns glazing-to-floor ratio as a percentage.
  if not isFinitePositive(windowArea) or not isFinitePositive(floorArea) or
      windowArea > floorArea:
    return none(float64)
  some(windowArea / floorArea * 100.0)

proc capacityCount*(usableArea, areaPerUnit: float64): Option[uint32] =
  ## Returns the whole number of occupants or spaces that fit in an area.
  if not isFinitePositive(usableArea) or not isFinitePositive(areaPerUnit):
    return none(uint32)
  let count = floor(usableArea / areaPerUnit)
  if count < 1.0 or count > float64(high(uint32)):
    return none(uint32)
  some(uint32(count))

proc occupancyCapacity*(usableArea, areaPerPerson: float64): Option[uint32] =
  ## Calculates conservative occupancy capacity from usable floor area.
  capacityCount(usableArea, areaPerPerson)

proc parkingSpaceCount*(usableArea, areaPerSpace: float64): Option[uint32] =
  ## Calculates whole parking spaces including their circulation allowance.
  capacityCount(usableArea, areaPerSpace)

proc reinforcementMass*(length, diameter: float64; density = 7850.0): Option[float64] =
  ## Calculates reinforcing-bar mass from dimensions and material density.
  let crossSection = circleArea(diameter)
  if crossSection.isNone or not isFinitePositive(length) or not isFinitePositive(density):
    return none(float64)
  some(crossSection.get * length * density)

proc pipeInternalVolume*(innerDiameter, length: float64): Option[float64] =
  ## Calculates the internal capacity of a cylindrical pipe.
  let crossSection = circleArea(innerDiameter)
  if crossSection.isNone or not isFinitePositive(length):
    return none(float64)
  some(crossSection.get * length)

proc ductSurfaceArea*(width, height, length: float64): Option[float64] =
  ## Calculates the four-sided sheet area of a rectangular duct.
  let perimeter = rectanglePerimeter(width, height)
  if perimeter.isNone or not isFinitePositive(length):
    return none(float64)
  some(perimeter.get * length)

proc ceilingPanelCount*(area, panelArea: float64): Option[uint32] =
  ## Rounds ceiling panels up without an additional waste allowance.
  unitsForQuantity(area, panelArea, 0.0)

proc gutterLength*(buildingLength: float64; eaves: uint32): Option[float64] =
  ## Calculates total gutter length for one or more eaves.
  if not isFinitePositive(buildingLength) or eaves == 0:
    return none(float64)
  some(buildingLength * float64(eaves))

proc roofOverhangArea*(buildingLength, buildingWidth, overhang: float64): Option[float64] =
  ## Calculates plan area added by a uniform roof overhang.
  if not isFinitePositive(buildingLength) or not isFinitePositive(buildingWidth) or
      not isFinitePositive(overhang):
    return none(float64)
  let outer = rectangleArea(buildingLength + 2.0 * overhang, buildingWidth + 2.0 * overhang)
  let inner = rectangleArea(buildingLength, buildingWidth)
  if outer.isNone or inner.isNone:
    return none(float64)
  some(outer.get - inner.get)

proc insulationVolume*(area, thickness: float64): Option[float64] =
  ## Calculates insulation volume from covered area and installed thickness.
  if not isFinitePositive(area) or not isFinitePositive(thickness):
    return none(float64)
  let result = area * thickness
  if classify(result) in {fcNan, fcInf, fcNegInf}:
    return none(float64)
  some(result)

proc sketchcad_fence_bay_count*(length, maximumSpacing: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  ## Stable C ABI entry point for the existing C++ application.
  fenceBayCount(length, maximumSpacing).get(0'u32)

proc sketchcad_roof_rafter_length*(span, rise: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  roofRafterLength(span, rise).get(NaN)

proc sketchcad_fence_post_count*(length, maximumSpacing: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  fencePostCount(length, maximumSpacing).get(0'u32)

proc sketchcad_railing_post_count*(width, depth, maximumSpacing: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  railingPostCount(width, depth, maximumSpacing).get(0'u32)

proc sketchcad_stair_going*(totalRun, totalRise: cdouble; steps: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  let dimensions = stairStep(totalRun, totalRise, steps)
  if dimensions.isSome: dimensions.get.going else: NaN

proc sketchcad_stair_rise*(totalRun, totalRise: cdouble; steps: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  let dimensions = stairStep(totalRun, totalRise, steps)
  if dimensions.isSome: dimensions.get.rise else: NaN

proc sketchcad_roof_pitch_degrees*(span, rise: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  roofPitchDegrees(span, rise).get(NaN)

proc sketchcad_gable_roof_area*(length, span, rise: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  gableRoofArea(length, span, rise).get(NaN)

proc sketchcad_wall_net_area*(length, height, openingsArea: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  wallNetArea(length, height, openingsArea).get(NaN)

proc sketchcad_material_unit_count*(area, coveragePerUnit, wastePercent: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  materialUnitCount(area, coveragePerUnit, wastePercent).get(0'u32)

proc sketchcad_ramp_length*(rise, maximumGradient: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  rampLength(rise, maximumGradient).get(NaN)

proc sketchcad_comfortable_stair_count*(totalRise, preferredRise: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  comfortableStairCount(totalRise, preferredRise).get(0'u32)

proc sketchcad_rectangle_area*(length, width: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  rectangleArea(length, width).get(NaN)

proc sketchcad_rectangle_perimeter*(length, width: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  rectanglePerimeter(length, width).get(NaN)

proc sketchcad_slab_volume*(length, width, thickness: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  slabVolume(length, width, thickness).get(NaN)

proc sketchcad_wall_volume*(length, height, thickness, openingsArea: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  wallVolume(length, height, thickness, openingsArea).get(NaN)

proc sketchcad_repeated_opening_area*(width, height: cdouble; count: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  repeatedOpeningArea(width, height, count).get(NaN)

proc sketchcad_masonry_unit_count*(wallVolume, unitVolume, wastePercent: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  masonryUnitCount(wallVolume, unitVolume, wastePercent).get(0'u32)

proc sketchcad_tile_count*(area, tileLength, tileWidth, wastePercent: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  tileCount(area, tileLength, tileWidth, wastePercent).get(0'u32)

proc sketchcad_paint_volume*(area, coveragePerLitre: cdouble; coats: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  paintVolume(area, coveragePerLitre, coats).get(NaN)

proc sketchcad_strip_footing_volume*(length, width, depth: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  stripFootingVolume(length, width, depth).get(NaN)

proc sketchcad_rectangular_column_volume*(width, depth, height: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  rectangularColumnVolume(width, depth, height).get(NaN)

proc sketchcad_beam_volume*(length, width, height: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  beamVolume(length, width, height).get(NaN)

proc sketchcad_circular_column_volume*(diameter, height: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  circularColumnVolume(diameter, height).get(NaN)

proc sketchcad_downpipe_count*(roofPerimeter, maximumSpacing: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  downpipeCount(roofPerimeter, maximumSpacing).get(0'u32)

proc sketchcad_triangle_area*(base, height: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  triangleArea(base, height).get(NaN)

proc sketchcad_circle_area*(diameter: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  circleArea(diameter).get(NaN)

proc sketchcad_circle_circumference*(diameter: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  circleCircumference(diameter).get(NaN)

proc sketchcad_trapezoid_area*(parallelA, parallelB, height: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  trapezoidArea(parallelA, parallelB, height).get(NaN)

proc sketchcad_room_volume*(length, width, height: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  roomVolume(length, width, height).get(NaN)

proc sketchcad_skirting_length*(length, width, doorwayWidth: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  skirtingLength(length, width, doorwayWidth).get(NaN)

proc sketchcad_excavation_volume*(length, width, depth: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  excavationVolume(length, width, depth).get(NaN)

proc sketchcad_backfill_volume*(excavation, occupiedVolume: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  backfillVolume(excavation, occupiedVolume).get(NaN)

proc sketchcad_ramp_slope_percent*(rise, run: cdouble): cdouble {.exportc, cdecl, dynlib.} =
  rampSlopePercent(rise, run).get(NaN)

proc sketchcad_stair_angle_degrees*(totalRun, totalRise: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  stairAngleDegrees(totalRun, totalRise).get(NaN)

proc sketchcad_handrail_length*(totalRun, totalRise: cdouble; sides: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  handrailLength(totalRun, totalRise, sides).get(NaN)

proc sketchcad_rainwater_volume*(roofArea, rainfallMillimetres: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  rainwaterVolume(roofArea, rainfallMillimetres).get(NaN)

proc sketchcad_thermal_transmittance*(thermalResistance: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  thermalTransmittance(thermalResistance).get(NaN)

proc sketchcad_fabric_heat_loss*(area, uValue, temperatureDifference: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  fabricHeatLoss(area, uValue, temperatureDifference).get(NaN)

proc sketchcad_ventilation_flow*(roomVolume, airChangesPerHour: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  ventilationFlow(roomVolume, airChangesPerHour).get(NaN)

proc sketchcad_daylight_ratio*(windowArea, floorArea: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  daylightRatio(windowArea, floorArea).get(NaN)

proc sketchcad_occupancy_capacity*(usableArea, areaPerPerson: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  occupancyCapacity(usableArea, areaPerPerson).get(0'u32)

proc sketchcad_parking_space_count*(usableArea, areaPerSpace: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  parkingSpaceCount(usableArea, areaPerSpace).get(0'u32)

proc sketchcad_reinforcement_mass*(length, diameter, density: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  reinforcementMass(length, diameter, density).get(NaN)

proc sketchcad_pipe_internal_volume*(innerDiameter, length: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  pipeInternalVolume(innerDiameter, length).get(NaN)

proc sketchcad_duct_surface_area*(width, height, length: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  ductSurfaceArea(width, height, length).get(NaN)

proc sketchcad_ceiling_panel_count*(area, panelArea: cdouble): uint32
    {.exportc, cdecl, dynlib.} =
  ceilingPanelCount(area, panelArea).get(0'u32)

proc sketchcad_gutter_length*(buildingLength: cdouble; eaves: uint32): cdouble
    {.exportc, cdecl, dynlib.} =
  gutterLength(buildingLength, eaves).get(NaN)

proc sketchcad_roof_overhang_area*(buildingLength, buildingWidth, overhang: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  roofOverhangArea(buildingLength, buildingWidth, overhang).get(NaN)

proc sketchcad_insulation_volume*(area, thickness: cdouble): cdouble
    {.exportc, cdecl, dynlib.} =
  insulationVolume(area, thickness).get(NaN)
