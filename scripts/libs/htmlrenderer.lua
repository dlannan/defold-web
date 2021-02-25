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
local frame = { top = 0.0, left = 0.0 }

----------------------------------------------------------------------------------

local stylestack = {}
stylestack[1] = { textsize = FONT_SIZES.P, linesize = FONT_SIZES.P * 1.5 }

----------------------------------------------------------------------------------
local function xmlhandler( gcairo, xml )

	-- Skip a head tag  TODO: This needs to be a bit smarter
	if(xml.label == "head") then return end

	local currstyle = stylestack[#stylestack]
	local style = deepcopy(currstyle)
	-- Copydown buttons and unqiue text objects
	style.button = currstyle.button
	local g = { gcairo=gcairo, cursor = cursor, frame = frame }

	-- Check element names 
	local label = nil
	if( xml.label ) then label = string.lower(xml.label) end
	if(label) then 
		style.etype = label
		local iselement = htmlelements[label]
		if(iselement) then iselement.opened( g, style, xml.xarg ) end
		tinsert(stylestack, style)
	end 

	for k,v in pairs(xml) do 

		-- Might be a string index
		if(type(k) == "number") then
			if( type(v) == "string") then
				if(string.find(v, "DOCTYPE") == nil) then
					htmle.addtextobject( g, style, v )
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

	frame.top 	= position.top or 0.0
	frame.left = position.left or 0.0
	cursor.top 	= frame.top
	cursor.left = frame.left

	htmle.init()
	xmlhandler( gcairo, xmldoc )
	htmle.finish()
	
	gcairo:FontSetFace(nil,nil,nil)	
end

----------------------------------------------------------------------------------

return { renderxml = renderxml }

----------------------------------------------------------------------------------
