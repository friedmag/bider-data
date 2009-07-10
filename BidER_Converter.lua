#!/usr/bin/env lua

require('BidER')

local dkpset = "official"
if arg[1] ~= nil then
  dkpset = arg[1]
end

local dkp = BidER_DKP[dkpset]
local names = {}
for i,v in pairs(dkp) do
  table.insert(names, i)
end
table.sort(names)
for i,v in ipairs(names) do
  -- Don't print out alt names
  if BidER_Aliases[v] == nil then
    print(v .. ": " .. dkp[v].total)
  end
end
