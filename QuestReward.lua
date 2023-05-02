
function RecvQuestReward(name, info)
	local i1, i2 = string.find(info, "Hitem");
	if (i1 == nil or i2 == nil) then
		return;
	end
	
	local textList = UnBotSplit(string.sub(info, i2), "Hitem:");
	local itemIDs = {};
	for i=1, #textList do
		local itemID = tonumber(string.match(textList[i],"%d+"));
		if (itemID ~= nil) then
			local texture;
			local itemName;
			itemName,_,_,_,_,_,_,_,_,texture = GetItemInfo(itemID);
			local needQuery = false;
			if (itemName == nil or texture == nil) then
				YssBossLoot:QueryItemInfo(itemID);
				itemName = "???";
				texture = "Interface\\Icons\\Temp";
				needQuery = true;
			end
			local itemInfo = {[1] = itemID, [2] = needQuery, [3] = tostring(name), [4] = texture, [5] = tostring(itemName)};
			table.insert(itemIDs, itemInfo);
		end
	end
	if (#itemIDs > 0) then
		ShowQuestReward(name, itemIDs);
	end
end

function ShowQuestReward(name, items)
	local qrFrame = CreateFrame("Frame","QR"..name,UIParent,"QuestRewardFrame");
	qrFrame.showTick = GetTime();
	local qrLabel = _G[qrFrame:GetName().."TitleLabel"];
	if (qrLabel ~= nil) then
		qrLabel:SetText(name.." |cffcccc00完成任务选择奖励|r");
	else
		DisplayInfomation("完成任务奖励面板Label "..qrFrame:GetName().."TitleLabel 未找到，设置玩家名失败 "..name);
	end
	local qrBar = _G[qrFrame:GetName().."TickBar"];
	if (qrBar ~= nil) then
		qrBar:SetPoint("CENTER", qrFrame, "TOP", 0, -7);
		qrFrame.tickBar = qrBar;
		qrFrame.tickBar:SetValue(0);
	end
	for i=1, #items do
		local item = items[i];
		local qrBtn = CreateFrame("Button",qrFrame:GetName()..tostring(i),qrFrame,"QuestRewardButtonTemplate");
		local offsetX = 15 + (qrBtn:GetWidth() + 8) * (i - 1);
		qrBtn:SetPoint("BOTTOMLEFT", qrFrame, "BOTTOMLEFT", offsetX, 15);
		qrBtn.item = item;
		if (item[4] ~= nil) then
			qrBtn:SetNormalTexture(item[4]);
		end
		table.insert(qrFrame.rewardItems, item);
		table.insert(qrFrame.rewardBtns, qrBtn);
		qrBtn:Show();
	end
	
	local frameCount = #UnBotFrame.ShowedQRs;
	local startHeight = (UIParent:GetHeight() - (qrFrame:GetHeight() + 30) * 4) / 2;
	local posY = startHeight + (frameCount % 4) * (qrFrame:GetHeight() + 30);
	qrFrame:SetPoint("CENTER", UIParent, "TOPLEFT", UIParent:GetWidth() / 2, posY * (-1));
	qrFrame:Show();
	table.insert(UnBotFrame.ShowedQRs, qrFrame);
end

function UnBotShowQuestRewardTips(self, item)
	if (self == nil or item == nil) then
		return;
	end
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
	if (item[2] == true) then
		local texture;
		local itemName;
		itemName,_,_,_,_,_,_,_,_,texture = GetItemInfo(item[1]);
		if (itemName ~= nil and texture ~= nil) then
			self.item[2] = false;
			self.item[4] = texture;
			self.item[5] = tostring(itemName);
			self:SetNormalTexture(self.item[4]);
			GameTooltip:SetHyperlink("item:"..tostring(item[1])..":0:0:0:0:0:0:0");
		else
			GameTooltip:AddLine(item[5],1,0,0,1);
			GameTooltip:AddLine(" ",1,1,1,1);
			GameTooltip:AddLine("该道具没有在你的客户端出现过，需要等待片刻查询服务器后再次将鼠标移动到这个道具上。",1,0,0,1);
		end
	else
		GameTooltip:SetHyperlink("item:"..tostring(item[1])..":0:0:0:0:0:0:0");
	end

	if (self.item[2] == false) then
		GameTooltip:AddLine(" ",1,1,1,1);
		GameTooltip:AddLine("鼠标左键单击：让 "..item[3].." 选择这个任务奖励",1,0,0,1);
	end
	GameTooltip:Show();
end

function UnBotSelectQuestReward(self, item)
	if (self == nil or item == nil or item[2] == nil or item[2] == true) then
		return;
	end
	local itemLink = "|cffffffff|Hitem:"..tostring(item[1])..":0:0:0:0:0:0:0|h["..item[5].."]|h|r";
	SendChatMessage("r "..itemLink, "WHISPER", nil, item[3]);
	local qr = self:GetParent();
	UnBotRemoveByQRFrame(qr);
	setglobal(qr:GetName().."TitleLabel", nil);
	qr:Hide();
	qr:SetParent(nil);
end

function UnBotQuestRewardTick(qrFrame, tick)
	if (qrFrame.showTick > 0) then
		if  ((tick - qrFrame.showTick) > qrFrame.waitTime) then
			qrFrame.showTick = 0;
			qrFrame.tickBar = nil;
			if ((#qrFrame.rewardItems) > 0 and (#qrFrame.rewardBtns) > 0) then
				UnBotSelectQuestReward(qrFrame.rewardBtns[1], qrFrame.rewardItems[1]);
			end
		else
			if (qrFrame.tickBar ~= nil and qrFrame.waitTime > 0) then
				local timed = tick - qrFrame.showTick;
				if (timed > qrFrame.waitTime) then
					timed = qrFrame.waitTime;
				end
				qrFrame.tickBar:SetValue(timed / qrFrame.waitTime);
			end
		end
	end
end
