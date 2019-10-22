local modifier = 1.0
local modStart = 1.0
local modMax = 2.0
local modMin = 0.1

local jobs = {}
local contJobs = true

trackHealth = function()
  modifier = modStart
  lastHp = GetEntityHealth(GetPlayerPed(-1))
  while true do
    local plyPed = GetPlayerPed(-1)
    local plyHp  = GetEntityHealth(plyPed)
    if lastHp ~= plyHp then
      if lastHp < plyHp then
        local diff = plyHp - lastHp
        local mod = math.floor(diff * modifier)
        SetEntityHealth(plyPed, lastHp - mod)
        lastHp = lastHp - mod
      else
        lastHp = plyHp
      end
    end
    Wait(0)
  end
end

trackJobs = function()
  while true do
    if doAdd then
      table.insert(jobs,1,doAdd)
      doAdd = false
    else
      if (#jobs > 0) then
        if contJobs then
          jobActive = true
          local cur = jobs[1]
          if not cur.started then
            cur.started = GetGameTimer()
          else
            local time = GetGameTimer() - cur.started
            if time >= cur.time then
              if jobs[2] then
                table.remove(jobs,1)
              else
                modifier = modStart
              end
            else      
              if modifier ~= cur.mod then
                modifier = cur.mod
              end
            end
          end
        else
          jobs = {}
          contJobs = true
        end
      else
        jobActive = false
        contJobs = true
      end
    end
    Wait(0)
  end
end

addJob = function(mod,time)
  while doAdd do Wait(0); end
  doAdd = {mod = mod, time = (time * 1000)}
end
  
setModifier = function(mod,critical)
  if critical or not jobActive then
    if mod > modMax then mod = modMax; end
    if mod < modMin then mod = minMin; end
    contJobs = false
    modifier = mod
  end
end

RegisterNetEvent('healthFX:setModifier')
AddEventHandler('healthFX:setModifier',setModifier)

RegisterNetEvent('healthFX:addJob')
AddEventHandler('healthFX:addJob',addJob)

Citizen.CreateThread(trackHealth)
Citizen.CreateThread(trackJobs)
