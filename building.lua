require 'middleclass.lua'
require 'enemy.lua'
require 'image.lua'

local g = love.graphics
local a = love.audio

Building = class('Building')

function Building:initialize(player, x)
	platformImage = platformImage or Image:new('assets/platform.png')
	holeImage = holeImage or Image:new('assets/hole.png')
	holeFrameImage = holeFrameImage or Image:new('assets/hole_frame.png')
	windowShatterImage = windowShatterImage or Image:new('assets/window_shatter.png')
	windowShatterImage2 = windowShatterImage2 or Image:new('assets/window_shatter02.png')
	
	holeBeginQuad = holeBeginQuad or g.newQuad(0,0, 80, holeImage:getHeight(), holeImage:getTextureWidth(), holeImage:getTextureHeight()  ) 
	holeMiddleQuad = holeMiddleQuad or g.newQuad(80,0, 40, holeImage:getHeight(), holeImage:getTextureWidth(), holeImage:getTextureHeight()  ) 
	holeEndQuad = holeEndQuad or g.newQuad(holeImage:getWidth()-80, 0, 80, holeImage:getHeight(), holeImage:getTextureWidth(), holeImage:getTextureHeight()  ) 
	
	platformBeginQuad = platformBeginQuad or g.newQuad(0,0, 50, platformImage:getHeight(), platformImage:getTextureWidth(), platformImage:getHeight()  ) 
	platformEndQuad = platformEndQuad or g.newQuad(platformImage:getWidth()-50,0, 50, platformImage:getHeight(), platformImage:getTextureWidth(), platformImage:getHeight()  ) 
	
	platformMiddleQuad = platformMiddleQuad or g.newQuad(50,0, 20, platformImage:getHeight(), platformImage:getTextureWidth(), platformImage:getHeight()  ) 

	wallBegin = wallBegin or Image:new('assets/wallSegment_start.png')
	wallMiddle = wallMiddle or Image:new('assets/wallSegment_middle.png')
	wallEnd = wallEnd or Image:new('assets/wallSegment_end.png')

	wallBeginQuad = wallBeginQuad or g.newQuad(0, 0, 35, wallBegin:getHeight(), wallBegin:getTextureWidth(), wallBegin:getTextureHeight())
	wallEndQuad = wallBeginQuad or g.newQuad(0, 0, 30, wallEnd:getHeight(), wallEnd:getTextureWidth(), wallEnd:getTextureHeight())

	self.shatterAnim = newAnimation(windowShatterImage:getImage(), 0, 0, 565, 720, 0.08, 6)
	self.shatterAnim:setMode('once')
	
	self.shatterAnim2 = newAnimation(windowShatterImage2:getImage(), 0, 0, 565, 720, 0.08, 6)
	self.shatterAnim2:setMode('once')
	
	if sound then
		self.shatterSound = a.newSource("assets/audio/glassShatter01.mp3")
	end
	
	self.player = player	
	self:create(x)
end

function Building:setOther(b)
	self.building = b
end

function floorY(f)
	if f == 0 then
		return g.getHeight() - 30
	else
		return g.getHeight() - 120 - f * 120
	end
end

