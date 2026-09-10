# C++ to Nim migration

SketchCAD migrates native code by subsystem rather than mechanically translating files. This
keeps the application buildable and gives every replacement a reviewed C ABI, tests, and a
rollback path.

## Architecture-core milestone

The first milestone defines 50 native operations for architectural modelling and quantity
calculation. Ten operations (20%) are now implemented in Nim and exported to C/C++:

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

The percentage refers to this explicitly bounded architecture-core milestone, not to 20% of all
historical FreeCAD C++ lines. The repository currently contains hundreds of thousands of C/C++
lines; replacing a fifth in one unreviewed change would make geometry compatibility and file
safety unverifiable.

## Migration rules

* Nim operations reject non-finite and invalid dimensions at the ABI boundary.
* The C header is the compatibility contract; callers never depend on Nim internals.
* Every exported calculation requires normal, boundary, and invalid-input tests.
* C++ is removed only after its callers use the Nim ABI and document compatibility results.
* CI must build and test each change on Windows, Ubuntu, and Fedora for x64 and ARM64.
