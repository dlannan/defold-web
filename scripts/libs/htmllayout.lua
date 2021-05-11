----------------------------------------------------------------------------------

local tinsert 	= table.insert
local tremove 	= table.remove

require("scripts.utils.copy")
local GM 		= require("scripts.libs.htmlgeom")

----------------------------------------------------------------------------------
-- A html render tree  -- created during first pass
local render 		= {}
-- A html layout tree  -- created during passing of render tree - this should be rasterised
local layout 		= {}

-- A mapping of elements - using id's. This allows for referential structuring so we can 
--   easily replicate operations on a dom using it.
local elements		= {}

local geom 			= nil

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

local function getparent( style )

	local pid = nil 
	if(style.pstyle and style.pstyle.elementid) then 
		local eid 			= elements[style.pstyle.elementid]
		if(eid) then 
			local pelement 	= geom[eid.gid]
			pid = pelement.gid or nil
		end
	end
	return pid
end 

----------------------------------------------------------------------------------

local function getgeometry( )

	return geom
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
-- TODO: this need to be changed to use element geometry instead of cursor.
local function rendertext( g, v )

	local text 		= v.text
	local style 	= v.style
	if(type(text) ~= "string") then return end 
	g.gcairo:FontSetFace(style.fontface, style.fontstyle, style.fontweight)	
	g.gcairo:RenderText( text, g.cursor.left, g.cursor.top + style.textsize * 0.75, style.textsize, tcolor )
end 

----------------------------------------------------------------------------------

local function renderbutton( g, v )

	local text 		= v.text
	local style 	= v.style
	local ele = getelement( v.eid )
	local button = g.gcairo:Button("", ele.pos.left, ele.pos.top, ele.width, ele.height, 3, 0 )
	g.gcairo:RenderButton(button, 0)
end 

----------------------------------------------------------------------------------
local bgcolor		= { r=1, g=1, b=1, a=0 }
local brdrcolor 	= { r=0, g=0, b=0, a=1 }
local margincolor 	= { r=0, g=0, b=1, a=1 }

local function renderelement( g, ele) 

	-- local ele = getelement( v.eid )
	-- g.gcairo:RenderBox( ele.pos.left, ele.pos.top, ele.width, ele.height, 0, bgcolor, brdrcolor )
	local tg = geom.geometries[ele.gid]
	--print("TG:", tg.left, tg.top, tg.width, tg.height)
	g.gcairo:RenderBox( tg.left, tg.top, tg.width, tg.height, 0, bgcolor, brdrcolor )
	g.gcairo:RenderText( tostring(tg.gid), tg.left, tg.top, 16, tcolor )
end	

local function rendergeom( g, tg ) 

	-- local ele = getelement( v.eid )
	-- g.gcairo:RenderBox( ele.pos.left, ele.pos.top, ele.width, ele.height, 0, bgcolor, brdrcolor )
	--print("TG:", tg.gid, tg.left, tg.top, tg.width, tg.height)
	g.gcairo:RenderBox( tg.left, tg.top, tg.width, tg.height, 0, bgcolor, brdrcolor )
	--g.gcairo:RenderText( tostring(tg.gid), tg.left, tg.top, 16, tcolor )
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

	-- Just dump all the element layouts as boxes
-- 	for k, v in pairs( elements ) do 
-- 
-- 		local g = { gcairo = v.gcairo, cursor=v.cursor, frame = v.frame }
-- 		-- Render a box around all elements 
-- 		renderelement( g, v)
-- 	end 

	local ele = elements[1]
	local html = geom.geometries[1]
	local g = { gcairo = ele.gcairo, cursor=ele.cursor, frame = ele.frame }
	for k, v in ipairs(geom.geometries) do 
		rendergeom( g, v )
	end
	-- geom.dump()
end

----------------------------------------------------------------------------------

local function doraster( )

end

----------------------------------------------------------------------------------
-- Gen new geom layout every frame?!! (for now - this will be cached later)
geom 		= GM.create(frame, cursor)

local function init(frame, cursor) 
	render 		= {}
	layout 		= {}
	elements 	= {}
	geom.clear()
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

	attribs = attribs or { width = style.width, height = style.height }
	local element = {}
	element.gcairo 		= g.gcairo
	element.etype 		= style.etype
	element.border 		= { width = 2, height = 2 }
	element.background 	= { color = style.background or "#aaaaaa" }
	element.margin 		= { top = style.margin.top or 0, bottom = style.margin.bottom or 0, left = style.margin.left or 0, right = style.margin.right or 0 }
	element.pos 		= { top = g.cursor.top, left = g.cursor.left }
	element.width 		= (attribs.width or style.width or 0)
	element.height 		= (attribs.height or style.height or 0)
	element.id 			= #elements + 1

	local pid = getparent(style)
	element.gid 		= geom.add( style.etype, pid, element.pos.left, element.pos.top, element.width, element.height )
	geom.update( element.gid )
	
	style.elementid 	= element.id
	tinsert(elements, element)
	return element
end 

----------------------------------------------------------------------------------

local function addtextobject( g, style, text )

	local stylecopy = deepcopy(style)

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

	local pid = getparent(style)
	if(pid) then print(text, style.width, pid, style.pstyle.etype) end
	renderobj.gid 		= geom.add( style.etype, pid, g.cursor.left, g.cursor.top, style.width, style.height )
	geom.update( renderobj.gid )
		
	-- Render objects are queued in order of the output data with the correct styles
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
	
	local pid = getparent(style)
	renderobj.gid 		= geom.add( style.etype, pid, g.cursor.left, g.cursor.top, style.width, style.height )
	geom.update( renderobj.gid )
		
	-- Render obejcts are queued in order of the output data with the correct styles
	tinsert(render, renderobj)
end 

----------------------------------------------------------------------------------

local function addlayout( layout )

	local layoutobj = deepcopy(layout)
	tinsert(layout, layoutobj)
end 

----------------------------------------------------------------------------------

return {

	init 			= init,
	finish 			= finish,

	addelement		= addelement,
	getelement		= getelement,
	updateelement	= updateelement,
	
	addtextobject 	= addtextobject,
	addbuttonobject	= addbuttonobject,
	
	addlayout 		= addlayout,

	getgeom 		= getgeometry,
}

----------------------------------------------------------------------------------
