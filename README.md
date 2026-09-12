<img src="logo.png" alt="Logo" width="200" height="100">

# SketchCAD

### Fast, approachable parametric 3D design

SketchCAD is a community CAD application focused on direct, discoverable modelling for
architecture, houses, fences, balconies, decks and outdoor structures. It combines a
SketchUp-inspired quick-building workflow with precise parametric models, BIM/IFC tools,
and production drawings.

## Highlights

* **SketchCAD Build toolbar** — one-click house, fence, balcony, stair, deck and pergola
  generators provide useful starting geometry, and each generator is also scriptable.
* **Familiar modelling** — sketch in 2D, push designs into 3D, group building elements and
  return to parameters whenever dimensions change. A dedicated Direct Modeling toolbar keeps
  line, rectangle, offset, extrude, move, rotate, measure and camera controls together without
  copying another application's protected branding or visual assets.
* **Modern interface** — an airy SketchCAD Modern theme, architecture-first startup and
  focused tool grouping reduce visual clutter.
* **Modern foundations** — new geometry calculations are being implemented in Nim behind a
  stable C ABI. The first bounded architecture-core migration milestone is 20% complete; see
  [`nim/MIGRATION.md`](nim/MIGRATION.md) for its scope and safety rules.
* **Cross-platform** — automated core builds cover Windows, Ubuntu and Fedora on x64 and ARM64.

SketchCAD is derived from FreeCAD and remains LGPL-licensed. Existing FreeCAD file-format,
workbench and Python API compatibility is intentionally retained during the transition.

Installing
----------

Precompiled packages for stable releases are available for Windows, macOS and Linux on the
[latest releases page](https://github.com/FreeCAD/FreeCAD/releases/latest).

On most Linux distributions, FreeCAD is also directly installable from the 
software center application.

For weekly development releases visit the [releases page](https://github.com/FreeCAD/FreeCAD/releases/).

Other options are described on the [wiki Download page](https://wiki.freecad.org/Download).

Compiling
---------

See the [Developers Handbook – Getting Started](https://freecad.github.io/DevelopersHandbook/gettingstarted/)
for build instructions.


Reporting Issues
---------

To report an issue please:

- Consider posting to the [Forum](https://forum.freecad.org), [Discord](https://discord.com/invite/w2cTKGzccC) channel, or [Reddit](https://www.reddit.com/r/FreeCAD) to verify the issue; 
- Search the existing [issues](https://github.com/FreeCAD/FreeCAD/issues) for potential duplicates; 
- Use the most updated stable or [development versions](https://github.com/FreeCAD/FreeCAD/releases/) of FreeCAD; 
- Post version info from `Help > About FreeCAD > Copy to clipboard`; 
- Restart FreeCAD in safe mode `Help > Restart in safe mode` and try to reproduce the issue again. If the issue is resolved it can be fixed by deleting the FreeCAD config files.
- Start recording a macro `Macro > Macro recording...` and repeat all steps. Stop recording after the issue occurs and upload the saved macro or copy the macro code in the issue; 
- Post a Step-By-Step explanation on how to recreate the issue; 
- Upload an example file (FCStd as ZIP file) to demonstrate the problem; 

For more details see:

- [Bug Tracker](https://github.com/FreeCAD/FreeCAD/issues)
- [Reporting Issues and Requesting Features](https://github.com/FreeCAD/FreeCAD/issues/new/choose)
- [Contributing](https://github.com/FreeCAD/FreeCAD/blob/main/CONTRIBUTING.md)
- [Help Forum](https://forum.freecad.org/viewforum.php?f=3)

> [!NOTE]
The [FPA](https://fpa.freecad.org) offers developers the opportunity
to apply for a grant to work on projects of their choosing. Check
[jobs and funding](https://blog.freecad.org/jobs/) to know more.


Usage & Getting Help
--------------------

The FreeCAD wiki contains documentation on 
general FreeCAD usage, Python scripting, and development.
View these pages for more information:

- [Getting started](https://wiki.freecad.org/Getting_started)
- [Features list](https://wiki.freecad.org/Feature_list)
- [Frequent questions](https://wiki.freecad.org/FAQ/en)
- [Workbenches](https://wiki.freecad.org/Workbenches)
- [Scripting](https://wiki.freecad.org/Power_users_hub)
- [Developers Handbook](https://freecad.github.io/DevelopersHandbook/)

The [FreeCAD forum](https://forum.freecad.org) is a great place
to find help and solve specific problems when learning to use FreeCAD.

---

<p>This project receives generous infrastructure support from
  <a href="https://www.digitalocean.com/">
    <img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/SVG/DO_Logo_horizontal_blue.svg" width="91px">
  </a> and <a href="https://www.kipro-pcb.com/">KiCad Services Corp.</a>
</p>
