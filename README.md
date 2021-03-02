# Web UI for Defold

Note: This is for applications only (at the moment). Web deployment may be possible - to be investigated.
This is derived from the defold-cairo project Im working on.

The aim is to provide a cairo web styled interface for easy UI development and integration with my OpenGLES rendering setup.

The current systems use a state manager to control the flow of UI execution. This is _not_ required. This is to make building GUI applications a little easier and it maps in nicely to Defold state processes.

## Libraries
All of this wouldnt work without some awesome libs:
- Cairo toolkit [ https://www.cairographics.org/ ]
- ImageLoader Extension for Defold   [ https://github.com/Lerg/extension-imageloader ]
- xml2lua for Svg loading   [ https://github.com/manoelcampos/xml2lua ]
- feather icons   [ https://feathericons.com/ ]

If I have missed anyone, please let me know. 

## Development
Feb 2021:
In its current state - its a mess :) Beware. Everything is changing, the XML parser, the element parser and rendering. Dont rely on anything at the moment. I expect a stable version to be a month away.

Only tested on Linux, but should work on Windows and OSX. Android and IOS I need to build cairo for them to be usable. 

Im working on:
- Better element/cell parsing and raster descriptions
- Handling render and dom styled structures
- Adding more element support
- A demonstration of a basic html page.

## Notes
Performance is based on defold-cairo, so it will get better once caching and layering is added.
---
