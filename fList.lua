--AceAddon-3.0
--AceConsole-3.0
--AceEvent-3.0
--AceTimer-3.0
--AceDB-3.0
--AceConfig-3.0
--AceConfigDialog-3.0

--fList.db.global.currentlist.players
--fList.db.global.altlist


fList = LibStub("AceAddon-3.0"):NewAddon("fList", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "fLib")
local addon = fList
local NAME = 'fList'
local DBNAME = 'fListDB'
local MYNAME = fList:CardinalName(UnitName('player'))

local TIMER_INTERVAL = 10 --secs
local AFK_OFFLINE_LIMIT = 10 --minutes

local CURRENTLIST = {} --table to hold functions
addon.CURRENTLIST = CURRENTLIST

local helptxtt = {
	txt = ' /w ' .. MYNAME .. ' help for more info.  Reminder: Please remember to set your alt if you are going to switch to your alt',
	help = 'Usage: /w ' .. MYNAME .. ' cmd [args] - Commands: list, unlist, alt, note - /w ' .. MYNAME .. ' help cmd for more info',
	list = 'Usage1: /w ' .. MYNAME .. ' list - This adds yourself to the list. Usage2: /w ' ..MYNAME .. " list name - name = main character's name - This should be used from an alt to list your main char.  The name you provide will be listed, and you are set as the alt.",
	unlist = 'Usage1: /w ' .. MYNAME .. ' unlist - This removes yourself from the list. Usage2: /w ' .. MYNAME .. " unlist name - name = main character's name - This should be used from an alt to unlist your main char.  The name you provide will be removed from the list.",
	alt = 'Usage1: /w ' .. MYNAME .. ' alt name - This sets your alt, so you can logoff your main and play your alt.  You need to list first with the list command.',
	note = 'Usage1: /w ' .. MYNAME .. ' note text - This sets your note, so you can leave info like phone number or if you will be afk for a little bit etc.  You need to list first with the list command.',
}

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
		help = {
			order = 40,
			type = 'group',
			name = 'Help',
			desc = 'Info on how to use this addon.',
			args = {
				text1 = {
					order = 0,
					type = 'description',
					name = [[Click on players in the list to see a menu of options.
Shift-Click to invite.
Ctrl-Click to remove.

Columns can be sorted by clicking on the column header line.
Click to sort next column.
Shift-Click to sort current column.
Ctrl-Click to sort previous column.]]
				},
			},
		}
	}
}

local defaults = {
	global = {
		debug = false,
		name = 'The Fabled',
		prefix = {
			list = 'list',
			unlist = 'unlist',
			invite = 'invite',
			alt = 'alt',
			note = 'note',
			listrequest = 'listrequest',
		},
		timeout = {
			invite = 5, --minutes
			offline = 5, -- minutes
		},
		announcement = {
			message = '',
			officer = false,
			guild = true,
			raid = false,
			channels = 'fabledapps',
			interval = 5, --minutes
		},
		printlist = {
			password = 'oreos',
			channels = 'fabledleaders',
			interval = 10, --minutes
			officer = false,
			guild = false,
			raid = false,
		},
		count = 0,
		oldlist = {},
        altlist = {}
	},
}

--a filter handler to be called by the messsage event handler
--return true causes the msg not to be displayed in the chat frame

--CHAT_MSG_WHISPER
--hide incoming messages
local function WhisperFilter(self, event, msg)
	msg = strlower(strtrim(msg))
	addon:Debug('<<WhisperFilter>>msg='..msg)
	if strfind(msg, addon.db.global.prefix.list) == 1 then
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
	elseif strfind(msg, 'help') == 1 then
		return true
	end
	
	--you could change the msg also by doing
	--return false, gsub(msg, "lol", "")
end

--CHAT_MSG_WHISPER_INFORM
--hide outgoing messages
local function WhisperFilter2(self, event, msg)
	msg = strlower(strtrim(msg))
	addon:Debug('<<WhisperFilter2>>msg='..msg)
	if strfind(msg, "%[" .. strlower(NAME) .. "%]") == 1 then
		return true
	end
end

