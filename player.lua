require 'middleclass.lua'
require 'ringbuffer.lua'
require 'animation.lua'

local g = love.graphics
local k = love.keyboard

Player = class('Player')

function Player:initialize(x,y,speed)
	self.x = x
	self.y = y
	self.speed = speed
	self.originalSpeed = speed
	
	debugFont = debugFont or g.newFont(12)
	
	playerImage = playerImage or g.newImage("assets/player.png")
	runImage = runImage or g.newImage('assets/playerRun.png')
	jumpImage = jumpImage or g.newImage('assets/playerJump.png')
	dodgeImage = dodgeImage or g.newImage('assets/playerSlide.png')
	deathImage = deathImage or g.newImage('assets/playerDeath.png')
	muzzleImage3 = muzzleImage3 or g.newImage('assets/muzzleFire.png')
	
	self.image = playerImage
	self.runImage = runImage
	self.jumpImage = jumpImage
	self.dodgeImage = dodgeImage
	self.deathImage = deathImage
	self.muzzleImage = muzzleImage3

	playerMeleeImage = playerMeleeImage or g.newImage('assets/playerMelee.png')

	self.meleeBeginAnim = newAnimation(playerMeleeImage, 300, 0, 150, 150, 0.10, 2)
--	self.meleeBeginAnim:setMode('once')

	self.muzzle = 0
	
	bulletImage = bulletImage or g.newImage('assets/bullet.png')

	self.runAnim = newAnimation(self.runImage, 0, 0, 150, 150, 0.15, 4)
	self.jumpAnim = newAnimation(self.jumpImage, 0, 0, 150, 150, 0.15, 4)
	self.dodgeAnim = newAnimation(self.dodgeImage, 0, 0, 150, 150, 0.10, 2)
	self.deathAnim = newAnimation(self.deathImage, 0, 0, 150, 150, 0.15, 4)

	self.deathAnim:setMode('once')
	self.jumpAnim:setMode('once')
--	self.dodgeAnim:setMode('once')

	self.bulletMax = 4
	self.bulletSpeed = 1200
	self.bullets = Ringbuffer()
	
	self.dead = false
	self.dying = nil
	self.dodging = nil
	self.inHole = false
	self.meleeAttack = false
	
	self.onPlatform = true
	self.time = 0
	
	if sound then
	
		self.bulletSource = {}
	
		for i=1, self.bulletMax do
			self.bulletSource[i] = love.audio.newSource("assets/audio/gunshot_avatar.mp3", "static")
		end
	
		self.deathSource = love.audio.newSource("assets/audio/death_avatar.wav", "static")

	end
end

function Player:getSpeed()
	return self.speed
end

function Player:keypressed(key)
	if key == ' ' and not self.jump and not self.dodging and not self.dead and self.inHole == false then
		self.jump = true

		-- short jump
--		self.jumpVelocity = 900
--		self.gravity = -1800
		-- long jump
		self.jumpVelocity = 900
		self.gravity = -1900

		self.jumpY = self.y
		self.onPlatform = false
		self.jumpAnim:reset()
		self.jumpAnim:play()
		
		self.jumpBegin = self.time
		self.jumpDuration = 0
		self.jumpStop = nil
		self.y = self.y - 15
		
	elseif key == 'f' and not self.dead and not self.dodging then
		self:fire()
	elseif key == 'd' and not self.dead and not self.dodging and not self.jump then
		self:dodge(0.5)
	end	
end

function Player:keyreleased(key)

	if key == ' ' then
		self.jumpStop = true
	end

end

function Player:die(d)
	self.dead = true
--	self.speed = 0
	self.dying = d
	
	if sound then
		self.deathSource:play()
	end
end

function Player:isDead()
	return self.dead and self.dying == 0 
end

