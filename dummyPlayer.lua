require 'middleclass.lua'

DummyPlayer = class('DummyPlayer')

function DummyPlayer:initialize(speed)
	self.speed = speed
end

function DummyPlayer:getSpeed()
	return self.speed
end