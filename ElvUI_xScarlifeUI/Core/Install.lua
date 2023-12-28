local E, L = unpack(ElvUI)
local AddOnName, Engine = ...
local D = E.Distributor
local PI = E.PluginInstaller
local AS = E:IsAddOnEnabled('AddOnSkins') and unpack(AddOnSkins)

local config = Engine.Config
local acceptedTerms = false
local acceptDisplayString = '%s %s'
local checked = '[|TInterface\\AddOns\\'..AddOnName..'\\Media\\Textures\\check:0|t]'
local cross = '[|TInterface\\AddOns\\'..AddOnName..'\\Media\\Textures\\cross:0|t]'
local hexElvUIBlue = '|cff1785d1'

local function TermsButtonText()
	return format(acceptDisplayString, acceptedTerms and checked or cross, acceptedTerms and L["I wish to continue!"] or L["|cffFF0000CLICK|r to continue!"])
end

function Engine:GetProfileButtonText(profileType)
	if not profileType then E:Print('Invalid configuration for the GetProfileButtonText function.') return 'Error!' end
	local profileName = (E.Retail and Engine.ProfileData.ElvUI[profileType..'1NAME']) or (not E.Retail and Engine.ProfileData.ElvUI[profileType..'2NAME'])
	return (profileName ~= '' and profileName) or 'Coming Soon™'
end

function Engine:GetProfileButtonState(profileType, overrideTerm)
	if not profileType then E:Print('Invalid configuration for the GetProfileButtonState function.') return false end
	local profileString = (E.Retail and Engine.ProfileData.ElvUI[profileType..'1']) or (not E.Retail and Engine.ProfileData.ElvUI[profileType..'2'])
	local profileName = (E.Retail and Engine.ProfileData.ElvUI[profileType..'1NAME']) or (not E.Retail and Engine.ProfileData.ElvUI[profileType..'2NAME'])

	return (overrideTerm or acceptedTerms) and not (profileString == '' or profileString == nil or profileName == '' or profileName == nil)
end

local function GetWindToolsDesc3Text()
	if E.Retail then
		return not E:IsAddOnEnabled('ElvUI_WindTools') and '|cffFF3333WARNING:|r WindTools is not enabled to configure.' or ''
	elseif not E.Retail then
		return '|cffFF3333WARNING:|r This is for Retail only.'
	end
end

local function GetDetailsDesc3Text()
	if E:IsAddOnEnabled('Details') then
		return Engine:ASEmbedEnabled() and format('%sAddOnSkins|r has been detected and has a conflicting option that needs to be disabled before importing the %sDetails|r profile.|nClick the %s\"|r%sFix Confict|r%s\"|r button to fix that option and reload the ui to continue importing the %sDetails|r profile.', hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, '|cffFFD900', hexElvUIBlue, hexElvUIBlue) or ''
	else
		return '|cffFF3333WARNING:|r Details! is not enabled to configure.'
	end
end

