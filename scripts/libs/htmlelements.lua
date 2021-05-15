----------------------------------------------------------------------------------
-- Html element rendering. 
--
-- 		Each element has a style setup (element entry) and a style cleanup (element exit)

----------------------------------------------------------------------------------

local tinsert 	= table.insert
local tremove 	= table.remove

local tcolor = { r=0.0, b=1.0, g=0.0, a=1.0 }

----------------------------------------------------------------------------------

local FONT_SIZES = {

	h1		= 24.0,
	h2 		= 20.0,
	h3 		= 16.0,
	h4 		= 14.0,
	h5 		= 12.0,
	h6 		= 10.0,

	p 		= 14.0,
}

----------------------------------------------------------------------------------

local TEXT_CONST = {

	NONE 		= 0,
	TAB 		= FONT_SIZES.p * 2.0,

	MARGINS 	= 1.0 / 1.1875,
	HEADINGS 	= 1.0 / 1.8,
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

----------------------------------------------------------------------------------

local function getmargin( style, factorrows, sides )

	local fr = factorrows or 0
	local fs = sides or 0
	return { 
		top 	= style.textsize * factorrows, 
		bottom 	= style.textsize * factorrows,
		left 	= sides, right = sides 
	}
end

----------------------------------------------------------------------------------

local function getlineheight( style ) 

	return style.textsize + style.margin.top + style.margin.bottom
end


----------------------------------------------------------------------------------

local function elementopen( g, style, attribs )

	local element 		= layout.addelement( g, style, attribs )
	style.elementid 	= element.id
	g.cursor.left = g.cursor.left + element.margin.left
end 

----------------------------------------------------------------------------------

local function elementclose( g, style )

	local element 		= layout.getelement(style.elementid)
	local geom 			= layout.getgeom()
	local dim 			= geom[element.gid]

	-- print(element.etype, dim.left, dim.top, dim.width, dim.height)
	geom.renew( element.gid, dim.left, dim.top, dim.width, dim.height )

	-- This is not needed?
	-- g.cursor.left = g.cursor.left + style.margin.right
end 

----------------------------------------------------------------------------------
-- 
local function textdefault( g, style, attribs, text )

	style.etype = "text"
	local fontface 	= g.ctx.getstyle(style)
	local fontscale = style.textsize/g.ctx.fontsize
	local w, h 		= imgui.text_getsize(text, fontscale, fontface)
	
	style.width 	= w * g.ctx.fontsize
	style.height 	= h * g.ctx.fontsize

	-- if(style.margin == nil) then print(style.etype) end
	local element 	= layout.addelement( g, style, attribs )	

	layout.addtextobject( g, style, text )

	g.cursor.left 	= g.cursor.left + w * g.ctx.fontsize
	elementclose(g, style)
end
----------------------------------------------------------------------------------

local function textnone( g, style, text )

end 

----------------------------------------------------------------------------------

local function buttonopen( g, style, attribs )

	local omargin = style.margin
	style.margin.top 	= 8
	style.margin.bottom = 8
	style.margin.left 	= 8
	style.margin.right 	= 8 
	
	local element 		= layout.addelement( g, style, attribs )
	layout.addbuttonobject( g, style )

	-- Move cursor to first correct top left position
	g.cursor.top 		= g.cursor.top + element.margin.top
	g.cursor.left 		= g.cursor.left + element.margin.left
end 

----------------------------------------------------------------------------------

local function buttonclose( g, style )

	-- Push the size of the element into the button object
	local element 		= layout.getelement(style.elementid)
--	print(element.pos.left, g.cursor.left, g.cursor.left-element.pos.left)
	element.width 		= g.cursor.left-element.pos.left + element.margin.left
	element.height 		= g.cursor.top-element.pos.top + element.border.width * 2 + element.margin.top + element.margin.bottom
	--layout.updateelement( style.elementid, element )

	local geom = layout.getgeom()
	geom.renew( element.gid, element.pos.left, element.pos.top, element.width, element.height )

	g.cursor.left 	= g.cursor.left + style.margin.right
	g.cursor.top 	= geom[ element.gid ].top
	-- Buttons do not modify the top cursor
	if(element.height > style.pstyle.linesize) then style.pstyle.linesize  = element.height end
end

----------------------------------------------------------------------------------
-- Default close always end the line of elements back to the leftmost start position
local function defaultclose( g, style )
	
	elementclose(g, style)
	-- Step a line
	local height_step = style.linesize
	if((style.height or 0) > style.linesize) then height_step = style.height end 
	g.cursor.top 	= g.cursor.top + height_step
	local pmargin 	= style.pstyle.margin or 0
	if(pmargin ~= 0) then pmargin = pmargin.left end
	-- Return to leftmost + parent margin
	g.cursor.left 	= g.frame.left + pmargin
end	

local function closenone( g, style )

end	

----------------------------------------------------------------------------------

local function headingopen( g, style, attribs )

	style.textsize 	= FONT_SIZES[string.lower(style.etype)]
	style.margin 	= getmargin(style, TEXT_CONST.HEADINGS, 2)
	style.linesize 	= style.textsize + style.margin.top + style.margin.bottom
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
		--g.cursor.top 	= g.cursor.top + style.margin.top
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["i"]  = {
	opened 		= function( g, style, attribs )
		style.margin 		= getmargin(style, TEXT_CONST.NONE, 0)
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
		style.margin 		= getmargin(style, TEXT_CONST.NONE, 0)
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
		g.cursor.left 		= g.frame.left
		style.margin 		= getmargin(style, 0, 0)
		-- style.linesize	= getlineheight(style) 
		--g.cursor.top = g.cursor.top + style.linesize
		--elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["blockquote"] = {
	opened 		= function( g, style, attribs )
		style.textsize 		= FONT_SIZES.p
		style.margin 		= getmargin(style, TEXT_CONST.MARGINS, 40)	-- Dont like this 40 indent is too arbitrary
		--g.cursor.top = g.cursor.top + style.linesize
		style.linesize 		= getlineheight(style)
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["img"]  = {
	opened 		= function( g, style, attribs )
		g.cursor.left 		= g.frame.left
		style.margin 		= getmargin(style, 0, 0)

		if(attribs.width) then style.width = width end 
		if(attribs.height) then style.height = height end 

		elementopen(g, style, attribs)
		end,
	closed 		= function( g, style )	
		pprint(">>>", style)		
		elementclose(g, style)
		local element 		= layout.getelement(style.elementid)
		g.cursor.top = g.cursor.top + element.height
		style.fontweight = nil
	end,
}

----------------------------------------------------------------------------------

htmlelements["button"] = {
	opened 		= buttonopen,
	closed 		= buttonclose,
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
	
	elements 		= htmlelements, 
	init			= layout.init,
	finish			= layout.finish,
}

----------------------------------------------------------------------------------