local QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Server:UpdateObject', function() if source ~= '' then return false end QBCore = exports['qb-core']:GetCoreObject() end)

AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end
	for k in pairs(Config.Prices) do if not QBCore.Shared.Items[k] then print("^5Debug^7: ^6Prices^7: ^2Missing Item from ^4QBCore^7.^4Shared^7.^4Items^7: '^6"..k.."^7'") end end
	if not QBCore.Shared.Items["recyclablematerial"] then print("^5Debug^7: ^2Missing Item from ^4QBCore^7.^4Shared^7.^4Items^7: '^6recyclablematerial^7'") end
end)

QBCore.Functions.CreateCallback('jim-recycle:GetRecyclable', function(source, cb)
	if QBCore.Functions.GetPlayer(source).Functions.GetItemByName("recyclablematerial") then cb(QBCore.Functions.GetPlayer(source).Functions.GetItemByName("recyclablematerial").amount)
	else cb(0) end
end)

QBCore.Functions.CreateCallback('jim-recycle:GetCash', function(source, cb)	cb(QBCore.Functions.GetPlayer(source).Functions.GetMoney("cash")) end)
RegisterServerEvent("jim-recycle:DoorCharge", function() QBCore.Functions.GetPlayer(source).Functions.RemoveMoney("cash", Config.PayAtDoor) end)

--- Event For Getting Recyclable Material----
RegisterServerEvent("jim-recycle:getrecyclablematerial", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = math.random(Config.RecycleAmounts.recycleMin, Config.RecycleAmounts.recycleMax)
    Player.Functions.AddItem("recyclablematerial", amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["recyclablematerial"], 'add', amount)
    Wait(500)
end)

RegisterServerEvent("jim-recycle:TradeItems", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local remAmount, min, max
	if data == 1 then
		remAmount = 1
		itemAmount = 1
		min = 1
		max = 1
	elseif data == 2 then
		remAmount = 10
		itemAmount = 2
		min = Config.RecycleAmounts.tenMin
		max = Config.RecycleAmounts.tenMax
	elseif data == 3 then
		remAmount = 100
		itemAmount = 6
		min = Config.RecycleAmounts.hundMin
		max = Config.RecycleAmounts.hundMax
	elseif data == 4 then
		remAmount = 1000
		itemAmount = 8
		min = Config.RecycleAmounts.thouMin
		max = Config.RecycleAmounts.thouMax
	end
	Player.Functions.RemoveItem("recyclablematerial", remAmount)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["recyclablematerial"], 'remove', remAmount)
	Wait(1000)
	for i = 1, itemAmount do
		randItem = Config.TradeTable[math.random(1, #Config.TradeTable)]
		local amount = math.random(min, max)
		Player.Functions.AddItem(randItem, amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add', amount)
	end
end)

RegisterNetEvent("jim-recycle:Selling:Mat", function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item) ~= nil then
        local amount = Player.Functions.GetItemByName(item).amount
        local pay = (amount * Config.Prices[item])
        Player.Functions.RemoveItem(item, amount)
        Player.Functions.AddMoney('cash', pay)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
        TriggerClientEvent("QBCore:Notify", src, "Payment received. Total: $"..pay, "success")
    end
end)

RegisterNetEvent('jim-recycle:server:toggleItem', function(give, item, amount)
	local src = source
	if give == 0 or give == false then
		if QBCore.Functions.HasItem(src, item, amount or 1) then -- check if you still have the item
			if QBCore.Functions.GetPlayer(src).Functions.RemoveItem(item, amount or 1) then
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", amount or 1)
			end
		else TriggerEvent("jim-recycle:server:DupeWarn", item, src) end -- if not boot the player
	else
		if QBCore.Functions.GetPlayer(src).Functions.AddItem(item, amount or 1) then
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amount or 1)
		end
	end
end)

RegisterNetEvent("jim-recycle:server:DupeWarn", function(item, newsrc)
	local src = newsrc or source
	local P = QBCore.Functions.GetPlayer(src)
	print("^5DupeWarn: ^1"..P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname.."^7(^1"..tostring(src).."^7) ^2Tried to remove item ^7('^3"..item.."^7')^2 but it wasn't there^7")
	DropPlayer(src, "Kicked for attempting to duplicate items")
	print("^5DupeWarn: ^1"..P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname.."^7(^1"..tostring(src).."^7) ^2Dropped from server for item duplicating^7")
end)