function Building:addRandomSection(offsetX)
	
	local s =  math.floor(math.random(1,4.99))
	
	s = math.max(1, math.min(s, 4))
	
	if s == 1 then	
		local p = self.platforms
		local pi = p.index
		
		p[pi+0] = { x = offsetX + 80, y = floorY(1), w = 400, draw = true }
		p[pi+1] = { x = offsetX + 105, y = floorY(2), w = 400, draw = true }
		p[pi+2] = { x = offsetX + 680, y = floorY(3), w = 400, draw = true }

		p.index = p.index + 3
		
		local e = self.enemies
		local ei = self.enemies.index
		
		e[ei+0] = Enemy:new( self.x + p[pi+0].x - 40 + 250,  p[pi+0].y, player.bullets)
		e[ei+1] = Enemy:new( self.x + offsetX - 40 + 1100,  floorY(0), player.bullets)
		
		e.index = e.index + 2
	elseif s == 2 then 
		local p = self.platforms
		local pi = p.index
	
		p[pi+0] = { x = offsetX + 170, y = floorY(1), w = 840, draw = true }
		p[pi+1] = { x = offsetX + 400, y = floorY(2), w = 400, draw = true }

		p.index = p.index + 2
	
		local h = self.holes
		local hi = h.index
		
		self.holes[hi+0] = { x = offsetX + 170, y = g.getHeight() - 30 , w = 840}
		
		h.index = h.index + 1
	
	
		local e = self.enemies
		local ei = self.enemies.index
	
		e[ei+0] = Enemy:new( self.x + p[pi+0].x - 40 + 600,  p[pi+0].y, player.bullets)
		e.index = e.index + 1

	elseif s == 3 then
		local p = self.platforms
		local pi = p.index

		p[pi+0] = { x = offsetX + 135, y = floorY(1), w = 400, draw = true }
		p[pi+1] = { x = offsetX + 535, y = floorY(2), w = 400, draw = true }

		p.index = p.index + 2

		local h = self.holes
		local hi = h.index
	
		self.holes[hi+0] = { x = offsetX + 135, y = g.getHeight() - 30 , w = 840}
	
		h.index = h.index + 1

		local e = self.enemies
		local ei = self.enemies.index

		e[ei+0] = Enemy:new( self.x + p[pi+0].x - 40 + 200,  p[pi+0].y, player.bullets)
		e.index = e.index + 1
		
	elseif s == 4 then
		local p = self.platforms
		local pi = p.index

		p[pi+0] = { x = offsetX + 135, y = floorY(1), w = 400, draw = true }
		p[pi+1] = { x = offsetX + 335, y = floorY(2), w = 400, draw = true }
		p[pi+2] = { x = offsetX + 535, y = floorY(3), w = 400, draw = true }

		p.index = p.index + 3

		local h = self.holes
		local hi = h.index

		self.holes[hi+0] = { x = offsetX + 300, y = g.getHeight() - 30 , w = 340}

		h.index = h.index + 1

		local e = self.enemies
		local ei = self.enemies.index

		e[ei+0] = Enemy:new( self.x + offsetX - 40 + 800,  floorY(0), player.bullets)
		e.index = e.index + 1
	else
--		assert(false)
	end

end

function Building:create(x)

	self.enemyX = x
	self.x = x + math.floor(math.random(530,550))

	self.numSections = math.floor(math.random(3, 5)) + 1 -- blank start section
	
	local minMiddleWallsWidth = (self.numSections * (g.getWidth()+100)) - wallBegin:getWidth() - wallEnd:getWidth()
	
	self.middleWalls = math.ceil( minMiddleWallsWidth / wallMiddle:getWidth() )
	self.w = wallBegin:getWidth() + self.middleWalls * wallMiddle:getWidth() + wallEnd:getWidth()
	
	self.platforms = {}
	self.platforms.index = 2
	
	self.enemies = {}
	self.enemies.index = 1
	
	self.holes = {}
	self.holes.index = 1
	
	self.shatter = false
	self.shatterAnim:reset()
	self.shatterAnim:play()
	
	self.shatter2 = false
	self.shatterAnim2:reset()
	self.shatterAnim2:play()
		
	-- floor
	self.platforms[1] = { x = 0, y = floorY(0) , w = self.w, draw = false}

	for i=1, self.numSections-1 do
		self:addRandomSection(i*(g.getWidth()+100))
	end
end

function Building:getPlatforms()
	return self.platforms
end

function Building:getHoles()
	return self.holes
end

function Building:update(dt)
	if self.x + self.w < 0 then
		self:create( self.building.x + self.building.w)
	end
	
	local dx =  self.player:getSpeed() * dt
	
	self.x = math.floor(self.x - dx)
	
	for i, enemy in ipairs(self.enemies) do
		enemy:update(dt, dx)
	end
	
	if self.player.x < self.x + self.w - 150 and self.player.x >= self.x + self.w - 180 then
		self.shatter = true
		if sound then
			self.shatterSound:play()
		end
	end

	if self.player.x < self.x - 150 and self.player.x >= self.x - 180 then
		self.shatter2 = true
		if sound then
			self.shatterSound:play()
		end
	end

	if self.shatter then
		self.shatterAnim:update(dt)
	end

	if self.shatter2 then
		self.shatterAnim2:update(dt)
	end