--* Installer Template
Engine.InstallerData = {
	Title = format('%s |cffFFD900%s|r', config.Title, L["Installation"]),
	Name = config.Title,
	tutorialImage = config.Logo,
	tutorialImageSize = {256, 256},
	tutorialImagePoint = {0, -30},
	Pages = {
		[1] = function()
			PluginInstallFrame.SubTitle:SetText(L["Welcome"])
			PluginInstallFrame.Desc1:SetText(format(L["The %s installer will guide you through some steps and apply all the profile settings of your choice."], config.Title))
			PluginInstallFrame.Desc2:SetText('|cffFFFF00'..L["Please read the steps carefully before clicking any buttons!"]..'|r')

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:Size(160, 30)
			PluginInstallFrame.Option1:SetScript('OnClick', function() acceptedTerms = (acceptedTerms and false) or (not acceptedTerms and true) PluginInstallFrame.Next:SetEnabled(acceptedTerms) PluginInstallFrame.Option1:SetText(TermsButtonText()) end)
			PluginInstallFrame.Option1:SetText(TermsButtonText())
			PluginInstallFrame.Option1:SetEnabled(true)

			PluginInstallFrame.Next:SetEnabled(acceptedTerms)

			if xScarlifeCharDB.DetailsStepNeeded then
				acceptedTerms = true
				PI:SetPage(4, 3)
			end
		end,
		[2] = function()
			PluginInstallFrame.SubTitle:SetText('General Profile')
			PluginInstallFrame.Desc1:SetFormattedText('%sCurrent Profile:|r %s%s|r|n%s(|rElvUI Config %s>|r Profiles %s>|r Profile Tab%s)|r', '|cffFFD900', '|cff5CE1E6', E.data:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue)
			PluginInstallFrame.Desc2:SetText('Pick from one of the availabe profiles below to have the profile create and/or updated!|nIf the profile name exists in your list of profile, it will let you decide to overwrite or change the name of the selected profile.')
			PluginInstallFrame.Desc3:SetText(format('|cff4beb2c%s', L["Recommended step. Should not be skipped."]))

			PluginInstallFrame.Option1:SetShown(Engine.ProfileData.ElvUI.PROFILE1TEASER or not (Engine.ProfileData.ElvUI.PROFILE1 == '' or Engine.ProfileData.ElvUI.PROFILE1 == nil))
			PluginInstallFrame.Option1:SetScript('OnClick', function() Engine:SetupProfile(E.Retail and 'PROFILE1' or 'PROFILE2') end)
			PluginInstallFrame.Option1:SetText(Engine:GetProfileButtonText('PROFILE'))
			PluginInstallFrame.Option1:SetEnabled(Engine:GetProfileButtonState('PROFILE'))

			PluginInstallFrame.Option2:Hide()
			-- PluginInstallFrame.Option2:SetShown(Engine.ProfileData.ElvUI.PROFILE2TEASER or not (Engine.ProfileData.ElvUI.PROFILE2 == '' or Engine.ProfileData.ElvUI.PROFILE2 == nil))
			-- PluginInstallFrame.Option2:SetScript('OnClick', function() Engine:SetupProfile('PROFILE2') end)
			-- PluginInstallFrame.Option2:SetText((Engine.ProfileData.ElvUI.PROFILE2NAME ~= '' and Engine.ProfileData.ElvUI.PROFILE2NAME) or 'Coming Soon™')
			-- PluginInstallFrame.Option2:SetEnabled(acceptedTerms and not (Engine.ProfileData.ElvUI.PROFILE2 == '' or Engine.ProfileData.ElvUI.PROFILE2 == nil))

			PluginInstallFrame.Next:SetEnabled(acceptedTerms)
		end,
		[3] = function()
			PluginInstallFrame.SubTitle:SetText('Private Profile')

			PluginInstallFrame.Desc1:SetFormattedText('%sCurrent Private Profile:|r %s%s|r|n%s(|rElvUI Config %s>|r Profiles %s>|r Private Tab%s)|r', '|cffFFD900', '|cff5CE1E6', E.charSettings:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue)
			PluginInstallFrame.Desc2:SetText('|cffFF3333WARNING:|r This will overwrite your current Private Profile!')
			PluginInstallFrame.Desc3:SetText('Pick from one of the availabe Private Profiles below to have their settings applied to your current Private Profile.')
			PluginInstallFrame.Desc4:SetText(format('|cff4beb2c%s', L["Recommended step. Should not be skipped."]))

			PluginInstallFrame.Option1:SetShown(Engine.ProfileData.ElvUI.PRIVATE1TEASER or not (Engine.ProfileData.ElvUI.PRIVATE1 == '' or Engine.ProfileData.ElvUI.PRIVATE1 == nil))
			PluginInstallFrame.Option1:SetScript('OnClick', function() local profile = E.Retail and Engine.ProfileData.ElvUI.PRIVATE1 or Engine.ProfileData.ElvUI.PRIVATE2 local profileName = E.Retail and Engine.ProfileData.ElvUI.PRIVATE1NAME or Engine.ProfileData.ElvUI.PRIVATE2NAME E:StaticPopup_Show('XSCARLIFE_IMPORT_PRIVATE_PROFILE_OVERWRITE', nil, nil, {ProfileString = profile, ProfileName = profileName}) end)
			PluginInstallFrame.Option1:SetText(Engine:GetProfileButtonText('PRIVATE'))
			PluginInstallFrame.Option1:SetEnabled(Engine:GetProfileButtonState('PRIVATE'))
			
			PluginInstallFrame.Option2:Hide()
			-- PluginInstallFrame.Option2:SetShown(Engine.ProfileData.ElvUI.PRIVATE2TEASER or not (Engine.ProfileData.ElvUI.PRIVATE2 == '' or Engine.ProfileData.ElvUI.PRIVATE2 == nil))
			-- PluginInstallFrame.Option2:SetScript('OnClick', function() E:StaticPopup_Show('XSCARLIFE_IMPORT_PRIVATE_PROFILE_OVERWRITE', nil, nil, {ProfileString = Engine.ProfileData.ElvUI.PRIVATE2}) end)
			-- PluginInstallFrame.Option2:SetText((Engine.ProfileData.ElvUI.PRIVATE2NAME ~= '' and Engine.ProfileData.ElvUI.PRIVATE2NAME) or 'Coming Soon™')
			-- PluginInstallFrame.Option2:SetEnabled(acceptedTerms and not (Engine.ProfileData.ElvUI.PRIVATE2 == '' or Engine.ProfileData.ElvUI.PRIVATE2 == nil))

			PluginInstallFrame.Next:SetEnabled(acceptedTerms)
		end,
		[4] = function()
			PluginInstallFrame.SubTitle:SetText('Details Profile')
			PluginInstallFrame.Desc1:SetText(format('Please click the button below to apply %s Details! Damage Meter profile!', config.Title))
			PluginInstallFrame.Desc2:SetText(format('|cff4beb2c%s', L["Recommended step. Should not be skipped."]))
			PluginInstallFrame.Desc3:SetText(GetDetailsDesc3Text())

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() if not E:IsAddOnEnabled('Details') then return end xScarlifeCharDB.DetailsStepNeeded = nil Engine:SetupDetails() end)
			PluginInstallFrame.Option1:SetText(L["Setup Details"])
			PluginInstallFrame.Option1:SetEnabled(acceptedTerms and E:IsAddOnEnabled('Details') and not xScarlifeCharDB.ASEmbedEnabled)
			
			PluginInstallFrame.Option2:SetShown(xScarlifeCharDB.ASEmbedEnabled)
			PluginInstallFrame.Option2:SetScript('OnClick', function() if E:IsAddOnEnabled('Details') then xScarlifeCharDB.DetailsStepNeeded = true xScarlifeCharDB.ASEmbedEnabled = false AS:SetOption('EmbedSystem', false) AS:SetOption('EmbedSystemDual', false) ReloadUI() end end)
			PluginInstallFrame.Option2:SetText('Fix Conflict')
			PluginInstallFrame.Option2:SetEnabled(acceptedTerms and E:IsAddOnEnabled('Details') and xScarlifeCharDB.ASEmbedEnabled)

			PluginInstallFrame.Next:SetEnabled(acceptedTerms)
		end,
		[5] = function()
			PluginInstallFrame.SubTitle:SetText('OmniCD Profile')
			PluginInstallFrame.Desc1:SetText(format('Please click the button below to apply %s OmniCD profile!', config.Title))
			PluginInstallFrame.Desc2:SetText(format('|cff4beb2c%s', L["Recommended step. Should not be skipped."]))

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() if not E:IsAddOnEnabled('OmniCD') then return end Engine:SetupOmniCD() end)
			PluginInstallFrame.Option1:SetText(L["Setup OmniCD"])
			PluginInstallFrame.Option1:SetEnabled(acceptedTerms and (E:IsAddOnEnabled('OmniCD') and not (Engine.ProfileData.OmniCD.ProfileString == '' or Engine.ProfileData.OmniCD.ProfileString == nil)))
			
			PluginInstallFrame.Next:SetEnabled(acceptedTerms)
		end,
		[6] = function()
			PluginInstallFrame.SubTitle:SetText('|cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r')
			PluginInstallFrame.Desc1:SetText(L["This step will configure the settings for |cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r."])
			PluginInstallFrame.Desc2:SetText(format('|cff4beb2c%s', L["Recommended step. Should not be skipped."]))
			PluginInstallFrame.Desc3:SetText(GetWindToolsDesc3Text())

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() Engine:SetupWindTools() end)
			PluginInstallFrame.Option1:SetText('Setup |cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r')
			PluginInstallFrame.Option1:SetEnabled(acceptedTerms and E:IsAddOnEnabled('ElvUI_WindTools') and E.Retail)

			PluginInstallFrame.Next:SetEnabled(acceptedTerms)
		end,
		[7] = function()
			PluginInstallFrame.SubTitle:SetText(L["Installation Complete"])
			PluginInstallFrame.Desc1:SetText(L["You have completed the installation process, please click 'Finished' to reload the UI."])
			PluginInstallFrame.Desc2:SetText(L["Feel free to join our community Discord for support and social chats."])

			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript('OnClick', function() E:StaticPopup_Show('XSCARLIFE_EDITBOX', nil, nil, config.Discord) end)
			PluginInstallFrame.Option1:SetText(L["Discord"])
			PluginInstallFrame.Option1:SetEnabled(true)

			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript('OnClick', function() xScarlifeCharDB.install_complete = config.Version ReloadUI() end)
			PluginInstallFrame.Option2:SetText(format('|cff4beb2c%s', L["Finished"]))
			PluginInstallFrame.Option2:SetEnabled(true)
		end,
	},
	StepTitles = {
		[1] = L["Welcome"],
		[2] = L["General Profile"],
		[3] = L["Private Profile"],
		[4] = 'Details',
		[5] = 'OmniCD',
		[6] = L["Windtools"],
		[7] = L["Installation Complete"],
	},
	StepTitlesColor = config.Installer.StepTitlesColor,
	StepTitlesColorSelected = config.Installer.StepTitlesColorSelected,
	StepTitleWidth = config.Installer.StepTitleWidth,
	StepTitleButtonWidth = config.Installer.StepTitleButtonWidth,
	StepTitleTextJustification = config.Installer.StepTitleTextJustification,
}
