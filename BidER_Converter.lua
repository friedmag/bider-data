#!/usr/bin/env lua

require('BidER')

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

local dkp = BidER_DKP[dkpset]
local names = {}
for i,v in pairs(dkp) do
  table.insert(names, i)
end
table.sort(names)

file = io.open(pointfile, 'w+')
for i,v in ipairs(names) do
  -- Don't print out alt names
  if BidER_Aliases[v] == nil then
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
    return raid.events[left].attempts[1] < raid.events[right].attempts[1]
  end)
  for j,boss in pairs(bosses) do
    local event = raid.events[boss]
    local names = {}
    for j,name in ipairs(event.attendance) do
      table.insert(names, name)
    end
    table.sort(names)
    local out = ""
    for j,name in pairs(names) do
      if out == "" then out = name
      else out = out .. ", " .. name end
    end
    file:write(boss .. ": " .. out .. " (" .. #names .. ")\n")
    for j,attempt in ipairs(event.attempts) do
      file:write("     " .. os.date(nil, attempt) .. "\n")
    end
    if event.killed then
      file:write("     KILLED\n")
    end
    file:write("\n")
    if event.loots then
      for j,loot in pairs(event.loots) do
        local item = loot.item:match("%[([^%]]+)%]")
        file:write("     " .. loot.who .. ": [item]" .. item .. "[/item] (" .. loot.amount .. ")\n")
      end
      file:write("\n")
    end
  end
end
file:close()
