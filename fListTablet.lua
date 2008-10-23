fListTablet = LibStub("AceAddon-3.0"):NewAddon("fListTablet", "AceConsole-3.0", "AceEvent-3.0", "fLib")
local addon = fListTablet
local NAME = 'fListTablet'
local MYNAME = UnitName('player')

local tablet = AceLibrary('Tablet-2.0')

local tablet_data = {
	detached = true,
	anchor = "TOPLEFT",
	offsetx = 340,
	offsety = -104 }

--Required by AceAddon
function addon:OnInitialize()
	self:RegisterGUI()
	
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

-- and tablet:AddLine
--make sure no nils inside values, messes things up
local function MakeLine(data)
	local str = ""
	for idx, val in ipairs(columnnames) do
		if idx == 1 then
			idx = ''
		end
		str = str .. 'text' .. idx .. '%' .. tostring(data[val]) --.. '%'
		--str = str .. 'text' .. idx .. 'R', 1, 'text' .. idx .. 'G', 0.6, 'text' .. idx .. 'B', 0
		if idx == '' or idx < #columnnames then
		 	str = str .. '%'
		 end
	end
	--strtrim(str)
	print(strsplit('%', str))
	local ttt  = {strsplit('%', str)}
	print(#ttt)
	return strsplit('%', str)
end

local function MakeHighlight()
	local str = ""
	for idx, val in ipairs(columnnames) do
		if idx == 1 then
			idx = ''
		end
		str = str .. 'text' .. idx .. 'R%1%text' .. idx .. 'G%1%text' .. idx .. 'B%.5%'
	end
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
	
end

local function SortCurentPlayers()
	if fList then
		table.sort(fList.db.global.currentlist, 
	end
end

function addon:RegisterGUI()
	if not tablet:IsRegistered(NAME) then
		tablet:Register(NAME, 'detachedData', tablet_data,
			'Strata', 'DIALOG',
			'minWidth', 50,
			'maxHeight', 650,
			'canAttach', false,
			'dontHook', true,
			'showTitleWhenDetached', true,
			'children', function()
				tablet:SetTitle('Current List')
				
				local highlight = 'text'
				if SORT ~= 1 then
					highlight = highlight .. SORT
				end
				addon:Print('highlight=' .. highlight)
				
				local cat = tablet:AddCategory(
				    'columns', 10,
				    'func', function() SORT = columnnames[SORT+1] and SORT+1 or 1 self:RefreshGUI()  end,
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
				
				if fList then
					for idx,data in pairs(fList.db.global.currentlist) do
						cat:AddLine(
							'hasCheck', true,
							'checked', data.invited,
							'text', data.name,
							'text2', data.level,
							'text3', data.class,
							'text4', data.alt,
							'text5', data.note,
							'text6', data.rank,
							'text7', data.rankIndex,
							'text8', data.zone,
							'text9', data.online,
							'text10', data.status,
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
		SortCurentPlayers()
		tablet:Refresh(NAME)
	else
		self:Print(NAME .. ' is not a registered tablet')
	end
end
