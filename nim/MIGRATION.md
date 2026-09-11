# C++ to Nim migration

SketchCAD migrates native code by subsystem rather than mechanically translating files. This
keeps the application buildable and gives every replacement a reviewed C ABI, tests, and a
rollback path.

## Architecture-core milestone

The first milestone defines 50 native operations for architectural modelling and quantity
calculation. All fifty operations (100%) are now implemented in Nim and exported to C/C++.
The first group covers:

1. fence bay count
2. fence post count
3. three-sided balcony railing post count
4. stair going
5. stair rise
6. roof rafter length
7. roof pitch
8. gable roof area
9. net wall area and material-unit estimation
10. accessible-ramp length

The second group adds preferred stair counts, rectangular area and perimeter, opening area,
slab and wall volumes, strip-footing, beam, rectangular-column and circular-column volumes,
masonry and tile unit estimates, paint volume, and roof downpipe counts.

The final group adds triangle, circle and trapezoid geometry; room, excavation, backfill and
insulation quantities; stair, ramp, skirting and handrail measurements; rainwater, gutter and
roof-overhang calculations; thermal, heat-loss, ventilation and daylight metrics; occupancy and
parking capacity; and reinforcement, pipe, duct and ceiling-panel quantities.

The percentage refers to this explicitly bounded architecture-core milestone, not to all
historical FreeCAD C++ lines. The repository currently contains hundreds of thousands of C/C++
lines; replacing them in one unreviewed change would make geometry compatibility and file safety
unverifiable.

## CAD geometry milestone

The next migration stage moves reusable 3D point and vector primitives into the Nim library.
It currently provides validated vector addition, subtraction, scaling, dot and cross products,
length, distance, normalization, interpolation, and rotation around the global Z axis. The C ABI
uses a plain three-double `SketchCADPoint3` value and caller-owned output pointers; Nim-managed
memory never crosses the boundary.

## Migration rules

* Nim operations reject non-finite and invalid dimensions at the ABI boundary.
* The C header is the compatibility contract; callers never depend on Nim internals.
* Every exported calculation requires normal, boundary, and invalid-input tests.
* C++ is removed only after its callers use the Nim ABI and document compatibility results.
* CI must build and test each change on Windows, Ubuntu, and Fedora for x64 and ARM64.
