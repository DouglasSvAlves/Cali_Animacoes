RegisterCommand(Config.Comando,function(source,args,rawCommand)
	TriggerClientEvent("caliemotes",source,args[1])
end)

RegisterServerEvent("Cali_animacoes:deletarObj")
AddEventHandler("Cali_animacoes:deletarObj",function(entIndex)
	TriggerClientEvent("Cali_animacoes:deletarObjeto",-1,entIndex)
end)