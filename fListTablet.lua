--http://old.wowace.com/wiki/Tablet-2.0

fListTablet = LibStub("AceAddon-3.0"):NewAddon("fListTablet", "AceConsole-3.0", "AceEvent-3.0", "fLib")
local addon = fListTablet
local NAME = 'fListTablet'
local MYNAME = UnitName('player')

local tablet = AceLibrary('Tablet-2.0')
local dew = AceLibrary("Dewdrop-2.0")

local tablet_data = {
	detached = true,
	anchor = "TOPLEFT",
	offsetx = 340,
	offsety = -104 }

--Required by AceAddon
function addon:OnInitialize()
	self:RegisterGUI()
	dew:Register(NAME..'RightClickMenu',
		'children', function()
			dew:AddLine('text', "Text")
		end,
		'cursorX', true, 'cursorY', true
	)
	self:Debug("<<OnInitialize>> end")
end

--Called by AceAddon when addon enabled
function addon:OnEnable()
	self:Debug("<<OnEnable>> start")
	
	self:Debug("<<OnEnable>> end")
end

--Called by AceAddon when addon disabled
function addon:OnDisable()
	self:Debug("<<OnDisable>> start")
end

local SORT = 1
local columnnames = {
	'name',
	'level',
	'class',
	'alt',
	'note',
	'rank',
	'rankIndex',
	'zone',
	'online',
	'status',
}

local function compare1(p1, p2)
	fList:Debug('<<compare1>> SORT=' .. SORT)
	if p1== nil or p2 == nil then
		return true
	end
	local column = columnnames[SORT]
	
	if p1[column] == p2[column] then
		return p1.name < p2.name
	else
		
		return p1[column] < p2[column]
	end
end

local function SortCurrentPlayers()
	if fList and fList.CURRENTLIST.IsListOpen() then
		table.sort(fList.CURRENTLIST.GetList(), compare1) 
	end
end

local function ClickPlayer(idx, info)
	print(idx)
	print(info)
	dew:Open(NAME .. 'RightClickMenu')
end

local function CreateDewMenu()
	local dewmenu = {}
	
	if fList then
		dewmenu.fList = {
	        text = "fList",
	        func = function() if fList then fList:OpenConfig() end end,
	        hasArrow = true,
	        subMenu = {
	            Apple = {
	                text = "A juicy apple",
	                func = function()
	                	fLib:Print("You clicked a juicy apple")
	                	fListTablet:ShowGUI()
	                end,
	            },
	            Strawberry = {
	                text = "A tasty strawberry", 
	                func = function()
	                	fLib:Print("You clicked a tasty strawberry")
	                	fListTablet:HideGUI()
	                end,
	            },
	        }
	     }
	end
	
	if fDKP then
		dewmenu.fDKP = {
	        text = "fDKP",
	        func = function() if fDKP then fDKP:OpenConfig() end end,
	    }
	end
	
	return dewmenu
end

function addon:RegisterGUI()
	if not tablet:IsRegistered(NAME) then
		SortCurrentPlayers()
		tablet:Register(NAME, 'detachedData', tablet_data,
			'strata', "HIGH", 'maxHeight', 850,
			'cantAttach', true, 'dontHook', true, 'showTitleWhenDetached', true,
			'children', function()
				tablet:SetTitle('Current List')
				
				local highlight = 'text'
				if SORT ~= 1 then
					highlight = highlight .. SORT
				end
				addon:Print('highlight=' .. highlight)
				
				local cat = tablet:AddCategory(
				    'columns', 10,
				    'showWithoutChildren', true,
				    'func', function()
				    	if IsShiftKeyDown() then
				    		SORT = columnnames[SORT-1] and SORT-1 or 10
				    	else
				    		SORT = columnnames[SORT+1] and SORT+1 or 1
				    	end
				    	SortCurrentPlayers()
				    	self:RefreshGUI()
				    end,
				    'text', 'name',
					'text2', 'level',
					'text3', 'class',
					'text4', 'alt',
					'text5', 'note',
					'text6', 'rank',
					'text7', 'rankIndex',
					'text8', 'zone',
					'text9', 'online',
					'text10', 'status',
					'textR', .2, 'textG', .6, 'textB', 1,
					'text2R', .2, 'text2G', .6, 'text2B', 1,
					'text3R', .2, 'text3G', .6, 'text3B', 1,
					'text4R', .2, 'text4G', .6, 'text4B', 1,
					'text5R', .2, 'text5G', .6, 'text5B', 1,
					'text6R', .2, 'text6G', .6, 'text6B', 1,
					'text7R', .2, 'text7G', .6, 'text7B', 1,
					'text8R', .2, 'text8G', .6, 'text8B', 1,
					'text9R', .2, 'text9G', .6, 'text9B', 1,
					'text10R', .2, 'text10G', .6, 'text10B', 1,
				 	highlight..'R', 1,
				 	highlight..'G', 0.6,
				 	highlight..'B', 0
				)
				
				--pretty brown 'textR', .75, 'textG', .55, 'textB', .35,
				
				local R = 1
				local G = 1
				local B = 1
				
				if fList and fList.CURRENTLIST.IsListOpen() then
					if fList.CURRENTLIST.Count() == 0 then
						cat:AddLine('text', 'List is empty')
					end
					for idx,info in ipairs(fList.CURRENTLIST.GetList()) do
						cat:AddLine(
							'func', ClickPlayer,
							'arg1', idx,
							'arg2', info,
							'hasCheck', true,
							'checked', info.invited,
							'text', info.name,
							'text2', info.level,
							'text3', info.class,
							'text4', info.alt,
							'text5', info.note,
							'text6', info.rank,
							'text7', info.rankIndex,
							'text8', info.zone,
							'text9', info.online,
							'text10', info.status,
							'textR', R, 'textG', G, 'textB', B,
							'text2R', R, 'text2G', G, 'text2B', B,
							'text3R', R, 'text3G', G, 'text3B', B,
							'text4R', R, 'text4G', G, 'text4B', B,
							'text5R', R, 'text5G', G, 'text5B', B,
							'text6R', R, 'text6G', G, 'text6B', B,
							'text7R', R, 'text7G', G, 'text7B', B,
							'text8R', R, 'text8G', G, 'text8B', B,
							'text9R', R, 'text9G', G, 'text9B', B,
							'text10R', R, 'text10G', G, 'text10B', B,
							highlight..'R', 1,
						 	highlight..'G', 1,
						 	highlight..'B', .5
						)
					end
				else
					cat:AddLine('text', 'List is closed')
				end
			end
		)
	end
end


function addon:ShowGUI()
	--[[
	if not tablet:IsRegistered(guiname) then
		self:RegisterGUI()
	end
	tablet:Open(guiname)
	--]]
	if tablet:IsRegistered(NAME) then
		SortCurrentPlayers()
		tablet:Open(NAME)
	else
		self:Print(NAME .. ' is not a registered tablet')
	end
end

function addon:HideGUI()
	--[[
	if tablet:IsRegistered(guiname) then
		tablet:Close(guiname)
	end
	--]]
	if tablet:IsRegistered(NAME) then
		tablet:Close(NAME)
	else
		self:Print(NAME .. ' is not a registered tablet')
	end
end

function addon:RefreshGUI()
	--[[
	if not tablet:IsRegistered(guiname) then
		self:RegisterGUI()
	end
	tablet:Refresh(guiname)
	--]]
	if tablet:IsRegistered(NAME) then
		tablet:Refresh(NAME)
	else
		self:Print(NAME .. ' is not a registered tablet')
	end
end
