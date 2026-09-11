## Reusable three-dimensional CAD geometry implemented in Nim.
##
## The value-level API returns Option for operations that can fail. The exported
## C ABI uses an integer status and caller-owned output storage so no Nim-managed
## memory crosses the language boundary.

import std/[math, options]

type
  SketchCadPoint3* {.bycopy.} = object
    x*, y*, z*: float64

proc isFinite(value: float64): bool {.inline.} =
  classify(value) notin {fcNan, fcInf, fcNegInf}

proc isFinite(point: SketchCadPoint3): bool {.inline.} =
  isFinite(point.x) and isFinite(point.y) and isFinite(point.z)

proc point3*(x, y, z: float64): Option[SketchCadPoint3] =
  ## Creates a validated point or vector.
  let point = SketchCadPoint3(x: x, y: y, z: z)
  if not point.isFinite:
    return none(SketchCadPoint3)
  some(point)

proc add*(left, right: SketchCadPoint3): Option[SketchCadPoint3] =
  ## Adds two vectors component by component.
  if not left.isFinite or not right.isFinite:
    return none(SketchCadPoint3)
  point3(left.x + right.x, left.y + right.y, left.z + right.z)

proc subtract*(left, right: SketchCadPoint3): Option[SketchCadPoint3] =
  ## Subtracts right from left component by component.
  if not left.isFinite or not right.isFinite:
    return none(SketchCadPoint3)
  point3(left.x - right.x, left.y - right.y, left.z - right.z)

proc scale*(vector: SketchCadPoint3; factor: float64): Option[SketchCadPoint3] =
  ## Scales a vector uniformly.
  if not vector.isFinite or not factor.isFinite:
    return none(SketchCadPoint3)
  point3(vector.x * factor, vector.y * factor, vector.z * factor)

proc dot*(left, right: SketchCadPoint3): Option[float64] =
  ## Calculates the scalar product of two vectors.
  if not left.isFinite or not right.isFinite:
    return none(float64)
  let result = left.x * right.x + left.y * right.y + left.z * right.z
  if not result.isFinite: none(float64) else: some(result)

proc cross*(left, right: SketchCadPoint3): Option[SketchCadPoint3] =
  ## Calculates the right-handed cross product.
  if not left.isFinite or not right.isFinite:
    return none(SketchCadPoint3)
  point3(
    left.y * right.z - left.z * right.y,
    left.z * right.x - left.x * right.z,
    left.x * right.y - left.y * right.x,
  )

proc vectorLength*(vector: SketchCadPoint3): Option[float64] =
  ## Calculates Euclidean vector length without avoidable intermediate overflow.
  if not vector.isFinite:
    return none(float64)
  let result = hypot(hypot(vector.x, vector.y), vector.z)
  if not result.isFinite: none(float64) else: some(result)

proc distance*(left, right: SketchCadPoint3): Option[float64] =
  ## Calculates Euclidean distance between two points.
  let delta = subtract(left, right)
  if delta.isNone: none(float64) else: vectorLength(delta.get)

proc normalize*(vector: SketchCadPoint3): Option[SketchCadPoint3] =
  ## Produces a unit vector; the zero vector has no normalization.
  let length = vectorLength(vector)
  if length.isNone or length.get == 0.0:
    return none(SketchCadPoint3)
  scale(vector, 1.0 / length.get)

proc lerp*(startPoint, endPoint: SketchCadPoint3; amount: float64): Option[SketchCadPoint3] =
  ## Interpolates between points; amount must be in the closed interval [0, 1].
  if not amount.isFinite or amount < 0.0 or amount > 1.0:
    return none(SketchCadPoint3)
  let delta = subtract(endPoint, startPoint)
  if delta.isNone:
    return none(SketchCadPoint3)
  let offset = scale(delta.get, amount)
  if offset.isNone: none(SketchCadPoint3) else: add(startPoint, offset.get)

proc rotateAroundZ*(point: SketchCadPoint3; angleDegrees: float64): Option[SketchCadPoint3] =
  ## Rotates a point around the global Z axis.
  if not point.isFinite or not angleDegrees.isFinite:
    return none(SketchCadPoint3)
  let angle = angleDegrees * PI / 180.0
  let cosine = cos(angle)
  let sine = sin(angle)
  point3(point.x * cosine - point.y * sine, point.x * sine + point.y * cosine, point.z)

proc writeResult(output: ptr SketchCadPoint3; result: Option[SketchCadPoint3]): cint =
  if output.isNil or result.isNone:
    return 0
  output[] = result.get
  1

proc sketchcad_point3_add*(left, right: ptr SketchCadPoint3; output: ptr SketchCadPoint3): cint
    {.exportc, cdecl, dynlib.} =
  if left.isNil or right.isNil: 0 else: writeResult(output, add(left[], right[]))

proc sketchcad_point3_subtract*(left, right: ptr SketchCadPoint3; output: ptr SketchCadPoint3): cint
    {.exportc, cdecl, dynlib.} =
  if left.isNil or right.isNil: 0 else: writeResult(output, subtract(left[], right[]))

proc sketchcad_point3_scale*(vector: ptr SketchCadPoint3; factor: cdouble;
    output: ptr SketchCadPoint3): cint {.exportc, cdecl, dynlib.} =
  if vector.isNil: 0 else: writeResult(output, scale(vector[], factor))

proc sketchcad_point3_dot*(left, right: ptr SketchCadPoint3; output: ptr cdouble): cint
    {.exportc, cdecl, dynlib.} =
  if left.isNil or right.isNil or output.isNil:
    return 0
  let result = dot(left[], right[])
  if result.isNone:
    return 0
  output[] = result.get
  1

proc sketchcad_point3_cross*(left, right: ptr SketchCadPoint3; output: ptr SketchCadPoint3): cint
    {.exportc, cdecl, dynlib.} =
  if left.isNil or right.isNil: 0 else: writeResult(output, cross(left[], right[]))

proc sketchcad_point3_length*(vector: ptr SketchCadPoint3): cdouble {.exportc, cdecl, dynlib.} =
  if vector.isNil: NaN else: vectorLength(vector[]).get(NaN)

proc sketchcad_point3_distance*(left, right: ptr SketchCadPoint3): cdouble
    {.exportc, cdecl, dynlib.} =
  if left.isNil or right.isNil: NaN else: distance(left[], right[]).get(NaN)

proc sketchcad_point3_normalize*(vector: ptr SketchCadPoint3; output: ptr SketchCadPoint3): cint
    {.exportc, cdecl, dynlib.} =
  if vector.isNil: 0 else: writeResult(output, normalize(vector[]))

proc sketchcad_point3_lerp*(startPoint, endPoint: ptr SketchCadPoint3; amount: cdouble;
    output: ptr SketchCadPoint3): cint {.exportc, cdecl, dynlib.} =
  if startPoint.isNil or endPoint.isNil:
    return 0
  writeResult(output, lerp(startPoint[], endPoint[], amount))

proc sketchcad_point3_rotate_z*(point: ptr SketchCadPoint3; angleDegrees: cdouble;
    output: ptr SketchCadPoint3): cint {.exportc, cdecl, dynlib.} =
  if point.isNil: 0 else: writeResult(output, rotateAroundZ(point[], angleDegrees))
