local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function get(url)
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	return success and result or nil
end

-- Получение ника игрока
local username = Players.LocalPlayer.Name

-- Загрузка данных о подписке
local playersData = get("https://raw.githubusercontent.com/d1pfyx/StockScript/refs/heads/main/libary/data/Players.json")
if not playersData then
	warn("Ошибка загрузки Players.json")
	return
end

local playersDecoded = HttpService:JSONDecode(playersData)
local userInfo = playersDecoded[username]

if not userInfo or userInfo["active"] ~= true then
	print("Купите подписку")
	return
end

local uuid = tostring(userInfo["uuid"])
local subscriptionData = get("https://raw.githubusercontent.com/d1pfyx/StockScript/refs/heads/main/libary/data/Data.json")
if not subscriptionData then
	warn("Ошибка загрузки Data.json")
	return
end

local subscriptionDecoded = HttpService:JSONDecode(subscriptionData)
local subInfo = subscriptionDecoded[uuid]

if not subInfo then
	print("Купите подписку")
	return
end

-- Проверка срока действия подписки
local function isSubscriptionValid(dateStr, timeStr)
	local targetDateTime = DateTime.fromIsoDate(dateStr .. "T" .. timeStr .. "+03:00")
	return DateTime.now():ToUniversalTime():UnixTimestamp < targetDateTime:ToUniversalTime():UnixTimestamp
end

local isValid = isSubscriptionValid(subInfo["date"], subInfo["time"])

if not isValid then
	print("Купите подписку")
	return
end

-- Выполнение второго скрипта
local secondScript = get("https://raw.githubusercontent.com/d1pfyx/StockScript/refs/heads/main/script.lua")
if secondScript then
	loadstring(secondScript)()
else
	warn("Не удалось загрузить основной скрипт")
end
