# SCNHighlight

Scale-invariant highlight effect for SCNNodes

![example_1](data/scnhighlight_demo.gif)

## Description

This project can be used as inspiration (or it can brutally copy-pasted)
to achieve a scale-invariant highlight effect on your SCNNodes.

"Scale-invariant" means that the highlight border maintains the same
thickness no matter how far from the camera the SCNNode is.
This is in contrast with the other main techniques to show a border around
objects which, although work when you're at close range from the highlighted
object, they "thin out" the highlight as the object is far away.

SCNHighlight can be particularly useful to show a highlight around SCNNodes
in an ARKit app, where selected objects might be far from the camera.

## Prerequisites

* XCode >= 10
* iOS >= 12.1

## Usage

* Clone the repo
* Build

## References

* Inspired and adapted from [SCNTechniqueGlow](https://github.com/laanlabs/SCNTechniqueGlow)

## Authors

* [Alberto Taiuti](https://albertotaiuti.com)