--Required by AceAddon
--self.db contains the AceDB which gives you access to saved variables
--self.Count keeps track of how much time has passed, each count is one TIMER_INTERVAL
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(DBNAME, defaults)
	self:Debug(DBNAME .. " loaded")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {NAME})
	self.BlizOptionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(NAME, NAME)
	
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperFilter2)
	
	if CURRENTLIST.IsListOpen() then
		self:RegisterEvent("GROUP_ROSTER_UPDATE")
	end
	
	if fListTablet then
		addon.GUI = fListTablet
	end
	
	self.Count = 1
	self.announcementcount = 1
	self.printlistcount = 1
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
		if self.db.global.announcement.interval > 0 then
			--self:Debug("Announcement...")
			if self.Count - self.announcementcount > self.db.global.announcement.interval * 60 / TIMER_INTERVAL then
				self:AnnounceList()
				self.announcementcount = self.Count
			end
		end
		
		if self.db.global.printlist.interval > 0 then
			--self:Debug("Print List...")
			if self.Count - self.printlistcount > self.db.global.printlist.interval * 60 / TIMER_INTERVAL then
				self:PrintList("")
				self.printlistcount = self.Count
			end
		end
		
		--self:Debug("Cleaning up list...")
		for idx,info in ipairs(CURRENTLIST.GetPlayers()) do
			if fList:NameInRaid(info.name) then
				--unlist players in raid
				self:UnlistPlayer(info.name)
			else
				if info.invited then
					--expire invites
					if self.Count - info.invitedcount > self.db.global.timeout.invite * 60 / TIMER_INTERVAL then
						self:ExpireInvite(info.name)
					end
				end
			end
		end
		fLib.Guild.RefreshStatus(fList.UpdateFromGRoster)
	end
	self:Debug("<<TimeUp>>", 'end')
end

function addon.UpdateFromGRoster()
	fLib.Friends.RefreshStatus(fList.UpdateFromFRoster)
end
function addon.UpdateFromFRoster()
	fList:Debug("<<UpdateFromFRoster>>")
	for idx,info in ipairs(CURRENTLIST.GetPlayers()) do
		--update info from fLib.Guild or fLib.Friends
		local rosterdata = fLib.Guild.GetInfo(info.name)
		if not rosterdata then
			rosterdata = fLib.Friends.GetInfo(info.name)
		end
		
		if rosterdata then
			info.level = rosterdata.level
			info.class = rosterdata.class
			info.zone = rosterdata.zone
			info.status = rosterdata.status
			
			if rosterdata.rank then
				info.rank = rosterdata.rank
			else
				info.rank = 'n/a'
			end
			
			if rosterdata.online then
				info.online = 'yes'
			else
				info.online = 'no'
			end
			
			if info.alt and info.alt ~= '' then
				local altrosterdata = fLib.Guild.GetInfo(info.alt)
				if not altrosterdata then
					altrosterdata = fLib.Friends.GetInfo(info.alt)
				end
				if altrosterdata then
					info.altstatus = altrosterdata.status
					if altrosterdata.online then
						info.altonline = 'yes'
					else
						info.altonline = 'no'
					end
				end
			else
				info.altstatus = ''
				info.altonline = ''
			end
			
			--check if to be removed flag needs to be set/unset
			local tbr = false
			if info.status == '<AFK>' or info.online == 'no' then --afk or offline
				--check alt
				if info.alt and #info.alt > 0 then --has an alt set
					if info.altstatus == '<AFK>' or info.altonline == 'no' then --afk or offline
						tbr = true
					end
				else
					tbr = true
				end
			end
	
			if tbr then
				if not info.toberemoved then --flag isn't set
					--set the time this player to be removed from the list
					info.toberemoved = fLib.GetTimestamp(fLib.AddMinutes(nil, AFK_OFFLINE_LIMIT)) --10minutes
				end
			else
				--unsetting the flag
				info.toberemoved = nil
			end
			
			CURRENTLIST.SavePlayerInfo(info,false)
		end

		--remove players who's to be removed flag is set
		--aka they have been afk or offline for too long
		if info.toberemoved and fLib.GetTimestamp() > info.toberemoved then
			addon:Whisper(info.name, "auto-unlisting due to afk/offline for " .. AFK_OFFLINE_LIMIT .. " minute(s); relist when back");
			fList:UnlistPlayer(info.name)
		end
	end
