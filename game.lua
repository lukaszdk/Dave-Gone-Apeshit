require 'player.lua'
require 'building.lua'
require 'background.lua'

local g = love.graphics
local a = love.audio

game = {}

kills = 0

function game.addObject(o)
	gameObjects.size  = gameObjects.size + 1
	gameObjects[gameObjects.size] = o
end

function game.load()
	gameObjects = {}
	gameObjects.size = 0
	kills = 0
	
	font = font or g.newFont('assets/Alien-Encounters-Italic.ttf', 36)

	player = Player:new(200, g.getHeight() -30, 500)
	
	buildingA = Building:new(player, -400)
	buildingB = Building:new(player, buildingA.x + buildingA.w)
	
	buildingA:setOther(buildingB)
	buildingB:setOther(buildingA)
	
	bgSky = bgSky or g.newImage('assets/bg_gradient.jpg')
	bgSkyQuad = bgSkyQuad or g.newQuad(0,0, g.getWidth(), g.getHeight(), bgSky:getWidth(), bgSky:getHeight())
	
	bgImage1 = bgImage1 or g.newImage("assets/bg01_y=525.png")
	bgImage2 = bgImage2 or g.newImage("assets/bg02_y=425.png")
	
	
	local bg1 = Background:new(player, bgImage1, 525, { 123, 122, 122, 255}, 0.2, 0.1)
	local bg2 = Background:new(player, bgImage2, 425, { 175, 175, 175, 255}, 0.1, 0.1)

	game.addObject(bg2)
	game.addObject(bg1)
	
	game.addObject(buildingA)
	game.addObject(buildingB)
	game.addObject(player)

	g.setBackgroundColor(239, 147, 49, 255)
	
	time = 0
end

function game.keypressed(key)
	if key == "escape" then 
		menu.load()
		state = menu
	else
		for i,obj in ipairs(gameObjects) do
			if obj.keypressed then obj:keypressed(key)	end
		end	
	end
end

function game.keyreleased(key)
	for i,obj in ipairs(gameObjects) do
		if obj.keypressed then obj:keyreleased(key)	end
	end	
end

function game.update(dt)
	player:checkCollision(buildingA, buildingB)
	player:checkEnemies(buildingA.enemies, buildingB.enemies)

	for i,obj in ipairs(gameObjects) do
		if obj.update then obj:update(dt)	end
	end
	
	
	if player:isDead() then
		if time > bestTime then
			local int, frac = math.modf(time)
			local string = "bestTime = " .. int .. "." .. math.floor(frac * 100)
			love.filesystem.write('highscore.lua', string, string:len())
			bestTime = time
		end
		game.load()
	end
	
	time = time + dt
end

function game.draw()
	
	g.drawq(bgSky, bgSkyQuad, 0, 0)
	
	for i,obj in ipairs(gameObjects) do
		obj:draw()	
	end

	for i,obj in ipairs(gameObjects) do
		if obj.postDraw then obj:postDraw()	end
	end


	g.setColor(255,255,255, 255)

--	g.print("KILLS: " .. kills, g.getWidth() - 200, 10)
	
	g.setFont(font)
	
	local int, frac = math.modf(bestTime)
	g.print("HIGHSCORE: " .. int .. "." .. math.floor(frac * 100), 20, 10)


	local int, frac = math.modf(time)
	g.print("TIME: " .. int .. "." .. math.floor(frac * 100), g.getWidth()-300, 10)
	

end
