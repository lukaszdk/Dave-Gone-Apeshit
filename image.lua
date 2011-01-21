require 'middleclass.lua'

local g = love.graphics
local i = love.image

Image = class('Image')

function Image:initialize(path)
	local source = i.newImageData(path)	
	self.width = source:getWidth()
	self.height = source:getHeight()
	self.powerwidth = math.pow(2, math.ceil(math.log(self.width)/math.log(2)))
	self.powerheight = math.pow(2, math.ceil(math.log(self.height)/math.log(2)))
	
	if powerwidth ~= self.width or powerheight ~= self.height then
		local padded = love.image.newImageData(self.powerwidth, self.powerheight)
		padded:paste(source, 0, 0)
		self.image = g.newImage(padded)
	else
		self.image = g.newImage(source)
	end
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

function Image:getTextureWidth()
	return self.powerwidth
end

function Image:getTextureHeight()
	return self.powerheight
end
