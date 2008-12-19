--AceAddon-3.0
--AceConsole-3.0
--AceEvent-3.0
--AceTimer-3.0
--AceDB-3.0
--AceConfig-3.0
--AceConfigDialog-3.0


fList = LibStub("AceAddon-3.0"):NewAddon("fList", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "fLib")
local addon = fList
local NAME = 'fList'
local DBNAME = 'fListDB'
local MYNAME = UnitName('player')

local TIMER_INTERVAL = 10 --secs
local GUILD_ROSTER_INTERVAL = 50 --secs

local CURRENTLIST = {} --table to hold functions
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
		guildroster = {},
        friendroster = {}
	},
}

--a filter handler to be called by the messsage event handler
--return true causes the msg not to be displayed in the chat frame

--CHAT_MSG_WHISPER
--hide incoming messages
local function WhisperFilter(msg)
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
	end
	
	--you could change the msg also by doing
	--return false, gsub(msg, "lol", "")
end

--CHAT_MSG_WHISPER_INFORM
--hide outgoing messages
local function WhisperFilter2(msg)
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
	
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperFilter2)
	
	if CURRENTLIST.IsListOpen() then
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	end
	
	if fListTablet then
		addon.GUI = fListTablet
	end
	
	self.Count = 1
	self.announcementcount = 1
	self.printlistcount = 1
	self.guildrostercount = 1
	self.Timer = self:ScheduleRepeatingTimer(self["TimeUp"], TIMER_INTERVAL, self)
	
	self:Debug("<<OnInitialize>> end")
    self.db.global.guildroster = {};
    GuildRoster();
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
	--self:Debug("<<TimeUp>>")
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
				--self:AnnounceList()
				self.printlistcount = self.Count
			end
		end
		
		if GUILD_ROSTER_INTERVAL > 0 then
			--self:Debug("Guild Roster...")
			if self.Count - self.guildrostercount > GUILD_ROSTER_INTERVAL * 60 / TIMER_INTERVAL then
				GuildRoster()
				self.guildrostercount = self.Count
			end
		end
		
		--self:Debug("Cleaning up list...")
		for idx,info in ipairs(CURRENTLIST.GetPlayers()) do
			if UnitInRaid(info.name) then
				--unlist players in raid
				self:UnlistPlayer(info.name)
			else
				--update info to match guild roster
				local rosterdata = fList.db.global.guildroster[strlower(info.name)]
				--self:Debug("104" .. GetGuild)
				if rosterdata then
					info.rank = rosterdata.rank
					info.rankIndex = rosterdata.rankIndex
					info.level = rosterdata.level
					info.class = rosterdata.class
					info.zone = rosterdata.zone
					--self:Debug("105" .. rosterdata.rank .. " : " .. strlower(info.name))
					if rosterdata.online then
                      if rosterdata.online == 'yes' then					   
						info.online = 'yes'
					  else
						info.online = 'no'
					  end
                    else
                    
                    end
					info.status = rosterdata.status                                
					CURRENTLIST.SavePlayerInfo(info,false)
				else
                  local froster = self.db.global.friendroster[strlower(info.name)];
                  if froster then
                    info.rank = "NON";
                    info.rankIndex = 0;
                    info.level = froster.level;
                    info.class = froster.class;
                    info.zone = froster.zone;
                    if froster.online then
                      if froster.online == 'yes' then
                        info.online = 'yes';
                      else
                        info.online = 'no';
                      end
                    else 
                      
                    end
                    info.status = froster.status                                
					CURRENTLIST.SavePlayerInfo(info,false)
                  else

                  end
                end
				
				--TODO: remove players from list if offline for too long
				
				if info.invited then
					--expire invites
					if self.Count - info.invitedcount > self.db.global.timeout.invite * 60 / TIMER_INTERVAL then
						self:ExpireInvite(info.name)
					end
				end
			end
		end
	end
end

