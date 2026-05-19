--!nocheck
local vape, vapeEvents, entitylib, store, bedwars = ...

local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local LPNAME = lplr and lplr.Name or ""

local cache = {}

local function walkPath(fullName)
	if LPNAME ~= "" then
		fullName = fullName:gsub("PlayerTemplate", LPNAME)
	end
	local parts = string.split(fullName, ".")
	if #parts == 0 then return nil end
	local current
	local first = parts[1]
	if first == "game" then
		current = game
		table.remove(parts, 1)
	else
		local ok, svc = pcall(function() return game:GetService(first) end)
		if ok and svc then
			current = svc
			table.remove(parts, 1)
		else
			current = game
		end
	end
	for _, seg in ipairs(parts) do
		if not current then return nil end
		current = current:FindFirstChild(seg)
	end
	return current
end

local function newPromise(fullName)
	local resolved = false
	local value
	local proxy = {}
	function proxy:await()
		if resolved then return value end
		local ins = walkPath(fullName)
		if not ins then
			resolved = true
			return nil
		end
		local ok, mod = pcall(require, ins)
		if not ok then
			task.wait()
			ok, mod = pcall(require, ins)
		end
		resolved = true
		value = ok and mod or nil
		return value
	end
	function proxy:andThen(fn)
		task.spawn(function()
			local v = proxy:await()
			pcall(fn, v)
		end)
		return proxy
	end
	function proxy:catch() return proxy end
	function proxy:timeout() return proxy end
	return proxy
end

return setmetatable(cache, {
	__index = function(self, key)
		if type(key) ~= "string" then return nil end
		local existing = rawget(self, key)
		if existing then return existing end
		local p = newPromise(key)
		rawset(self, key, p)
		return p
	end,
})
