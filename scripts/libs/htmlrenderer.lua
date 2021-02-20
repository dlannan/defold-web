----------------------------------------------------------------------------------
-- Fix colors later (with css etc)

require("scripts.utils.copy")

local tinsert 	= table.insert
local tremove 	= table.remove

local tcolor = { r=0.0, b=1.0, g=0.0, a=1.0 }

local htmle = require("scripts.libs.htmlelements")
local htmlelements 	= htmle.elements 
local FONT_SIZES 	= htmle.FONT_SIZES

----------------------------------------------------------------------------------

local cursor = { top = 0.0, left = 0.0 }
local layout = { top = 0.0, left = 0.0 }

----------------------------------------------------------------------------------

local stylestack = {}
stylestack[1] = { textsize = FONT_SIZES.P, linesize = FONT_SIZES.P * 1.5 }

----------------------------------------------------------------------------------
local function xmlhandler( gcairo, xml )

	-- Skip a head tag  TODO: This needs to be a bit smarter
	if(xml.label == "head") then return end

	local currstyle = stylestack[#stylestack]
	local style = deepcopy(currstyle)
	local g = { gcairo=gcairo, cursor = cursor, layout = layout }

	-- Check element names 
	local label = nil
	if( xml.label ) then label = string.lower(xml.label) end
	if(label) then 
		local iselement = htmlelements[label]
		if(iselement) then iselement.opened( g, style ) end
		tinsert(stylestack, style)
	end 

	for k,v in pairs(xml) do 

		-- Might be a string index
		if(type(k) == "number") then
			if( type(v) == "string") then
				if(string.find(v, "DOCTYPE") == nil) then
					
					local iselement = htmlelements[label]
					if(iselement) then iselement.render( g, style, v ) end 
				end
			end

			if(type(v) == "table") then
				xmlhandler( gcairo, v ) 
			end
		end
	end

	-- Check label to close the element
	if(label) then 
		local iselement = htmlelements[xml.label]
		if(iselement) then iselement.closed( g, style ) end 
		tremove( stylestack ) 
	end
end 

----------------------------------------------------------------------------------
local function renderxml( gcairo, xmldoc, position )

	layout.top 	= position.top or 0.0
	layout.left = position.left or 0.0
	cursor.top 	= layout.top
	cursor.left = layout.left
	xmlhandler( gcairo, xmldoc )
	gcairo:FontSetFace(nil,nil,nil)	
end

----------------------------------------------------------------------------------

return { renderxml = renderxml }

----------------------------------------------------------------------------------
