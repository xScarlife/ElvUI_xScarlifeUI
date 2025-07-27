local E, L, V, P, G = unpack(ElvUI)
local ACH = E.Libs.ACH
local PI = E.PluginInstaller
local AddOnName, Engine = ...

local tconcat, sort = table.concat, sort
local config = Engine.Config

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end
sort(config.Credits, SortList)
local CREDITS_STRING = tconcat(config.Credits, '|n')

local function configTable()
	local options = ACH:Group(config.Title, nil, 99, 'tab')
	E.Options.args.xScarlifeUI = options

	local Help = ACH:Group(L["Help"], nil, 99)
	options.args.help = Help
	options.args.header = ACH:Header(format('|cff99ff33%s|r', config.Version), 2)
	options.args.logo = ACH:Description('', 1, nil, Engine.Config, imageCoords, 160, 160, width, hidden)

	Help.args.installButton = ACH:Execute(L["Install"], L["Re-Run the installation process."], 5, function() PI:Queue(Engine.InstallerData) E:ToggleOptions() end)

	for k, v in next, Engine.InstallerData.StepTitles do
		if k > 1 and k < #Engine.InstallerData.StepTitles then
			Help.args['step'..k] = ACH:Group(v, nil, k+10)
			Help.args['step'..k].inline = true
		end
	end

	Help.args.step2.args.button1 = ACH:Execute(Engine:GetProfileButtonText('PROFILE'), L["Re-Run step 2 of the installation process."], 1, function() Engine:SetupProfile(E.Retail and 'PROFILE1' or 'PROFILE2') end, nil, nil, nil, nil, nil, not Engine:GetProfileButtonState('PROFILE', true))
	Help.args.step3.args.button1 = ACH:Execute(Engine:GetProfileButtonText('PRIVATE'), L["Re-Run step 3 of the installation process."], 1, function() local profile = E.Retail and Engine.ProfileData.ElvUI.PRIVATE1 or Engine.ProfileData.ElvUI.PRIVATE2 local profileName = E.Retail and Engine.ProfileData.ElvUI.PRIVATE1NAME or Engine.ProfileData.ElvUI.PRIVATE2NAME E:StaticPopup_Show('XSCARLIFE_IMPORT_PRIVATE_PROFILE_OVERWRITE', nil, nil, {ProfileString = profile, ProfileName = profileName}) end, nil, nil, nil, nil, nil, not Engine:GetProfileButtonState('PRIVATE', true))
	Help.args.step4.args.button1 = ACH:Execute(L["Setup Details"], L["Re-Run Details setup part of the installation process."], 1, function() if not E:IsAddOnEnabled('Details') then return end xScarlifeCharDB.DetailsStepNeeded = nil Engine:SetupDetails() end, nil, nil, nil, nil, nil, not (E:IsAddOnEnabled('Details') and not xScarlifeCharDB.ASEmbedEnabled))
	Help.args.step4.args.button2 = ACH:Execute('Fix Conflict', 'Disables AddOnSkins embed system and reloads the UI so you can continue setting up the details profile.', 2, function() if E:IsAddOnEnabled('Details') then xScarlifeCharDB.DetailsStepNeeded = true xScarlifeCharDB.ASEmbedEnabled = false AS:SetOption('EmbedSystem', false) AS:SetOption('EmbedSystemDual', false) ReloadUI() end end, nil, nil, nil, nil, nil, not (E:IsAddOnEnabled('Details') and xScarlifeCharDB.ASEmbedEnabled))
	Help.args.step5.args.button1 = ACH:Execute(L["Setup OmniCD"], format(L["Re-Run %s setup part of the installation process."], 'OmniCD'), 1, function() if not E:IsAddOnEnabled('OmniCD') then return end Engine:SetupOmniCD() end, nil, nil, nil, nil, nil, not (E:IsAddOnEnabled('OmniCD')))
	Help.args.step6.args.button1 = ACH:Execute('Setup |cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r', L["Re-Run |cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r setup part of the installation process."], 1, function() Engine:SetupWindTools() end, nil, nil, nil, nil, nil, not (E:IsAddOnEnabled('ElvUI_WindTools') and E.Retail))
	Help.args.step7.args.button1 = ACH:Execute('Setup BigWigs', format(L["Re-Run %s setup part of the installation process."], 'BigWigs'), 1, function() if not E:IsAddOnEnabled('BigWigs') then return end Engine:SetupBigWigs() end, nil, nil, nil, nil, nil, not (E:IsAddOnEnabled('BigWigs')))

	local credits = ACH:Group(L["Credits"], nil, 99)
	Help.args.credits = credits
	credits.inline = true

	credits.args.string = ACH:Description(CREDITS_STRING, 1, 'medium')
end

tinsert(Engine.Options, configTable)
