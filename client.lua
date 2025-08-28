local object = nil
local animFlags = 0
local animActived = false
local animDict = nil
local animName = nil

RegisterNetEvent("caliemotes")
AddEventHandler("caliemotes",function(nome) 
    local ped = PlayerPedId()
	for _,emote in pairs(Config.animacoes) do 
		if nome == emote.nome then
			if emote.nome and not IsPedArmed(ped,6) and not IsPedSwimming(ped) then
				removeObjects("one")
				if not IsPedInAnyVehicle(ped) then
					if emote.altura and emote.anim == nil then
						createObjects("","",emote.prop, emote.flag, emote.mao, emote.altura, emote.pos1, emote.pos2, emote.pos3, emote.pos4, emote.pos5)
					elseif emote.altura and emote.anim then
						createObjects(emote.dict, emote.anim, emote.prop, emote.flag, emote.mao, emote.altura, emote.pos1, emote.pos2, emote.pos3, emote.pos4, emote.pos5)
					elseif emote.prop then
						createObjects(emote.dict, emote.anim, emote.prop, emote.flag, emote.mao)
					elseif emote.dict then
						playAnim(emote.andar, {emote.dict, emote.anim}, emote.loop)
					else
						playAnim(false,{ task = emote.anim },false)
					end
				end
			end
		end
	end
end)

function loadAnimSet(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

function playAnim(animUpper,animSequency,animLoop)
	local playFlags = 0
	local ped = PlayerPedId()
	if animSequency["task"] then
		stopAnim(true)

		if animSequency["task"] == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then
			local coords = GetEntityCoords(ped)
			TaskStartScenarioAtPosition(ped,animSequency["task"],coords["x"],coords["y"],coords["z"] - 1,GetEntityHeading(ped),0,0,false)
		else
			TaskStartScenarioInPlace(ped,animSequency["task"],0,false)
		end
	else
		stopAnim(animUpper)

		if animUpper then
			playFlags = playFlags + 48
		end

		if animLoop then
			playFlags = playFlags + 1
		end

		Citizen.CreateThread(function()
			RequestAnimDict(animSequency[1])
			while not HasAnimDictLoaded(animSequency[1]) do
				Citizen.Wait(1)
			end

			if HasAnimDictLoaded(animSequency[1]) then
				animDict = animSequency[1]
				animName = animSequency[2]
				animFlags = playFlags

				if playFlags == 49 then
					animActived = true
				end

				TaskPlayAnim(ped,animSequency[1],animSequency[2],3.0,3.0,-1,playFlags,0,0,0,0)
			end
		end)
	end
end

function stopAnim(animUpper)
	animActived = false
	local ped = PlayerPedId()

	if animUpper then
		ClearPedSecondaryTask(ped)
	else
		ClearPedTasks(ped)
	end
end

function createObjects(dict,anim,prop,flag,mao,altura,pos1,pos2,pos3,pos4,pos5)
	if DoesEntityExist(object) then
		TriggerServerEvent("Cali_animacoes:deletarObj",NetworkGetNetworkIdFromEntity(object))
		object = nil
	end

	local ped = PlayerPedId()
	local mHash = GetHashKey(prop)

	RequestModel(mHash)
	while not HasModelLoaded(mHash) do
		Citizen.Wait(1)
	end

	if HasModelLoaded(mHash) then
		if anim ~= "" then
			loadAnimSet(dict)
			TaskPlayAnim(ped,dict,anim,3.0,3.0,-1,flag,0,0,0,0)
		end

		if altura then
			local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
			object = CreateObject(mHash,coords["x"],coords["y"],coords["z"],true,true,false)
			AttachEntityToEntity(object,ped,GetPedBoneIndex(ped,mao),altura,pos1,pos2,pos3,pos4,pos5,true,true,false,true,1,true)
		else
			local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
			object = CreateObject(mHash,coords["x"],coords["y"],coords["z"],true,true,false)
			AttachEntityToEntity(object,ped,GetPedBoneIndex(ped,mao),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
		end

		SetEntityAsMissionEntity(object,true,true)
		SetEntityAsNoLongerNeeded(object)
		SetModelAsNoLongerNeeded(mHash)

		animActived = true
		animFlags = flag
		animDict = dict
		animName = anim
	end
end

function removeObjects()
	stopAnim(true)
	animActived = false
	if DoesEntityExist(object) then
		TriggerServerEvent("Cali_animacoes:deletarObj",NetworkGetNetworkIdFromEntity(object))
		object = nil
	end
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		if animActived then
			if not IsEntityPlayingAnim(ped,animDict,animName,3) then
				TaskPlayAnim(ped,animDict,animName,3.0,3.0,-1,animFlags,0,0,0,0)
				timeDistance = 1
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local ped = GetPlayerPed(-1)
		if IsControlJustPressed(1,Config.Cancelar) then
			removeObjects()
			stopAnim(false)
		end
	end
end)

RegisterNetEvent("Cali_animacoes:deletarObjeto")
AddEventHandler("Cali_animacoes:deletarObjeto",function(entIndex)
	if NetworkDoesNetworkIdExist(entIndex) then
		local v = NetToEnt(entIndex)
		if DoesEntityExist(v) then
			SetEntityAsMissionEntity(v,false,false)
			DeleteEntity(v)
		end
	end
end)