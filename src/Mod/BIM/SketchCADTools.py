# SPDX-License-Identifier: LGPL-2.1-or-later
"""Quick architectural generators for the SketchCAD BIM workbench.

The functions are intentionally usable from both the GUI commands and Python console.
Dimensions are expressed in millimetres, matching the native document unit.
"""

import math

import FreeCAD as App
import Part


def _document():
    return App.ActiveDocument or App.newDocument("SketchCADModel")


def _feature(name, label, shapes, color):
    obj = _document().addObject("PartDesign::Feature", name)
    obj.Label = label
    obj.Shape = Part.makeCompound(shapes)
    obj.addProperty("App::PropertyString", "Generator", "SketchCAD", "Source tool")
    obj.Generator = name
    if hasattr(obj, "ViewObject"):
        obj.ViewObject.ShapeColor = color
    _document().recompute()
    return obj


def create_house(width=10000, depth=8000, height=3000, wall=250, roof_rise=1800):
    """Create an editable house shell with a doorway and a pitched roof."""
    if min(width, depth, height, wall, roof_rise) <= 0 or wall * 2 >= min(width, depth):
        raise ValueError(
            "House dimensions must be positive and wall must fit inside the footprint"
        )
    outer = Part.makeBox(width, depth, height)
    inner = Part.makeBox(
        width - 2 * wall, depth - 2 * wall, height, App.Vector(wall, wall, wall)
    )
    shell = outer.cut(inner)
    door = Part.makeBox(
        1000, wall * 2, 2100, App.Vector((width - 1000) / 2, -wall / 2, 0)
    )
    shell = shell.cut(door)
    run = depth / 2
    slope = math.hypot(run, roof_rise)
    angle = math.degrees(math.atan2(roof_rise, run))
    left = Part.makeBox(width, slope, wall, App.Vector(0, 0, height))
    left.rotate(App.Vector(0, 0, height), App.Vector(1, 0, 0), angle)
    right = Part.makeBox(width, slope, wall, App.Vector(0, depth, height))
    right.rotate(App.Vector(0, depth, height), App.Vector(1, 0, 0), 180 - angle)
    return _feature("SketchCADHouse", "House", [shell, left, right], (0.92, 0.86, 0.72))


def create_fence(length=6000, height=1200, spacing=1500, post=100, rails=2):
    """Create evenly spaced fence posts and horizontal rails."""
    if min(length, height, spacing, post) <= 0 or rails < 1:
        raise ValueError("Fence dimensions and rail count must be positive")
    intervals = max(1, math.ceil(length / spacing))
    shapes = [
        Part.makeBox(post, post, height, App.Vector(length * i / intervals, 0, 0))
        for i in range(intervals + 1)
    ]
    for i in range(rails):
        z = height * (i + 1) / (rails + 1)
        shapes.append(
            Part.makeBox(length + post, post / 2, post / 2, App.Vector(0, post / 4, z))
        )
    return _feature("SketchCADFence", "Fence", shapes, (0.45, 0.28, 0.12))


def create_balcony(width=3500, depth=1600, slab=180, railing=1050, spacing=900):
    """Create a balcony slab with three-sided guard railing."""
    if min(width, depth, slab, railing, spacing) <= 0:
        raise ValueError("Balcony dimensions must be positive")
    shapes = [Part.makeBox(width, depth, slab)]
    post = 45
    for x in _positions(width, spacing):
        shapes.append(
            Part.makeBox(post, post, railing, App.Vector(x, depth - post, slab))
        )
    for y in _positions(depth, spacing):
        shapes.extend(
            (
                Part.makeBox(post, post, railing, App.Vector(0, y, slab)),
                Part.makeBox(post, post, railing, App.Vector(width - post, y, slab)),
            )
        )
    shapes.extend(
        (
            Part.makeBox(
                width, post, post, App.Vector(0, depth - post, slab + railing)
            ),
            Part.makeBox(post, depth, post, App.Vector(0, 0, slab + railing)),
            Part.makeBox(
                post, depth, post, App.Vector(width - post, 0, slab + railing)
            ),
        )
    )
    return _feature("SketchCADBalcony", "Balcony", shapes, (0.72, 0.74, 0.78))


