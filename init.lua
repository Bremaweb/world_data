local world_data = {}
local world_dir = minetest.get_worldpath() .. "/"
local deserialize_from_file = nil
local serialize_to_file = nil

if default.deserialize_from_file ~= nil then
	deserialize_from_file = default.deserialize_from_file
else
	deserialize_from_file = function(filename)
		local f = io.open(filename, "r")
		if f==nil then 
			return {}
		end
			local t = f:read("*all")
			f:close()
		if t=="" or t==nil then 
			return {}
		end
		return minetest.deserialize(t)
	end
end

if default.serialize_to_file ~= nil then
	serialize_to_file = default.serialize_to_file
else
	serialize_to_file = function (filename,t)
		local f = io.open(filename, "w")
		if f ~= nil then
			f:write(minetest.serialize(t))
			f:close()
		else
			minetest.log("error","Unable to open for writing "..tostring(filename))
		end
	end
end

wd = {}

wd.load = function()
	minetest.log("action","Loading world data...")
	world_data = deserialize_from_file(world_dir.."world.data")
end

wd.unload = function()
	wd.save_player()
	world_data = nil
end

wd.save = function()
	if world_data ~= nil then
		minetest.log("action","Saving world data...")
		serialize_to_file(world_dir.."world.data",world_data)
	end
	minetest.after(300,wd.save)
end

wd.get = function(param)
	if wd.validate(param) then
		return world_data[param]
	else
		return nil
	end
end

wd.get_number = function(param)
	return tonumber(wd.get(param)) or 0
end

wd.set = function(param, value)
	if wd.validate(param) then
		world_data[param] = value
	else
		minetest.log("error","Unable to set "..tostring(param).." to "..tostring(value)) 
	end
end

wd.unset = function(param)
	wd.set(param,nil)
end

wd.increment = function (param, amount)
	local val = wd.get_number(param)  + amount
	wd.set(param,val)
end

wd.validate = function (param)
	if param ~= nil then
		if world_data ~= nil then
			return true
		else
			return false
		end
	else
		return false
	end
end

wd.dump = function()
	default.tprint(world_data,4)
end

minetest.register_on_shutdown(function()
	wd.save()
end)

minetest.after(300,wd.save)

wd.load()