end


function addon:CHAT_MSG_SYSTEM(arg1,arg2)
	--self:Debug('<<CHAT_MSG_SYSTEM>>arg1='..tostring(arg1)..',arg2='..tostring(arg2))

    -- Instantly delist memebers as they join
    if listOpen then
        local JoinedRaid  = strfind(arg2,"has joined the raid group");
        local JoinedParty = strfind(arg2,"joins the party");
        if (JoinedRaid or JoinedParty) then
            local JoinedPlace;
            if JoinedRaid then
                JoinedPlace = JoinedRaid;
            else
                JoinedPlace = JoinedParty;
            end
            local name = strsub(arg2,1,JoinedPlace-2)
            local info = CURRENTLIST.GetPlayerInfo(name); 
            if info then -- are they on the list?
                self:UnlistPlayer(name);
            end
        end
    end

     
--    Agronqui's online tracking stuff, save for me for a bit commented out, or I'll lose it all :)
--    if listOpen then
--        local ComeOnline  = strfind(arg2,"has come online");         
--        --if ComeOnline then           
--	if nil then           
--            local name = strsub(arg2,10,9+(ComeOnline-17)/2);  -- This extracts the player name out of the text links, don't modify it please
--            local info = CURRENTLIST.GetPlayerInfo(name);
--            if info then
--                local rosterinfo = fList.db.global.guildroster[strlower(info.name)];
--                if rosterinfo then
--                    rosterinfo.online = 'yes';
--                else
--                    local froster = fList.db.global.friendroster[strlower(info.name)];
--                    froster.online = 'yes';
--                end
--                info.online = 'yes';                
--                CURRENTLIST.SavePlayerInfo(info,false);
--            end
--
--        end      
--        --local WentOffline  = strfind(arg2,"has gone offline"); 
--        --if WentOffline then
--        if nil then
--            local name = strsub(arg2,1,WentOffline-2);
--            local info = CURRENTLIST.GetPlayerInfo(name);
--            if info then
--                local rosterinfo = fList.db.global.guildroster[strlower(info.name)];
--                if rosterinfo then
--                    rosterinfo.online = 'no';
--                else
--                    local froster = fList.db.global.friendroster[strlower(info.name)];
--                    froster.online = 'no';                    
--                end
--                --info.online = 'no';
--		--self:Debug("--302.6: offline no main, revoking invite");
--                --info.invited = false;
--                --CURRENTLIST.SavePlayerInfo(info,false);
--            end
--
--        end      
--    end
 
end

--CHAT_MSG_WHISPER handler
function addon:CHAT_MSG_WHISPER(eventName, msg, author, lang, status, ...)
	msg = strlower(strtrim(msg))
	cardinalAuthor = fList:CardinalName(author)
	self:Debug("<<CHAT_MSG_WHISPER>>" .. msg)
	
	local words = self:ParseWords(msg)
	if #words < 1 then
		return
	end
	
	local cmd = words[1];
	self:Debug("cmd=" .. cmd)
	
	if cmd == self.db.global.prefix.list then
		--LIST whisper
		--"list" main = cardinalAuthor
		--"list name" main = name, alt = cardinalAuthor (for 
		--listing from an alt)
		local main = cardinalAuthor
		if words[2] then
			self:Debug("words[2]=" .. words[2])
			main = fList:CardinalName(words[2])
		end
		
		self:ListPlayer(main, cardinalAuthor);
	elseif cmd == self.db.global.prefix.unlist then
		--UNLIST whisper
		--"unlist" main = cardinalAuthor
		--"unlist name" main = name (for unlisting from an alt)
		local main = cardinalAuthor
		if words[2] then
			self:Debug("words[2]=" .. words[2])
			main = fList:CardinalName(words[2])
		end
		self:UnlistPlayer(main, cardinalAuthor)
	elseif cmd == self.db.global.prefix.alt then
		--ALT whisper
		--"alt name" main = autor, alt = name
		if words[2] then
			self:AltPlayer(cardinalAuthor, fList:CardinalName(words[2]), cardinalAuthor)
		end
	elseif cmd == self.db.global.prefix.note then
		--NOTE whisper
		--"note text" main = cardinalAuthor, note = text
		if words[2] then
			local notetext = string.sub(table.concat(words, " "), 5)
			self:NotePlayer(cardinalAuthor, notetext, cardinalAuthor)
		end
	elseif cmd == self.db.global.prefix.invite then
		--INVITE whisper
		self:AcceptInvite(cardinalAuthor)
	elseif cmd == self.db.global.prefix.listrequest then
		--LISTREQUEST whisper
		--check cardinalAuthor is an officer
		if fRaid.Player.GetRank(cardinalAuthor) == "Officer" or fRaid.Player.GetRank(cardinalAuthor) == "Officer Alt" or fRaid.Player.GetRank(cardinalAuthor) == "Guild Master" then
			self:PrintList(cardinalAuthor)
		else
			self:Whisper(cardinalAuthor, "Access Denied")
		end
	elseif cmd == 'help' then
		addon:HelpPlayer(cardinalAuthor, fList:CardinalName(words[2]))
	end
