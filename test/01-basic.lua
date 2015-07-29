require 'busted'
-- require 'tap'

local obj = require 'obj'

describe("No parent class", function()
	it("shouldn't be created without args",function()
		assert.has_error(function()
			local Class1 = obj.class()
		end, "Initial class table must be passed")
	end)
	it("should be created with table arg",function()
		local Class1 = obj.class {}
		assert.truthy(Class1)		
	end)
	it("should be created with table arg",function()
		local Class1 = obj.class( {} )
		assert.truthy(Class1)
		assert.truthy(Class1.___name)
		assert.match("^Unn.+$",Class1.___name)
	end)

	it("should be created with name",function()
		local Class1 = obj.class( {}, 'Class1' )
		assert.truthy(Class1)
		assert.are.equal(Class1.___name,'Class1')
	end)
	it("should stringify",function()
		local Class1 = obj.class( {}, 'Class1' )
		assert.are.equal(tostring(Class1),'Class1{}')
	end)
end)

local Class1 = obj.class( {}, 'Class1' )

describe("Class with parent", function()
	it("should be created with table arg",function()
		local Class2 = obj.class( {}, Class1 )
		assert.truthy(Class2)
		assert.truthy(Class2.___name)
		assert.match("^Unn.+$",Class2.___name)
	end)

	it("should be created with name",function()
		local Class2 = obj.class( {}, 'Class2', Class1 )
		assert.truthy(Class2)
		assert.are.equal(Class2.___name,'Class2')
	end)

	it("should fail with duplicate",function()
		local Class2 = obj.class( {}, 'Class2', Class1 )
		assert.truthy(Class2)
		assert.are.equal(Class2.___name,'Class2')
	end)
end)

local Class2 = obj.class( {}, Class1 )

describe("Class with parent 2", function()
	it("should be created with table arg",function()
		local Class3 = obj.class( {}, Class2 )
		assert.truthy(Class3)
		assert.truthy(Class3.___name)
		assert.match("^Unn.+$",Class3.___name)
	end)

	it("should be created with name",function()
		local Class3 = obj.class( {}, 'Class3', Class2 )
		assert.truthy(Class3)
		assert.are.equal(Class3.___name,'Class3')
	end)

	it("should fail with duplicate",function()
		local Class3 = obj.class( {}, 'Class3', Class2 )
		assert.truthy(Class3)
		assert.are.equal(Class3.___name,'Class3')
	end)
end)

local Class3 = obj.class( {}, 'Class3', Class2 )

describe("Object", function()
	it("should be created with no args",function()
		local o1 = Class1()
		assert.truthy(o1)
	end)
	it("should be created with args",function()
		local o1 = Class1 {}
		assert.truthy(o1)
	end)
	it("should be stringifiable",function()
		local o1 = Class1 {}
		assert.match("^Class1#%d+$",tostring(o1))
		o1._stringify = function() return 'Overrded' end
		assert.are.equal('Overrded',tostring(o1))
	end)
	it("should have method from parent",function()
		local o3 = Class3 {}
		assert.match("^Class3#%d+$",tostring(o3))
		function Class1:test()
			return "got it"
		end
		assert.are.equal("got it",o3:test())
		function Class2:test()
			return "got too"
		end
		assert.are.equal("got too",o3:test())
		function Class3:test()
			return "got last"
		end
		assert.are.equal("got last",o3:test())
	end)
end)


describe("Object", function()
	it("should be able to call super",function()
		local Class1 = obj.class( {}, 'Class1' )
		local Class2 = obj.class( {}, 'Class2', Class1 )
		local Class3 = obj.class( {}, 'Class3', Class2 )
		local o3 = Class3 {}
		assert.has_error(function()
			o3:super()
		end, 'super() called with incorrect args')
		assert.has_error(function()
			o3:super('test')
		end, 'super() called with incorrect args')

		function Class1:test(arg)
			return "from 1"..arg
		end
		function Class2:test(arg)
			return "from 2"..arg..self:super(Class2,'test')(".")
		end
		function Class3:test(arg)
			return "from 3"..arg..self:super(Class3,'test')(";")
		end

		assert.are.equal("from 3,from 2;from 1.",o3:test(","))
		Class2.test = nil
		assert.are.equal("from 3,from 1;",o3:test(","))
		Class1.test = nil
		Class2.___name = 'Class2'
		assert.has_error(function()
			o3:test('?')
		end, 'parent classes Class2->Class1 for class Class3 have no method test')
	end)
end)
