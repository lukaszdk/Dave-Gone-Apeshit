require 'middleclass.lua'

local g = love.graphics
local i = love.image

Image = class('Image')

function Image:initialize(path)
	local source = i.newImageData(path)	
	self.width = source:getWidth()
	self.height = source:getHeight()
	local powerwidth = math.pow(2, math.ceil(math.log(self.width)/math.log(2)))
	local powerheight = math.pow(2, math.ceil(math.log(self.height)/math.log(2)))
	
	if powerwidth ~= self.width or powerheight ~= self.height then
		local padded = love.image.newImageData(powerwidth, powerheight)
		padded:paste(source, 0, 0)
		self.image = g.newImage(padded)
	end
	
	self.image = g.newImage(source)
end

function Image:getWidth()
	return self.width
end

function Image:getHeight()
	return self.height
end

function Image:getImage()
	return self.image
end