end

--GROUP_ROSTER_UPDATE handler
function addon:GROUP_ROSTER_UPDATE()
	self:Debug("<<GROUP_ROSTER_UPDATE>>" .. tostring(GetNumGroupMembers()) .. " members in the raid")
	if GetNumGroupMembers() > 0 then
		self:Debug('more than 0 group members')
		self:UnregisterEvent("GROUP_ROSTER_UPDATE")
		if not UnitInRaid('player') then
			self:Debug('not in raid')			
			ConvertToRaid();
        	addon.GUI:Refresh();
        end
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
		return #fList.db.global.currentlist.players
	end
	return 0
end

function CURRENTLIST.NewList()
	fList.db.global.currentlist = {
		starttime = fLib.GetTimestamp(),
		players = {},
		archive = {}
	}
	if addon.GUI then
		addon.GUI:Refresh()
	end
end

function CURRENTLIST.ClearList()
	fList.db.global.currentlist = nil
	if addon.GUI then
		addon.GUI:Refresh()
	end
end

function CURRENTLIST.GetData()
	return fList.db.global.currentlist
end

function CURRENTLIST.GetPlayers()
	if fList.db.global.currentlist then
		return	fList.db.global.currentlist.players
	else
		return {}
	end
end

--Returns a player info table
function CURRENTLIST.CreatePlayerInfo(name)
	local cardinalName = fList:CardinalName(name)
	local newplayer = {
		name = cardinalName,
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
		joinlisttime = '',
		leavelisttime = '',
		altstatus = '',
		altonline = '',
	}
	--Updating from fLib.Guild or fLib.Friends
	local rosterdata = fLib.Guild.GetInfo(cardinalName)
	if rosterdata then
		newplayer.rank = rosterdata.rank
		newplayer.level = rosterdata.level
		newplayer.class = rosterdata.class
		newplayer.zone = rosterdata.zone
		if rosterdata.online then
         if rosterdata.online == 1 then
		    newplayer.online = 'yes'
		 else
			newplayer.online = 'no'
         end
		end
		newplayer.status = rosterdata.status
    else
        local rosterdata = fLib.Friends.GetInfo(cardinalName)
        if rosterdata then
        	newplayer.level = rosterdata.level
        	newplayer.class = rosterdata.class
        	newplayer.zone = rosterdata.zone
        	if rosterdata.online == 1 then
	        	newplayer.online = 'yes'
	        else
	        	newplayer.online = 'no'
	        end
	        newplayer.status = rosterdata.status
        end
    end
	return newplayer
end