--GUILD_ROSTER_UPDATE handler
function addon:GUILD_ROSTER_UPDATE()
	for i=1,GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, 
			officernote, online, status, something = GetGuildRosterInfo(i)        
        if online then
            online = 'yes';            
        else
          online = 'no';
        end
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
    for i=1,GetNumFriends(true) do
		local name, level, class, zone, online, status, note = GetFriendInfo(i)        
        if online then
            online = 'yes';            
        else
            online = 'no';          
        end
		if not self.db.global.friendroster then            
			self.db.global.friendroster = {}
		end
		self.db.global.friendroster[strlower(name)] = {
			name = name,			
			level = level,
			class = class,
			zone = zone,
			online = online,
			status = status,
            note = note
		}
	end
end

function addon:CHAT_MSG_SYSTEM(arg1,arg2)
	--self:Debug('<<CHAT_MSG_SYSTEM>>arg1='..tostring(arg1)..',arg2='..tostring(arg2))
	
	local listOpen = CURRENTLIST.IsListOpen() ;
	if listOpen and (strfind(arg2, 'No player named') == 1) then
		local a = strfind(arg2,"'");
		local b = strfind(arg2,"'",a+1);
		if a and b then
			local name = strsub(arg2,a+1,b-1)
			local info = CURRENTLIST.GetPlayerInfo(name)		    
			if info then --need to check if info here, in case player was deleted

                if self.db.global.guildroster[strlower(name)] then                  
                  self.db.global.guildroster[strlower(name)].online = 'no';                  
                else
                  AddFriend(name);
                  self.db.global.friendroster[strlower(name)].online = 'no';
                end
                
				if strlen(info.alt) == 0 then
					self:Debug("302.5: offline no main, revoking invite");
					info.invited = false;
					info.online = 'no';
					CURRENTLIST.SavePlayerInfo(info, false);
				end
			end
		end
	end
  
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

      
    if listOpen then
        local ComeOnline  = strfind(arg2,"has come online");         
        if ComeOnline then           
            local name = strsub(arg2,10,9+(ComeOnline-17)/2);  -- This extracts the player name out of the text links, don't modify it please
            local info = CURRENTLIST.GetPlayerInfo(name);
            if info then
                local rosterinfo = fList.db.global.guildroster[strlower(info.name)];
                if rosterinfo then
                    rosterinfo.online = 'yes';
                else
                    local froster = fList.db.global.friendroster[strlower(info.name)];
                    froster.online = 'yes';
                end
                info.online = 'yes';                
                CURRENTLIST.SavePlayerInfo(info,false);
            end

        end      
        local WentOffline  = strfind(arg2,"has gone offline"); 
        if WentOffline then
            local name = strsub(arg2,1,WentOffline-2);
            local info = CURRENTLIST.GetPlayerInfo(name);
            if info then
                local rosterinfo = fList.db.global.guildroster[strlower(info.name)];
                if rosterinfo then
                    rosterinfo.online = 'no';
                else
                    local froster = fList.db.global.friendroster[strlower(info.name)];
                    froster.online = 'no';                    
                end
                info.online = 'no';
                info.invited = false;
                CURRENTLIST.SavePlayerInfo(info,false);
            end

        end      
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
	
	--update the guildees online status if they whisper you
	if self.db.global.guildroster[author] then
		self.db.global.guildroster[author].online = 'yes'
    else
        if self.db.global.friendroster[author] then
          self.db.global.friendroster[author].online = 'yes'
        else
          self.db.global.friendroster[author] = {};
          self.db.global.friendroster[author].online = 'yes'
        end
	end
	
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
		
        local lowerMain = strlower(main);
        local dontList  = 0;
        if self.db.global.altlist then
          if self.db.global.altlist[lowerMain] then
              local msg = fList:Capitalize(main) .. " is already listed as the alt of " .. fList:Capitalize(self.db.global.altlist[lowerMain]) .. ", not listing.";
              self:Whisper(author, msg);
              dontList = 1;
          end
        end 
        if dontList == 0 then
          local gotListed = self:ListPlayer(main, author);
  		  if (#alt > 0) and (gotListed ~= 0) then
  	        self:AltPlayer(main, alt, author)
		  end         
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
		ConvertToRaid();
        addon.GUI:Refresh();
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
		--return #fList.db.global.currentlist
		return #fList.db.global.currentlist.players
	end
	return 0
end

function CURRENTLIST.NewList()
	--fList.db.global.currentlist = {}
	fList.db.global.currentlist = {
		starttime = date("%m/%d/%y %H:%M:%S"),
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
	return	fList.db.global.currentlist.players
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
		joinlisttime = '',
		leavelisttime = '',
	}
	if fList.db.global.guildroster[name] then
		local rosterdata = fList.db.global.guildroster[name]
		newplayer.rank = rosterdata.rank
		newplayer.rankIndex = rosterdata.rankIndex
		newplayer.level = rosterdata.level
		newplayer.class = rosterdata.class
		newplayer.zone = rosterdata.zone
		if rosterdata.online then
         if rosterdata.online == 'yes' then
		    newplayer.online = 'yes'
		 else
			newplayer.online = 'no'
         end
		end
		newplayer.status = rosterdata.status	
    else
        AddFriend(name);
        GuildRoster();
        local frosterdata = fList.db.global.friendroster[name]		
        if frosterdata then
			newplayer.level = frosterdata.level
			newplayer.class = frosterdata.class
			newplayer.zone = frosterdata.zone
			if frosterdata.online then
             if frosterdata.online == 'yes' then
			    newplayer.online = 'yes'
			 else
				newplayer.online = 'no'
             end
			end
			newplayer.status = frosterdata.status
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
			--for idx,info in ipairs(fList.db.global.currentlist) do
			for idx,info in ipairs(fList.db.global.currentlist.players) do
				fList:Debug(idx .. " comparing " .. info.name .. ' with ' .. newplayerinfo.name)
				if info.name == newplayerinfo.name then
					fList:Debug("MATCH " .. info.name .. ' with ' .. newplayerinfo.name)
					--fList.db.global.currentlist.idx = newplayerinfo
					fList.db.global.currentlist.players[idx] = newplayerinfo
					if addon.GUI then
						addon.GUI:Refresh()
					end
					return true
				end
			end
			--fList.db.global.currentlist[#fList.db.global.currentlist + 1] = newplayerinfo
			newplayerinfo.joinlisttime = date("%m/%d/%y %H:%M:%S")
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
	if CURRENTLIST.IsListOpen() then
		name = strlower(strtrim(name))
		name = fList:Capitalize(name)
		--for idx,info in ipairs(fList.db.global.currentlist) do
		for idx,info in ipairs(fList.db.global.currentlist.players) do         
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
		--for idx,info in ipairs(fList.db.global.currentlist) do
		for idx,info in ipairs(fList.db.global.currentlist.players) do
			if name ==  info.name then
				--tremove(fList.db.global.currentlist, idx)
				tremove(fList.db.global.currentlist.players, idx)
				info.leavelisttime = date("%m/%d/%y %H:%M:%S")
				tinsert(fList.db.global.currentlist.archive, info)
				if fList.GUI then
					fList.GUI:Refresh()
				end
			end
		end
	end
end

function CURRENTLIST.RemovePlayerAlt(name)
	if CURRENTLIST.IsListOpen() then
        name = strlower(strtrim(name));	
        fList:Debug("Addy4444: " .. name);	
		for idx,info in pairs(fList.db.global.altlist) do
            fList:Debug("Addy4445: name = " .. name .. "  -- info = " .. info .. "  -- idx = " .. idx);	
			if name ==  idx then
				fList.db.global.altlist[idx] = nil;			
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
--self.db.global.count keeps track of how many lists have been run  --don't need this...
--self.db.global.oldlist is a list of old lists
function addon:CloseListHandler(callback)
	if CURRENTLIST.IsListOpen() then
        self.db.global.altlist = {};
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		
		--if self.db.global.count == nil then
		--	self.db.global.count = 0
		--end
		if self.db.global.oldlist == nil then
			self.db.global.oldlist = {}
		end
		
		--save the list in self.db.global.oldlist
		if CURRENTLIST.Count() > 0 then
			--self.db.global.count = self.db.global.count + 1
			--self.db.global.oldlist[self.db.global.count] = CURRENTLIST.GetPlayers()
			local data = CURRENTLIST.GetData()
			data.endtime = date("%m/%d/%y %H:%M:%S")
			tinsert(self.db.global.oldlist, data)
		end
		CURRENTLIST.ClearList()
		self:Announce("Thank you for listing with " .. self.db.global.name .. ". The list is now closed.")
		self:Print("List closed")
	else
		self:Print("No list to close")
	end
	callback()
end
function addon:CloseList()
	self:ConfirmDialog('Are you sure you want to close the current list?', 'YESNO', addon.CloseListHandler, self)
end

--List a new player and notifies whispertarget on success or failure
function addon:ListPlayer(name, whispertarget)
        self:Debug("500: List player: " .. name);
    local gotListed = 0;
	name = strlower(strtrim(name))
	local capname = self:Capitalize(name)
	whispertarget = strtrim(whispertarget)
	
	if name == strlower(MYNAME) then
		self:Print("Why are you trying to list yourself?? You're the one running this list!!")		
	end
	
	local msg = ""
    local inRaid = UnitInRaid(name);
	if not CURRENTLIST.IsListOpen() then
		msg = "No list available"
	elseif inRaid then
		msg = capname .. " is already in the raid"
	else
		local info = CURRENTLIST.GetPlayerInfo(name)
		if info then
			msg = capname .. " is already on the list"
		else
			local newplayerinfo = CURRENTLIST.CreatePlayerInfo(name)
			CURRENTLIST.SavePlayerInfo(newplayerinfo)
            gotListed = 1;
			msg = capname .. " has been added to the list"
		end
	end
	

	if whispertarget then
		self:Whisper(whispertarget, msg)
	else
		self:Whisper(name, msg)
	end
	self:Print(msg)
    return gotListed;
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
        local info = CURRENTLIST.GetPlayerInfo(name);
        self:Debug("Addy404: " .. name);
        if info then
          self:Debug("Addy405: " .. name);
          if info.alt ~= "" then
            self:Debug("Addy406: " .. name);
            if self.db.global.altlist then
              if self.db.global.altlist[info.alt] then
                self:Debug("Addy407: " .. name .. "  --  " .. info.alt);
                CURRENTLIST.RemovePlayerAlt(info.alt)
              end
            end
          end
		  msg = capname .. " has been removed from the list"
        end
        CURRENTLIST.RemovePlayerInfo(name)
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
        if self.db.global.altlist then
        else 
          self.db.global.altlist = {};
        end
        self.db.global.altlist[alt] = name;
		CURRENTLIST.SavePlayerInfo(info, false)
		self:Whisper(whispertarget, capname .. "'s alt has been set to " .. capalt)
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
			local msg = capname .. " has been accepted to the raid. /w " .. 
					UnitName('player') .. " " .. self.db.global.prefix.invite .. 
					" to receive invite.  Your invite will expire in " .. 
					self.db.global.timeout.invite .. " minutes."
			
			--We now always whisper both the alt and the main, and track if either both or neither gets it...			
			self:Whisper(name, msg)
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
function addon:PrintList()
	if CURRENTLIST.IsListOpen() then
		--TODO: sort list
		local listmsg = ''--"Current list: "
		for idx, info in ipairs(CURRENTLIST.GetPlayers()) do
			listmsg = listmsg .. info.name .. " "
		end
		if listmsg == '' then
			listmsg = 'empty...'
		end
		listmsg = 'Current list: ' .. listmsg
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
function addon:GetPlayers()
	local players = {}
	if CURRENTLIST.IsListOpen() then
		for idx, info in ipairs(CURRENTLIST.GetPlayers()) do
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