function Player:update(dt)
	self.time = self.time + dt

	deltaTime = dt
	
	if self.onPlatform and self.jump then
		self.jump = false
	end
	
	if self.dodging then
		self.dodging = self.dodging - dt
		
		if self.dodging < 0 then
			self.dodging = nil
		end
	elseif self.jump then
	
		if not self.jumpStop then
			self.jumpDuration = self.time - self.jumpBegin
		end
	
		if self.jumpDuration and self.jumpDuration > 0.1  then
			self.gravity = -1400
		end
	
		self.jumpVelocity = self.jumpVelocity + (dt  * self.gravity) 
		
		self.jumpVelocity = math.max(-1400, math.min(self.jumpVelocity, 1400))
		
		self.y = self.y - self.jumpVelocity * dt
	end

	if not self.onPlatform and not self.jump then
		self.y = self.y + 500 * dt
	end
	
	-- Bullets
	local i = 0
	while i < self.bullets:size() do
		local bullet = self.bullets:getAt(i+1)
		bullet.x = math.floor(bullet.x + dt * self.bulletSpeed)
		
		if bullet.x > g.getWidth() then
			self.bullets:removeAt(i+1)
		end
		
		i = i + 1
	end
	
	if self.jump then
		self.jumpAnim:update(dt)
	elseif self.dodging then
		self.dodgeAnim:update(dt)
	else
		self.runAnim:update(dt)
	end

	if self.melee then
		self.meleeBeginAnim:update(dt)
	end
	
	if not self.dying and self.y - 120 >= g.getHeight() then
		self:die(0.5)
	end
	
	if self.dead then
		self.originalSpeed = math.max(0, self.originalSpeed - 10)
	
		self.deathAnim:update(dt)
	end
	
	if self.dying and self.dying > 0 then
		self.dying = math.max(0, self.dying - dt)
	end	
end

function equal(a,b)
	return math.abs(a-b) < 12
end

function overlap(x1, w1, x2, w2)
	
	if x1 >= x2 and x1 <= x2 + w2 then
		return true
	end
	
	if x1+w1 >= x2 and x1 + w1 <= x2 + w2 then
		return true
	end
	
	return false
end

function contained(x1, w1, x2, w2)

	if x1 >= x2 and x1 + w1 <= x2 + w2 then
		return true
	end

	return false
end


function Player:enemyInSight(enemy)

	local pX, pY = self:getCenter()
	local eX, eY, eH = enemy.x, enemy.y, enemyImage:getHeight()

	if pY >= eY and pY <= eY+eH then
		return true
	end
	
	return false
end

function Player:checkEnemies(enemiesA, enemiesB)

	local melee = false
	local distance = 300
	
	for i, enemy in ipairs(enemiesA) do
		if self:enemyInSight(enemy) and enemy.x > player.x and math.abs(enemy.x-player.x) < distance and not enemy.dead then
			melee = true
		end
	end

	for i, enemy in ipairs(enemiesB) do
		if self:enemyInSight(enemy) and enemy.x > player.x and math.abs(enemy.x-player.x) < distance and not enemy.dead then
			melee = true
		end
	end

	if self.meleeAttack == false and melee == true then
		self.meleeBeginAnim:reset()
	end

	self.meleeAttack = melee
	
	if melee then
		self.speed = self.originalSpeed - 50
	else
		self.speed = self.originalSpeed
		self.melee = false
	end

end

function Player:checkCollision(buildingA, buildingB)

	local platforms = buildingA:getPlatforms()
	local onPlatform = false
	local y = self.y
	
	if not self.inHole then
		for i, platform in ipairs(platforms) do
			if overlap(self.x, 120, buildingA.x + platform.x, platform.w) and equal(self.y, platform.y) then
				onPlatform = true
				self.y = platform.y
			end
		end

		local platforms = buildingB:getPlatforms()

		for i, platform in ipairs(platforms) do
			if overlap(self.x, 120, buildingB.x + platform.x, platform.w) and equal(self.y, platform.y) then
				onPlatform = true
				self.y = platform.y
			end
		end
	end

	if self.jumpVelocity and self.jumpVelocity >= 0 then
		onPlatform = false
		self.y = y
	end

	local holes = buildingA:getHoles()
	
	for i, hole in ipairs(holes) do
		if contained(self.x+60, 30, buildingA.x + hole.x, hole.w) and self.y >= hole.y then
			onPlatform = false
			self.inHole = true
		end
	end
	
	local holes = buildingB:getHoles()
	
	for i, hole in ipairs(holes) do
		if contained(self.x+60, 30, buildingB.x + hole.x, hole.w) and self.y >= hole.y then
			onPlatform = false
			self.inHole = true
		end
	end


	self.onPlatform = onPlatform