--Returns true if successful
--else false
function CURRENTLIST.SavePlayerInfo(newplayerinfo, isnewplayer)
	--fList:Debug("<<SavePlayerInfo>>")
	if isnewplayer == nil then
		isnewplayer = true
	end
	if CURRENTLIST.IsListOpen() then
		if isnewplayer then
			for idx,info in ipairs(fList.db.global.currentlist.players) do
				fList:Debug(idx .. " comparing " .. info.name .. ' with ' .. newplayerinfo.name)
				if info.name == newplayerinfo.name then
					fList:Debug("MATCH " .. info.name .. ' with ' .. newplayerinfo.name)
					fList.db.global.currentlist.players[idx] = newplayerinfo
					if addon.GUI then
						addon.GUI:Refresh()
					end
					return true
				end
			end
			newplayerinfo.joinlisttime = date("!%y/%m/%d %H:%M:%S")
			tinsert(fList.db.global.currentlist.players, newplayerinfo)
		end
		if fList.GUI then
			fList.GUI:Refresh()
		end
		return true
	end
	return false
end

--Returns a player info table
--returns nil if no currentlist or player not listed
--if you GetPlayerInfo then edit the info, be sure to SavePlayerInfo again, so the GUI is refreshed
function CURRENTLIST.GetPlayerInfo(name)
	local name = fList:CardinalName(name)
	if CURRENTLIST.IsListOpen() then
		for idx,info in ipairs(fList.db.global.currentlist.players) do
			if name == info.name then
				return info
			end
		end
	end
	return nil
end

function CURRENTLIST.RemovePlayerInfo(name)
	local name = fList:CardinalName(name)
	if CURRENTLIST.IsListOpen() then
		for idx,info in ipairs(fList.db.global.currentlist.players) do
			if name == info.name then
				tremove(fList.db.global.currentlist.players, idx)
				info.leavelisttime = date("!%y/%m/%d %H:%M:%S")
				tinsert(fList.db.global.currentlist.archive, info)
				if fList.GUI then
					fList.GUI:Refresh()
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
		self:RegisterEvent("GROUP_ROSTER_UPDATE")
		self:AnnounceList()
		self:Print("List started")
	end
end

--Closes the current list
--self.db.global.oldlist is a list of old lists
function addon:CloseListHandler()
	if CURRENTLIST.IsListOpen() then
        self.db.global.altlist = {};
		self:UnregisterEvent("GROUP_ROSTER_UPDATE")
		
		--save the list in self.db.global.oldlist
		if CURRENTLIST.Count() > 0 then
			local data = CURRENTLIST.GetData()
			data.endtime = fLib.GetTimestamp()
			tinsert(self.db.global.oldlist, data)
		end
		CURRENTLIST.ClearList()
		
		fLib.Friends.CleanUp()
		
		self:Announce("Thank you for listing with " .. self.db.global.name .. ". The list is now closed.")
		self:Print("List closed")
	else
		self:Print("No list to close")
	end
end
function addon:CloseList()
	self:ConfirmDialog2('Are you sure you want to close the current list?', addon.CloseListHandler, self)
end

--List a new player and notifies whispertarget on success or failure
--whisper target to be set as alt
function addon:ListPlayer(name, whispertarget)
	local cardinalName = fList:CardinalName(name)
	local cardinalWhisperTarget = fList:CardinalName(whispertarget)

	self:Debug("500: List player: " .. cardinalName);

	if not whispertarget then
		whispertarget = cardinalName
	else
		whispertarget = cardinalWhisperTarget
	end

	local msg = ''

	--no open list
	if not CURRENTLIST.IsListOpen() then
		msg = "No list available"
		self:Whisper(cardinalWhisperTarget, msg .. ' ' .. helptxtt.txt)
		return
	end

	--listing yourself
	if cardinalName == MYNAME then
		self:Print("Why are you trying to list yourself?? You're the one running this list!!")
		return
	end

	--already in the raid
	if fList:NameInRaid(cardinalName) then
		msg = cardinalName .. " is already in the raid"
		self:Whisper(cardinalWhisperTarget, msg .. ' ' .. helptxtt.txt)
		return
	end

	local info = CURRENTLIST.GetPlayerInfo(cardinalName)
	
	--already listed/invited
	if info then
		if info.invited then
			msg = cardinalName .. " is already invited to the raid"
		else
			msg = cardinalName .. " is already on the list"
		end
		self:Whisper(cardinalWhisperTarget, msg .. ' ' .. helptxtt.txt)
		return
	end
	
	--cardinalWhisperTarget aka alt is already someone else's alt
	local main = fList.GetPlayerFromAlt(cardinalWhisperTarget)
	if main and main ~= cardinalName then
		self:Whisper(cardinalWhisperTarget, "You are already set as the alt of "..main)
		return
	end	
	
	--list them
	info = CURRENTLIST.CreatePlayerInfo(cardinalName)
	CURRENTLIST.SavePlayerInfo(info)
	msg = cardinalName .. " has been added to the list"
	
	self:Whisper(cardinalWhisperTarget, msg .. ' ' .. helptxtt.txt)
	self:Print(msg)
	
	--set alt
	if cardinalWhisperTarget ~= cardinalName then
		fList:AltPlayer(cardinalName, cardinalWhisperTarget, cardinalWhisperTarget)
	end