end

function Building:draw()	
--[[	-- Windows
	g.setColor(0,0,0,255)
	local x = 0
	
	g.rectangle("fill", self.x + 20, 120+60, self.w, 3)
	
	while x < self.w do
		g.rectangle("fill", self.x + x + 20, 120+60, 3, g.getHeight() - 240 )
		x = x + 300
	end
	
	g.rectangle("fill", self.x + self.w + 20, 120+60, 3, g.getHeight() - 240 )
	
	]]--
	
--	self.x = math.floor(self.x)
	
	g.setColor(255,255,255,255)
	
	g.draw(wallBegin:getImage(), self.x, 0)

	for i = 0, self.middleWalls-1 do
		g.draw(wallMiddle:getImage(), self.x + wallBegin:getWidth() + i * wallMiddle:getWidth(), 0)
	
	end

	g.draw(wallEnd:getImage(), self.x + self.w - wallEnd:getWidth(), 0)

	if self.shatterAnim:getCurrentFrame() < 6 then
		self.shatterAnim:draw(self.x + self.w - wallEnd:getWidth(), 0)
	end

	if self.shatterAnim2:getCurrentFrame() < 6 then
		self.shatterAnim2:draw(self.x, 0)
	end

	for i, platform in ipairs(self.platforms) do 
		local x, y, w, h = self.x + platform.x,  platform.y, platform.w, 60

		g.setColor(240, 188, 52, 255)
		
		if platform.draw == true then
			self:drawPlatform(x,y,w,h, 40)
		end
		
--		g.setColor(255,0,0,255)
--		g.rectangle("fill", x,y, w, 2)
	end
	
	for i, hole in ipairs(self.holes) do 
		local x, y, w, h = self.x + hole.x,  hole.y - 40, hole.w + 25, 70
	
		self:drawHole(holeImage:getImage(), x,y,w,h)
	end

	for i, enemy in ipairs(self.enemies) do
		enemy:draw()
	end
	
end

function Building:postDraw()
	g.setColor(255, 255, 255, 255)
	g.drawq(wallBegin:getImage(), wallBeginQuad, self.x, 0)
	g.drawq(wallEnd:getImage(), wallEndQuad, self.x + self.w - wallEnd:getWidth(), 0)
	
	if player.inHole then	
		for i, hole in ipairs(self.holes) do 
			local x, y, w, h = self.x + hole.x,  hole.y - 40, hole.w + 25, 70
	
			self:drawHole(holeFrameImage:getImage(), x,y,w,h)
		end
	end
end

function Building:drawHole(image, x,y,w,h)
--	g.setColor(0,0,0, 255)
--	g.rectangle("fill", x, y, w, h)

	y = y - 42
	g.setColor(255,255,255,255)
	g.drawq(image, holeBeginQuad, x, y)

	local scaleX = (w+50-160)/40
	g.drawq(image, holeEndQuad, x+w-80+50, y)

	g.drawq(image, holeMiddleQuad, x+80, y, 0, scaleX, 1)

end

function Building:drawPlatform(x,y,w,h, offset)
	y = y +  h / 2
	x = x - offset / 2

--	local vertices = { x, y, x + offset, y - h, x + offset + w, y - h, x + w, y}
--	g.polygon("fill", vertices)
	
	y = y + 25

	g.setColor(255,255,255,255)
	g.drawq(platformImage:getImage(), platformBeginQuad, x, y - platformImage:getHeight() )

	local scaleX = (w-50)/20

	g.drawq(platformImage:getImage(), platformEndQuad, x + w, y - platformImage:getHeight() )
	g.drawq(platformImage:getImage(), platformMiddleQuad, x + 50, y - platformImage:getHeight(), 0, scaleX, 1 )
end
