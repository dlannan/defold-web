-- htmlgeom is the html geometry object used to generate element/cell information for layout_changed
-----------------------------------------------------------------------------------------------------------------------------------

local tinsert 		= table.insert 
local tremove 		= table.remove 

-----------------------------------------------------------------------------------------------------------------------------------

local function updategeom( pg, tg )

	pg.left 	= tg.left 
	pg.top 		= tg.top
	pg.width 	= tg.width
	pg.height	= tg.height
	pg.right 	= tg.left + tg.width
	pg.bottom 	= tg.top + tg.height
end

-----------------------------------------------------------------------------------------------------------------------------------

local function mergegeom( g, tg )

	if( g.left < tg.left) then tg.left = g.left end 
	if( g.top < tg.top) then tg.top = g.top end
	if( g.left + g.width > tg.left + tg.width ) then tg.width = g.left + g.width - tg.left end  
	if( g.top + g.height > tg.top + tg.height ) then tg.height = g.top + g.height - tg.top end  
	return tg
end 

-----------------------------------------------------------------------------------------------------------------------------------

local function checkgeomchanges(pg, g )

	local tgeom = { left = 0, top = 0, width = 0, height = 0, right = 0, bottom = 0 }
	-- Only check first level children (we assume they are done, or will be done later)
	for k,v in ipairs(pg.childs) do 
		tgeom  = mergegeom( geometries[v], tgeom )
	end 
	tgeom  = mergegeom( g, tgeom )
	updategeom( pg, tgeom )
	return pg
end 

-----------------------------------------------------------------------------------------------------------------------------------

local geommanager = {}

geommanager.create 	= function( )

	-- The geom object you will work with
	local geom 				= {}
	
	-- All the geometries 
	geom.geometries 		= {}
	geom.geomid 			= 0

	geom.traverseup = function ( geomid, g ) 

		if( g.pid ) then 
			local pg = geometries[g.pid] or nil 
			if(pg == nil) then return end 

			-- Update parent if bounds of the child geom impact it
			pg = checkgeomchanges( pg, g )
			-- Write this back before more traversal 
			geometries[g.pid] = pg 

			geom.traverseup(g.pid, pg)
		end 
	end 
	
	-- Add a new geometry. If name is empty it will be generated, and if parent is empty then it is a root geom
	--   All other params will default to 0 if not set
	geom.add 	= function( name, parentid, left, top, width, height )

		geom.geomid 	= geom.geomid + 1
		if(name == nil) then name = "geom_"..geom.geomid end

		left 	= left or 0
		top 	= top or 0
		width 	= width or 0
		height 	= height or 0

		local newgeom = {
			left 	= left,
			top 	= top,
			width 	= width,
			height 	= height,
			right 	= left + width,		-- These are recalced when others are moved/changed
			bottom 	= top + height,

			gid 	= geom.geomid,
			pid 	= parentid,			-- allows loose referencing (weak refs) Fast geom traversals (up only needed)
			childs	= {},				-- children ids of this geom
		}

		if(parentid) then 
			local pg = geom.geometries[parentid] or nil 
			if(pg) then 
				tinsert(pg.childs, geom.geomid)
			end
		end 
	
		geom.geometries[geom.geomid] = newgeom 
		return geom.geomid
	end

	geom.remove 	= function( gid )

		local g = geom.geometries[gid] or nil 
		if(g == nil) then return nil end -- silent fail check returns!
		geom.geometries[gid] = nil
		return true
	end

	-- Takes a single geomid and updates all parents (travserses upwards) 
	geom.update 	= function( geomid ) 

		if(geomid == nil) then return nil end -- silent fail check returns!
		local g = geom.geometries[geomid] or nil 
		if(g == nil) then return nil end -- silent fail check returns!
		geom.traverseup( geomid, g )
	end
	
	-- Setting any of the params to nil will use current values
	-- A nil geomid will fail
	geom.resize 	= function( geomid, left, top, width, height )

		if(geomid == nil) then return nil end -- silent fail check returns!
		local g = geom.geometries[geomid] or nil 
		if(g == nil) then return nil end -- silent fail check returns!
		g.left		= left or g.left 
		g.top 		= top or g.top 
		g.width 	= width or g.width
		g.height 	= height or g.height 
		g.right 	= g.left + g.width 
		g.bottom 	= g.top + g.height

		-- Force a parent update - may need to resize!
		geom.traverseup( geomid, g )
		return true
	end

	setmetatable( geom, 
	{
		__index 	= function(t, k)
			return t.geometries[k]
		end, 
		__newindex 	= function( t, k, v )
			t.geometries[k] = v 
		end,

		__len 		= function( t )
			return table.length( t.geometries )
		end
	})

	return geom
end

-----------------------------------------------------------------------------------------------------------------------------------

return geommanager

-----------------------------------------------------------------------------------------------------------------------------------
