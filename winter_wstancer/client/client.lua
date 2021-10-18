local tuning = false
local checked = false
local width = {}
local wheelBones = {
	[0] = "wheel_lf",
	[1] = "wheel_rf",
	[2] = "wheel_lr",
	[3] = "wheel_rr"
}
local blackListClass = {
	[8]  = true,  -- Motorbikes
	[13] = true, -- Cycles
	[14] = true, -- Boats
	[15] = true, -- Helis
	[16] = true, -- Planes
	[21] = true -- Trains LMAO
}

Citizen.CreateThread(function()
	DecorRegister('wheelLF', 1)
	DecorRegister('wheelRF', 1)
	DecorRegister('wheelLR', 1)
	DecorRegister('wheelRR', 1)
end)



Citizen.CreateThread(function()
	local pId = nil
	local pIdVehicle = nil
	local pIdVehicleClass = nil
	while true do
		pId = PlayerPedId()
		if IsPedInAnyVehicle(pId, false) and isPedDriving(pId) then
			pIdVehicle = GetVehiclePedIsIn(pId, false)
			pIdVehicleClass = GetVehicleClass(pIdVehicle)
			if not blackListClass[pIdVehicleClass] and not tuning and not checked then
				checked = true
				width = {DecorGetFloat(pIdVehicle, "wheelLF"), DecorGetFloat(pIdVehicle, "wheelRF"), DecorGetFloat(pIdVehicle, "wheelLR"), DecorGetFloat(pIdVehicle, "wheelRR")}
				Citizen.Wait(100)
				updateWheels()
			end
		else
			checked = false
		end
		Citizen.Wait(200)
	end
end)

RegisterCommand("wheel", function()
	modifyWheels()
end, false)

function modifyWheels()
	local pIdVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local modified = false
	local wheel = 0
	local wheelPos = 0
	width = {GetVehicleWheelXOffset(pIdVehicle, 0), GetVehicleWheelXOffset(pIdVehicle, 1), GetVehicleWheelXOffset(pIdVehicle, 2), GetVehicleWheelXOffset(pIdVehicle, 3)}
	FreezeEntityPosition(pIdVehicle, true) -- Freeze vehicle at start so it does not reset wheels
	while not IsControlJustReleased(0, 38) do  -- Until you do not press the desired key Check Config for more it does not stop
		tuning = true
		SetVehicleEngineOn(pIdVehicle, false, true, false)  -- Turn engine of the vehicle off
		if IsControlJustPressed(0, 172) then  -- Advance on wheel list
			if wheel < 3 then
				wheel = wheel + 1
			end 
		elseif IsControlJustPressed(0, 173) then  -- Minus on wheel list 
			if wheel > 0 then
				wheel = wheel - 1
			end 	
		elseif IsControlJustPressed(0, 174) then  -- Push wheel left
			width[wheel + 1] = width[wheel + 1] - 0.01
			modified = true
		elseif IsControlJustPressed(0, 175) then  -- Push wheel right
			width[wheel + 1] = width[wheel + 1] + 0.01
			modified = true
		end
		wheelPos = GetEntityBonePosition_2(pIdVehicle, GetEntityBoneIndexByName(pIdVehicle, wheelBones[wheel]))  -- Gets coords for later on showing a marker
		DrawMarker(0, wheelPos.x, wheelPos.y, wheelPos.z + 1.0, 0, 0, 0, 0, 0, 0, 0.55, 0.55, 0.55, 35, 255, 0, 255, false, false) -- Draw a marker on top of the wheel to know the wheel we are working on.
		if modified then 
			SetVehicleWheelXOffset(pIdVehicle, wheel, width[wheel + 1])
		end 
		modified = false
		Citizen.Wait(0)
	end
	tuning = false
	DecorSetFloat(pIdVehicle, "wheelLF", width[1]) -- Setting the data we modified
	DecorSetFloat(pIdVehicle, "wheelRF", width[2]) -- Setting the data we modified
	DecorSetFloat(pIdVehicle, "wheelLR", width[3]) -- Setting the data we modified
	DecorSetFloat(pIdVehicle, "wheelRR", width[4]) -- Setting the data we modified
	SetVehicleEngineOn(pIdVehicle, true, true, false) -- Engine on again
	FreezeEntityPosition(pIdVehicle, false) -- Unfreeze
end

function updateWheels() -- If you dont constantly apply the properties, they reset to normal
	local count = 4
	local pId = PlayerPedId()
	local pIdVehicle = GetVehiclePedIsIn(pId, false)
	while IsPedInAnyVehicle(pId, false) do
		count = 4
		pId = PlayerPedId()
		pIdVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
		for k,v in pairs(width) do
			--print("width[k]", width[k])
			if width[k] ~= 0.0 then -- If width[k] == 0 then it has not been modified
				SetVehicleWheelXOffset(pIdVehicle, k - 1, width[k]) 
				count = count - 1 -- If the wheel is modified then substract
			end
		end
		if count == 4 then-- If none of the wheels have been modified then stop updating
			break
		end
		Citizen.Wait(0)
	end
end

function isPedDriving(pId)
	if GetPedInVehicleSeat(GetVehiclePedIsIn(pId, false), -1) == pId then
		return true
	else
		return false
	end
end