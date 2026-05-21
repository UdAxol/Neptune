repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor then
	if table.find({'Wave', 'Seliware', 'Volt'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local args = ...
if type(args) == "table" and args.Username then
	shared.ValidatedUsername = args.Username
end

if type(args) == "table" and args.Closet then
	getgenv().Closet = true
else
	if getgenv().Closet == nil then
		getgenv().Closet = false
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/UdAxol/Neptune/' .. readfile('neptune/profiles/commit.txt') .. '/' .. select(1, path:gsub('neptune/', '')), true)
			end)
			if suc and result ~= '404: Not Found' then
				res = result
				success = true
				break
			end
			task.wait(1)
		end
		if not success then
			error('Failed to download ' .. path .. ' after 3 attempts')
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function migrateProfiles()
	if isfile('neptune/profiles/migrated_placeid.txt') then return end

    local oldId = tostring(game.GameId)
    local newId = tostring(game.PlaceId)

	if oldId == newId then
		pcall(writefile, 'neptune/profiles/migrated_placeid.txt', 'done')
		return
	end

	local suffix = oldId .. '.txt'
	for _, path in ipairs(listfiles('neptune/profiles')) do
		local name = path:gsub('\\', '/')
		if name:sub(-#suffix) == suffix then
			local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
			if not isfile(newPath) then
				pcall(function() writefile(newPath, readfile(path)) end)
			end
		end
	end

	if isfolder('neptune/profiles/premade') then
		for _, path in ipairs(listfiles('neptune/profiles/premade')) do
			local name = path:gsub('\\', '/')
			if name:sub(-#suffix) == suffix then
				local newPath = name:sub(1, -#suffix - 1) .. newId .. '.txt'
				if not isfile(newPath) then
					pcall(function() writefile(newPath, readfile(path)) end)
				end
			end
		end
	end

	pcall(writefile, 'neptune/profiles/migrated_placeid.txt', 'done')
end

pcall(migrateProfiles)

local function finishLoading()
	vape.Init = nil
	if not vape.Load then
		warn('[NEPTUNE] vape.Load is nil skipping load')
		return
	end
	vape:Load()
	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				repeat task.wait() until game:IsLoaded()
				if getgenv and not getgenv().shared then getgenv().shared = {} end
				shared.vapereload = true
				loadstring(game:HttpGet('https://raw.githubusercontent.com/UdAxol/Neptune/'..readfile('neptune/profiles/commit.txt')..'/loader.lua', true), 'loader')()
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n' .. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
			end
			if shared.ValidatedUsername then
				teleportScript = 'shared.ValidatedUsername = "' .. shared.ValidatedUsername .. '"\n' .. teleportScript
			end
			local _ok, _err = pcall(function() vape:Save() end)
			if not _ok then warn('[NEPTUNE] save failed before teleport: ' .. tostring(_err)) end
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			local name = shared.ValidatedUsername and ('wsg, ' .. shared.ValidatedUsername .. ' :D ') or 'welcome '
			task.spawn(function()
				local deadline = tick() + 15
				while tick() < deadline do
					if getgenv()._aeroTierReady then break end
					task.wait(0.5)
				end
				local tier = 0
				if getgenv().getAeroTier then
					tier = getgenv().getAeroTier(playersService.LocalPlayer) or 0
				end
				vape:CreateNotification('[NEPTUNE] Finished Loading [Tier ' .. tostring(tier) .. ']', name .. (vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press ' .. table.concat(vape.Keybind, ' + '):upper() .. ' to open GUI'), 5)
			end)
		end
	end
end

do
	local SUPABASE_URL_GATE = "https://jfkhuzpqypttaddgbkin.supabase.co"
	local SUPABASE_ANON_GATE = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impma2h1enBxeXB0dGFkZGdia2luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMjUzMzksImV4cCI6MjA5NDgwMTMzOX0.O_A2a7uVN8MVajlewMsb0dXqAz4sir4HiYvKTb0cp1o"
	local CACHE_GATE = "neptune_account.json"
	local DISCORD_GATE = "https://discord.gg/axM8rzg5"
	-- OWNER HWIDS — hardware-id-based bypass. Hardcode your machine's HWID
	-- here and you'll auto-bypass the gate forever, no key needed. HWID is
	-- stable per-machine across roblox installs / username changes so this
	-- is far stronger than the old username check.
	--
	-- First-time setup: run the loader once, look in console for
	--   "[NEPTUNE] Your HWID: <something>"
	-- copy that string into the array below, push, re-inject.
	local OWNER_HWIDS = {
		-- "your_hwid_here",
	}
	local lp = playersService.LocalPlayer
	local httpG = httpService

	-- HWID gatherer — tries executor's gethwid() first, falls back to
	-- Roblox's RbxAnalyticsService:GetClientId() (stable per-install).
	local function getHWID()
		if type(gethwid) == "function" then
			local ok, h = pcall(gethwid)
			if ok and h and h ~= "" then return tostring(h) end
		end
		local ok, c = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
		if ok and c and c ~= "" then return tostring(c) end
		return "unknown-" .. tostring(lp.UserId)
	end
	local currentHWID = getHWID()
	-- HWID is shown in the key-gate GUI (bottom row) — see far below — so the
	-- owner can grab it with a Copy button instead of digging into console.

	-- Owner HWID bypass — runs BEFORE any network call so even with Supabase
	-- down the owner loads. Username-independent (Roblox username changes
	-- don't lose access).
	for _, ownerHwid in ipairs(OWNER_HWIDS) do
		if currentHWID == ownerHwid then
			getgenv()._NEPTUNE_LIFETIME = true
			pcall(writefile, CACHE_GATE, httpService:JSONEncode({
				active = true, tier = "premium", is_lifetime = true, owner = true,
				hwid = currentHWID,
			}))
			warn("[NEPTUNE] owner HWID matched — key gate bypassed, granted Premium")
			return
		end
	end
	local reqG = (syn and syn.request) or (http and http.request) or http_request or request
		or function(t) return { Body = game:HttpGet(t.Url, true), StatusCode = 200 } end

	local function gateCall(path, body, method)
		local ok, res = pcall(function()
			return reqG({
				Url = SUPABASE_URL_GATE .. path,
				Method = method or (body and "POST" or "GET"),
				Headers = {
					["apikey"] = SUPABASE_ANON_GATE,
					["Authorization"] = "Bearer " .. SUPABASE_ANON_GATE,
					["Content-Type"] = "application/json",
				},
				Body = body and httpG:JSONEncode(body) or nil,
			})
		end)
		if not ok or not res or not res.Body then return nil end
		local sok, parsed = pcall(function() return httpG:JSONDecode(res.Body) end)
		return sok and parsed or nil
	end

	local function checkStatus()
		local r = gateCall("/rest/v1/rpc/get_user_premium",
			{ p_user_id = lp.UserId, p_hwid = currentHWID }, "POST")
		if type(r) == "table" and r[1] then return r[1].active == true, r[1] end
		-- Fallback for the pre-HWID-migration RPC signature
		r = gateCall("/rest/v1/rpc/get_user_premium", { p_user_id = lp.UserId }, "POST")
		if type(r) == "table" and r[1] then return r[1].active == true, r[1] end
		return false, nil
	end

	local function tryRedeem(key)
		if not key or #key < 8 then return false, "key too short" end
		local cleaned = key:gsub("%s+", "")
		local r = gateCall("/rest/v1/rpc/redeem_key", {
			p_user_id = lp.UserId, p_username = lp.Name, p_key = cleaned, p_hwid = currentHWID,
		}, "POST")
		if (type(r) ~= "table" or not r[1]) then
			r = gateCall("/rest/v1/rpc/redeem_key", {
				p_user_id = lp.UserId, p_username = lp.Name, p_key = cleaned,
			}, "POST")
		end
		if type(r) == "table" and type(r.message) == "string" then
			return false, "supabase: " .. r.message
		end
		if type(r) ~= "table" or not r[1] then return false, "no response (supabase unreachable / RPC missing)" end
		if not r[1].success then return false, r[1].message or "invalid" end
		return true, r[1]
	end

	-- Check existing auth via cache + live verification
	local active = false
	do
		local ok, cached = pcall(readfile, CACHE_GATE)
		if ok and cached then
			pcall(function()
				local d = httpG:JSONDecode(cached)
				if d and d.active then active = true end
			end)
		end
		local liveActive, _row = checkStatus()
		if liveActive then active = true end
	end

	if not active then
		local sg = Instance.new("ScreenGui")
		sg.Name = "NeptuneGate"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
		sg.DisplayOrder = 999
		sg.Parent = gethui and gethui() or game:GetService("CoreGui")
		local back = Instance.new("Frame", sg)
		back.Size = UDim2.new(1, 0, 1, 0)
		back.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		back.BackgroundTransparency = 0.2
		back.BorderSizePixel = 0
		local card = Instance.new("Frame", back)
		card.Size = UDim2.fromOffset(460, 320)
		card.Position = UDim2.new(0.5, -230, 0.5, -160)
		card.BackgroundColor3 = Color3.fromRGB(16, 22, 50)
		card.BorderSizePixel = 0
		do local c = Instance.new("UICorner", card); c.CornerRadius = UDim.new(0, 14) end
		local title = Instance.new("TextLabel", card)
		title.Size = UDim2.new(1, 0, 0, 50)
		title.Position = UDim2.fromOffset(0, 20)
		title.BackgroundTransparency = 1
		title.Text = "NEPTUNE"
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 28
		title.TextColor3 = Color3.fromRGB(96, 128, 255)
		local sub = Instance.new("TextLabel", card)
		sub.Size = UDim2.new(1, -40, 0, 24)
		sub.Position = UDim2.fromOffset(20, 78)
		sub.BackgroundTransparency = 1
		sub.Text = "A key is required to use Neptune."
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 13
		sub.TextColor3 = Color3.fromRGB(170, 180, 210)
		local box = Instance.new("TextBox", card)
		box.Size = UDim2.fromOffset(420, 44)
		box.Position = UDim2.fromOffset(20, 116)
		box.BackgroundColor3 = Color3.fromRGB(8, 12, 28)
		box.BorderSizePixel = 0
		box.PlaceholderText = "NEP-XXXXX-XXXXX-XXXXX-XXXXX"
		box.Text = ""
		box.ClearTextOnFocus = false
		box.Font = Enum.Font.Code
		box.TextSize = 14
		box.TextColor3 = Color3.fromRGB(120, 160, 255)
		do local c = Instance.new("UICorner", box); c.CornerRadius = UDim.new(0, 8) end
		local btnRedeem = Instance.new("TextButton", card)
		btnRedeem.Size = UDim2.fromOffset(420, 40)
		btnRedeem.Position = UDim2.fromOffset(20, 172)
		btnRedeem.BackgroundColor3 = Color3.fromRGB(50, 80, 200)
		btnRedeem.BorderSizePixel = 0
		btnRedeem.Text = "Redeem Key"
		btnRedeem.TextColor3 = Color3.new(1, 1, 1)
		btnRedeem.Font = Enum.Font.GothamBold
		btnRedeem.TextSize = 15
		do local c = Instance.new("UICorner", btnRedeem); c.CornerRadius = UDim.new(0, 8) end
		local btnGetKey = Instance.new("TextButton", card)
		btnGetKey.Size = UDim2.fromOffset(420, 40)
		btnGetKey.Position = UDim2.fromOffset(20, 220)
		btnGetKey.BackgroundColor3 = Color3.fromRGB(70, 90, 130)
		btnGetKey.BorderSizePixel = 0
		btnGetKey.Text = "Buy / Get Key (Discord)"
		btnGetKey.TextColor3 = Color3.new(1, 1, 1)
		btnGetKey.Font = Enum.Font.GothamBold
		btnGetKey.TextSize = 14
		do local c = Instance.new("UICorner", btnGetKey); c.CornerRadius = UDim.new(0, 8) end
		local status = Instance.new("TextLabel", card)
		status.Size = UDim2.new(1, -40, 0, 20)
		status.Position = UDim2.fromOffset(20, 270)
		status.BackgroundTransparency = 1
		status.Text = ""
		status.Font = Enum.Font.Gotham
		status.TextSize = 12
		status.TextColor3 = Color3.fromRGB(255, 110, 110)

		-- Show a MASKED HWID for the user to recognise their own device
		-- without exposing the full string to anyone shoulder-surfing or
		-- screenshotting. Only the first 6 + last 4 characters are visible,
		-- middle is dots. NO copy button — copying the full HWID would let
		-- another player paste your device fingerprint and impersonate
		-- you on a transfer request. If the owner truly needs the full
		-- string they can pull it from the local cache file
		-- (neptune_account.json) or from Supabase.
		card.Size = UDim2.fromOffset(460, 350)
		card.Position = UDim2.new(0.5, -230, 0.5, -175)
		local function maskHWID(h)
			h = tostring(h or "")
			if #h <= 14 then return h end
			return h:sub(1, 6) .. " ... " .. h:sub(-4)
		end
		local hwidLbl = Instance.new("TextLabel", card)
		hwidLbl.Size = UDim2.fromOffset(420, 22)
		hwidLbl.Position = UDim2.fromOffset(20, 304)
		hwidLbl.BackgroundTransparency = 1
		hwidLbl.Text = "HWID: " .. maskHWID(currentHWID)
		hwidLbl.TextXAlignment = Enum.TextXAlignment.Center
		hwidLbl.Font = Enum.Font.Code
		hwidLbl.TextSize = 11
		hwidLbl.TextColor3 = Color3.fromRGB(110, 130, 180)

		local done = false
		btnRedeem.MouseButton1Click:Connect(function()
			local k = box.Text:gsub("%s+", "")
			if #k < 8 then status.Text = "paste a key first"; return end
			status.Text = "validating..."; status.TextColor3 = Color3.fromRGB(180, 180, 180)
			local ok, info = tryRedeem(k)
			if ok then
				pcall(writefile, CACHE_GATE, httpG:JSONEncode({
					active = true,
					tier = info.tier,
					expires_unix = info.expires_unix,
					is_lifetime = info.is_lifetime,
				}))
				status.Text = info.tier == "premium" and "PREMIUM unlocked" or "key activated"
				status.TextColor3 = Color3.fromRGB(80, 220, 120)
				task.wait(0.7); done = true
			else
				local msg = tostring(info)
				local low = msg:lower()
				-- "device_locked" — key was bound to a different HWID. Tell
				-- the user to contact the owner for a transfer.
				if low:find("device") or low:find("hwid") or low:find("locked") then
					status.Text = "this key is locked to a different device — DM owner on Discord for transfer"
					status.TextColor3 = Color3.fromRGB(255, 180, 80)
				-- "Already used by THIS user" — they consumed it before,
				-- cache deleted. Re-fetch premium status; if active, grant.
				elseif low:find("already") or low:find("used") or low:find("consumed") then
					status.Text = "key already redeemed — checking your premium status..."
					status.TextColor3 = Color3.fromRGB(180, 180, 180)
					local liveActive, row = checkStatus()
					if liveActive then
						pcall(writefile, CACHE_GATE, httpG:JSONEncode({
							active = true,
							tier = row and row.tier or "premium",
							expires_unix = row and row.expires_unix or nil,
							is_lifetime = row and row.is_lifetime or false,
							hwid = currentHWID,
						}))
						status.Text = "verified — premium restored from your account"
						status.TextColor3 = Color3.fromRGB(80, 220, 120)
						task.wait(0.7); done = true
						return
					end
					status.Text = "rejected: " .. msg
					status.TextColor3 = Color3.fromRGB(255, 110, 110)
				else
					status.Text = "rejected: " .. msg
					status.TextColor3 = Color3.fromRGB(255, 110, 110)
				end
			end
		end)
		btnGetKey.MouseButton1Click:Connect(function()
			pcall(function() setclipboard(DISCORD_GATE) end)
			status.Text = "Discord link copied — DM the owner to buy a key"
			status.TextColor3 = Color3.fromRGB(96, 160, 255)
		end)

		local t0 = tick()
		repeat task.wait(0.1) until done or (tick() - t0 > 600)
		sg:Destroy()
		if not done then
			pcall(function() lp:Kick("Neptune: no key provided") end)
			error("[NEPTUNE] no key — aborted")
		end
	end
end

if not isfile('neptune/profiles/gui.txt') then
	writefile('neptune/profiles/gui.txt', 'new')
end
local gui = readfile('neptune/profiles/gui.txt')

if not isfolder('neptune/assets/' .. gui) then
	makefolder('neptune/assets/' .. gui)
end

local guiFunc, guiErr = loadstring(downloadFile('neptune/guis/' .. gui .. '.lua'), 'gui')
if not guiFunc then
	error('[NEPTUNE] Failed to load GUI: ' .. tostring(guiErr))
end
vape = guiFunc()
if not vape then
	error('[NEPTUNE] GUI returned nil file may be corrupted try deleting neptune/guis/' .. gui .. '.lua and reinjecting.')
end
if not vape.Load then
	if delfile then pcall(function() delfile('neptune/guis/' .. gui .. '.lua') end) end
	error('[NEPTUNE] gui file corrupted (missing load) reinject..')
end
if not vape.Init and not vape.Load then
	error('[NEPTUNE] failed to initialize properly reinject to fix this bs')
end
shared.vape = vape
task.wait(0.1)

do
	local SUPABASE_URL = "https://jfkhuzpqypttaddgbkin.supabase.co"
	local SUPABASE_ANON = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impma2h1enBxeXB0dGFkZGdia2luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyMjUzMzksImV4cCI6MjA5NDgwMTMzOX0.O_A2a7uVN8MVajlewMsb0dXqAz4sir4HiYvKTb0cp1o"
	local CACHE_FILE = "neptune_account.json"
	local DISCORD_LINK = "https://discord.gg/axM8rzg5"

	local Players     = cloneref(game:GetService("Players"))
	local httpService = cloneref(game:GetService("HttpService"))
	local RunService  = cloneref(game:GetService("RunService"))
	local lplr        = Players.LocalPlayer

	local req = (syn and syn.request) or (http and http.request) or http_request or request
		or function(t) return { Body = game:HttpGet(t.Url, true), StatusCode = 200 } end

	local function hreq(url, method, body, extra_headers)
		local headers = {
			["apikey"] = SUPABASE_ANON,
			["Authorization"] = "Bearer " .. SUPABASE_ANON,
			["Content-Type"] = "application/json",
		}
		if extra_headers then for k, v in pairs(extra_headers) do headers[k] = v end end
		local ok, res = pcall(function()
			return req({
				Url = SUPABASE_URL .. url,
				Method = method or "GET",
				Headers = headers,
				Body = body and httpService:JSONEncode(body) or nil,
			})
		end)
		if not ok or not res or not res.Body then return nil end
		local sok, parsed = pcall(function() return httpService:JSONDecode(res.Body) end)
		return sok and parsed or nil
	end

	local function rpc(name, args) return hreq("/rest/v1/rpc/" .. name, "POST", args or {}) end

	local function loadCache()
		local ok, c = pcall(readfile, CACHE_FILE)
		if not ok or not c or #c < 2 then return nil end
		local sok, d = pcall(function() return httpService:JSONDecode(c) end)
		return sok and d or nil
	end
	local function saveCache(t)
		pcall(writefile, CACHE_FILE, httpService:JSONEncode(t))
	end

	-- ===== Status helpers exposed to other modules =====
	local function pushStatus(active, tier, expires_unix, is_lifetime)
		getgenv()._NEPTUNE_ACTIVE     = active and true or false
		getgenv()._NEPTUNE_TIER       = tier or "free"
		getgenv()._NEPTUNE_EXPIRES    = expires_unix
		getgenv()._NEPTUNE_LIFETIME   = is_lifetime and true or false
		getgenv()._NEPTUNE_PREMIUM    = (tier == "premium") -- backwards compat
	end

	-- Default: free
	pushStatus(false, "free", nil, false)

	-- ===== Boot: try cache first, then verify with server =====
	do
		local c = loadCache()
		if c then
			pushStatus(c.active, c.tier, c.expires_unix, c.is_lifetime)
		end
		-- Always re-verify with server in the background
		task.spawn(function()
			local r = rpc("get_user_premium", { p_user_id = lplr.UserId })
			if type(r) == "table" and r[1] then
				local row = r[1]
				pushStatus(row.active, row.tier, row.expires_unix, row.is_lifetime)
				saveCache({
					active = row.active, tier = row.tier,
					expires_unix = row.expires_unix, is_lifetime = row.is_lifetime,
				})
			end
		end)
	end

	-- ===== Active session registration =====
	local function upsertSession()
		pcall(function()
			req({
				Url = SUPABASE_URL .. "/rest/v1/active_sessions?on_conflict=user_id",
				Method = "POST",
				Headers = {
					["apikey"] = SUPABASE_ANON,
					["Authorization"] = "Bearer " .. SUPABASE_ANON,
					["Content-Type"] = "application/json",
					["Prefer"] = "resolution=merge-duplicates,return=minimal",
				},
				Body = httpService:JSONEncode({
					user_id    = lplr.UserId,
					username   = lplr.Name,
					job_id     = game.JobId,
					place_id   = game.PlaceId,
					is_premium = getgenv()._NEPTUNE_LIFETIME or false,
					last_seen  = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
				}),
			})
		end)
	end
	upsertSession()

	-- ===== Heartbeat: keep session fresh + check kick flag =====
	task.spawn(function()
		while task.wait(getgenv()._NEPTUNE_LIFETIME and 5 or 3) do
			pcall(function()
				req({
					Url = SUPABASE_URL .. "/rest/v1/active_sessions?user_id=eq." .. lplr.UserId,
					Method = "PATCH",
					Headers = {
						["apikey"] = SUPABASE_ANON,
						["Authorization"] = "Bearer " .. SUPABASE_ANON,
						["Content-Type"] = "application/json",
					},
					Body = httpService:JSONEncode({
						last_seen = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
						is_premium = getgenv()._NEPTUNE_LIFETIME or false,
					}),
				})
			end)
			-- Premium users can't be kicked by this system; skip the check
			if not getgenv()._NEPTUNE_LIFETIME then
				local r = hreq("/rest/v1/active_sessions?select=kick_requested,kick_reason&user_id=eq." .. lplr.UserId)
				if type(r) == "table" and r[1] and r[1].kick_requested then
					pcall(function() lplr:Kick(r[1].kick_reason or "kicked by Premium user") end)
				end
			end
		end
	end)

	if shared.vape and shared.vape.Clean then
		shared.vape:Clean(function()
			pcall(function()
				req({
					Url = SUPABASE_URL .. "/rest/v1/active_sessions?user_id=eq." .. lplr.UserId,
					Method = "DELETE",
					Headers = {
						["apikey"] = SUPABASE_ANON,
						["Authorization"] = "Bearer " .. SUPABASE_ANON,
					},
				})
			end)
		end)
	end

	-- ===== Redeem function =====
	local function redeem(key)
		if not key or #key < 8 then return false, "key too short" end
		local r = rpc("redeem_key", {
			p_user_id = lplr.UserId,
			p_username = lplr.Name,
			p_key = key:gsub("%s+", ""),
		})
		if type(r) ~= "table" or not r[1] then return false, "no response" end
		local row = r[1]
		if not row.success then return false, row.message or "invalid" end
		pushStatus(true, row.tier, row.expires_unix, row.is_lifetime)
		saveCache({ active = true, tier = row.tier, expires_unix = row.expires_unix, is_lifetime = row.is_lifetime })
		upsertSession()
		return true, row
	end

	-- ===== Time formatting =====
	local function fmtRemaining()
		if getgenv()._NEPTUNE_LIFETIME then return "LIFETIME" end
		if not getgenv()._NEPTUNE_EXPIRES then return "no active subscription" end
		local rem = getgenv()._NEPTUNE_EXPIRES - os.time()
		if rem <= 0 then return "expired" end
		local d = math.floor(rem / 86400)
		local h = math.floor((rem % 86400) / 3600)
		local m = math.floor((rem % 3600) / 60)
		local s = rem % 60
		if d > 0 then return string.format("%dd %dh %dm", d, h, m) end
		if h > 0 then return string.format("%dh %dm", h, m) end
		if m > 0 then return string.format("%dm %ds", m, s) end
		return string.format("%ds", s)
	end

	getgenv()._NEPTUNE_REDEEM = redeem
	getgenv()._NEPTUNE_TIME_LEFT = fmtRemaining


	-- Account module DISABLED per user request — the redeem/key-status pane
	-- is no longer registered. The key system still functions in the
	-- background (validateKey on chunk start, kick-non-premium hooks, etc.)
	-- but doesn't appear in the GUI's Settings/Account category.
	-- getgenv()._NEPTUNE_REDEEM and getgenv()._NEPTUNE_TIME_LEFT remain
	-- exposed so command-line redeem still works.

	-- ===== Premium-only: Kick Non-Premium Users module =====
	task.defer(function()
		local deadline = tick() + 10
		while tick() < deadline do
			if shared.vape and shared.vape.Categories then break end
			task.wait(0.2)
		end
		if not getgenv()._NEPTUNE_LIFETIME then return end
		if not shared.vape or not shared.vape.Categories then return end
		local cat = shared.vape.Categories.Render or shared.vape.Categories.Main
		if not cat or not cat.CreateModule then return end
		local Kick = cat:CreateModule({
			Name = "Kick Non-Premium",
			Tooltip = "PREMIUM — kicks every non-premium Neptune user in your current Roblox server.",
			Function = function() end,
		})
		local tog
		tog = Kick:CreateToggle({
			Name = "Kick now",
			Function = function(state)
				if not state then return end
				task.spawn(function()
					local r = rpc("request_kick_non_premium", {
						p_user_id = lplr.UserId,
						p_job_id  = game.JobId,
					})
					local count = (type(r) == "number") and r
						or (type(r) == "table" and (r[1] and r[1] or 0))
						or 0
					if type(count) == "table" then count = 0 end
					shared.vape:CreateNotification("Premium",
						"Kicked " .. tostring(count) .. " non-premium user(s)", 5, "info")
				end)
				task.defer(function() if tog.Enabled then tog:Toggle() end end)
			end,
		})
	end)

	-- ===== Boot notification =====
	if getgenv()._NEPTUNE_ACTIVE and shared.vape and shared.vape.CreateNotification then
		task.defer(function()
			task.wait(1)
			shared.vape:CreateNotification(
				(getgenv()._NEPTUNE_LIFETIME and "PREMIUM" or "REGULAR"),
				"welcome back — " .. fmtRemaining() .. " left", 6, "info")
		end)
	end
end


do
	getgenv()._aeroTierReady = true
	getgenv().getAeroTier = function() return 0 end
	getgenv().getAccountTier = function() return 0 end
	getgenv()._aeroInjectedUsers = {}
end

-- canDebug detection: true if executor has full debug library (debug.getconstant + debug.getproto)
-- and isn't a known weak exec. Used by bedwars/main.luau to decide whether to use real `require`
-- or fall back to a cached cheatenginelib (which we no longer ship — engine.luau was Luraph-obf'd).
getgenv().canDebug = (function()
	local exec = identifyexecutor and ({identifyexecutor()})[1] or ''
	if exec == 'Xeno' or exec == 'Solara' then return false end
	if not (debug and debug.getconstant and debug.getproto) then return false end
	return true
end)()


if getgenv().Closet then
	local LogService = cloneref(game:GetService('LogService'))
	local originals = {}
	local function hook(funcName)
		if typeof(getgenv()[funcName]) == 'function' then
			local original = hookfunction(getgenv()[funcName], function() end)
			originals[funcName] = original
		end
	end
	hook('print')
	hook('warn')
	hook('error')
	hook('info')
	pcall(function() LogService:ClearOutput() end)
	local conn = LogService.MessageOut:Connect(function()
		LogService:ClearOutput()
	end)
	getgenv()._vape_log_connection = conn
	getgenv()._vape_originals = originals
end

if not shared.VapeIndependent then
	local _argv = {...}
	loadstring(downloadFile('neptune/games/universal.lua'), 'universal')()

	-- Aero-exact loader logic. See poopparty/poopparty/main.lua line 535:
	-- one file per place ID. For bedwars (GameId 2619619496) we collapse
	-- the lobby to 6872265039 and every match instance to 6872274481. For
	-- any other game we use game.PlaceId directly. No supported.json
	-- manifest, no per-game subfolders.
	local gameFileId = (game.GameId == 2619619496)
		and ((game.PlaceId == 6872265039) and 6872265039 or 6872274481)
		or game.PlaceId
	vape.Place = gameFileId
	if isfile('neptune/games/' .. gameFileId .. '.lua') then
		loadstring(downloadFile('neptune/games/' .. gameFileId .. '.lua'), tostring(gameFileId))((table.unpack or unpack)(_argv))
	elseif not shared.VapeDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/UdAxol/Neptune/' .. readfile('neptune/profiles/commit.txt') .. '/games/' .. gameFileId .. '.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('neptune/games/' .. gameFileId .. '.lua'), tostring(gameFileId))((table.unpack or unpack)(_argv))
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