def create_stairs(width=1000, total_run=3000, total_rise=2700, steps=15):
    """Create a straight staircase from ergonomic rise/run inputs."""
    if min(width, total_run, total_rise, steps) <= 0:
        raise ValueError("Stair dimensions and step count must be positive")
    tread, rise = total_run / steps, total_rise / steps
    shapes = [
        Part.makeBox(width, tread, rise * (i + 1), App.Vector(0, tread * i, 0))
        for i in range(steps)
    ]
    return _feature("SketchCADStairs", "Staircase", shapes, (0.65, 0.65, 0.67))


def create_deck(width=5000, depth=3000, board=140, gap=6, thickness=28):
    """Create a deck made from individually visible boards."""
    if min(width, depth, board, thickness) <= 0 or gap < 0:
        raise ValueError("Deck dimensions must be positive")
    count = max(1, math.floor((depth + gap) / (board + gap)))
    shapes = [
        Part.makeBox(width, board, thickness, App.Vector(0, i * (board + gap), 0))
        for i in range(count)
    ]
    return _feature("SketchCADDeck", "Deck", shapes, (0.58, 0.36, 0.18))


def create_pergola(width=4000, depth=3000, height=2500, post=140, beam=180, rafters=7):
    """Create a four-post pergola with beams and evenly distributed rafters."""
    if min(width, depth, height, post, beam, rafters) <= 0:
        raise ValueError("Pergola dimensions must be positive")
    shapes = [
        Part.makeBox(post, post, height, App.Vector(x, y, 0))
        for x in (0, width - post)
        for y in (0, depth - post)
    ]
    shapes.extend(
        (
            Part.makeBox(width, beam, beam, App.Vector(0, 0, height)),
            Part.makeBox(width, beam, beam, App.Vector(0, depth - beam, height)),
        )
    )
    for x in _positions(width - post, (width - post) / max(1, rafters - 1)):
        shapes.append(
            Part.makeBox(post, depth, beam / 2, App.Vector(x, 0, height + beam))
        )
    return _feature("SketchCADPergola", "Pergola", shapes, (0.50, 0.31, 0.14))


def _positions(length, maximum_spacing):
    intervals = max(1, math.ceil(length / maximum_spacing))
    return [length * i / intervals for i in range(intervals + 1)]


class _CreateCommand:
    def __init__(self, label, tooltip, icon, function):
        self.resources = {"MenuText": label, "ToolTip": tooltip, "Pixmap": icon}
        self.function = function

    def GetResources(self):
        return self.resources

    def IsActive(self):
        return True

    def Activated(self):
        doc = _document()
        doc.openTransaction(self.resources["MenuText"])
        try:
            self.function()
            doc.commitTransaction()
        except Exception:
            doc.abortTransaction()
            raise


if App.GuiUp:
    import FreeCADGui as Gui

    _COMMANDS = {
        "SketchCAD_House": (
            "House",
            "Create a house shell with pitched roof",
            "Arch_Building",
            create_house,
        ),
        "SketchCAD_Fence": (
            "Fence",
            "Create a post-and-rail fence",
            "Arch_Fence",
            create_fence,
        ),
        "SketchCAD_Balcony": (
            "Balcony",
            "Create a balcony and guard railing",
            "Arch_Structure",
            create_balcony,
        ),
        "SketchCAD_Stairs": (
            "Stairs",
            "Create a straight staircase",
            "Arch_Stairs",
            create_stairs,
        ),
        "SketchCAD_Deck": ("Deck", "Create a timber deck", "Arch_Floor", create_deck),
        "SketchCAD_Pergola": (
            "Pergola",
            "Create a post, beam and rafter pergola",
            "Arch_Frame",
            create_pergola,
        ),
    }
    for command_name, command in _COMMANDS.items():
        Gui.addCommand(command_name, _CreateCommand(*command))
