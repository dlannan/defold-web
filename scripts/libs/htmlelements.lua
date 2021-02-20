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

----------------------------------------------------------------------------------

local function rendertext( g, style, text )

	if(type(text) ~= "string") then return end 
	g.gcairo:FontSetFace(style.fontface, style.fontstyle, style.fontweight)	
	local w,h = g.gcairo:GetTextSize(text, style.textsize)
	g.gcairo:RenderText( text, g.cursor.left, g.cursor.top + style.linesize * 0.5, style.textsize, tcolor )
	g.cursor.left = g.cursor.left + w
end 

----------------------------------------------------------------------------------

local function rendernone( g, style, text )

end 

----------------------------------------------------------------------------------

local function customRenderButton( g, button, style )

	g.gcairo:RenderBox( button.left, button.top, button.width, button.height, button.corner )
	g.gcairo:ClipRegion(button.left+button.border, button.top+button.border, button.width-button.border, button.height-button.border)
	local bs = button.height 
	if(bs > button.width) then bs = button.width end

	cr.cairo_save(g.gcairo.ctx)
	cr.cairo_translate(g.gcairo.ctx, button.left, button.top)

	local brdr = button.border * 2.0
	local txthgt = bs - brdr

	local savedleft = g.cursor.left
	local savedtop = g.cursor.top
	g.cursor.left = brdr
	g.cursor.top = (txthgt * 0.5)

	style.fontheight = txthgt 
	
	rendertext( g, style, button.name )
	cr.cairo_restore(g.gcairo.ctx)

	g.cursor.top = savedtop
	g.cursor.left = savedleft
	g.cursor.left = g.cursor.left + button.width + 2
	g.gcairo:ClipReset()
end	

local function renderbutton( g, style, text )

	if(type(text) ~= "string") then return end 
	if(#text <= 0) then return end

	-- TODO: Bit messy.. make this nicer.
	local brdr = 5
	local textsize = style.textsize + brdr * 2
	local w,h = g.gcairo:GetTextSize(text, textsize)
	local button = g.gcairo:Button(text, g.cursor.left, g.cursor.top, w, textsize, 3, brdr, nil, nil)
	customRenderButton(g, button, style)	
end 

----------------------------------------------------------------------------------

local function defaultclose( g, style )
	
	g.cursor.top = g.cursor.top + style.linesize
	g.cursor.left = g.layout.left
end	

local function closenone( g, style )

end	

----------------------------------------------------------------------------------
-- Heading elements 


htmlelements["h1"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H1
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

htmlelements["h2"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H2
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

htmlelements["h3"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H3
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

htmlelements["h4"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H4
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

htmlelements["h5"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H5
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

htmlelements["h6"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.H6
		style.linesize = style.textsize * 1.5
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["p"]  = {
	opened 		= function( g, style )
		style.textsize = FONT_SIZES.P
		style.linesize = style.textsize * 1.5
		style.paragraph = true
		g.cursor.top = g.cursor.top + FONT_SIZES.P * 0.5
		g.cursor.left = g.layout.left
	end,
	render 		= rendertext,
	closed 		= function( g, style )
		g.cursor.top = g.cursor.top + FONT_SIZES.P * 1.5
		g.cursor.left = g.layout.left
	end,
}

----------------------------------------------------------------------------------

htmlelements["i"]  = {
	opened 		= function( g, style )
		style.fontstyle = 1
	end,
	render 		= rendertext,
	closed 		= function( g, style )	
		style.fontstyle = nil
	end,
}

htmlelements["b"]  = {
	opened 		= function( g, style )
		style.fontweight = 1
	end,
	render 		= rendertext,
	closed 		= function( g, style )	
		style.fontweight = nil
	end,
}

----------------------------------------------------------------------------------

htmlelements["br"]  = {
	opened 		= function( g, style )
		style.linesize = style.textsize
		g.cursor.left = g.layout.left
		--g.cursor.top = g.cursor.top + style.linesize
	end,
	render 		= rendernone,
	closed 		= defaultclose,
}

----------------------------------------------------------------------------------

htmlelements["blockquote"] = {
	opened 		= function( g, style )
		g.cursor.left = g.cursor.left + TEXT_CONST.TAB
		--g.cursor.top = g.cursor.top + style.linesize
	end,
	render 		= rendertext,
	closed 		= defaultclose,
}


----------------------------------------------------------------------------------

htmlelements["button"] = {
	opened 		= function( g, style )
		--g.cursor.top = g.cursor.top + style.linesize * 0.5
	end,
	render 		= renderbutton,
	closed 		= closenone,
}

----------------------------------------------------------------------------------

return {
	FONT_SIZES 	= FONT_SIZES,
	elements 	= htmlelements, 
}

----------------------------------------------------------------------------------