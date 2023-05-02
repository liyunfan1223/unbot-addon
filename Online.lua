
function UnBotGetOptionByType(classType)
	for i=1,#(OnlineFrame.options) do
		local opt = OnlineFrame.options[i];
		if (opt.gameclasstype == classType) then
			return opt;
		end
	end
	return nil;
end

function UnBotResetMembers()
	for i=1,#(OnlineFrame.options) do
		local opt = OnlineFrame.options[i];
		opt.members = {};
		if (opt.gameclasstype == "FRIENDS") then
			local num= GetNumFriends();
			if num>0 then
				for x=1,num,1 do
					local name,level,className,un2,online,un4 = GetFriendInfo(x);
					table.insert(opt.members, {[1] = name, [2] = tonumber(level), [3] = tostring(className), [4] = tonumber(online)});
				end
			end
		end
	end

	local num= GetNumGuildMembers();
	if num>0 then
		for i=1,num,1 do
			local name,un1,un2,level,className,un4,un5,un6,online,un8,classFileName= GetGuildRosterInfo(i);
			--local info = "GuildMem "..tostring(name)..","..tostring(level)..","..tostring(className)..","..tostring(online)..","..tostring(classFileName);
			--DisplayInfomation(info);
			--table.insert(UnBotLogInfo, info);
			local opt = UnBotGetOptionByType(classFileName);
			if (opt ~= nil) then
				table.insert(opt.members, {[1] = name, [2] = tonumber(level), [3] = className, [4] = tonumber(online)});
			else
				opt = UnBotGetOptionByType("DEATHKIGHT");
				if (opt ~= nil) then
					table.insert(opt.members, {[1] = name, [2] = tonumber(level), [3] = className, [4] = tonumber(online)});
				end
			end
		end
	end
end

function UnBotShowOnlineFrame()
	if (OnlineFrame.scrollFrame == nil) then
		OnlineFrame.scrollFrame = _G["OnlineFrameListBox"];
		if (OnlineFrame.scrollFrame == nil) then
			DisplayInfomation("打开Online窗口失败。");
			return;
		end
	end
	OnlineFrame.child = OnlineFrame.scrollFrame:GetScrollChild();
	if (OnlineFrame.child == nil) then
		OnlineFrame.child = CreateFrame("Frame", "UnBotScrollChildFrame", OnlineFrame.scrollFrame);
		OnlineFrame.child.memberBars = {};
		OnlineFrame.scrollFrame:SetScrollChild(OnlineFrame.child);
		OnlineFrame.child:SetPoint("TOPLEFT", OnlineFrame.scrollFrame, "TOPLEFT", 0, 0);
		OnlineFrame.child:SetWidth(424);
		OnlineFrame.child:SetHeight(OnlineFrame.scrollFrame:GetHeight());
		OnlineFrame.scrollFrame:SetVerticalScroll(0);
		OnlineFrame.scrollFrame:SetHorizontalScroll(0);
		OnlineFrame.slider = _G["OnlineFrameSlider"];

		OnlineFrame.options = {};
		table.insert(OnlineFrame.options, _G["OnlineFrameFriend"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameWarrior"]);
		table.insert(OnlineFrame.options, _G["OnlineFramePaladin"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameRogue"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameDruid"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameHunter"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameShaman"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameMage"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameWarlock"]);
		table.insert(OnlineFrame.options, _G["OnlineFramePriest"]);
		table.insert(OnlineFrame.options, _G["OnlineFrameDK"]);
	end
	UnBotResetMembers();
	UnBotUpdateChecked(UnBotGetOptionByType("FRIENDS"));
end

function UnBotEnableOption(opt)
	if (opt == nil) then
		return;
	end
	local defaultH = OnlineFrame.scrollFrame:GetHeight();
	local realHeight = 3 + (#(opt.members) * (20 + 3));
	if (realHeight < defaultH) then
		OnlineFrame.child:SetHeight(defaultH);
		OnlineFrame.slider:SetMinMaxValues(0, 0);
		OnlineFrame.slider:SetValueStep(0);
	else
		OnlineFrame.child:SetHeight(realHeight);
		OnlineFrame.slider:SetMinMaxValues(0, realHeight - defaultH);
		OnlineFrame.slider:SetValueStep((realHeight - defaultH) / 10);
	end
	OnlineFrame.slider:SetValue(0);

	for i=1,#(OnlineFrame.child.memberBars) do
		local bar = OnlineFrame.child.memberBars[i];
		bar:Hide();
		bar:SetParent(nil);
	end
	OnlineFrame.child.memberBars = {};
	for i=1,#(opt.members) do
		local newBar = UnBotCreateMemberBar(opt.members[i], i, OnlineFrame.child);
		if (newBar ~= nil) then
			table.insert(OnlineFrame.child.memberBars, newBar);
		end
	end

	OnlineFrame.scrollFrame:SetVerticalScroll(0);
end

function UnBotCreateMemberBar(member, index, fromParent)
	if (fromParent == nil or member == nil) then
		return nil;
	end
	local newFrame = CreateFrame("Button","UnBotMemberBar"..tostring(index),fromParent,"MemberBarTemplate");
	newFrame.unit = member;
	newFrame.index = index;
	local height = newFrame:GetHeight() + 3;
	newFrame:SetPoint("TOPLEFT", fromParent, "TOPLEFT", 10, (3 + (index - 1) * height) * (-1));
	newFrame:SetText(string.format("|cffcc00cc%s|r    |cffffcc00%d 级|r", member[1], member[2]));
	newFrame:Show();
	return newFrame;
end

function UnBotUpdateChecked(selectOpt)
	if (selectOpt == nil) then
		return;
	end
	for i=1,#(OnlineFrame.options) do
		local opt = OnlineFrame.options[i];
		if (opt.gameclasstype == selectOpt.gameclasstype) then
			opt:SetChecked(1);
			UnBotEnableOption(opt);
		else
			opt:SetChecked(nil);
		end
	end
end
