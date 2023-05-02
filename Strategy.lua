
local function GetClassFlag(className)
	if (className == "戰士") then
		return 1;
	elseif (className == "聖騎士") then
		return 2;
	elseif (className == "盜賊") then
		return 3;
	elseif (className == "德魯伊") then
		return 4;
	elseif (className == "獵人") then
		return 5;
	elseif (className == "薩滿") then
		return 6;
	elseif (className == "法師") then
		return 7;
	elseif (className == "術士") then
		return 8;
	elseif (className == "牧師") then
		return 9;
	else
		return nil;
	end
end

local function CreateStrategyFrame(name)
	local strategyFrame = CreateFrame("Frame","StrategyFrame"..name,UIParent,"StrategyFrameTemplate");
	strategyFrame.targetName = name;
	strategyFrame.recvType = 0;
	if (AddToUnBotStrategyFrame(strategyFrame, "StrategyFrame"..name) == false) then
		strategyFrame:Hide();
		strategyFrame:SetParent(nil);
		return nil;
	end

	strategyFrame.title = strategyFrame:CreateFontString(strategyFrame:GetName().."Title","ARTWORK");
	strategyFrame.title:SetFont([[Fonts\ZYHei.ttf]],24);
	strategyFrame.title:SetTextColor(1,0,1,1);
	strategyFrame.title:SetText("|cff00ffff"..name.."|r".."策略编辑器");
	strategyFrame.title:SetPoint("TOP",strategyFrame,"TOP",0,5);
	strategyFrame.title:SetShadowColor(0,0,0);
	strategyFrame.title:SetShadowOffset(1,-1);

	strategyFrame.leftText = strategyFrame:CreateFontString(strategyFrame:GetName().."LeftText","ARTWORK");
	strategyFrame.leftText:SetFont([[Fonts\ZYHei.ttf]],24);
	strategyFrame.leftText:SetTextColor(1,0,0,1);
	strategyFrame.leftText:SetText("战斗策略");
	strategyFrame.leftText:SetPoint("CENTER",strategyFrame,"TOPLEFT",80,-52);
	strategyFrame.leftText:SetShadowColor(0,0,0);
	strategyFrame.leftText:SetShadowOffset(1,-1);

	strategyFrame.rightText = strategyFrame:CreateFontString(strategyFrame:GetName().."RightText","ARTWORK");
	strategyFrame.rightText:SetFont([[Fonts\ZYHei.ttf]],24);
	strategyFrame.rightText:SetTextColor(0,1,0,1);
	strategyFrame.rightText:SetText("非战斗策略");
	strategyFrame.rightText:SetPoint("CENTER",strategyFrame,"TOPRIGHT",-85,-52);
	strategyFrame.rightText:SetShadowColor(0,0,0);
	strategyFrame.rightText:SetShadowOffset(1,-1);

	strategyFrame.leftScrollFrame = CreateFrame("ScrollFrame", "StrategyListFrameLeft"..name, strategyFrame,"StrategyListFrameTemplate");
	strategyFrame.leftScrollFrame:SetPoint("TOPLEFT", strategyFrame, "TOPLEFT", 15, -65);
	strategyFrame.leftScrollFrame.strategyFrame = strategyFrame;
	strategyFrame.leftScrollFrame.slider = CreateFrame("Slider", "StrategyFrameChildLeftSlider"..name, strategyFrame.leftScrollFrame, "StrategyListFrameSlider");
	strategyFrame.leftScrollFrame.slider.scrollFrame = strategyFrame.leftScrollFrame;
	strategyFrame.leftScrollFrame.slider:SetPoint("TOPRIGHT", strategyFrame.leftScrollFrame, "TOPRIGHT", 0, 0);

	strategyFrame.rightScrollFrame = CreateFrame("ScrollFrame", "StrategyListFrameRight"..name, strategyFrame,"StrategyListFrameTemplate");
	strategyFrame.rightScrollFrame:SetPoint("TOPRIGHT", strategyFrame, "TOPRIGHT", -15, -65);
	strategyFrame.rightScrollFrame.strategyFrame = strategyFrame;
	strategyFrame.rightScrollFrame.slider = CreateFrame("Slider", "StrategyFrameChildLeftSlider"..name, strategyFrame.rightScrollFrame, "StrategyListFrameSlider");
	strategyFrame.rightScrollFrame.slider.scrollFrame = strategyFrame.rightScrollFrame;
	strategyFrame.rightScrollFrame.slider:SetPoint("TOPRIGHT", strategyFrame.rightScrollFrame, "TOPRIGHT", 0, 0);

	local childGap = 5;
	strategyFrame.leftScrollFrame.child = CreateFrame("Frame", "StrategyFrameChildLeft"..name, strategyFrame.leftScrollFrame);
	strategyFrame.leftScrollFrame.child.memberBars = {};
	strategyFrame.leftScrollFrame.child:SetPoint("TOPLEFT", strategyFrame.leftScrollFrame, "TOPLEFT", childGap, -childGap);
	strategyFrame.leftScrollFrame.child:SetWidth(strategyFrame.leftScrollFrame:GetWidth() - (childGap * 2));
	strategyFrame.leftScrollFrame.child:SetHeight(strategyFrame.leftScrollFrame:GetHeight() - (childGap * 2));
	strategyFrame.leftScrollFrame:SetScrollChild(strategyFrame.leftScrollFrame.child);

	strategyFrame.rightScrollFrame.child = CreateFrame("Frame", "StrategyFrameChildLeft"..name, strategyFrame.rightScrollFrame);
	strategyFrame.rightScrollFrame.child.memberBars = {};
	strategyFrame.rightScrollFrame.child:SetPoint("TOPLEFT", strategyFrame.rightScrollFrame, "TOPLEFT", childGap, -childGap);
	strategyFrame.rightScrollFrame.child:SetWidth(strategyFrame.rightScrollFrame:GetWidth() - (childGap * 2));
	strategyFrame.rightScrollFrame.child:SetHeight(strategyFrame.rightScrollFrame:GetHeight() - (childGap * 2));
	strategyFrame.rightScrollFrame:SetScrollChild(strategyFrame.rightScrollFrame.child);

	strategyFrame:Show();

	local closeFrame = CreateFrame("Button","StrategyFrameCloseBtn"..name,strategyFrame,"UIPanelCloseButton");
	closeFrame:SetWidth(58);
	closeFrame:SetHeight(58);
	closeFrame:Show();
	closeFrame:SetPoint("TOPRIGHT", strategyFrame, "TOPRIGHT", 20, 20);
	closeFrame:SetScript("OnClick", function()
		RemoveFromStrategyFrame(strategyFrame)
		strategyFrame:Hide()
		strategyFrame:SetParent(nil)
	end);

	return strategyFrame;
