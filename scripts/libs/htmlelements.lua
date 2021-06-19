----------------------------------------------------------------------------------
-- Html element rendering. 
--
-- 		Each element has a style setup (element entry) and a style cleanup (element exit)

----------------------------------------------------------------------------------

local tinsert 	= table.insert
local tremove 	= table.remove

local tcolor = { r=0.0, b=1.0, g=0.0, a=1.0 }
local rapi 		= require("scripts.libs.htmlrender-api")

----------------------------------------------------------------------------------

local FONT_SIZES = {

	h1		= 24.0,
	h2 		= 20.0,
	h3 		= 16.0,
	h4 		= 14.0,
	h5 		= 12.0,
	h6 		= 10.0,

	p 		= 14.0,
	normal	= 12.0,
	blockquote = 12.0,
}

----------------------------------------------------------------------------------

local TEXT_CONST = {

	NONE 		= 0,
	TAB 		= FONT_SIZES.p * 2.0,

	MARGINS 	= 1.0 / 1.1875,
	HEADINGS 	= 1.0 / 1.8,
	BLOCK		= 0.8,
}

----------------------------------------------------------------------------------

local htmlelements = {}
local layout = require("scripts.libs.htmllayout")

local function defaultmargin( style ) 

	return { 
		top 	= style.textsize * TEXT_CONST.MARGINS, 
		bottom 	= style.textsize * TEXT_CONST.MARGINS,
		left 	= 2,
		right 	= 2,
	}
end 

local function defaultpadding( style ) 

	return { 
		top 	= 0, 
		bottom 	= 0,
		left 	= 0,
		right 	= 0,
	}
end 

local function defaultborder( style ) 

	return { 
		top 	= 0, 
		bottom 	= 0,
		left 	= 0,
		right 	= 0,
	}
end 

----------------------------------------------------------------------------------

local function getmargin( style, topbottom, sides )

	local fr = topbottom or 0
	local fs = sides or 0
	return { 
		top 	= style.textsize * fr, 
		bottom 	= style.textsize * fr,
		left 	= fs, right = fs 
	}
end

local function checkmargins( g, style )

	-- Check if previous margin is big enough for this style otherwise add difference.
	local margin 	= style.margin
	if g.cursor.element_top then 
		local prev_margin = g.cursor.top - g.cursor.element_top
		if prev_margin < margin.top then 
			g.cursor.top = g.cursor.top + (margin.top - prev_margin)
		end
		g.cursor.element_top = nil
	else 
		g.cursor.top = g.cursor.top + margin.top
	end

	if g.cursor.element_left then 
		local prev_margin = g.cursor.left - g.cursor.element_left
		if prev_margin < margin.left then 
			g.cursor.left = g.cursor.left + (margin.left - prev_margin)
		end
	else 
		g.cursor.left = g.cursor.left + margin.left
	end
end 

----------------------------------------------------------------------------------

local function getlineheight( style ) 

	local lh =  style.textsize
	if(style.height > lh) then lh = style.height end 
	return lh
end

local function stepline( g, style )
	-- Step a line
	g.cursor.top 	= g.cursor.top + style.linesize
	-- Add in the collated margin from the bottom
	g.cursor.element_top = g.cursor.top
	g.cursor.top 	= g.cursor.top + style.margin.bottom

	-- Return to leftmost + parent margin
	g.cursor.left 	= g.frame.left
	g.cursor.element_left = g.cursor.left
end 

----------------------------------------------------------------------------------

local function elementopen( g, style, attribs )

	local element 		= layout.addelement( g, style, attribs )
	style.elementid 	= element.id
	element.cursor_top 	= g.cursor.top
	--g.cursor.left = g.cursor.left + element.margin.left
end 

----------------------------------------------------------------------------------

local function elementclose( g, style )

	local element 		= layout.getelement(style.elementid)
	local geom 			= layout.getgeom()
	local dim 			= geom[element.gid]

	-- print(element.etype, dim.left, dim.top, dim.width, dim.height)
	geom.renew( element.gid, dim.left, dim.top, dim.width, dim.height )
end 

----------------------------------------------------------------------------------
-- 
local function textdefault( g, style, attribs, text )

	-- remove any newlines or tabs from text!
	text = string.gsub(text, "[\n\r\t]", "")
	
	style.etype = "text"
	local fontface 	= g.ctx.getstyle(style)
	local fontscale = style.textsize/g.ctx.fontsize
	local wrapwidth = g.frame.width - g.cursor.left
	local w, h 		= rapi.text_getsize(text, fontscale, fontface, wrapwidth)
	
	style.width 	= w * g.ctx.fontsize
	style.height 	= h * g.ctx.fontsize

	-- if(style.margin == nil) then print(style.etype) end
	local element 	= layout.addelement( g, style, attribs )	

	layout.addtextobject( g, style, text )

	g.cursor.left 	= g.cursor.left + style.width 
	elementclose(g, style)
end
----------------------------------------------------------------------------------

local function textnone( g, style, text )

end 

----------------------------------------------------------------------------------
-- Default close always end the line of elements back to the leftmost start position
local function defaultclose( g, style )
	
	elementclose(g, style)
	
	stepline(g, style)
