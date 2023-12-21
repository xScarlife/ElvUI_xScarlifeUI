local E, _, V = unpack(ElvUI)
local PI = E.PluginInstaller
local EP = E.Libs.EP
local D = E.Distributor
local AS = E:IsAddOnEnabled('AddOnSkins') and unpack(AddOnSkins)

local AddOnName, Engine = ...
xScarlifeCharDB = xScarlifeCharDB or {}

Engine.Options = {}
local function GetOptions()
	for _, func in pairs(Engine.Options) do
		func()
	end
end

--* Check if AddOnSkins is enabled and if the Embed system is enabled
function Engine:ASEmbedEnabled()
	return (AS and (AS:CheckOption('EmbedSystem') or AS:CheckOption('EmbedSystemDual'))) and true or false
end

local function Initialize()
	xScarlifeCharDB.ASEmbedEnabled = Engine:ASEmbedEnabled()

	if not xScarlifeCharDB.install_complete then
		PI:Queue(Engine.InstallerData)
	end

	EP:RegisterPlugin(AddOnName, GetOptions)
end

EP:HookInitialize(AddOnName, Initialize)