end

local function CreateStrategyListItem(name, scrollFrame, src, strategyType)
	if (scrollFrame == nil or src == nil) then
		return;
	end
	local gap = 3;
	local onceHeight = 18 + gap;
	local srcHeight = scrollFrame.child:GetHeight();
	local newHeight = gap + (#src) * onceHeight;
	local useHeight = srcHeight;
	scrollFrame.slider:SetMinMaxValues(0, 0);
	scrollFrame.slider:SetValueStep(0);
	if (newHeight > srcHeight) then
		useHeight = newHeight;
		scrollFrame.slider:SetMinMaxValues(0, useHeight - srcHeight);
		scrollFrame.slider:SetValueStep((useHeight - srcHeight) / 10);
	end
	scrollFrame.child:SetHeight(useHeight);

	if (scrollFrame.strategies ~= nil) then
		for i=1, #(scrollFrame.strategies) do
			scrollFrame.strategies[i]:SetParent(nil);
			scrollFrame.strategies[i]:Hide();
			_G[scrollFrame.strategies[i]:GetName()] = nil;
		end
	end
	scrollFrame.strategies = {};

	for i=1, #src do
		local strategyOptionBtn = CreateFrame("Button","StrategyOption"..scrollFrame:GetName()..tostring(i),scrollFrame.child,"StrategyOptionTemplate");
		strategyOptionBtn:SetPoint("TOPLEFT", scrollFrame.child, "TOPLEFT", 8, (gap + onceHeight * (i - 1)) * (-1));
		strategyOptionBtn:Show();
		strategyOptionBtn.strategyFrame = scrollFrame.strategyFrame;
		strategyOptionBtn.targetName = name;
		strategyOptionBtn.use = false;
		strategyOptionBtn.data = src[i];
		strategyOptionBtn.strategyType = strategyType;
		if (src[i][2] ~= nil) then
			strategyOptionBtn:SetText("|cff00ffff"..src[i][2].."|r");
		end
		table.insert(scrollFrame.strategies, strategyOptionBtn);
	end
end

function UnBotShowStrategyFrame(name, className)
	local strategyFrame = CreateStrategyFrame(name);
	if (strategyFrame == nil) then
		return;
	end
	CreateStrategyListItem(name, strategyFrame.leftScrollFrame, ClassStrategyCO, 1);
	CreateStrategyListItem(name, strategyFrame.rightScrollFrame, ClassStrategyNC, 2);

	UnBotFlushStrategyData(strategyFrame, name);
end

function UnBotFlushStrategyData(strategyFrame, name)
	if (name == nil) then
		return;
	end

	strategyFrame.recvType = 1;
	SendChatMessage("co ?", "WHISPER", nil, name);
end

function UnBotRecvStrategyCOInfo(strategyFrame, info)
	local textList = UnBotSplit(info, ",");
	local strategies = {};
	for i=1, #textList do
		local proText = strtrim(textList[i]);
		table.insert(strategies, proText);
	end
	
	for i=1, #(strategyFrame.leftScrollFrame.strategies) do
		local strategy = strategyFrame.leftScrollFrame.strategies[i];
		if (ExistByTable(strategy.data[1], strategies) == true) then
			UnBotUpdateStrategyOptionBtnState(strategy, true);
		else
			UnBotUpdateStrategyOptionBtnState(strategy, false);
		end
	end
end

function UnBotRecvStrategyNCInfo(strategyFrame, info)
	local textList = UnBotSplit(info, ",");
	local strategies = {};
	for i=1, #textList do
		table.insert(strategies, strtrim(textList[i]));
	end
	
	for i=1, #(strategyFrame.rightScrollFrame.strategies) do
		local strategy = strategyFrame.rightScrollFrame.strategies[i];
		if (ExistByTable(strategy.data[1], strategies) == true) then
			UnBotUpdateStrategyOptionBtnState(strategy, true);
		else
			UnBotUpdateStrategyOptionBtnState(strategy, false);
		end
	end
end

function UnBotUpdateStrategyOptionBtnState(btn, state)
	if (state) then
		btn.use = true;
		btn:SetNormalTexture(btn.enableIcon);
	else
		btn.use = false;
		btn:SetNormalTexture(btn.disableIcon);
	end
end

function ExistByTable(target, tableData)
	for i=1, #tableData do
		if (tableData[i] == target) then
			return true;
		end
	end
	return false;
end

function StrategyOption_OnEnter(btn, name, use, strategyType, data)
	GameTooltip:SetOwner(btn, "ANCHOR_TOPRIGHT");
	GameTooltip:AddLine(data[2],1,1,1,1);
	if (use) then
		GameTooltip:AddLine(" 已激活",0,0,1,1);
	else
		GameTooltip:AddLine(" 未激活",1,0,0,1);
	end
	GameTooltip:AddLine(data[3],0,1,0,1);
	GameTooltip:AddLine("有些策略对某些职业无效，即使激活了这些策略，也会被机器人拒绝掉，并且某些策略是相互排斥的。",1,0.5,0,1);
	GameTooltip:AddLine(" ",1,1,1,1);
	GameTooltip:AddDoubleLine(" 执行命令：",data[1],0,0.85,0.85,0,0.85,0.85);
	if (use) then
		GameTooltip:AddLine(" 鼠标单击：取消该策略",0.65,0.55,0,1);
	else
		GameTooltip:AddLine(" 鼠标单击：激活该策略",0.65,0.55,0,1);
	end
	GameTooltip:Show();
end

function StrategyOption_OnClick(btn, strategyFrame, use, name, strategyType, command)
	if (strategyFrame == nil or name == nil or command == nil) then
		return;
	end

	if (strategyType == 1) then
		if (use == true) then
			SendChatMessage("co -"..tostring(command), "WHISPER", nil, name);
			UnBotUpdateStrategyOptionBtnState(btn, false);
			strategyFrame.tickTime = GetTime();
		elseif (use == false) then
			SendChatMessage("co +"..tostring(command), "WHISPER", nil, name);
			UnBotUpdateStrategyOptionBtnState(btn, true);
			strategyFrame.tickTime = GetTime();
		end
	elseif (strategyType == 2) then
		if (use == true) then
			SendChatMessage("nc -"..tostring(command), "WHISPER", nil, name);
			UnBotUpdateStrategyOptionBtnState(btn, false);
			strategyFrame.tickTime = GetTime();
		elseif (use == false) then
			SendChatMessage("nc +"..tostring(command), "WHISPER", nil, name);
			UnBotUpdateStrategyOptionBtnState(btn, true);
			strategyFrame.tickTime = GetTime();
		end
	end
end

function UnBotStrategyFrameTick(strategyFrame, tick)
	if (strategyFrame.tickTime > 0) then
		if  ((tick - strategyFrame.tickTime) > strategyFrame.delayTime) then
			strategyFrame.tickTime = 0;
			UnBotFlushStrategyData(strategyFrame, strategyFrame.targetName);
		end
	end
end