end	

local function closenone( g, style )

end	

----------------------------------------------------------------------------------

local function headingopen( g, style, attribs )

	style.textsize 	= FONT_SIZES[string.lower(style.etype)]
	style.margin 	= getmargin(style, TEXT_CONST.HEADINGS, 0)
	style.linesize 	= getlineheight(style)

	checkmargins( g, style )
	elementopen(g, style, attribs)
end	

----------------------------------------------------------------------------------
-- Heading elements 

htmlelements["h1"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

htmlelements["h2"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

htmlelements["h3"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

htmlelements["h4"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

htmlelements["h5"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

htmlelements["h6"]  = {
	opened 		= headingopen,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["p"]  = {
	opened 		= function( g, style, attribs)
		style.textsize 	= FONT_SIZES.p
		style.margin 	= getmargin(style, TEXT_CONST.MARGINS, 2)
		style.linesize 	= style.textsize
		checkmargins( g, style )
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["i"]  = {
	opened 		= function( g, style, attribs )
		style.fontstyle 	= 1
		elementopen(g, style, attribs)
	end,
	closed 		= function( g, style )	
		elementclose(g, style)
		style.fontstyle = nil
	end,
}

htmlelements["b"]  = {
	opened 		= function( g, style, attribs )
		style.fontweight 	= 1
		elementopen(g, style, attribs)
	end,
	closed 		= function( g, style )
		elementclose(g, style)
		style.fontweight = nil
	end,
}

----------------------------------------------------------------------------------

htmlelements["br"]  = {
	opened 		= function( g, style, attribs )
		style.margin 		= getmargin(style, TEXT_CONST.NONE, 0)
	end,
	closed 		= function( g, style )
		defaultclose(g, style)
		style.pstyle.linesize = getlineheight(style)
	end,
}

----------------------------------------------------------------------------------

htmlelements["blockquote"] = {
	opened 		= function( g, style, attribs )
		style.textsize 		= FONT_SIZES.blockquote
		style.margin 		= getmargin(style, TEXT_CONST.MARGINS, 40)
		style.linesize 		= getlineheight(style)
		checkmargins( g, style )
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["img"]  = {
	opened 		= function( g, style, attribs )

		style.etype 		= "img"

		if(attribs.width) then style.width = attribs.width end 
		if(attribs.height) then style.height = attribs.height end 
		if(attribs.src) then 
			style.src = attribs.src
			style.imgid = style.imgid or rapi.image_load(attribs.src) 
		end

		--checkmargins( g, style )
		
		local element 		= layout.addelement( g, style, attribs )
		layout.addimageobject( g, style )
	end,
	
	closed 		= function( g, style )	
		-- Push the size of the element into the button object
		local element 		= layout.getelement(style.elementid)
		--layout.updateelement( style.elementid, element )

		local geom = layout.getgeom()
		geom.renew( element.gid, element.pos.left, element.pos.top, element.width, element.height )

		-- Return to leftmost + parent margin
		g.cursor.left 	= g.cursor.left + element.width
		g.cursor.element_left = g.cursor.left
		
		-- g.cursor.top 	= geom[ element.gid ].top
		if(element.height > style.pstyle.linesize) then style.pstyle.linesize  = element.height end
	end,
}

----------------------------------------------------------------------------------

htmlelements["button"] = {
	opened 		= function( g, style, attribs )

		-- local omargin = style.margin
		style.margin.top 	= 0
		style.margin.bottom = 0
		style.margin.left 	= 0
		style.margin.right 	= 0 

		style.padding.top 	= 0
		style.padding.bottom = 0
		style.padding.left 	= 8
		style.padding.right = 8 

		style.border.top 	= 5
		style.border.bottom = 5
		style.border.left 	= 17
		style.border.right 	= 17 
		
		-- A button is inserted as an "empty" div which is expanded as elements are added.
		local element 		= layout.addelement( g, style, attribs )
		style.elementid 	= element.id
		element.cursor_top 	= g.cursor.top

		layout.addbuttonobject( g, style )
	end,
	closed 		= function( g, style )

		-- Push the size of the element into the button object
		local element 		= layout.getelement(style.elementid)
		local geom 			= layout.getgeom()
		local obj 			= geom.get( element.gid )
		
		element.width 		= obj.width
		element.height 		= obj.height

		geom.renew( element.gid, element.pos.left, element.pos.top, element.width, element.height )

		if(element.height > style.pstyle.linesize) then style.pstyle.linesize  = element.height end
	end,
}

----------------------------------------------------------------------------------

htmlelements["body"] = {
	opened 		= elementopen,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["html"] = {
	opened 		= elementopen,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["head"] = {
	opened 		= function(g, style, attribs)
		-- Dont process head element normally
		style.dontprocess = true
		end,
	closed 		= function() end ,
}

----------------------------------------------------------------------------------

return {
	FONT_SIZES 		= FONT_SIZES,

	addtextobject 	= textdefault,

	defaultmargin	= defaultmargin,
	defaultpadding	= defaultpadding,
	defaultborder	= defaultborder,
	
	elements 		= htmlelements, 
	init			= layout.init,
	finish			= layout.finish,
}

----------------------------------------------------------------------------------