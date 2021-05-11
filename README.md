# Web UI for Defold

Note: This is for applications only (at the moment). Web deployment may be possible - to be investigated.

This is a new type of web enginer. A very simplistic one that will support a number of html5 features.

The system utilises imgui for rendering. 

The current systems use a state manager to control the flow of UI execution. This is _not_ required. This is to make building GUI applications a little easier and it maps in nicely to Defold state processes.

## Libraries
All of this wouldnt work without some awesome libs:
- ImageLoader Extension for Defold   [ https://github.com/Lerg/extension-imageloader ]
- xml2lua for Svg loading   [ https://github.com/manoelcampos/xml2lua ]
- feather icons   [ https://feathericons.com/ ]

If I have missed anyone, please let me know. 

## Development
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
Performance is based on defold-cairo, so it will get better once caching and layering is added.
---
