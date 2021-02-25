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
	TAB 	= FONT_SIZES.P * 2.0,
}

----------------------------------------------------------------------------------

local htmlelements = {}
local layout = require("scripts.libs.htmllayout")

----------------------------------------------------------------------------------

local function textdefault( g, style, text )
	local w,h = g.gcairo:GetTextSize(text, style.textsize, style)	
	local savedtop = g.cursor.top
	g.cursor.top = g.cursor.top + style.linesize * 0.5
	layout.addtextobject( g, style, text )
	g.cursor.left = g.cursor.left + w
	g.cursor.top = savedtop
end 

----------------------------------------------------------------------------------

local function textnone( g, style, text )

end 

----------------------------------------------------------------------------------

local function buttonopen( g, style )

	style.rtype		= "button"
	style.border 	= { width = 2, height = 2 }
	style.background = { color = "#aaaaaa" }
	style.margin 	= { width = 2, height = 2 }
	style.pos 		= { top = g.cursor.top, left = g.cursor.left }
	
	style.button 	= layout.addbuttonobject( g, style )
	
	--g.cursor.left 	= g.cursor.left + style.border.width + style.margin.width
	g.cursor.top 	= g.cursor.top + style.border.height + style.margin.height
end 

----------------------------------------------------------------------------------

local function buttonclose( g, style )

	-- Push the size of the element into the button object
	style.button.width 		= g.cursor.left - style.pos.left  + style.border.width * 2 + style.margin.width * 2
	style.button.height 	= g.cursor.top - style.pos.top + style.textsize + style.border.height + style.margin.height
	--print(style.width, style.height)
	
	-- Restore height, not width
	g.cursor.left 	= g.cursor.left + style.border.width * 2 + style.margin.width * 2
	g.cursor.top = g.cursor.top - style.border.height - style.margin.height	
end

----------------------------------------------------------------------------------

local function defaultclose( g, style )
	
	g.cursor.top = g.cursor.top + style.linesize
	g.cursor.left = g.frame.left
end	

local function closenone( g, style )

end	

----------------------------------------------------------------------------------



----------------------------------------------------------------------------------
-- Heading elements 


htmlelements["h1"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H1
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

htmlelements["h2"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H2
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

htmlelements["h3"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H3
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

htmlelements["h4"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H4
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

htmlelements["h5"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H5
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

htmlelements["h6"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H6
		style.linesize = style.textsize * 1.5
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["p"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.P
		style.linesize = style.textsize * 1.5
		style.paragraph = true
		g.cursor.top = g.cursor.top + FONT_SIZES.P * 0.5
		g.cursor.left = g.frame.left
	end,
	closed 		= function( g, style )
		g.cursor.top = g.cursor.top + FONT_SIZES.P * 1.5
		g.cursor.left = g.frame.left
	end,
}

----------------------------------------------------------------------------------

htmlelements["i"]  = {
	opened 		= function( g, style )
		style.fontstyle = 1
	end,
	closed 		= function( g, style )	
		style.fontstyle = nil
	end,
}

htmlelements["b"]  = {
	opened 		= function( g, style )
		style.fontweight = 1
	end,
	closed 		= function( g, style )	
		style.fontweight = nil
	end,
}

----------------------------------------------------------------------------------

htmlelements["br"]  = {
	opened 		= function( g, style )
		style.linesize = style.textsize
		g.cursor.left = g.frame.left
		--g.cursor.top = g.cursor.top + style.linesize
	end,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["blockquote"] = {
	opened 		= function( g, style )
		g.cursor.left = g.cursor.left + TEXT_CONST.TAB
		--g.cursor.top = g.cursor.top + style.linesize
	end,
	closed 		= defaultclose,
}


----------------------------------------------------------------------------------

htmlelements["button"] = {
	opened 		= buttonopen,
	closed 		= buttonclose,
}

----------------------------------------------------------------------------------

return {
	FONT_SIZES 	= FONT_SIZES,

	addtextobject 	= textdefault,
	elements 		= htmlelements, 
	init			= layout.init,
	finish			= layout.finish,
}

----------------------------------------------------------------------------------