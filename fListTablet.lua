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
	self:Debug("<<OnInitialize>> end")
	
	--self.Timer = self:ScheduleRepeatingTimer(self["TimeUp"], TIMER_INTERVAL, self)
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

--info - the clicked player info
local function ClickPlayer(info)
	fList:Debug("<<ClickPlayer>>")
	fList:Debug(tostring(info))
	if IsShiftKeyDown() then
		fList:InvitePlayer(info.name)
	elseif IsControlKeyDown() then
		fList:UnlistPlayer(info.name, info.name)
	else
		dew:Open(NAME..'RightClickMenu',
			'cursorX', true,
			'cursorY', true,
			"children", function()
				dew:FeedTable({
					Invite = {
						text = "Invite",
	        			func = function() fList:InvitePlayer(info.name) end,},
					Remove = {
						text = "Remove",
						func = function() fList:UnlistPlayer(info.name, info.name) end,}
				})
			end
		)
	end
end

function addon:RegisterGUI()
	if not tablet:IsRegistered(NAME) then
		SortCurrentPlayers()
		tablet:Register(NAME, 'detachedData', tablet_data,
			'strata', "HIGH", 'maxHeight', 850,
			'cantAttach', true,
			'dontHook', true,
			'showTitleWhenDetached', true,
			--'showHintWhenDetached', true,
			'children', function()
				--print('in register children f unction')
				local cat
				tablet:SetTitle('fList')
				
				--Menu at the top
				cat = tablet:AddCategory('columns', 1)
				local x = 'Start List'
				if fList.CURRENTLIST.IsListOpen() then x = 'Close List' end
				cat:AddLine(
					'text', x,
					'justify', "RIGHT",
					'func', function()
						if fList.CURRENTLIST.IsListOpen() then
							fList:CloseList()
						else
							fList:StartList()
						end
					end)
				
				if UnitInRaid('player') then
					cat:AddLine(
						'text', 'Disband Raid',
						'justify', 'RIGHT',
						'func', function() fList:DisbandRaid() fListTablet:Refresh() end
					)
				end
				--Current List
				local highlight = 'text'
				if SORT ~= 1 then
					highlight = highlight .. SORT
				end
				
				cat = tablet:AddCategory(
				    'columns', 10,
				    'showWithoutChildren', true,
				    'hideBlankLine', true,
				    'func', function()
				    	if IsShiftKeyDown() then
				    	elseif IsControlKeyDown() then
				    		SORT = columnnames[SORT-1] and SORT-1 or 10
				    	else
				    		SORT = columnnames[SORT+1] and SORT+1 or 1
				    	end
				    	SortCurrentPlayers()
				    	fListTablet:Refresh()
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
							'arg1', info,
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
				
				--Menu at the bottom
				cat = tablet:AddCategory('columns', 1)
				if fList.CURRENTLIST.IsListOpen() then
					cat:AddLine('text', 'Print List', 'func', function() fList:PrintList() end)
				end
				cat:AddLine('text', 'Config', 'func', function() fList:OpenConfig() end)
				cat:AddLine(
					'text', "Close",
					'func', function()	LibStub('AceTimer-3.0'): ScheduleTimer( fListTablet['CloseHandler'], 0, fListTablet ) end --WTFWTFWTFOMGWTF
					--i have no idea why the close needs to be done from a timer....
				)
			end
		)
	end
end

function addon:CloseHandler()
	addon:Hide()
end

local isopen = false
function addon:Toggle()
	if isopen then
		addon:Hide()
	else
		addon:Show()
	end
end


function addon:Show()
	--[[
	if not tablet:IsRegistered(guiname) then
		self:Register()
	end
	tablet:Open(guiname)
	--]]
	if tablet:IsRegistered(NAME) then
		SortCurrentPlayers()
		tablet:Open(NAME)
		isopen = true
	end
end

function addon:Hide()
	--[[
	if tablet:IsRegistered(guiname) then
		tablet:Close(guiname)
	end
	--]]
	if tablet:IsRegistered(NAME) then
		tablet:Close(NAME)
		isopen = false
	end
end

function addon:Refresh()
	--[[
	if not tablet:IsRegistered(guiname) then
		self:RegisterGUI()
	end
	tablet:Refresh(guiname)
	--]]
	if tablet:IsRegistered(NAME) then
		tablet:Refresh(NAME)
	end
end