end

--Set handler for AceConfig
--Will remove the player from the list
function addon:UnlistPlayerHandler(info, name)
	self:UnlistPlayer(name)
end

--Unlist a player and notifies whispertarget
function addon:UnlistPlayer(name, whispertarget)
	local cardinalName = self:CardinalName(name)
	local cardinalWhisperTarget = self:CardinalName(whispertarget)
	local msg = ""
	
	if not CURRENTLIST.IsListOpen() then
		msg = "No list available"
	else		
		local info = CURRENTLIST.GetPlayerInfo(cardinalName);        
		if info then
			self.db.global.altlist[info.alt] = nil
			msg = cardinalName .. " has been removed from the list"
		end
		CURRENTLIST.RemovePlayerInfo(cardinalName)
	end
	
	if cardinalWhisperTarget then
		self:Whisper(cardinalWhisperTarget, msg)
	else
		self:Whisper(cardinalName, msg)
	end
	self:Print(msg)
end

--Set an alt for a player
function addon:AltPlayer(name, alt, whispertarget)
	fList:Debug("<<AltPlayer>>" .. 'name=' ..name .. ' alt=' ..alt .. ' whispertarget=' .. whispertarget)
	local cardinalName = self:CardinalName(name)
	local cardinalAlt = self:CardinalName(alt)
	local cardinalWhisperTarget = self:CardinalName(whispertarget)

	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(cardinalName)
		if not info then
			self:Whisper(cardinalWhisperTarget, cardinalName .. " has not listed yet")
			return
		end
		
		info.alt = cardinalAlt
		if self.db.global.altlist[cardinalAlt] then
			self:Whisper(cardinalWhisperTarget, cardinalAlt .. " is already set as the alt of "..cardinalName)
			return
		else
			self.db.global.altlist[cardinalAlt] = cardinalName;
		end
		
		--Updating from fLib.Guild or fLib.Friends
		local rosterdata = fLib.Guild.GetInfo(info.alt)
		if not rosterdata then
			rosterdata = fLib.Friends.GetInfo(info.alt) 
		end
		if rosterdata then
			info.altstatus = rosterdata.status
			if rosterdata.online and rosterdata.online == 1 then
				info.altonline = 'yes'
			else
				info.altonline = 'no'
			end
		end
        
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(cardinalWhisperTarget, cardinalName .. "'s alt has been set to " .. cardinalAlt)
	else
		self:Whisper(cardinalWhisperTarget, "No list available")
	end
end

--Set a note for a player
function addon:NotePlayer(name, note, whispertarget)
	local cardinalName = self:CardinalName(name)
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(cardinalName)
		if not info then
			self:Whisper(whispertarget, cardinalName .. " has not listed yet")
			return
		end
		--replace % so that note doens't break my tablet in fLibTablet.lua
		note = gsub(note, '%%', '*')
		info.note = note
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(whispertarget, cardinalName .. "'s note has been set to " .. note)
	else
		self:Whisper(whispertarget, "No list available")
	end
end

function addon:HelpPlayer(name, cmd)
	if not cmd or cmd == '' then
		self:Whisper(name, helptxtt.help)
	else
		self:Whisper(name, helptxtt[cmd])
	end
