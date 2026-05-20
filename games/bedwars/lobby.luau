-- Neptune bedwars LOBBY entry — forwards to bedwars/main.luau so the
-- player gets the SAME full module set in the lobby as in a match.
-- The upstream lobby file deliberately stripped Combat + Minigames
-- modules and only added Sprint/AutoGamble; Neptune treats every
-- bedwars place ID as equivalent so the same merged script (universal
-- + aero + catv6 + addon, deduped via the merge-aware CreateModule
-- patch) loads in either context. Bedwars-game-specific modules that
-- don't have valid state in the lobby just no-op via pcall — they
-- still appear in the GUI and become live when the player enters a
-- match.
local _argv = {...}
local _commit = 'main'
do
    local ok, c = pcall(function() return readfile('neptune/profiles/commit.txt') end)
    if ok and type(c) == 'string' and #c > 0 then _commit = c end
end
local _src
do
    local ok, body = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/UdAxol/Neptune/' .. _commit .. '/games/bedwars/main.luau', true)
    end)
    if not ok or type(body) ~= 'string' then
        warn('[NEPTUNE-LOBBY] failed to fetch bedwars/main.luau: ' .. tostring(body))
        return
    end
    _src = body
end
local _fn, _err = loadstring(_src, 'bedwars-lobby')
if not _fn then
    warn('[NEPTUNE-LOBBY] loadstring failed: ' .. tostring(_err))
    return
end
warn('[NEPTUNE-LOBBY] redirecting to bedwars/main.luau (argv=' .. tostring(#_argv) .. ')')
_fn((table.unpack or unpack)(_argv))
