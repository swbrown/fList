fList = LibStub("AceAddon-3.0"):NewAddon("fList", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "fLib")
local addon = fList
local COMNAME = "fList"
local DBNAME = "fListDB"
local TIMER_INTERVAL = 10 --secs

local options = {
	type='group',
	name = addon.name,
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
			    	set = 'InvitePlayer',
	    		},
	    		removeplayer = {
	    			order = 14,
			    	type = 'input',
			    	name = 'Remove Player',
			    	desc = 'Remove a player from the list',
			    	set = 'RemovePlayer',
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
	if strfind(msg, "%[" .. COMNAME .. "%]") == 1 then
		return true
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
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, options, {self.name})
	self.BlizOptionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addon.name, self.name)
	
	self:RegisterEvent("CHAT_MSG_WHISPER")
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", WhisperFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", WhisperFilter)
	
	self.Count = 1
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


--CHAT_MSG_WHISPER handler
function addon:CHAT_MSG_WHISPER(eventName, msg, author, lang, status, ...)
	msg = strtrim(msg)
	self:Debug("<<CHAT_MSG_WHISPER>>" .. msg)
	
	if strfind(msg, self.db.global.prefix.list) == 1 then
		--LIST whisper
		--"list" main = author
		--"list name" main = name, alt = author (for listing from an alt)
		local main = author
		local alt = ""
		
		if #msg > #self.db.global.prefix.list then
			self:Debug(#msg .. ">" .. #self.db.global.prefix.list)

			main = self:ParseName(msg)
			alt = author
			self:Debug("main=" .. main .. ",alt=" .. alt)
		end
		
		self:ListPlayer(main, author)
		if #alt > 0 then
			self:AltPlayer(main, alt, author)
		end
	elseif strfind(msg, self.db.global.prefix.unlist) == 1 then
		--UNLIST whisper
		--"unlist" main = author
		--"unlist name" main = name (for unlisting from an alt)
		local main = author
		
		if #msg > #self.db.global.prefix.unlist then
			self:Debug(#msg .. ">" .. #self.db.global.prefix.unlist)
			
			main = self:ParseName(msg)
			self:Debug("main=" .. main)
		end
		
		self:UnlistPlayer(main, author)
	elseif strfind(msg, self.db.global.prefix.alt) == 1 then
		--ALT whisper
		self:AltPlayer(author, self:ParseName(msg), author)
	elseif strfind(msg, self.db.global.prefix.note) == 1 then
		--NOTE whisper
		self:NotePlayer(author, self:ParseName(msg), author)
	elseif strfind(msg, self.db.global.prefix.invite) == 1 then
		--INVITE whisper
		self:AcceptInvite(author)
	elseif strfind(msg, self.db.global.prefix.listrequest) == 1 then
		--LISTREQUEST whisper
		addon:Debug("LISTREQUEST is not implemented yet")
	end
end

--PARTY_MEMBERS_CHANGED handler
function addon:PARTY_MEMBERS_CHANGED()
	self:Debug("<<PARTY_MEMBERS_CHANGED>>" .. tostring(GetNumPartyMembers()) .. " in the raid")
	if GetNumPartyMembers() > 0 then
		ConvertToRaid()
	end
end

--Returns true if there is a current list
function addon:IsListOpen()
	if self.db.global.currentlist then
		return true
	else
		return false
	end
end

--Returns true if name is on the list
function addon:IsPlayerListed(name)
	if self:IsListOpen() then
		if self.db.global.currentlist[name] then
			return true
		end
	end
	return false
end

--Starts a new list
function addon:StartList()
	if self:IsListOpen() then
		self:Print("List has already started")
	else
		self.db.global.currentlist = {}
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:Announce(self.db.global.announcement.message .. " /w " .. UnitName("player") .. " " .. self.db.global.prefix.list)
		self:Print("List started")
	end
end

--Closes the current list
--self.db.global.count keeps track of how many lists have been run
--self.db.global.oldlist saves each list
function addon:CloseList()
	if self:IsListOpen() then
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		
		if self.db.global.count == nil then
			self.db.global.count = 0
		end
		if self.db.global.oldlist == nil then
			self.db.global.oldlist = {}
		end
		
		if #self.db.global.currentlist > 0 then
			self.db.global.count = self.db.global.count + 1
			self.db.global.oldlist[self.db.global.count] = self.db.global.currentlist
		end
		self.db.global.currentlist = nil
		self:Announce("Thank you for listing with " .. self.db.global.name .. ". The list is now closed.")
		self:Print("List closed")
	else
		self:Print("No list to close.")
	end
end

--Handler for our AceTimer repeating timer (created during initialization)
--Increment self.Count
--Clean up list
function addon:TimeUp()
	self:Debug("<<TimeUp>>")
	self.Count = self.Count + 1
	if self:IsListOpen() then
		self:Debug("Cleaning up list...")
		for name, info in pairs(self.db.global.currentlist) do
			if UnitInRaid(name) then
				--unlist players in raid
				self:UnlistPlayer(name)
			elseif info.accepted then
				--expire invites
				if addon.Count - info.acceptedcount > self.db.global.timeout.invite * 60 / TIMER_INTERVAL then
					self:ExpireInvite(name)
				end
			end
		end
	end
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
	if self:IsListOpen() then
		if #self.db.global.currentlist == 0 then
			self:AnnounceInChannels("List is empty", {strsplit("\n", self.db.global.printlist.channels)})
			self:AnnounceInChat("List is empty",
				self:CreateChatList(
					self.db.global.printlist.officer,
					self.db.global.printlist.guild,
					self.db.global.printlist.raid))

		else
			fmt = "%-12s%-12s%-8s%s"
			listmsg = string.format(fmt, "name", "alt", "invited", "note")
			self:AnnounceInChannels(listmsg, {strsplit("\n", self.db.global.printlist.channels)})
			self:AnnounceInChat(listmsg,
				self:CreateChatList(
					self.db.global.printlist.officer,
					self.db.global.printlist.guild,
					self.db.global.printlist.raid))
			
			for name, info in pairs(self.db.global.currentlist) do
				if info.alt == nil then info.alt = "" end
				if info.note == nil then info.note = "" end
				if info.accepted == nil then info.accepted = false end
				listmsg = string.format(fmt, name, info.alt, info.accepted and "yes" or "", info.note)
				self:AnnounceInChannels(listmsg, {strsplit("\n", self.db.global.printlist.channels)})
				self:AnnounceInChat(listmsg,
					self:CreateChatList(
						self.db.global.printlist.officer,
						self.db.global.printlist.guild,
						self.db.global.printlist.raid))
			end
		end
	else
		self:Print("No list available")
	end
end

--List a new player and notifies whispertarget on success or failure
function addon:ListPlayer(name, whispertarget)
	local msg = ""
	if not self:IsListOpen() then
		msg = "No list available"
	elseif UnitInRaid(name) then
		msg = name .. " is already in the raid"
	elseif self:IsPlayerListed(name) then
		msg = name .. " is already on the list"
	else
		self.db.global.currentlist[name] = {
			alt = "",
			note = "",
			accepted = false,
			acceptedcount = 0,
		}
		msg = name .. " have been added to the list"
	end
	
	if whispertarget then
		self:Whisper(whispertarget, msg)
	else
		self:Whisper(name, msg)
	end
	self:Print(msg)
end

--Unlist a player and notifies whispertarget
function addon:UnlistPlayer(name, whispertarget)
	local msg = ""
	if not self:IsListOpen() then
		msg = "No list available"
	else
		self.db.global.currentlist[name] = nil
		msg = name .. " has been removed from the list"
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
	if self:IsListOpen() then
		if self:IsPlayerListed(name) then
			self:Whisper(whispertarget, "You have not yet listed")
		else
			self.db.global.currentlist[name].alt = alt
			self:Whisper(whispertarget, "Your alt has been sent to " .. alt)
		end
	else
		self:Whisper(whispertarget, "No list available")
	end
end

--Set a note for a player
function addon:NotePlayer(name, note, whispertarget)
	if self:IsListOpen() then
		if self:IsPlayerListed(name) then
			self:Whisper(whispertarget, "You have not yet listed")
		else
			self.db.global.currentlist[name].note = note
			self:Whisper(whispertarget, "Your note has been set to " .. note)
		end
	else
		self:Whisper(whispertarget, "No list available")
	end
end

--Invite a player to the raid
function addon:AcceptInvite(name)
	if self:IsListOpen() then
		if self:IsPlayerListed(name) then
			if self.db.global.currentlist[name].accepted then
				InviteUnit(name)
			else
				self:Whisper(name, "You have been caught trying to cheat!")
			end
		else
			self:Whisper(name, "You have not yet listed")
		end
	else
		self:Whisper(name, "List is closed")
	end
end

--Expires a player's invite and whispers them
function addon:ExpireInvite(name)
	if self:IsListOpen() then
		if self:IsPlayerListed(name) then
			self.db.global.currentlist[name].accepted = false
			self:Whisper(name, "Your invite has expired.")
			if #self.db.global.currentlist[name].alt > 0 then
				self:Whisper(self.db.global.currentlist[name].alt, "Your invite has expired.")
			end
		end
	end
end

--Set handler for AceConfig
--Notify a player that they have been accepted
function addon:InvitePlayer(info, name)
	self:Debug("Attempting to invite " .. name)
	if name then
		if self:IsListOpent() then
			if self:IsPlayerListed(name) then
				self.db.global.currentlist[name].accepted = true
				self.db.global.currentlist[name].acceptedcount = self.Count
				local msg = "You have been accepted to the raid. /w " .. 
					UnitName("player") .. " " .. self.db.global.prefix.invite .. 
					" to recieve invite.  Your invite will expre in " .. 
					self.db.global.timeout.invite .. " minutes."
				self:Whisper(name, msg)
				if self.db.global.currentlist[name].alt ~= "" then
					self:Whisper(self.db.global.currentlist[name].alt, msg)
				end
			else
				self:Print("Nobody by that name is listed")
			end
		else
			self:Print("No list available.")
		end
	end
end

--Set handler for AceConfig
--Will remove the player from the list
function addon:RemovePlayer(info, name)
	self:UnlistPlayer(name)
end

--Send a whisper
function addon:Whisper(name, msg)
	SendChatMessage("[fList]" .. msg, "WHISPER", nil, name)
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