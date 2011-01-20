require 'middleclass.lua'

local g = love.graphics


Background = class('Background')

function Background:initialize(player, image, y, color, scrollX, scrollY)
	self.player = player
	self.image = image
	self.y = y
	self.color = color
	self.scrollX = scrollX
	self.scrollY = scrollY

	self.bg1X = 0
	self.bg2X = g.getWidth()
	self.y = y
end


function Background:update(dt)

	local delta = dt * self.scrollX * self.player:getSpeed()

	self.bg1X = math.floor(self.bg1X - delta)
	self.bg2X = math.floor(self.bg2X - delta)
	
	if self.bg1X + g.getWidth() < 0 then
		self.bg1X = g.getWidth()
	end
	
	if self.bg2X + g.getWidth() < 0 then
		self.bg2X = g.getWidth()
	end
end

function Background:draw()

	g.setColor(255, 255, 255, 255)

	local y = self.y - self.image:getHeight()
	
	g.draw(self.image:getImage(), math.floor(self.bg1X), y)
	g.draw(self.image:getImage(), math.floor(self.bg2X), y)
	
	g.setColor(unpack(self.color))
	
	g.rectangle("fill", 0, y + self.image:getHeight(), g.getWidth(), g.getHeight() - y + self.image:getHeight())

end