end

--Invite a player to the raid
function addon:AcceptInvite(name)
	local cardinalName = fList:CardinalName(name)
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(cardinalName)
		if not info then
			self:Whisper(cardinalName, cardinalName .. " has not listed yet")
			return
		end
		
		if info.invited then
			InviteUnit(cardinalName)
		else
			self:Whisper(cardinalName, cardinalName .. " does not have an open invite")
		end
	else
		self:Whisper(cardinalName, "List is closed")
	end
end

--Expires a player's invite and whispers them
function addon:ExpireInvite(name)
	local cardinalName = fList:CardinalName(name)
	
	if CURRENTLIST.IsListOpen() then
		local info = CURRENTLIST.GetPlayerInfo(cardinalName)
		if not info then
			return
		end
		
		info.invited = false
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(cardinalName, cardinalName .. "'s invite has expired")
		if #info.alt > 0 then
			self:Whisper(info.alt, cardinalName .. "'s invite has expired.")
		end
	end
end

--Set handler for AceConfig
function addon:InvitePlayerHandler(info, name)
	self:InvitePlayer(name)
end

--Notify a player that they have been invited
function addon:InvitePlayer(name)
	local cardinalName = fList:CardinalName(name)

	if cardinalName then
		if CURRENTLIST.IsListOpen() then
			
			local info = CURRENTLIST.GetPlayerInfo(cardinalName)
			if not info then
				self:Print(cardinalName .. " has not yet listed")
				return
			end
			
			info.invited = true
			info.invitedcount = self.Count
			CURRENTLIST.SavePlayerInfo(info, false)
			local msg = cardinalName .. " has been accepted to the raid. /w " .. 
					UnitName('player') .. " " .. self.db.global.prefix.invite .. 
					" to receive invite.  Your invite will expire in " .. 
					self.db.global.timeout.invite .. " minutes."
			
			--We now always whisper both the alt and the main, and track if either both or neither gets it...			
			self:Whisper(cardinalName, msg)
            info.mainInvited = true;
			if info.alt ~= "" then
    			self:Whisper(info.alt, msg)
                info.altInvited = true;
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
function addon:PrintList(author)
	if CURRENTLIST.IsListOpen() then
		--TODO: sort list
		local listmsg = ''--"Current list: "
		for idx, info in ipairs(CURRENTLIST.GetPlayers()) do
			if info.alt and info.alt ~= '' then
				listmsg = listmsg .. info.name .. "(" .. info.alt .. ") "
			else
				listmsg = listmsg .. info.name .. " "
			end
		end
		if listmsg == '' then
			listmsg = 'empty...'
		else
			listmsg = listmsg .. " " .. CURRENTLIST.Count() .. " total"
		end
		listmsg = '<' .. author .. '> Current list: ' .. listmsg
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

function addon.GetAltFromPlayer(name)
	local info = CURRENTLIST.GetPlayerInfo(name)
	if info then
		return info.alt
	end
end

function addon.GetPlayerFromAlt(alt)
	return fList.db.global.altlist[strlower(alt)]
	--[[
	for idx,info in ipairs(CURRENTLIST.GetPlayers()) do
		if strlower(info.alt) == strlower(alt) then
			return info.name
		end
	end
	--]]
end

--Returns the players in the current list in an array
function addon.GetPlayers(timestamp)
	if CURRENTLIST.IsListOpen() then
		return fList.GetPlayersFromListObj(CURRENTLIST.GetData())
	end
	return {}
end

function addon.GetPlayersFromListObj(listobj)
	local players = {}
	for idx, info in ipairs(listobj.players) do
		tinsert(players, info.name)
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
	local maxMessageLength = 254

	while #msg > 0 do

		local messagePart = string.sub(msg, 1, maxMessageLength)
		msg = string.sub(msg, maxMessageLength + 1, #msg)

		for i = 1, select("#", ...) do
			local chat = select(i, ...)
			if chat ~= "" then
				self:Debug("Attempting to send chat to " .. chat)
				SendChatMessage(messagePart, chat, nil, nil)
			end
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
