require 'game.lua'
require 'menu.lua'

local g = love.graphics
local m = love.mouse

state = menu
sound = true

function love.load()
	love.filesystem.setIdentity("davegoneapeshit")

	if love.filesystem.exists('highscore.lua') then
		love.filesystem.load('highscore.lua')()
	else
		bestTime = 20.52
	end

	if sound then
		musicSource = musicSource or love.audio.newSource("assets/audio/music.mp3")
		musicSource:setLooping("true")
		musicSource:setVolume(1)
		musicSource:play()
	end
	
	if state.load then state.load() end
	m.setVisible(false)
end

function love.keypressed(key)
	if state.keypressed then state.keypressed(key) end
end

function love.keyreleased(key)
	if state.keyreleased then state.keyreleased(key) end
end

function love.update(dt)
	if state.update then state.update(dt) end
end

function love.draw()	
	g.setColor(255, 255, 255, 255)
	if state.draw then state.draw() end	
end