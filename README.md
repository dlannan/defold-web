# Web UI for Defold

Note: This is for applications only (at the moment). 
* Web deployment may be possible - Yes it works. defold-web now works within the web as well. 
* Android, Linux, Win10 and HTML all appear to be working well - your mileage may vary on platforms, only sample testing has been done.

This is a new type of web engine. A very simplistic one that will support a number of html5 features.
Primary layout, elements creation and rendering are done in lua. The rendering system is decoupled, so this could be used in almost any luajit based system.

## Imgui
The system currently utilises imgui for rendering. 
[ https://github.com/britzl/extension-imgui ]

## Libraries
All of this wouldnt work without some awesome libs:
- xml2lua for Svg loading   [ https://github.com/manoelcampos/xml2lua ]
- feather icons   [ https://feathericons.com/ ]

If I have missed anyone, please let me know. 

## Development
June 2021:
- imgui being improved to support fonts and images
- rewrote the layout system. Now uses a correct margin calc - still not ideal, but much better.
- Image buttons added.

May 2021:
Many changes 
- No more cairo. Replaced with imgui extension from defold (modified)
- Simplified whole process. Aim is minimalist with key html5 features.

Feb 2021:
In its current state - its a mess :) Beware. Everything is changing, the XML parser, the element parser and rendering. Dont rely on anything at the moment. I expect a stable version to be a month away.

---
Im working on:
- Better element/cell parsing and raster descriptions
- Handling render and dom styled structures
- Adding more element support
- A demonstration of a basic html page.
- Adding QuickJS for running JS within the engine.
- Adding a CSS parser (pure lua) so _some_ css features can be used.

Only tested on Linux, but should work on Windows and OSX. Android and IOS I need to build cairo for them to be usable. 

## Notes

When running in Defold debug is _very_ slow. This is because of the debug info when calling imgui. Run with release to see proper perf - Ctrl + B.
Early html testing is passing. Will use W3C html tests to validate pages once the system is stable. 

---
