--- @diagnostic disable

local area = minetest.settings:get("rtp_area") or 500
local interval = minetest.settings:get("rtp_cooldown") or 15

local mcl = rawget(_G, "mcl_vars")

local c = minetest.colorize
local cooldown = {}
minetest.register_chatcommand("rtp", {
    description = "Brings you to a random world position",
    privs = {interact = true},
    param = "[<playername>]",
    func = function(name, param)
        if not minetest.get_player_by_name(name) then return end
        local victim
        if not param or param == "" or not minetest.check_player_privs(name, {bring = true}) then
            if cooldown[name] then 
                return false, ("%s %s %s"):format(c("orange", "Rtp -!- You will be able to rtp again in"),
                c("cyan", interval-math.abs(os.difftime(os.time(), cooldown[name]))), c("orange", "seconds!"))
            end
            if mcl then mcl_hunger.set_hunger(minetest.get_player_by_name(name), mcl_hunger.get_hunger(minetest.get_player_by_name(name)) - 8) end
            victim = name
            cooldown[name] = os.time()
            minetest.after(interval, function() cooldown[name] = nil end)
        else
            if not minetest.get_player_by_name(param) then 
                return false, ("%s %s %s"):format(c("orange", "Rtp -!- Player"), c("cyan", param), 
                c("orange", "is not online!"))
            end
            victim = param
            return true, ("%s %s %s"):format(c("orange", "Rtp -!- Player"), c("cyan", param), 
            c("orange", "was successfully teleported!"))
        end
        local pos = {}
        while not pos.y do
            pos = {x = math.random(-area, area), z = math.random(-area, area), y = 0} 
            pos.y = minetest.get_spawn_level(pos.x, pos.z)
        end
        minetest.emerge_area(pos, {pos.x, pos.z, pos.y + 2})
        minetest.get_player_by_name(victim):set_pos(pos)
        minetest.chat_send_player(victim, ("%s %s"):format(c("orange", "Rtp -!- You were teleported to"), 
        c("cyan", vector.to_string(pos))))
    end
})