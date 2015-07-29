local base = _G
module("obj", package.seeall)

local seq = 0
local obj = {
	___name    = "obj{}",
	__tostring = function(self)
		return self:_stringify()
	end
}
obj.__index = obj

base.setmetatable(obj, {
	___name    = "obj:mt";
	__tostring = function(self)
		return self.___namename
	end;
	__call = function (class,...)
		seq = seq + 1
		local self = base.setmetatable({ ___id = seq }, class)
		self:_init(...)
		return self
	end;
})

function obj:new(...)
	return self(...)
end

function obj:_init(...)
	-- ...
end

function obj:_stringify()
	return self.___name..'#'..self.___id
end

function obj:_super(class,method,calldepth)
	calldepth = ( calldepth or 0 ) + 2
	local parent = getmetatable(class.__index).__index
	local fun = parent[method]
	if fun then return fun end
	local parents = {}
	repeat
		table.insert(parents, parent.___name)
		parent = getmetatable( parent ).__index
	until not parent or parent == obj
	error("parent classes "..table.concat(parents,"->").." for class "..class.___name.." have no method "..method,calldepth)
end

function obj:super(class,method)
	if class and method then
		local super_method = self:_super(class,method,1)
		return function(...)
			return super_method(self,...)
		end
	else
		error('super() called with incorrect args',2)
	end
end

local function class_generator(base_obj)
	return
	function(pkg,newc,...)
		if not newc then error("Initial class table must be passed",2) end
		local name,parent
		local refaddr = tostring(newc):match("0x(.+)")
		if select('#',...) == 2 then
			name,parent = ...
		else
			local arg = ...
			if type(arg) == 'string' then
				name = ...
				parent = base_obj
			else				
				parent = ...
			end
		end
		parent = parent or base_obj
		name = name or 'Unn'..refaddr

		newc.__index = newc;
		base.setmetatable(newc,{
			__index     = parent;
			__call      = base.rawget(base.getmetatable(parent),'__call');
			__tostring  = function(class)
				return class.___name and class.___name .. '{}' or 'Unn'..class.___refaddr..'{}'
			end;
		})

		for k,v in base.pairs(parent) do
			if not base.rawget(newc,k) and k:match("^__[^_]") then
				newc[k] = parent[k]
			end
		end
		newc.___name = name
		newc.___refaddr = refaddr
		return newc;
	end	
end

local class = {}
setmetatable(class,{
	__tostring = function () return 'class{}' end;
	__call = class_generator(obj);
})

return {
	class = class;
}
