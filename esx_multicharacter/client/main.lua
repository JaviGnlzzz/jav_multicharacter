local mp_m_freemode_01 = `mp_m_freemode_01`
local mp_f_freemode_01 = `mp_f_freemode_01`

if ESX.GetConfig().Multichar then
	CreateThread(function()
		repeat Wait(800) until NetworkIsPlayerActive(PlayerId())
	
		exports.spawnmanager:setAutoSpawn(false)
		TriggerEvent("esx_multicharacter:SetupCharacters")
	end)

	local canRelog, cam, spawned = true, nil, nil
	local Characters =  {}
	local slots = {}

	RegisterNetEvent('esx_multicharacter:SetupCharacters')
	AddEventHandler('esx_multicharacter:SetupCharacters', function()
		ESX.PlayerLoaded = false
		ESX.PlayerData = {}
		spawned = false
		cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		local playerPed = PlayerPedId()
		SetEntityCoords(playerPed, Config.Spawn.x, Config.Spawn.y, Config.Spawn.z, true, false, false, false)
		SetEntityHeading(playerPed, Config.Spawn.w)
		local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.7, 0.4)
		SetCamActive(cam, true)
		RenderScriptCams(true, false, 1, true, true)
		SetCamCoord(cam, offset.x, offset.y, offset.z)
		PointCamAtCoord(cam, Config.Spawn.x, Config.Spawn.y, Config.Spawn.z + 1.3)
		StartLoop()
		ShutdownLoadingScreen()
		ShutdownLoadingScreenNui()
		TriggerEvent('esx:loadingScreenOff')
		Wait(200)
		TriggerServerEvent("esx_multicharacter:SetupCharacters")
	end)

	StartLoop = function()
		hidePlayers = true
		MumbleSetVolumeOverride(PlayerId(), 0.0)
		CreateThread(function()
			local keys = {18, 27, 172, 173, 174, 175, 176, 177, 187, 188, 191, 201, 108, 109}
			while hidePlayers do
				DisableAllControlActions(0)
				for i = 1, #keys do
					EnableControlAction(0, keys[i], true)
				end
				SetEntityVisible(PlayerPedId(), 0, 0)
				SetLocalPlayerVisibleLocally(1)
				SetPlayerInvincible(PlayerId(), 1)
				ThefeedHideThisFrame()
				HideHudComponentThisFrame(11)
				HideHudComponentThisFrame(12)
				HideHudComponentThisFrame(21)
				HideHudAndRadarThisFrame()
				Wait(0)
				local vehicles = GetGamePool('CVehicle')
				for i = 1, #vehicles do
					SetEntityLocallyInvisible(vehicles[i])
				end
			end
			local playerId, playerPed = PlayerId(), PlayerPedId()
			MumbleSetVolumeOverride(playerId, -1.0)
			SetEntityVisible(playerPed, 1, 0)
			SetPlayerInvincible(playerId, 0)
			FreezeEntityPosition(playerPed, false)
			Wait(10000)
			canRelog = true
		end)
		CreateThread(function()
			local playerPool = {}
			while hidePlayers do
				local players = GetActivePlayers()
				for i = 1, #players do
					local player = players[i]
					if player ~= PlayerId() and not playerPool[player] then
						playerPool[player] = true
						NetworkConcealPlayer(player, true, true)
					end
				end
				Wait(500)
			end
			for k in pairs(playerPool) do
				NetworkConcealPlayer(k, false, false)
			end
		end)
	end

	SetupCharacter = function(index)
		if (spawned == false) then
			
			SendNUIMessage({
				type = 'loading:multicharacter'
			})

			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = Characters[index].model or mp_m_freemode_01,
				skipFade = true
			}, function()

				canRelog = false
				if Characters[index] then
					local skin = Characters[index].skin or Config.Default
					if not Characters[index].model then
						if Characters[index].sex == TranslateCap('female') then skin.sex = 1 else skin.sex = 0 end
					end
					TriggerEvent('skinchanger:loadSkin', skin)
				end
			end)

			DoScreenFadeIn(600)
		repeat Wait(200) until not IsScreenFadedOut()

		elseif Characters[index] and Characters[index].skin then
			if Characters[spawned] and Characters[spawned].model then
				RequestModel(Characters[index].model)
				while not HasModelLoaded(Characters[index].model) do
					RequestModel(Characters[index].model)
					Wait(0)
				end
				SetPlayerModel(PlayerId(), Characters[index].model)
				SetModelAsNoLongerNeeded(Characters[index].model)
			end
			TriggerEvent('skinchanger:loadSkin', Characters[index].skin)
		end

		spawned = index
		local playerPed = PlayerPedId()
		FreezeEntityPosition(PlayerPedId(), true)
		SetPedAoBlobRendering(playerPed, true)
		SetEntityAlpha(playerPed, 255)

		Wait(4000)

		SetNuiFocus(true, true)

		SendNUIMessage({
			action = 'open:multicharacter',
			characters = Characters,
			can_add = Config.Can_Add,
		})

	end

	function SelectCharacterMenu(characters, slots)

		local first_id = nil

		for k,v in pairs(characters) do
			first_id = v.id
			break
		end

		Characters = characters

		SetupCharacter(first_id)

	end

	RegisterNUICallback('select_character', function(data, cb)
		ClearPedTasksImmediately(PlayerPedId())
		local animations = Config.Animations[math.random(1, #Config.Animations)]
		TriggerEvent('skinchanger:loadSkin', Characters[data.id].skin)
		Wait(400)
		Anim(animations)
	end)

	RegisterNUICallback('new_character', function()
		local slot = #Characters + 1

		TriggerServerEvent('esx_multicharacter:CharacterChosen', slot, true)
		TriggerEvent('esx_identity:showRegisterIdentity')

		local playerPed = PlayerPedId()
		SetPedAoBlobRendering(playerPed, false)
		SetEntityAlpha(playerPed, 0)

		SetNuiFocus(false, false)

		SendNUIMessage({
			action = "close:multicharacter"
		})
	end)

	RegisterNUICallback('enter_game', function(data)
		SetNuiFocus(false, false)
		SendNUIMessage({
			action = "close:multicharacter"
		})

		TriggerServerEvent('esx_multicharacter:CharacterChosen', data.id, false)
	end)

	RegisterNetEvent('esx_multicharacter:SetupUI')
	AddEventHandler('esx_multicharacter:SetupUI', function(data, slots)
		Characters = data
		slots = slots
		local Character = next(Characters)
		exports.spawnmanager:forceRespawn()

		if (not Character) then
			exports.spawnmanager:spawnPlayer({
				x = Config.Spawn.x,
				y = Config.Spawn.y,
				z = Config.Spawn.z,
				heading = Config.Spawn.w,
				model = mp_m_freemode_01,
				skipFade = true
			}, function()
				canRelog = false
				Wait(400)
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, false)
				SetEntityAlpha(playerPed, 0)
				TriggerServerEvent('esx_multicharacter:CharacterChosen', 1, true)
				TriggerEvent('esx_identity:showRegisterIdentity')
			end)
		else
			SelectCharacterMenu(Characters, slots)
		end
	end)

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(playerData, isNew, skin)
		local spawn = playerData.coords or Config.Spawn
		if isNew or not skin or #skin == 1 then
			local finished = false
			skin = Config.Default[playerData.sex]
			skin.sex = playerData.sex == "m" and 0 or 1
			local model = skin.sex == 0 and mp_m_freemode_01 or mp_f_freemode_01
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(0)
			end
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
			TriggerEvent('skinchanger:loadSkin', skin, function()
				local playerPed = PlayerPedId()
				SetPedAoBlobRendering(playerPed, true)
				ResetEntityAlpha(playerPed)
				TriggerEvent('esx_skin:openSaveableMenu', function()
					finished = true end, function() finished = true
				end)
			end)
			repeat Wait(200) until finished
		end
		DoScreenFadeOut(100)

		SetCamActive(cam, false)
		RenderScriptCams(false, false, 0, true, true)
		cam = nil
		local playerPed = PlayerPedId()
		FreezeEntityPosition(playerPed, true)
		SetEntityCoordsNoOffset(playerPed, spawn.x, spawn.y, spawn.z, false, false, false, true)
		SetEntityHeading(playerPed, spawn.heading)
		if not isNew then TriggerEvent('skinchanger:loadSkin', skin or Characters[spawned].skin) end
		Wait(400)
		DoScreenFadeIn(400)
		repeat Wait(200) until not IsScreenFadedOut()
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('playerSpawned')
		TriggerEvent('esx:restoreLoadout')
		Characters, hidePlayers = {}, false
		DoScreenFadeIn(400)
	end)

	RegisterNetEvent('esx:onPlayerLogout')
	AddEventHandler('esx:onPlayerLogout', function()
		DoScreenFadeOut(500)
		Wait(1000)
		spawned = false
		TriggerEvent("esx_multicharacter:SetupCharacters")
		TriggerEvent('esx_skin:resetFirstSpawn')
	end)

	function Anim(anims)
		RequestAnimDict(anims.dict)
		while not HasAnimDictLoaded(anims.dict) do
			Wait(7)
		end
		TaskPlayAnim(PlayerPedId(), anims.dict, anims.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
	end

end
