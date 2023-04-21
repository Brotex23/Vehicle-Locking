ESX = exports["es_extended"]:getSharedObject()

local isRunningWorkaround = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)
		Citizen.Wait(1000)	
		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

function ToggleVehicleLock()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle
	Citizen.Wait(300)	
	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('esx_vehiclelock:requestPlayerCars', function(isOwnedVehicle)

		if isOwnedVehicle then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)
			if lockStatus == 1 then -- unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				if Config.okokNotify then
					exports['okokNotify']:Alert("Vehicle", "Locked", 3000, 'info')
				elseif Config.DefaultNotify then
				 	ESX.ShowNotification('Vozilo zakljucano')
				elseif Config.Mythic then 
					exports['mythic_notify']:DoHudText('inform', 'Vozilo zakljucano')	 
				end	
			elseif lockStatus == 2 then -- locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				if Config.okokNotify then
					exports['okokNotify']:Alert("Vehicle", "", 3000, 'info')
				elseif Config.DefaultNotify then
					ESX.ShowNotification('Vozilo zakljucano')	
				elseif Config.Mythic then
					exports['mythic_notify']:DoHudText('inform', 'Vozilo zakljucano')	
				end	
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

if Config.qtarget then
	AddEventHandler('brotex:vehiclelock', function(data)
		ToggleVehicleLock()
	end)

	exports.qtarget:Vehicle({
		options = {
			{
				event = "brotex:vehiclelock",
				icon = "fas fa-lock",
				label = "Lock/Unlock",
				num = 1 
			},
		},
		distance = 2
	})
end

if Config.default then
	RegisterKeyMapping('vehlock', 'locking the car', 'keyboard', 'U')
	RegisterCommand('vehlock', function()
	ToggleVehicleLock()
	end)
end	