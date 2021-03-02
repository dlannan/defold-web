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

	H1		= 24.0,
	H2 		= 20.0,
	H3 		= 16.0,
	H4 		= 14.0,
	H5 		= 12.0,
	H6 		= 10.0,

	P 		= 14.0,
}

----------------------------------------------------------------------------------

local TEXT_CONST = {
	TAB 		= FONT_SIZES.P * 2.0,

	MARGINS 	= 1.0 / 1.1875,
	HEADINGS 	= 1.0 / 1.8,
}

----------------------------------------------------------------------------------

local htmlelements = {}
local layout = require("scripts.libs.htmllayout")

local function defaultmargin( style ) 

	return { 
		top = style.textsize * TEXT_CONST.MARGINS, 
		bottom = style.textsize * TEXT_CONST.MARGINS,
		left = 2,
		right = 2,
	}
end 

----------------------------------------------------------------------------------

local function getmargin( style, factorrows, sides )

	local fr = factorrows or 0
	local fs = sides or 0
	return { 
		top = style.textsize * factorrows, 
		bottom = style.textsize * factorrows,
		left = sides, right = sides 
	}
end

----------------------------------------------------------------------------------

local function getlineheight( style ) 

	return style.textsize + style.margin.top + style.margin.bottom
end

----------------------------------------------------------------------------------

local function textdefault( g, style, text )
	local w,h = g.gcairo:GetTextSize(text, style.textsize, style)	
	local savedtop = g.cursor.top
	local savedleft = g.cursor.left

	local geom = layout.getgeom()
	local element = layout.getelement(style.elementid)
	geom.resize( element.gid, g.cursor.left, g.cursor.top, w, h )

	local middle = style.linesize * 0.35
	g.cursor.top = g.cursor.top + middle
	g.cursor.left = g.cursor.left + style.margin.left

	if(style.margin == nil) then print(style.etype) end
	layout.addtextobject( g, style, text )
	
	style.width = w 
	style.height = h
	g.cursor.top = savedtop
end 

----------------------------------------------------------------------------------

local function textnone( g, style, text )

end 

----------------------------------------------------------------------------------

local function elementopen( g, style, attribs )

	local element = layout.addelement( g, style, attribs )
	style.elementid = element.id
end 

----------------------------------------------------------------------------------

local function elementclose( g, style )

	local element = layout.getelement(style.elementid)
 	element.width 		= style.width or 0
 	element.height 		= style.height or 0
	g.cursor.left = g.cursor.left + element.width
	layout.updateelement( style.elementid, element )
end 

----------------------------------------------------------------------------------

local function buttonopen( g, style, attribs )

	local omargin = style.margin
	style.margin.top 	= 8
	style.margin.bottom = 8
	style.margin.left 	= 8
	style.margin.right 	= 8 
	
	local element = layout.addelement( g, style, attribs )
	layout.addbuttonobject( g, style )

	-- Move cursor to firs correct top left position
	g.cursor.top = g.cursor.top + element.margin.top
	g.cursor.left = g.cursor.left + element.margin.left
end 

----------------------------------------------------------------------------------

local function buttonclose( g, style )

	-- Push the size of the element into the button object
	local element = layout.getelement(style.elementid)
	element.width 		= style.width + element.margin.right  + element.margin.left
	element.height 		= style.height + element.border.width * 2 + element.margin.top + element.margin.bottom
	layout.updateelement( style.elementid, element )

	g.cursor.left 	= element.pos.left + element.width
	g.cursor.top 	= element.pos.top
	-- Buttons do not modify the top cursor
	if(element.height > style.pstyle.linesize) then style.pstyle.linesize  = element.height end
end

----------------------------------------------------------------------------------

local function defaultclose( g, style )
	
	g.cursor.top = g.cursor.top + style.linesize
	elementclose(g, style)
	g.cursor.left = g.frame.left
end	

local function closenone( g, style )

end	

----------------------------------------------------------------------------------

local function headingopen( g, style, attribs )

	style.textsize = FONT_SIZES[string.upper(style.etype)]
	style.margin = getmargin(style, TEXT_CONST.HEADINGS, 0)
	style.linesize = style.textsize + style.margin.top + style.margin.bottom
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
		style.textsize = FONT_SIZES.P
		style.margin = getmargin(style, TEXT_CONST.MARGINS, 0)
		style.linesize = style.textsize
		g.cursor.top = g.cursor.top + style.margin.top
		g.cursor.left = g.frame.left
		elementopen(g, style, attribs)
	end,
	closed 		= function( g, style )
		g.cursor.top = g.cursor.top + style.linesize + style.margin.bottom
		elementclose(g, style)
		g.cursor.left = g.frame.left
	end,
}

----------------------------------------------------------------------------------

htmlelements["i"]  = {
	opened 		= function( g, style, attribs )
		style.margin = getmargin(style, 0, 0)
		style.fontstyle = 1
		elementopen(g, style, attribs)
	end,
	closed 		= function( g, style )	
		elementclose(g, style)
		style.fontstyle = nil
	end,
}

htmlelements["b"]  = {
	opened 		= function( g, style, attribs )
		style.margin = getmargin(style, 0, 0)
		style.fontweight = 1
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
		g.cursor.left 	= g.frame.left
		style.margin 	= getmargin(style, 0, 0)
		-- style.linesize	= getlineheight(style) 
		--g.cursor.top = g.cursor.top + style.linesize
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["blockquote"] = {
	opened 		= function( g, style, attribs )
		g.cursor.left 		= g.cursor.left + TEXT_CONST.TAB
		style.margin 		= getmargin(style, TEXT_CONST.MARGINS, 0)		
		--g.cursor.top = g.cursor.top + style.linesize
		style.linesize 		= getlineheight(style)
		elementopen(g, style, attribs)
	end,
	closed 		= defaultclose,
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

return {
	FONT_SIZES 	= FONT_SIZES,

	addtextobject 	= textdefault,

	defaultmargin	= defaultmargin,
	
	elements 		= htmlelements, 
	init			= layout.init,
	finish			= layout.finish,
}

----------------------------------------------------------------------------------