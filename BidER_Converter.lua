#!/usr/bin/env lua

require('BidER')
require('GRSS_Data')

local dkpset = "official"
local pointfile = "points.txt"
local lootfile = "loots.txt"
if arg[1] ~= nil then
  pointfile = arg[1]
end
if arg[2] ~= nil then
  lootfile = arg[2]
end
if arg[3] ~= nil then
  dkpset = arg[3]
end

GRSS_Initialize_Data()

local function GetNames(tab)
  local out = ""
  for i,name in pairs(tab) do
    if out == "" then out = name
    else out = out .. ", " .. name end
  end
  return out
end

local dkp = BidER_DKP[dkpset]
local names = {}
for i,v in pairs(dkp) do
  table.insert(names, i)
end
table.sort(names)

file = io.open(pointfile, 'w+')
for i,v in ipairs(names) do
  -- Don't print out alt names
  if GRSS_Alts[v:lower()] == nil then
    file:write(v .. ": " .. dkp[v].total .. "\n")
  end
end
file:close()

file = io.open(lootfile, 'w+')
for i,raid in pairs(BidER_Raids) do
  file:write("Raid on " .. raid.zone .. " from ")
  file:write(os.date(nil, raid.start_time) .. " to " .. os.date(nil, raid.end_time))
  file:write("\n\n")
  local bosses = {}
  for boss,event in pairs(raid.events) do table.insert(bosses, boss) end
  table.sort(bosses, function(left, right)
    return raid.events[left].attempts[1].time < raid.events[right].attempts[1].time
  end)
  for j,boss in pairs(bosses) do
    local event = raid.events[boss]

    local names = {}
    for j=1, #event.attempts do
      names[j] = {}
    end

    local counts = {}
    local killed = {}
    for j,attempt in ipairs(event.attempts) do
      for k,name in ipairs(attempt.attendance) do
        if counts[name] == nil then counts[name] = 0 end
        counts[name] = counts[name] + 1
        if attempt.killed then
          table.insert(killed, name)
        end
      end
    end
    table.sort(killed)

    for name,count in pairs(counts) do
      table.insert(names[count], name)
      table.sort(names[count])
    end

    local out = ""
    file:write(boss .. ":\n")
    if #killed > 0 then
      file:write("    KILL - " .. GetNames(killed) .. " (" .. #killed .. ")\n")
    end
    for j=#names, 1, -1 do
      if #names[j] > 0 then
        file:write("    " .. j .. "x fight - " .. GetNames(names[j]) .. " (" .. #names[j] .. ")\n")
      end
    end
    file:write("\n")
    if event.loots then
      for j,loot in pairs(event.loots) do
        local item = loot.item:match("%[([^%]]+)%]")
        if loot.amount then
          file:write("     " .. loot.who .. ": [item]" .. item .. "[/item] (" .. loot.amount .. ")\n")
        else
          file:write("     DE: [item]" .. item .. "[/item]\n")
        end
      end
      file:write("\n")
    end
  end
end
file:close()
