----------------------------------------------------------------------------------

local tinsert 	= table.insert
local tremove 	= table.remove

require("scripts.utils.copy")

----------------------------------------------------------------------------------
-- A html render tree  -- created during first pass
local render 		= {}
-- A html layout tree  -- created during passing of render tree - this should be rasterised
local layout 		= {}


local tcolor = { r=0.0, b=1.0, g=0.0, a=1.0 }

----------------------------------------------------------------------------------

function table_print(tt, indent, done)
	done = done or {}
	indent = indent or 0
	if type(tt) == "table" then
		for key, value in pairs (tt) do
			io.write(string.rep (" ", indent)) -- indent it
			if type (value) == "table" and not done [value] then
				done [value] = true
				io.write(string.format("[%s] => table\n", tostring (key)));
				io.write(string.rep (" ", indent+4)) -- indent it
				io.write("(\n");
				table_print (value, indent + 7, done)
				io.write(string.rep (" ", indent+4)) -- indent it
				io.write(")\n");
			else
				io.write(string.format("[%s] => %s\n",
				tostring (key), tostring(value)))
			end
		end
	else
		io.write(tt .. "\n")
	end
end


----------------------------------------------------------------------------------

local function rendertext( g, style, text )

	if(type(text) ~= "string") then return end 
	g.gcairo:FontSetFace(style.fontface, style.fontstyle, style.fontweight)	
	g.gcairo:RenderText( text, g.cursor.left, g.cursor.top, style.textsize, tcolor )
end 

----------------------------------------------------------------------------------

local function renderbutton( g, style, text )

	if(text == nil or #text <= 0) then return end
	local button = g.gcairo:Button("", style.pos.left, style.pos.top, style.button.width, style.button.height, 3, 6 )
	g.gcairo:RenderButton(button, 0)
	rendertext( g, style, text )
end 

----------------------------------------------------------------------------------

local function dolayout( )

	for k, v in ipairs( render ) do 

		local g = { gcairo = v.gcairo, cursor=v.cursor, frame = v.frame }
		if( v.rtype == "button" ) then 
			renderbutton(g, v.style, v.text)
		else 
			rendertext(g, v.style, v.text)
		end
	end 
end

----------------------------------------------------------------------------------

local function doraster( )

end

----------------------------------------------------------------------------------

local function init() 
	render 	= {}
	layout 	= {}
end 

local function finish() 

	-- Dump the layout tree 
	-- table_print(render)
	
	-- upon completion of building render tree, run layout pass 
	dolayout()
	doraster()
end

----------------------------------------------------------------------------------

local function addtextobject( g, style, text )

	local stylecopy = deepcopy(style)
	stylecopy.button = style.button 

	-- Try to treat _all_ output as text + style. Style here means a css objects type
	--    like border, background, size, margin etc
	local renderobj = { 
		gcairo = g.gcairo, 
		rtype = style.rtype,
		style = stylecopy, 
		text = text,
		cursor = { top = g.cursor.top, left = g.cursor.left },
		frame  = { top = g.frame.top, left = g.frame.left },
	}
	
	-- Render obejcts are queued in order of the output data with the correct styles
	tinsert(render, renderobj)
end 


----------------------------------------------------------------------------------

local function addbuttonobject( g, style )

	local stylecopy = deepcopy(style)

	-- Try to treat _all_ output as text + style. Style here means a css objects type
	--    like border, background, size, margin etc
	local renderobj = { 
		gcairo = g.gcairo, 
		rtype = style.rtype,
		style = stylecopy, 
		cursor = { top = g.cursor.top, left = g.cursor.left },
		frame  = { top = g.frame.top, left = g.frame.left },
	}

	-- Render obejcts are queued in order of the output data with the correct styles
	tinsert(render, renderobj)
	return renderobj
end 

----------------------------------------------------------------------------------

local function addlayout( layout )

	local layoutobj = deepcopy(layout)
	tinsert(layout, layoutobj)
end 

----------------------------------------------------------------------------------

return {

	init 		= init,
	finish 		= finish,

	addtextobject 	= addtextobject,
	addbuttonobject	= addbuttonobject,
	
	addlayout 	= addlayout,
}

----------------------------------------------------------------------------------
