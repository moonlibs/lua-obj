package.path = package.path .. ';' .. '../?.lua'
local hi = require 'hires'
local oo = require 'obj'


local Class1 = oo.class( {}, 'Class1' )
local Class2 = oo.class( {}, 'Class2', Class1 )
local Class3 = oo.class( {}, 'Class3', Class2 )

function Class1:test()
	return true
end
function Class2:test()
	return true
end
function Class3:test()
	return true
end

local obj = Class3()


local N = 1e7
local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("pure      call: %0.8fs; %0.4f/s # direct method call, most fastest. reference",delta,N/delta))

Class2.test = nil
Class3.test = nil

local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("parent2   call: %0.8fs; %0.4f/s # call by inheritance",delta,N/delta))


function Class3:test()
	return Class2.test(self)
end

local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("raw super call: %0.8fs; %0.4f/s # call directly by Class.function",delta,N/delta))

function Class3:test()
	return self:_super(Class3,'test')(self)
end

local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("_super    call: %0.8fs; %0.4f/s # call to _super without closure",delta,N/delta))

function Class3:test()
	return self:super(Class3,'test')()
end

local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("super     call: %0.8fs; %0.4f/s",delta,N/delta))

function Class3:test()
	return getmetatable(self.__index).__index.test(self)
end

local clock = hi.clock()

for i = 1,N do
	local x = obj:test()
end

local delta = hi.clock() - clock
print(string.format("mt super  call: %0.8fs; %0.4f/s # only for comparison, it's wrong for depth > 2",delta,N/delta))

