local E, L, V, P, G = unpack(ElvUI)
local AddOnName, Engine = ...
local D = E.Distributor
local AS = E:IsAddOnEnabled('AddOnSkins') and unpack(AddOnSkins)

E.PopupDialogs.XSCARLIFE_IMPORT_PRIVATE_PROFILE_OVERWRITE = {
	text = L["|cffFF3333WARNING:|r You are about to overwrite your settings for your current Private Profile (Character Settings).|nClick the button below to confirm you want to overwrite this Private Profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, data) Engine:ImportProfile(data.ProfileString) xScarlifeCharDB.DetailsStepNeeded = true ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

E.PopupDialogs.XSCARLIFE_EDITBOX = {
	text = Engine.Config.Title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine('text')
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH('CENTER')
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= self.temptxt then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = E.noop,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

E.PopupDialogs.XSCARLIFE_OMNICD_IMPORT_EDITOR = {
	text = L["Importing Custom Spells will reload UI. Press Cancel to abort."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, data)
		OmniCD[1].ProfileSharing:CopyCustomSpells(data)
		C_UI.Reload()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

E.PopupDialogs.XSCARLIFE_OMNICD_IMPORT_PROFILE = {
	text = L["Press Accept to save profile %s. Addon will switch to the imported profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, data)
		OmniCD[1].ProfileSharing:CopyProfile(data.profileType, data.profileKey, data.profileData)
		OmniCD[1]:ACR_NotifyChange()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3
}

function Engine:SetupDetails()
	_G.Details:EraseProfile(Engine.ProfileData.Details.ProfileTitle)

	_G.Details:ImportProfile(Engine.ProfileData.Details.ProfileString, Engine.ProfileData.Details.ProfileTitle)

	if _G.Details:GetCurrentProfileName() ~= Engine.ProfileData.Details.ProfileTitle then
		_G.Details:ApplyProfile(Engine.ProfileData.Details.ProfileTitle)
	end
end

function Engine:SetupOmniCD()
		if not E:IsAddOnEnabled('OmniCD') then return end

		local profileType, profileKey, profileData = OmniCD[1].ProfileSharing:Decode(Engine.ProfileData.OmniCD.ProfileString)
		if not profileData then
			return
		end

		local prefix = '[IMPORT-%s]%s'
		local n = 1
		local key
		while true do
			key = format(prefix, n, profileKey)
			if not OmniCDDB.profiles[key] then
				profileKey = key
				break
			end
			n = n + 1
		end

		if profileType == "cds" then
			E:StaticPopup_Show('XSCARLIFE_OMNICD_IMPORT_EDITOR', nil, nil, profileData)
		else
			E:StaticPopup_Show('XSCARLIFE_OMNICD_IMPORT_PROFILE', format('|cffffd200%s|r', profileKey), nil, {profileType=profileType, profileKey=profileKey, profileData=profileData})
		end
end

function Engine:SetupWindTools()
	if E:IsAddOnEnabled('ElvUI_WindTools') then
		local _, F = unpack(WindTools)
		F.Profiles.ImportByString(Engine.ProfileData.WindTools.ALL)
	else
		E:Print('|cff5385edW|r|cff5094eai|r|cff4da4e7n|r|cff4ab4e4d|r|cff47c0e1T|r|cff44cbdfo|r|cff41d7ddo|r|cff41d7ddl|r|cff41d7dds|r is not Enabled!')
	end
end

local function BigWigsCallback(completed)
	if completed then return end
	E:Print('BigWigs profile import process has been cancelled. No profile has been imported.')
end

function Engine:SetupBigWigs()
	if not E:IsAddOnEnabled('BigWigs') then E:Print('BigWigs is not Enabled!') return end
	if not Engine.ProfileData.BigWigs.ProfileString or not Engine.ProfileData.BigWigs.ProfileTitle then return end
	if Engine.ProfileData.BigWigs.ProfileString == '' or Engine.ProfileData.BigWigs.ProfileTitle == '' then return end

	BigWigsAPI.RegisterProfile('xScarlife', Engine.ProfileData.BigWigs.ProfileString, Engine.ProfileData.BigWigs.ProfileTitle, BigWigsCallback)
end

function Engine:SetupProfile(profile)
	local profileImport = profile and profile or 'PROFILE1'
	D:ImportProfile(Engine.ProfileData.ElvUI[profileImport])
	E.db.chat.hideVoiceButtons = true
end

local function SetImportedProfile(profileType, profileKey, profileData, force)
	if profileType == 'private' then
		local privateKey = ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm]

		if privateKey then
			profileData = E:FilterTableFromBlacklist(profileData, D.blacklistedKeys.private) --Remove unwanted options from import
			ElvPrivateDB.profiles[privateKey] = profileData
			-- E:StaticPopup_Show('IMPORT_RL')
		end
	end
end

function Engine:ImportProfile(dataString)
	local profileType, profileKey, profileData = D:Decode(dataString)

	if not profileData or type(profileData) ~= 'table' then
		E:Print('Error: something went wrong when converting string to table!')
		return
	end

	if profileType and ((profileType == 'profile' and profileKey) or profileType ~= 'profile') then
		SetImportedProfile(profileType, profileKey, profileData)
	end

	return true
end
