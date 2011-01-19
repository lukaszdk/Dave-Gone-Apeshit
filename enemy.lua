require 'middleclass.lua'
require 'animation.lua'

local g = love.graphics


Enemy = class('Enemy')

function Enemy:initialize(x,y, playerBullets)	
	enemyImage = enemyImage or g.newImage('assets/agent.png')
	enemyDeath = enemyDeath or g.newImage('assets/agentDeath.png')
	enemyDeath2 = enemyDeath2 or g.newImage('assets/agentDeath2.png')
	enemyMelee = enemyMelee or g.newImage('assets/agentMelee.png')
	bulletImage2 = bulletImage2 or g.newImage('assets/bullet2.png')
	bloodImage = bloodImage or g.newImage('assets/blood.png')

	muzzleImage2 = muzzleImage2 or g.newImage('assets/muzzleFire2.png') 
	
	self.deathAnim = newAnimation(enemyDeath, 0, 0, 200, 150, 0.20, 5)
	self.deathAnim:setMode('once')

	self.deathAnim2 = newAnimation(enemyDeath2, 0, 0, 230, 183, 0.15, 8)
	self.deathAnim2:setMode('once')


	self.meleeAnim = newAnimation(enemyMelee, 0, 0, 150, 180, 0.1, 2)
	
	self.x = x + enemyImage:getWidth()/2
	self.y = y - enemyImage:getHeight()
	self.playerBullets = playerBullets
	self.dead = false
	
	self.bulletMax = 1	
	self.bulletSpeed = 900
	self.bullets = Ringbuffer()
	self.time = 0
	self.fireTime = math.random(0, 0.5)
	self.muzzle = 0
	self.melee = false
	self.deathType = 1
	self.killY = nil
	self.killYDur = nnil
	
	if sound then
		self.bulletSource = love.audio.newSource("assets/audio/gunshot_agent.mp3", "static")
		self.deathSource = love.audio.newSource("assets/audio/death_agent.wav", "static")
	end

end

function Enemy:hit(x,y)

	local eX, eY, eW, eH = self.x, self.y, enemyImage:getWidth(), enemyImage:getHeight()
	
	if eX >= 0 and eX + eW <= g.getWidth() and x >= eX and x <= eX+eW and y >= eY and y <= eY + eH then
		return true
	end 

	return false
end

function Enemy:visible()

	local eX, eW = self.x, enemyImage:getWidth()
	
	if eX >= 0 and eX <= g.getWidth() then
		return true
	end

	if eX + eW >= 0 and eX + eW <= g.getWidth() then
		return true
	end

	return false
end

function Enemy:playerInSight()

	local pX, pY = player:getCenter()
	local eX, eY, eH = self.x, self.y, enemyImage:getHeight()

	if pY >= eY and pY <= eY+eH then
		return true
	end
	
	
	return false
end

function Enemy:update(dt, dx)

	if self.killYDur and self.killYDur > 0 then
		self.killYDur = math.max(self.killYDur - dt, 0)
	end

	self.time = self.time + dt

	local i = 0

	self.x = math.floor(self.x - dx)

	while i < self.playerBullets:size() do
		local bullet = self.playerBullets:getAt(i+1)

		-- die
		if self:hit(bullet.x, bullet.y) then 
			
			if self.dead == false then
				kills = kills + 1
--				self.deathSource:stop()
				if sound then
					self.deathSource:play()
				end
				
				if bullet.y >= self.y + 60 then
					self.deathType = 2
					self.killY = bullet.y
					self.killYDur = 0.2
--					assert(false)
				end
			end
			
			bullet.x = g.getWidth() + 10
			
			self.dead = true		
		end

		i = i + 1
	end
	
	if player.x < self.x and math.abs(player.x - self.x) < 200 and (self:playerInSight() or self.melee == true) and not self.dead then 
		self.melee = true		
	else
		self.melee = false
	end
	
	if player.x < self.x and math.abs(self.x  - player.x) < 30 and self:playerInSight() and not self.dead then 
	
		if player.melee and self.dead == false then
			self.dead = true
			self.deathType = 2
			kills = kills + 1
		else
			player:die(0.6)
		end
	end
		
	if not self.melee and self:visible() and self.x < g.getWidth() - 200 and self:playerInSight() and not self.dead and self.time > self.fireTime and player.x < self.x and math.abs(player.x - self.x) > 500 then
		-- fire 
		if self.bullets:size() < self.bulletMax then

			local bullet = { x = self.x + 30, y = self.y + 30 }

			self.bullets:append(bullet)
			
			self.fireTime = self.time + math.random(2,4)
			
			self.muzzle = 7
			
			if sound then
				self.bulletSource:play()
			end
		end	
	end
	
	-- Bullets
	local i = 0
	while i < self.bullets:size() do
		local bullet = self.bullets:getAt(i+1)
		bullet.x = math.floor(bullet.x - dt * self.bulletSpeed)
		
		if bullet.x < 0 then
			self.bullets:removeAt(i+1)
		end
		
		i = i + 1
	end
	
	if self.dead then
		self.deathAnim:update(dt)
		self.deathAnim2:update(dt)
	end
	
	if self.melee then
		self.meleeAnim:update(dt)
	end
	
	player:checkBullets(self.bullets)
end

function Enemy:draw(x)
	g.setColor(255,255,255,255)
	
	if self.dead then
		if self.deathType == 1 then
			self.deathAnim:draw(self.x, self.y) 
		else
			self.deathAnim2:draw(self.x, self.y-30)
			
			if self.killY and self.killYDur > 0 then
				g.draw(bloodImage, self.x + 125, self.killY - bloodImage:getHeight())
			end
			
		end
	else
		if self.melee then
			self.meleeAnim:draw(self.x, self.y - 30)
		else
			g.draw(enemyImage, self.x, self.y)
		end
	end
			
	g.setColor(255,255,255,255)
	local i = 0
	while i < self.bullets:size() do
		local bullet = self.bullets:getAt(i+1)
		--g.rectangle("fill", bullet.x, bullet.y, 12, 4)
		g.draw(bulletImage2, bullet.x, bullet.y)
		i = i + 1
	end
	
	if self.muzzle > 0 then
		g.setColor(255, 255, 255, 255)
		g.draw(muzzleImage2, self.x - 40, self.y + 20)
	
		self.muzzle = self.muzzle - 1
	end

	g.setColor(255,0,0,255)
	
	local eY, eH = self.y, enemyImage:getHeight()

	-- Debug
--	g.setColor(255, 0, 0, 255)
--	g.line(self.x, eY, self.x - 120, eY)
--	g.line(self.x, eY+60, self.x - 120, eY+60)
	
	
end