end

function Player:hit(x,y)

	local pX, pY, pW, pH = self.x + 40 , self.y - 150, 60, self.image:getHeight()
	
	if self.dodging then
		pY = pY + 75
		pH = pH - 75
	end
	
	if x >= pX and x <= pX+pW and y >= pY and y <= pY + pH then
		return true
	end 

	return false
end


function Player:checkBullets(bullets)

	local i = 0
	while i < bullets:size() do
		local bullet = bullets:getAt(i+1)
		
		if self:hit(bullet.x, bullet.y) then
			self:die(0.9)
		end
		
		i = i + 1
	end
end

function Player:dodge(time)
	self.dodging = time
	self.dodgeAnim:reset()
	self.dodgeAnim:play()
end

function Player:fire()
	
	self.melee = false
	
	if self.meleeAttack then
		self.melee = true
	elseif self.bullets:size() < self.bulletMax then

		local bullet = { x = self.x + 125 + 40, y = self.y - 95 }

		self.bullets:append(bullet)
		self.muzzle = 2
		
		if sound then
			self.bulletSource[self.bullets:size()]:play()
		end
	end
end

function boolStr(b)
	if b then return "true" else return "false" end
end

function Player:getCenter()
	return self.x + 75, self.y - 75
end

function Player:draw()
	g.setColor(255,255,255,255)
	
--	if self.gravity then
--		g.print("self.gravity " .. self.gravity, 10, 10 )
--	end

	if false then
		g.setFont(debugFont)

		if self.jumpVelocity then
			g.print("jumpVelocity " .. math.floor(self.jumpVelocity), 10, 50)
			g.print("deltaTime " .. math.floor(deltaTime * 1000), 10, 60)
			g.print("gravity " .. self.gravity, 10, 70)

		end

		g.print("inHole " .. boolStr(self.inHole), 10, 80)
		g.print("onPlatform " .. boolStr(self.onPlatform), 10, 90)
	end
	
--	g.print("building " .. buildingA.x .. " player "  .. player.x, 10, 20)
--	g.print("bullets " .. self.bullets:size(), 10, 10)

	g.setColor(255,255,255,255)
--	g.draw(self.image, self.x, self.y - 120)

	if self.dying then
		self.deathAnim:draw(self.x, self.y - 150)
	elseif self.jump then
		self.jumpAnim:draw(self.x, self.y - 150)
	elseif self.dodging then
		self.dodgeAnim:draw(self.x, self.y - 130)
		g.setColor(255,0,0,255)
--		g.rectangle("fill", self.x, self.y - 75, 150, 75)
	elseif self.melee then
		self.meleeBeginAnim:draw(self.x, self.y - 130)
	else
		self.runAnim:draw(self.x, self.y - 150)
	end
--	g.rectangle("fill", self.x, self.y, 120, 3)

	-- Bullets	
	g.setColor(255,255,255,255)
	
	local i = 0
	
	while i < self.bullets:size() do
		local bullet = self.bullets:getAt(i+1)
		g.draw(bulletImage, bullet.x, bullet.y)	
		i = i + 1
	end
	
	if self.muzzle > 0 then
		g.setColor(255, 255, 255, 255)
	
		g.draw(self.muzzleImage, self.x + 137, self.y - 110)
	
		self.muzzle = self.muzzle - 1
	end
	
	-- Debug
--	local cx, cy = self:getCenter()	
--	g.setColor(255,0,0,255)
--	g.rectangle("fill", self.x+60, self.y - 50, 30, 50)

--	g.circle("fill", cx, cy, 20)

end