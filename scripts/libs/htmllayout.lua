----------------------------------------------------------------------------------

local tinsert 	= table.insert
local tremove 	= table.remove

require("scripts.utils.copy")

----------------------------------------------------------------------------------
-- A html render tree  -- created during first pass
local render 		= {}
-- A html layout tree  -- created during passing of render tree - this should be rasterised
local layout 		= {}

-- A mapping of elements - using id's. This allows for referential structuring so we can 
--   easily replicate operations on a dom using it.
local elements		= {}

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
local function getelement(eid)

	return elements[eid] or nil
end

----------------------------------------------------------------------------------

local function updateelement( eid, element )
	elements[eid] = element 
end
----------------------------------------------------------------------------------

local function rendertext( g, v )

	local text 		= v.text
	local style 	= v.style
	if(type(text) ~= "string") then return end 
	g.gcairo:FontSetFace(style.fontface, style.fontstyle, style.fontweight)	
	g.gcairo:RenderText( text, g.cursor.left, g.cursor.top, style.textsize, tcolor )
end 

----------------------------------------------------------------------------------

local function renderbutton( g, v )

	local text 		= v.text
	local style 	= v.style
	
	local ele = getelement( v.eid )
	local button = g.gcairo:Button("", ele.pos.left, ele.pos.top, ele.width, ele.height, 3, 6 )
	g.gcairo:RenderButton(button, 0)
	if(text) then rendertext( g, v ) end 
end 

----------------------------------------------------------------------------------

local function dolayout( )

	for k, v in ipairs( render ) do 

		local g = { gcairo = v.gcairo, cursor=v.cursor, frame = v.frame }
		if( v.etype == "button" ) then 
			renderbutton(g, v)
		else 
			rendertext(g, v)
		end
	end 
end

----------------------------------------------------------------------------------

local function doraster( )

end

----------------------------------------------------------------------------------

local function init() 
	render 		= {}
	layout 		= {}
	elements 	= {}
end 

local function finish() 

	-- Dump the layout tree 
	-- table_print(render)
	
	-- upon completion of building render tree, run layout pass 
	dolayout()
	doraster()
end

----------------------------------------------------------------------------------
-- Try to replicate css properties here. 
local function addelement( g, style, attribs )

	local element = {}
	element.etype 		= style.etype
	element.border 		= { width = 2, height = 2 }
	element.background 	= { color = style.background or "#aaaaaa" }
	element.margin 		= { width = 2, height = 2 }
	element.pos 		= { top = g.cursor.top, left = g.cursor.left }
	element.width 		= attribs.width or 200
	element.height 		= attribs.height or 150
	element.id 			= #elements + 1

	style.elementid 	= element.id
	tinsert(elements, element)
	return element
end 

----------------------------------------------------------------------------------

local function addtextobject( g, style, text )

	local stylecopy = deepcopy(style)
	stylecopy.button = style.button 

	-- Try to treat _all_ output as text + style. Style here means a css objects type
	--    like border, background, size, margin etc
	local renderobj = { 
		gcairo 	= g.gcairo, 
		etype 	= style.etype,
		eid 	= style.elementid,
		style 	= stylecopy, 
		text 	= text,
		cursor 	= { top = g.cursor.top, left = g.cursor.left },
		frame  	= { top = g.frame.top, left = g.frame.left },
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
		gcairo 	= g.gcairo, 
		etype 	= style.etype,
		eid 	= style.elementid,
		style 	= stylecopy, 
		cursor 	= { top = g.cursor.top, left = g.cursor.left },
		frame  	= { top = g.frame.top, left = g.frame.left },
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

	addelement		= addelement,
	getelement		= getelement,
	updateelement	= updateelement,
	
	addtextobject 	= addtextobject,
	addbuttonobject	= addbuttonobject,
	
	addlayout 	= addlayout,
}

----------------------------------------------------------------------------------
