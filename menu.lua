require 'background.lua'
require 'dummyPlayer.lua'
require 'animation.lua'

local g = love.graphics
local m = love.mouse
local k = love.keyboard

menu = {}

menuMode = "main"

function menu.addObject(o)
	menuObjects.size  = menuObjects.size + 1
	menuObjects[menuObjects.size] = o
end


function menu.load()
	menuObjects = {}
	menuObjects.size = 0
	
	bgSky = bgSky or g.newImage('assets/bg_gradient.jpg')
	bgSkyQuad = bgSkyQuad or g.newQuad(0,0, g.getWidth(), g.getHeight(), bgSky:getWidth(), bgSky:getHeight())
	
	headlineFont = headLineFont or g.newFont('assets/Alien-Encounters-Italic.ttf', 110)
	menuFont = menuFont or g.newFont('assets/Alien-Encounters-Solid-Bold-Italic.ttf', 60)
	scoreFont = scoreFont or g.newFont('assets/Alien-Encounters-Solid-Bold-Italic.ttf', 32)
	
	createdBy = createdBy or g.newImage('assets/title_createdBy.png')
	banner = banner or g.newImage('assets/title_banner.png')
	helicopter = helicopter or g.newImage('assets/helicopter.png')
	
	heliAnimMenu = heliAnimMenu or newAnimation(helicopter, 0, 0, 90, 90, 0.1, 2)
	
	instructionsImage = instructionsImage or g.newImage('assets/title_instructions.png')
	
	bgImage1 = bgImage1 or g.newImage("assets/bg01_y=525.png")
	bgImage2 = bgImage2 or g.newImage("assets/bg02_y=425.png")
	
	cursor = cursor or g.newImage('assets/cursor.png')
	
	dummyPlayer = dummyPlayer or DummyPlayer:new(400)
	
	local bg1 = Background:new(dummyPlayer, bgImage1, 525+100, { 123, 122, 122, 255}, 0.2, 0.1)
	local bg2 = Background:new(dummyPlayer, bgImage2, 425+100, { 175, 175, 175, 255}, 0.1, 0.1)

	menu.addObject(bg2)
	menu.addObject(bg1)

	m.setVisible(false)
end

function menu.keypressed(key)
end

function menu.update(dt)
	for i,obj in ipairs(menuObjects) do
		if obj.update then obj:update(dt)	end
	end
	
	heliAnimMenu:update(dt)
end

function menu.draw()
	mouseX, mouseY = m.getPosition()
	mouseDown = m.isDown('l')

	g.setColor(255,255,255,255)
	g.drawq(bgSky, bgSkyQuad, 0, 0)
	
	for i,obj in ipairs(menuObjects) do
		if obj.update then obj:draw(dt)	end
	end

	g.setColor(255,255,255,255)
	g.setFont(headlineFont)
	g.print("DAVE GONE APESHIT", 93, 170)

	if menuMode == "main" then
		if menu.button("NEW GAME", 475, 310) then
			game.load()
			state = game
		end

		if menu.button("INSTRUCTIONS", 420, 380) then
			menuMode = "instructions"
		end

		if menu.button("QUIT", 570, 450) then
			love.event.push('q')
		end		
		
	elseif menuMode == "instructions" then
		
		g.draw(instructionsImage, 0, 0)
	
		if menu.button("BACK", 90, 620) or k.isDown('escape') then
			menuMode = "main"
		end
	end
	
	g.setColor(255,255,255)
	
	heliAnimMenu:draw(782, 30)
	g.draw(banner, 870, 47)
	
	g.setFont(scoreFont)
	local int, frac = math.modf(bestTime)
	
	g.print("HIGHSCORE: " .. int .. "." .. math.floor(frac * 100), 920, 50)
	

	g.setColor(255,255,255,255)
	g.draw(createdBy, 550, 690)	
	g.draw(cursor, mouseX, mouseY)
end

function menu.button(text, x, y)
	
	local w, h = menuFont:getWidth(text), menuFont:getHeight()
	
	local hot 
		
	if mouseX >= x and mouseX <= x+w and mouseY >= y and mouseY <= y+h then
		g.setColor(0,0,0,255)
		hot = true		
	else
		g.setColor(255,255,255,255)
		hot = false
	end
	
	g.setFont(menuFont)
	g.print(text, x, y)

	return hot and mouseDown
end