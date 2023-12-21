local E, L, V, P, G = unpack(ElvUI)
local AddOnName, Engine = ...
local D = E.Distributor
local AS = E:IsAddOnEnabled('AddOnSkins') and unpack(AddOnSkins)

E.PopupDialogs.XSCARLIFE_IMPORT_PRIVATE_PROFILE_OVERWRITE = {
	text = L["|cffFF3333WARNING:|r You are about to overwrite your settings for your current Private Profile (Character Settings).|nClick the button below to confirm you want to overwrite this Private Profile."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(_, data) Engine:ImportProfile(data.ProfileString) end,
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

function Engine:SetupDetails()
	_G.Details:EraseProfile(Engine.ProfileData.Details.ProfileTitle)

	_G.Details:ImportProfile(Engine.ProfileData.Details.ProfileString, Engine.ProfileData.Details.ProfileTitle)

	if _G.Details:GetCurrentProfileName() ~= Engine.ProfileData.Details.ProfileTitle then
		_G.Details:ApplyProfile(Engine.ProfileData.Details.ProfileTitle)
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

function Engine:SetupProfile(profile)
	local profileImport = profile and profile or 'PROFILE1'
	D:ImportProfile(Engine.ProfileData.ElvUI[profileImport])
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
