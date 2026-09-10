## Native architectural calculations used while SketchCAD migrates its C++ core to Nim.

import std/[math, options]

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
