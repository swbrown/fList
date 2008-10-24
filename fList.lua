fList = LibStub("AceAddon-3.0"):NewAddon("fList", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "fLib")
local addon = fList
local NAME = 'fList'
local DBNAME = 'fListDB'

local TIMER_INTERVAL = 10 --secs
local GUILD_ROSTER_INTERVAL = 50 --secs

local CURRENTLIST = {}
addon.CURRENTLIST = CURRENTLIST

local options = {
	type='group',
	name = NAME,
	handler = addon,
	args = {
		debug = {
			order = -1,
			type = "toggle",
			name = 'Debug',
            desc = "Enables and disables debug mode.",
            get = "GetOptions",
            set = "SetOptions",
		},
	    config = {
	    	order = -1,
	    	type = 'execute',
	    	name = 'config',
	    	desc = 'Opens configuration window',
	    	func = 'OpenConfig',
	    	guiHidden = true,
	    },
	    action = {
	    	order = 10,
	    	type = 'group',
	    	name = 'Actions',
	    	desc = 'List Actions',
	    	args = {
	    		startlist = {
			    	order = 10,
			    	type = 'execute',
			    	name = 'Start List',
			    	desc = 'Starts a new list',
			    	func = 'StartList',
	    		},
	    		closelist = {
			    	order = 11,
			    	type = 'execute',
			    	name = 'Close List',
			    	desc = 'Closes the current list',
			    	func = 'CloseList',
	    		},
	    		printlist = {
	    			order = 12,
	    			type = 'execute',
			    	name = 'Print List',
			    	desc = 'Prints the current list',
	    			func = 'PrintList',
	    		},
	    		inviteplayer = {
	    			order = 13,
			    	type = 'input',
			    	name = 'Invite Player',
			    	desc = 'Send an invite whisper to a player',
			    	set = 'InvitePlayerHandler',
	    		},
	    		removeplayer = {
	    			order = 14,
			    	type = 'input',
			    	name = 'Remove Player',
			    	desc = 'Remove a player from the list',
			    	set = 'UnlistPlayerHandler',
	    		},
	    		disbandraid = {
	    			order = 15,
	    			type = 'execute',
			    	name = 'Disband Raid',
			    	desc = 'Disbands the current raid',
	    			func = 'DisbandRaid',
	    		},
	    	},
	    },
		name = {
			order = 20,
			type = 'input',
			name = 'Guild/Raid Name',
			desc = 'The name of the guild running the list or some name for the raid being run',
			get = 'GetOptions',
			set = 'SetOptions',
		},
		prefix = {
			order = 21,
			type = 'group',
			name = 'Prefixes (for whispers)',
			desc = 'Special words that players can use to whisper you',
			args = {
				warning = {
					order = 0,
					type = 'description',
					name = 'blah blah blah',
				},
				list = {
					order = 5,
					type = 'input',
					name = 'List Prefix',
					desc = 'Special word allowing players to list with you',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				unlist = {
					order = 6,
					type = 'input',
					name = 'Unlist Prefix',
					desc = 'Special word allowing players to unlist with you',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				invite = {
					order = 7,
					type = 'input',
					name = 'Invite Prefix',
					desc = 'Special word allowing players to accept an invite',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				alt = {
					order = 8,
					type = 'input',
					name = 'Alt Prefix',
					desc = 'Special word allowing players to set an alt',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				note = {
					order = 9,
					type = 'input',
					name = 'Note Prefix',
					desc = 'Special word allowing players to set a note',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				listrequest = {
					order = 10,
					type = 'input',
					name = 'List Request Prefix',
					desc = 'Special word allowing players to request the current list',
					get = 'GetOptions',
					set = 'SetOptions',
				},
			}
		},
		timeout = {
			order = 22,
			type = 'group',
			name = 'Timeouts (in minutes)',
			desc = 'Various timeout settings',
			args = {
				invite = {
					order = 0,
					type = 'range',
					name = 'Invite Timeout',
					desc = 'Timeout (in minutes) before a player\'s invitation times out',
					min = 0,
					max = 30,
					step = 1,
					get = 'GetOptions',
					set = 'SetOptions',
				},
				offline = {
					order = 1,
					type = 'range',
					name = 'Offline Timeout',
					desc = 'Timeout (in minutes) before an offline player is automatically removed from the list',
					min = 0,
					max = 30,
					step = 1,
					get = 'GetOptions',
					set = 'SetOptions',
				},
			},
		},
		announcement = {
			order = 23,
			type = 'group',
			name = 'Announcement Settings',
			desc = 'Announcements, to announce list information to players',
			args = {
				message = {
					order = 0,
					type = 'input',
					name = 'Message',
					desc = 'Message for your list announcement, /w currentplayer listprefix will be automatically appended to the message',
					get = 'GetOptions',
					set = 'SetOptions',
				},
				officer = {
					order = 10,
					type = 'toggle',
					name = 'Officer',
		            desc = 'Announce to officer chat',
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				guild = {
					order = 11,
					type = 'toggle',
					name = 'Guild',
		            desc = "Announce to guild chat",
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				raid = {
					order = 12,
					type = 'toggle',
					name = 'Raid',
		            desc = "Announce to raid chat",
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				channels = {
					order = 20,
					type = 'input',
					name = 'Channels',
					desc = 'List of channels that your announcement message will be shown',
					get = 'GetOptions',
					set = 'SetOptions',
					multiline = true,
				},
				interval = {
					order = 21,
					type = 'range',
					name = 'Interval',
					desc = 'Interval (in minutes) until your announcement message will automatically be repeated',
					min = 0,
					max = 30,
					step = 1,
					get = 'GetOptions',
					set = 'SetOptions',
				},
			},
		},
		printlist = {
			order = 24,
			type = 'group',
			name = 'Print List Settings',
			desc = 'Print the current list to players',
			args = {
				officer = {
					order = 10,
					type = 'toggle',
					name = 'Officer',
		            desc = 'Print List to officer chat',
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				guild = {
					order = 11,
					type = 'toggle',
					name = 'Guild',
		            desc = 'Print List to guild chat',
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				raid = {
					order = 12,
					type = 'toggle',
					name = 'Raid',
		            desc = 'Print List to raid chat',
		            get = 'GetOptions',
		            set = 'SetOptions',
				},
				channels = {
					order = 13,
					type = 'input',
					name = 'Channels',
					desc = 'List of channels where current list will be printed',
					get = 'GetOptions',
					set = 'SetOptions',
					multiline = true,
				},
				interval = {
					order = 14,
					type = 'range',
					name = 'Interval',
					desc = 'Interval (in minutes) until current list will automatically be reprinted',
					min = 0,
					max = 30,
					step = 1,
					get = 'GetOptions',
					set = 'SetOptions',
				},
				password = {
					order = 15,
					type = 'input',
					name = 'Password',
					desc = 'Password required for players doing a listrequest',
					get = 'GetOptions',
					set = 'SetOptions',
				},
			},
		},
		blacklist = {
			order = 25,
			type = 'group',
			name = 'Blacklist settings',
			desc = 'Blacklist players from every listing with you again',
			args = {
				names = {
					order = 0,
					type = 'input',
					name = 'Names',
					desc = 'List of names',
					get = 'GetOptions',
					set = 'SetOptions',
					multiline = true,
				},
			},
		},
	}
}

--a filter handler to be called by the messsage event handler
--return true causes the msg not to be displayed in the chat frame
local function WhisperFilter(msg)
	msg = strlower(strtrim(msg))
	if strfind(msg, "%[" .. NAME .. "%]") == 1 then
		if strfind(msg, strlower(UnitName('player'))) then
			return false
		else
			return true
		end
	elseif strfind(msg, addon.db.global.prefix.list) == 1 then
		return true
	elseif strfind(msg, addon.db.global.prefix.unlist) == 1 then
		return true
	elseif strfind(msg, addon.db.global.prefix.alt) == 1 then
		return true
	elseif strfind(msg, addon.db.global.prefix.note) == 1 then
		return true
	elseif strfind(msg, addon.db.global.prefix.invite) == 1 then
		return true
	elseif strfind(msg, addon.db.global.prefix.listrequest) == 1 then
		return true
	--elseif strfind(msg, "%[MegaelliAR%]") == 1 then
		--special temporary stuff to do
		--local wds = addon:ParseWords(msg, 7)
		--if wds then
		--	local name = wds[5]
		--	local dkpparts = {strsplit(".", strsub(wds[7], 1, #wds[7]-1))}
		--	addon:Print(name .. " hashas " .. dkpparts[1] .. " dkp")
		--	fDKP:AddPlayer(name)
		--	fDKP:SetDKP(name, tonumber(dkpparts[1]))
		--else
		--	addon:Print("wds is nil")
		--end
		--return false
	end
	
	--you could change the msg also by doing
	--return false, gsub(msg, "lol", "")
end

--Required by AceAddon
--self.db contains the AceDB which gives you access to saved variables
--self.Count keeps track of how much time has passed, each count is one TIMER_INTERVAL
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(DBNAME)
	self:Debug(DBNAME .. " loaded")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {NAME})
	self.BlizOptionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(NAME, NAME)
	
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperFilter)
	
	self.Count = 1
	self.announcementcount = 1
	self.printlistcount = 1
	self.guildrostercount = 1
	self.Timer = self:ScheduleRepeatingTimer(self["TimeUp"], TIMER_INTERVAL, self)
	
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

--Handler for our AceTimer repeating timer (created during initialization)
--Increment self.Count
--Clean up list
--Announce
--Print list
function addon:TimeUp()
	self:Debug("<<TimeUp>>")
	self.Count = self.Count + 1
	if CURRENTLIST.IsListOpen() then
		if GUILD_ROSTER_INTERVAL > 0 then
			self:Debug("Guild Roster...")
			if self.Count - self.guildrostercount > GUILD_ROSTER_INTERVAL * 60 / TIMER_INTERVAL then
				GuildRoster()
				self.guildrostercount = self.Count
			end
		end
		
		self:Debug("Cleaning up list...")
		for idx,info in ipairs(CURRENTLIST.GetList()) do
			if UnitInRaid(info.name) then
				--unlist players in raid
				self:UnlistPlayer(info.name)
			else
				--update info to match guild roster
				local rosterdata = fList.db.global.guildroster[strlower(info.name)]
				if rosterdata then
					info.rank = rosterdata.rank
					info.rankIndex = rosterdata.rankIndex
					info.level = rosterdata.level
					info.class = rosterdata.class
					info.zone = rosterdata.zone
					if rosterdata.online then
						info.online = 'yes'
					else
						info.online = 'no'
					end
					info.status = rosterdata.status
					CURRENTLIST.SavePlayerInfo(info,false)
				end
				if info.invited then
					--expire invites
					if self.Count - info.invitedcount > self.db.global.timeout.invite * 60 / TIMER_INTERVAL then
						self:ExpireInvite(info.name)
					end
				end
			end
		end
		
		if self.db.global.announcement.interval > 0 then
			self:Debug("Announcement...")
			if self.Count - self.announcementcount > self.db.global.announcement.interval * 60 / TIMER_INTERVAL then
				self:AnnounceList()
				self.announcementcount = self.Count
			end
		end
		
		if self.db.global.printlist.interval > 0 then
			self:Debug("Print List...")
			if self.Count - self.printlistcount > self.db.global.printlist.interval * 60 / TIMER_INTERVAL then
				self:AnnounceList()
				self.printlistcount = self.Count
			end
		end
	end
	
	--tempidx = tempidx + 1
	--if tempidx <= #tempnames then
	--	self:Print("Whispering Megaelli raidpoints " .. tempnames[tempidx])
	--	SendChatMessage("raidpoints " .. tempnames[tempidx], "WHISPER", nil, "Megaelli")
	--end
end

--GUILD_ROSTER_UPDATE handler
function addon:GUILD_ROSTER_UPDATE()
	for i=1,GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, 
			officernote, online, status, something = GetGuildRosterInfo(i)
		if not self.db.global.guildroster then
			self.db.global.guildroster = {}
		end
		self.db.global.guildroster[strlower(name)] = {
			name = name,
			rank = rank,
			rankIndex = rankIndex,
			level = level,
			class = class,
			zone = zone,
			note = note,
			officernote = officernote,
			online = online,
			status = status,
		}
	end
end

--CHAT_MSG_WHISPER handler
function addon:CHAT_MSG_WHISPER(eventName, msg, author, lang, status, ...)
	msg = strlower(strtrim(msg))
	author = strlower(author)
	self:Debug("<<CHAT_MSG_WHISPER>>" .. msg)
	
	local words = self:ParseWords(msg)
	if #words < 1 then
		return
	end
	
	local cmd = words[1];
	self:Debug("cmd=" .. cmd)
	
	if cmd == self.db.global.prefix.list then
		--LIST whisper
		--"list" main = author
		--"list name" main = name, alt = author (for listing from an alt)
		local main = author
		local alt = ""
		
		if words[2] then
			self:Debug("words[2]=" .. words[2])
			main = words[2]
			alt = author
		end
		
		self:ListPlayer(main, author)
		if #alt > 0 then
			self:AltPlayer(main, alt, author)
		end
	elseif cmd == self.db.global.prefix.unlist then
		--UNLIST whisper
		--"unlist" main = author
		--"unlist name" main = name (for unlisting from an alt)
		local main = author
		if words[2] then
			self:Debug("words[2]=" .. words[2])
			main = words[2]
		end
		self:UnlistPlayer(main, author)
	elseif cmd == self.db.global.prefix.alt then
		--ALT whisper
		if words[2] then
			self:AltPlayer(author, words[2], author)
		end
	elseif cmd == self.db.global.prefix.note then
		--NOTE whisper
		if words[2] then
			self:NotePlayer(author, words[2], author)
		end
	elseif cmd == self.db.global.prefix.invite then
		--INVITE whisper
		self:AcceptInvite(author)
	elseif cmd == self.db.global.prefix.listrequest then
		--LISTREQUEST whisper
		addon:Debug("LISTREQUEST is not implemented yet")
	end
end

--PARTY_MEMBERS_CHANGED handler
function addon:PARTY_MEMBERS_CHANGED()
	self:Debug("<<PARTY_MEMBERS_CHANGED>>" .. tostring(GetNumPartyMembers()) .. " members in the raid")
	if GetNumPartyMembers() > 0 then
		ConvertToRaid()
	end
end

--==============================================================================================
--==============================================================================================
--USE ONLY THESE FUNCTIONS TO ACCESS CURRENTLIST--
--fList.db.global.currentlist
--Returns true if there is a current list
function CURRENTLIST.IsListOpen()
	if fList.db.global.currentlist then
		return true
	else
		return false
	end
end

function CURRENTLIST.Count()
	if fList.db.global.currentlist then
		return #fList.db.global.currentlist
	end
	return 0
end

function CURRENTLIST.NewList()
	fList.db.global.currentlist = {}
	if fListTablet then
		fListTablet:RefreshGUI()
	end
end

function CURRENTLIST.ClearList()
	fList.db.global.currentlist = nil
	if fListTablet then
		fListTablet:RefreshGUI()
	end
end

function CURRENTLIST.GetList()
	return	fList.db.global.currentlist
end

--Returns a player info table
function CURRENTLIST.CreatePlayerInfo(name)
	name = strlower(strtrim(name))
	local capname = fList:Capitalize(name)
	local newplayer = {
		name = capname,
		alt = '',
		note = '',
		invited = false,
		invitedcount = 0,
		rank = '',
		rankIndex = 0,
		level = 0,
		class = '',
		zone = '',
		online = 'yes',
		status = '',
	}
	if fList.db.global.guildroster[name] then
		local rosterdata = fList.db.global.guildroster[name]
		newplayer.rank = rosterdata.rank
		newplayer.rankIndex = rosterdata.rankIndex
		newplayer.level = rosterdata.level
		newplayer.class = rosterdata.class
		newplayer.zone = rosterdata.zone
		if rosterdata.online then
			newplayer.online = 'yes'
		else
			newplayer.online = 'no'
		end
		newplayer.status = rosterdata.status
	end
	return newplayer
end

--Returns true if successful
--else false
function CURRENTLIST.SavePlayerInfo(newplayerinfo, isnewplayer)
	fList:Debug("<<SavePlayerInfo>>")
	if isnewplayer == nil then
		isnewplayer = true
	end
	if CURRENTLIST.IsListOpen() then
		if isnewplayer then
			for idx,info in ipairs(fList.db.global.currentlist) do
				fList:Debug(idx .. " comparing " .. info.name .. ' with ' .. newplayerinfo.name)
				if info.name == newplayerinfo.name then
					fList:Debug("MATCH " .. info.name .. ' with ' .. newplayerinfo.name)
					fList.db.global.currentlist.idx = newplayerinfo
					if fListTablet then
						fListTablet:RefreshGUI()
					end
					return true
				end
			end
			fList.db.global.currentlist[#fList.db.global.currentlist + 1] = newplayerinfo
		end
		if fListTablet then
			fListTablet:RefreshGUI()
		end
		return true
	end
	return false
end

--Returns a player info table
--returns nil if no currentlist or player not listed
--if you GetPlayerInfo then edit the info, be sure to SavePlayerInfo again, so the GUI is refreshed
function CURRENTLIST.GetPlayerInfo(name)
	if CURRENTLIST.IsListOpen() then
		name = strlower(strtrim(name))
		name = fList:Capitalize(name)
		for idx,info in ipairs(fList.db.global.currentlist) do
			if name ==  info.name then
				return info
			end
		end
	end
	return nil
end

function CURRENTLIST.RemovePlayerInfo(name)
	if CURRENTLIST.IsListOpen() then
		name = strlower(strtrim(name))
		name = fList:Capitalize(name)
		for idx,info in ipairs(fList.db.global.currentlist) do
			if name ==  info.name then
				tremove(fList.db.global.currentlist, idx)
				if fListTablet then
					fListTablet:RefreshGUI()
				end
			end
		end
	end
end
--==============================================================================================
--==============================================================================================

--Starts a new list
--self.db.global.currentlist is an array of player info tables
function addon:StartList()
	if CURRENTLIST.IsListOpen() then
		self:Print("List has already started")
	else
		CURRENTLIST.NewList()
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:AnnounceList()
		self:Print("List started")
	end
end

--Closes the current list
--self.db.global.count keeps track of how many lists have been run
--self.db.global.oldlist is a list of old lists
function addon:CloseList()
	if CURRENTLIST.IsListOpen() then
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		
		if self.db.global.count == nil then
			self.db.global.count = 0
		end
		if self.db.global.oldlist == nil then
			self.db.global.oldlist = {}
		end
		
		--save the list in self.db.global.oldlist
		if CURRENTLIST.Count() > 0 then
			self.db.global.count = self.db.global.count + 1
			self.db.global.oldlist[self.db.global.count] = CURRENTLIST.GetList()
		end
		CURRENTLIST.ClearList()
		if fListTablet then
			fListTablet:RefreshGUI()
		end
		self:Announce("Thank you for listing with " .. self.db.global.name .. ". The list is now closed.")
		self:Print("List closed")
	else
		self:Print("No list to close")
	end
end

--List a new player and notifies whispertarget on success or failure
function addon:ListPlayer(name, whispertarget)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	whispertarget = strtrim(whispertarget)
	
	if name == strlower(UnitName('player')) then
		self:Print("Why are you trying to list yourself?? You're the one running this list!!")
		return
	end
	
	local msg = ""
	if not CURRENTLIST.IsListOpen() then
		msg = "No list available"
	elseif UnitInRaid(name) then
		msg = capname .. " is already in the raid"
	else
		local info = CURRENTLIST.GetPlayerInfo(name)
		if info then
			msg = capname .. " is already on the list"
		else
			local newplayerinfo = CURRENTLIST.CreatePlayerInfo(name)
			CURRENTLIST.SavePlayerInfo(newplayerinfo)
			msg = capname .. " has been added to the list"
		end
	end
	
	if whispertarget then
		self:Whisper(whispertarget, msg)
	else
		self:Whisper(name, msg)
	end
	self:Print(msg)
end

--Set handler for AceConfig
--Will remove the player from the list
function addon:UnlistPlayerHandler(info, name)
	self:UnlistPlayer(name)
end

--Unlist a player and notifies whispertarget
function addon:UnlistPlayer(name, whispertarget)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	local msg = ""
	
	if not CURRENTLIST.IsListOpen() then
		msg = "No list available"
	else
		CURRENTLIST.RemovePlayerInfo(name)
		msg = capname .. " has been removed from the list"
	end
	
	if whispertarget then
		self:Whisper(whispertarget, msg)
	else
		self:Whisper(name, msg)
	end
	self:Print(msg)
end

--Set an alt for a player
function addon:AltPlayer(name, alt, whispertarget)
	fList:Debug("<<AltPlayer>>" .. 'name=' ..name .. ' alt=' ..alt .. ' whispertarget=' .. whispertarget)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	alt = strlower(strtrim(alt))
	local capalt = self:Capitalize(alt)
	whispertarget = strlower(strtrim(whispertarget))

	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(name)
		if not info then
			self:Whisper(whispertarget, capname .. " has not listed yet")
			return
		end
		
		info.alt = alt
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(whispertarget, capname .. "'s alt has been sent to " .. capalt)
	else
		self:Whisper(whispertarget, "No list available")
	end
end

--Set a note for a player
function addon:NotePlayer(name, note, whispertarget)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	whispertarget = strlower(strtrim(whispertarget))
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(name)
		if not info then
			self:Whisper(whispertarget, capname .. " has not listed yet")
			return
		end
		--replace % so that note doens't break my tablet in fLibTablet.lua
		note = gsub(note, '%%', '*')
		info.note = note
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(whispertarget, capname .. "'s note has been set to " .. note)
	else
		self:Whisper(whispertarget, "No list available")
	end
end

--Invite a player to the raid
function addon:AcceptInvite(name)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(name)
		if not info then
			self:Whisper(name, capname .. " has not listed yet")
			return
		end
		
		if info.invited then
			InviteUnit(name)
		else
			self:Whisper(name, capname .. " does not have an open invite")
		end
	else
		self:Whisper(name, "List is closed")
	end
end

--Expires a player's invite and whispers them
function addon:ExpireInvite(name)
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(name)
		if not info then
			return
		end
		
		info.invited = false
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(name, capname .. "'s invite has expired")
		if #info.alt > 0 then
			self:Whisper(info.alt, capname .. "'s invite has expired.")
		end
	end
end

--Set handler for AceConfig
function addon:InvitePlayerHandler(info, name)
	self:InvitePlayer(name)
end

--Notify a player that they have been invited
function addon:InvitePlayer(name)
	self:Debug("Attempting to invite " .. name)
	if name then
		if CURRENTLIST.IsListOpen() then
			name = strlower(strtrim(name))
			local capname = self:Capitalize(name)
			
			local info = CURRENTLIST.GetPlayerInfo(name)
			if not info then
				self:Print(capname .. " has not yet listed")
				return
			end
			
			info.invited = true
			info.invitedcount = self.Count
			CURRENTLIST.SavePlayerInfo(info, false)
			local msg = capname .. "has been accepted to the raid. /w " .. 
					UnitName('player') .. " " .. self.db.global.prefix.invite .. 
					" to receive invite.  Your invite will expire in " .. 
					self.db.global.timeout.invite .. " minutes."
			
			if info.online == 1 then
				--check if player online, then accept and whisper
				self:Whisper(name, msg)
			else
				--send whisper to alt
				if info.alt ~= "" then
					self:Whisper(info.alt, msg)
				end
			end
		else
			self:Print("No list available.")
		end
	end
end

function addon:AnnounceList()
	self:Announce(self.db.global.announcement.message .. " /w " .. UnitName('player') .. " " .. self.db.global.prefix.list)
end

--Announces msg to specified chat and channels
function addon:Announce(msg)
	if msg == nil then
		self:Print("No msg specified for announcement")
	end
	self:AnnounceInChannels(msg, {strsplit("\n", self.db.global.announcement.channels)})
	self:AnnounceInChat(msg,
			self:CreateChatList(
				self.db.global.announcement.officer,
				self.db.global.announcement.guild,
				self.db.global.announcement.raid))
end

--Prints the current list to specified chat and channels
function addon:PrintList()
	if CURRENTLIST.IsListOpen() then
		--TODO: sort list
		local listmsg = "Current list: "
		for idx, info in ipairs(CURRENTLIST.GetList()) do
			listmsg = listmsg .. info.name .. " "
		end
		self:AnnounceInChannels(listmsg, {strsplit("\n", self.db.global.printlist.channels)})
		self:AnnounceInChat(listmsg,
			self:CreateChatList(
				self.db.global.printlist.officer,
				self.db.global.printlist.guild,
				self.db.global.printlist.raid))
	else
		self:Print("No list available")
	end
end

--Returns the players in the current list in an array
function addon:GetList()
	local players = {}
	if CURRENTLIST.IsListOpen() then
		for idx, info in ipairs(CURRENTLIST.GetList()) do
			players[#players+1] = info.name
		end
	end
	return players
end

function addon:AnnounceInChannels(msg, channels)
	for idx,chan in ipairs(channels) do
		local id = GetChannelName(chan)
		if id > 0 then
			SendChatMessage(msg, "CHANNEL", nil, id)
		end
	end
end

function addon:AnnounceInChat(msg, ...)
	for i = 1, select("#", ...) do
		local chat = select(i, ...)
		if chat ~= "" then
			self:Debug("Attempting to send chat to " .. chat)
			SendChatMessage(msg, chat, nil, nil)
		end
	end
end

function addon:CreateChatList(officer, guild, raid)
	local ChatList = ""
	if officer then
		ChatList = ChatList .. "OFFICER "
	end
	if guild then
		ChatList = ChatList .. "GUILD "
	end
	if raid then
		ChatList = ChatList .. "RAID "
	end
	
	ChatList = strtrim(ChatList)
	
	return strsplit(" ", ChatList)
end