ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem('wytrych', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	TriggerClientEvent('fun-picklock:lockpick:start', xPlayer.source)
end)

RegisterServerEvent('fun-lockpick:remove')
AddEventHandler('fun-lockpick:remove', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer ~= nil then
		local item = 'picklock' 
		
		if xPlayer.getInventoryItem(item) and xPlayer.getInventoryItem(item).count > 0 then
			xPlayer.removeInventoryItem(item, 1)
		end
	end
end)
