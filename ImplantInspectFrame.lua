
function UnBotCheckOffHand(dstFrame, targetName)
	local slot16Linnk = GetInventoryItemLink(InspectFrame.unit, 16);
	local slot17Linnk = GetInventoryItemLink(InspectFrame.unit, 17);
	--DisplayInfomation("Check "..tostring(slot16Linnk).." and "..tostring(slot17Linnk));
	if (slot17Linnk == nil and slot16Linnk ~= nil) then
		local item = UnBotQueryItemByID(UnBotGetItemIDByLink(slot16Linnk));
		if (item ~= nil and item[11] ~= "INVTYPE_2HWEAPON") then
			local matchItems = UnBotMatchItemBySlotType(17, dstFrame.bagItems);
			local selectItem = nil;
			for i=1, #matchItems do
				local item = matchItems[i];
				if (item[8] <= tonumber(UnitLevel(targetName))) then
					if (selectItem == nil) then
						selectItem = item;
					elseif (item[7] > selectItem[7]) then
						selectItem = item;
					end
				end
			end
			if (selectItem ~= nil) then
				local itemLink
				_,itemLink,_,_,_,_,_,_,_,_ = GetItemInfo(tostring(selectItem[3]));
				SendChatMessage("e "..tostring(itemLink), "WHISPER", nil, targetName);
				dstFrame.canCheckEquip = false;
				for i=1, #(dstFrame.bagItems) do
					if (dstFrame.bagItems[i][3] == selectItem[3]) then
						table.remove(dstFrame.bagItems, i);
						break;
					end
				end
				--DisplayInfomation("Need up 副手 "..tostring(selectItem[5])..", LV "..tostring(UnitLevel(targetName)));
			end
		end
	end
end

function UnBotGetItemIDByLink(itemLink)
	local info = tostring(itemLink);
	local i1,i2 = string.find(info,"Hitem:");
	if (i1 == nil or i2 == nil) then
		return nil;
	end
	local itemID = tonumber(string.match(info,"%d+",i2));
	return itemID;
end

function UnBotBindFrameFunction(frameName, srcFunc, dstFunc)
	if (frameName == nil or srcFunc == nil or dstFunc == nil) then
		return;
	end

	local dstFrame = _G[frameName];
	if (dstFrame == nil) then
		return;
	end
	local dstFrameScript = dstFrame:GetScript(srcFunc);
	setglobal("SRC_"..frameName.."_"..srcFunc, dstFrameScript);
	dstFrame:SetScript(srcFunc, dstFunc);
end

function UnBotInitInspectFrame()
	UnBotBindFrameFunction("InspectPaperDollFrame", "OnShow", UnBotInspectPaperDollFrame_OnShow);
	UnBotBindFrameFunction("InspectPaperDollFrame", "OnUpdate", UnBotInspectPaperDollFrame_OnUpdate);
	UnBotBindFrameFunction("InspectPaperDollFrame", "OnEvent", UnBotInspectPaperDollFrame_OnEvent);

	UnBotBindFrameFunction("InspectHeadSlot", "OnMouseUp", UnBotInspectHeadSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectNeckSlot", "OnMouseUp", UnBotInspectNeckSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectShoulderSlot", "OnMouseUp", UnBotInspectShoulderSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectBackSlot", "OnMouseUp", UnBotInspectBackSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectChestSlot", "OnMouseUp", UnBotInspectChestSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectShirtSlot", "OnMouseUp", UnBotInspectShirtSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectTabardSlot", "OnMouseUp", UnBotInspectTabardSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectWristSlot", "OnMouseUp", UnBotInspectWristSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectHandsSlot", "OnMouseUp", UnBotInspectHandsSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectWaistSlot", "OnMouseUp", UnBotInspectWaistSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectLegsSlot", "OnMouseUp", UnBotInspectLegsSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectFeetSlot", "OnMouseUp", UnBotInspectFeetSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectFinger0Slot", "OnMouseUp", UnBotInspectFinger0Slot_OnMouseUp);
	UnBotBindFrameFunction("InspectFinger1Slot", "OnMouseUp", UnBotInspectFinger1Slot_OnMouseUp);
	UnBotBindFrameFunction("InspectTrinket0Slot", "OnMouseUp", UnBotInspectTrinket0Slot_OnMouseUp);
	UnBotBindFrameFunction("InspectTrinket1Slot", "OnMouseUp", UnBotInspectTrinket1Slot_OnMouseUp);
	UnBotBindFrameFunction("InspectMainHandSlot", "OnMouseUp", UnBotInspectMainHandSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectSecondaryHandSlot", "OnMouseUp", UnBotInspectSecondaryHandSlot_OnMouseUp);
	UnBotBindFrameFunction("InspectRangedSlot", "OnMouseUp", UnBotInspectRangedSlot_OnMouseUp);

	local ipdf = _G["InspectPaperDollFrame"];
	if (ipdf ~= nil) then
		EquipInventoryFrame:SetParent(ipdf);
		EquipInventoryFrame:SetPoint("CENTER", ipdf, "CENTER", -10, 0);
		EquipInventoryFrame:Hide();
	end
	DisplayInfomation("嵌入模块到角色查看窗口完成。");
end

function UnBotInspectFrameCanOperator()
	local targetName = UnitName("target");
	local isParty = UnitInParty("target");
	local isRaid = UnitInRaid("target");
	if (targetName == nil or targetName == "") then
		return false;
	end
	if (not UnitIsPlayer("target")) then
		return false;
	end
	if (isParty == nil and isRaid == nil) then
		return false;
	end
	if (not IsRealPartyLeader()) then
		return false;
	end
	if (targetName == UnitName("player")) then
		return false;
	end
	
	return true;
end

function UnBotStartReloadInspectFrame()
	local dstFrame = _G["InspectPaperDollFrame"];
	if (dstFrame == nil) then
		return;
	end
	dstFrame.reloadTick = GetTime();
end

function UnBotFlushInspectPaperDollFrame(dstFrame)
	dstFrame.bagItems = {};
	dstFrame.flushTick = GetTime();
	dstFrame.reloadTick = 0;
	dstFrame.canCheckEquip = true;
	EquipInventoryFrame:Hide();
	SetPortraitTexture(EquipInventoryFrame.titleIcon, InspectFrame.unit);
	if (UnBotInspectFrameCanOperator() == true) then
		SendChatMessage("c", "WHISPER", nil, UnitName(InspectFrame.unit));
	end
end

function UnBotInspectPaperDollFrame_OnShow(...)
	local dstAction = _G["SRC_InspectPaperDollFrame_OnShow"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	--DisplayInfomation("UnBot UnBotInspectFrame_OnShow "..UnitName(InspectFrame.unit));
	local dstFrame = _G["InspectPaperDollFrame"];
	if (dstFrame == nil) then
		return;
	end

	dstFrame:RegisterEvent("CHAT_MSG_WHISPER");
	dstFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	dstFrame.waitFlushTime = 2;
	dstFrame.waitReloadTime = 0.5;
	if (dstFrame.ubHelpText == nil) then
		dstFrame.ubHelpText = dstFrame:CreateFontString(dstFrame:GetName().."UnBotHelp","ARTWORK");
		dstFrame.ubHelpText:SetFont([[Fonts\ZYHei.ttf]],12);
		dstFrame.ubHelpText:SetTextColor(0,0.8,0.8,1);
		dstFrame.ubHelpText:SetText("在装备槽中:鼠标左键点击更换装备,鼠标右键点击卸下装备");
		dstFrame.ubHelpText:SetPoint("TOP",dstFrame,"TOP",15,-58);
		dstFrame.ubHelpText:SetShadowColor(0,0,0);
		dstFrame.ubHelpText:SetShadowOffset(1,-1);
	end

	if (EquipInventoryFrame.titleIcon == nil) then
		EquipInventoryFrame.titleIcon = EquipInventoryFrame:CreateTexture(nil, "BACKGROUND");
		EquipInventoryFrame.titleIcon:SetSize(36,36);
		SetPortraitTexture(EquipInventoryFrame.titleIcon, "player");
		EquipInventoryFrame.titleIcon:SetPoint("TOPLEFT", EquipInventoryFrame, "TOPLEFT", 8, -6);
	end
	UnBotFlushInspectPaperDollFrame(dstFrame);
end

function UnBotInspectPaperDollFrame_OnEvent(...)
	local dstAction = _G["SRC_InspectPaperDollFrame_OnEvent"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	if (UnBotInspectFrameCanOperator() == false) then
		return;
	end
	local dstFrame = _G["InspectPaperDollFrame"];
	if (dstFrame == nil) then
		return;
	end

	if (dstFrame.flushTick > 0 and event == "CHAT_MSG_WHISPER") then
		if (arg2 == UnitName(InspectFrame.unit)) then
			UnBotInspectPaperDollFrameRecvItem(dstFrame, arg2, arg1);
		end
	end
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		UnBotFlushInspectPaperDollFrame(dstFrame);
	end
end

function UnBotInspectPaperDollFrame_OnUpdate(...)
	local dstAction = _G["SRC_InspectPaperDollFrame_OnUpdate"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectPaperDollFrame"];
	if (dstFrame == nil) then
		return;
	end
	
	if (dstFrame.flushTick > 0) then
		if  ((GetTime() - dstFrame.flushTick) > dstFrame.waitFlushTime) then
			dstFrame.flushTick = 0;
		end
	end
	if (dstFrame.reloadTick > 0) then
		if  ((GetTime() - dstFrame.reloadTick) > dstFrame.waitReloadTime) then
			dstFrame.reloadTick = 0;
			InspectFrame_Show(InspectFrame.unit);
		end
	end
end

function UnBotQueryItemByID(itemID)
	if (itemID == nil) then
		return nil;
	end
	local itemName;
	local itemQuality;
	local itemLevel;
	local itemMinLevel;
	local itemType;
	local itemSubType;
	local itemEquipLoc;
	local itemTexture;
	itemName,_,itemQuality,itemLevel,itemMinLevel,itemType,itemSubType,_,itemEquipLoc,itemTexture = GetItemInfo(itemID);
	local needQuery = false;
	if (itemName == nil or itemTexture == nil) then
		YssBossLoot:QueryItemInfo(itemID);
		itemName = "???";
		itemTexture = "Interface\\Icons\\Temp";
		needQuery = true;
	end
	local item = {
		[1] = 0, [2] = needQuery, [3] = itemID,
		[4] = itemTexture, [5] = itemName, [6] = itemQuality,
		[7] = itemLevel, [8] = itemMinLevel, [9] = itemType,
		[10] = itemSubType, [11] = itemEquipLoc,
	};
	return item;
end

function UnBotUpdateItems(items)
	for i=1, #items do
		local item = items[i];
		if (item[2] == true) then
			item[5],_,item[6],item[7],item[8],item[9],item[10],_,item[11],item[4] = GetItemInfo(item[3]);
			item[2] = false;
			if (item[5] == nil or item[4] == nil) then
				YssBossLoot:QueryItemInfo(item[3]);
				item[5] = "???";
				item[4] = "Interface\\Icons\\Temp";
				item[2] = true;
			end
		end
	end
end

function UnBotGetEquipLocBySlotID(slot)
	local locs = {};
	if (slot == 1) then
		table.insert(locs, "INVTYPE_HEAD");
	elseif (slot == 2) then
		table.insert(locs, "INVTYPE_NECK");
	elseif (slot == 3) then
		table.insert(locs, "INVTYPE_SHOULDER");
	elseif (slot == 4) then
		table.insert(locs, "INVTYPE_BODY");
	elseif (slot == 5) then
		table.insert(locs, "INVTYPE_CHEST");
		table.insert(locs, "INVTYPE_ROBE");
	elseif (slot == 6) then
		table.insert(locs, "INVTYPE_WAIST");
	elseif (slot == 7) then
		table.insert(locs, "INVTYPE_LEGS");
	elseif (slot == 8) then
		table.insert(locs, "INVTYPE_FEET");
	elseif (slot == 9) then
		table.insert(locs, "INVTYPE_WRIST");
	elseif (slot == 10) then
		table.insert(locs, "INVTYPE_HAND");
	elseif (slot == 11) then
		table.insert(locs, "INVTYPE_FINGER");
	elseif (slot == 12) then
		table.insert(locs, "INVTYPE_FINGER");
	elseif (slot == 13) then
		table.insert(locs, "INVTYPE_TRINKET");
	elseif (slot == 14) then
		table.insert(locs, "INVTYPE_TRINKET");
	elseif (slot == 15) then
		table.insert(locs, "INVTYPE_CLOAK");
	elseif (slot == 16) then
		table.insert(locs, "INVTYPE_WEAPON");
		table.insert(locs, "INVTYPE_2HWEAPON");
		table.insert(locs, "INVTYPE_WEAPONMAINHAND");
	elseif (slot == 17) then
		table.insert(locs, "INVTYPE_WEAPON");
		table.insert(locs, "INVTYPE_SHIELD");
		table.insert(locs, "INVTYPE_WEAPONOFFHAND");
		table.insert(locs, "INVTYPE_HOLDABLE");
	elseif (slot == 18) then
		table.insert(locs, "INVTYPE_RANGED");
		table.insert(locs, "INVTYPE_THROWN");
		table.insert(locs, "INVTYPE_RANGEDRIGHT");
		table.insert(locs, "INVTYPE_RELIC");
	end
	return locs;
end

function UnBotMatchItemBySlotType(slot, items)
	-- slot = 12 or 14 process
	local outItems = {};
	local equipLocs = UnBotGetEquipLocBySlotID(tonumber(slot));
	for i=1, #items do
		local item = items[i];
		if (item[2] == false and item[11] ~= "") then
			for j=1, #equipLocs do
				if (equipLocs[j] == item[11]) then
					table.insert(outItems, item);
					break;
				end
			end
		end
	end
	return outItems;
end

function UnBotInspectPaperDollFrameRecvItem(dstFrame, targetName, info)
	if (IsFilterInfo(info) == true) then
		return;
	end
	local i1,i2 = string.find(info,"Hitem:");
	if (i1 == nil or i2 == nil) then
		return;
	end
	local itemID = tonumber(string.match(info,"%d+",i2));
	if (itemID == nil or itemID == 0) then
		return;
	end

	table.insert(dstFrame.bagItems, UnBotQueryItemByID(itemID));
	--DisplayInfomation("IPDF RecvItem itemName "..tostring(itemName)..", itemQuality "..tostring(itemQuality)..", itemLevel "..tostring(itemLevel)..", itemMinLevel "..tostring(itemMinLevel));
	--DisplayInfomation("IPDF RecvItem itemType "..tostring(itemType)..", itemSubType "..tostring(itemSubType)..", itemEquipLoc "..tostring(itemEquipLoc)..", itemID "..tostring(itemID));
	--if (dstFrame.canCheckEquip == true) then
	--	UnBotCheckOffHand(dstFrame, targetName);
	--end
end

function UnBotInspectSlotShowItemChange(dstFrame, itemLink)
	if (UnBotInspectFrameCanOperator() == false) then
		return;
	end
	local ipdf = _G["InspectPaperDollFrame"];
	if (ipdf == nil) then
		UnBotUpdateItems(ipdf.bagItems);
	end
	EquipInventoryFrame.targetName = UnitName(InspectFrame.unit);
	EquipInventoryFrame.inventoryItems = UnBotMatchItemBySlotType(dstFrame:GetID(), ipdf.bagItems);
	for i=1, #(EquipInventoryFrame.inventoryItemButtons) do
		local itemBtn = EquipInventoryFrame.inventoryItemButtons[i];
		if (i > #(EquipInventoryFrame.inventoryItems)) then
			itemBtn:Hide();
		else
			itemBtn.targetName = EquipInventoryFrame.targetName;
			itemBtn.item = EquipInventoryFrame.inventoryItems[i];
			itemBtn.targetEquip = itemLink;
			itemBtn:SetNormalTexture(itemBtn.item[4]);
			itemBtn:Show();
		end
	end
	EquipInventoryFrame:Show();
end

function UnBotInspectSlotUnItem(dstFrame, itemLink)
	if (itemLink ~= nil and UnBotInspectFrameCanOperator() == true) then
		SendChatMessage("ue "..tostring(itemLink), "WHISPER", nil, UnitName(InspectFrame.unit));
		UnBotStartReloadInspectFrame();
	end
end

----------------------------------------------------------------------------------------

function UnBotInspectHeadSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectHeadSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectHeadSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectNeckSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectNeckSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectNeckSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectShoulderSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectShoulderSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectShoulderSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectBackSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectBackSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectBackSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectChestSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectChestSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectChestSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectShirtSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectShirtSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectShirtSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectTabardSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectTabardSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectTabardSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectWristSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectWristSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectWristSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectHandsSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectHandsSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectHandsSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectWaistSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectWaistSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectWaistSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectLegsSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectLegsSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectLegsSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectFeetSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectFeetSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectFeetSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectFinger0Slot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectFinger0Slot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectFinger0Slot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectFinger1Slot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectFinger1Slot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectFinger1Slot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectTrinket0Slot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectTrinket0Slot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectTrinket0Slot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectTrinket1Slot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectTrinket1Slot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectTrinket1Slot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectMainHandSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectMainHandSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectMainHandSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectSecondaryHandSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectSecondaryHandSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectSecondaryHandSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end

function UnBotInspectRangedSlot_OnMouseUp(...)
	local dstAction = _G["SRC_InspectRangedSlot_OnMouseUp"];
	if (dstAction ~= nil) then
		dstAction(...);
	end
	local dstFrame = _G["InspectRangedSlot"];
	if (dstFrame == nil) then
		return;
	end

	if (arg1 == "LeftButton") then
		UnBotInspectSlotShowItemChange(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	elseif (arg1 == "RightButton") then
		UnBotInspectSlotUnItem(dstFrame, GetInventoryItemLink(InspectFrame.unit, dstFrame:GetID()));
	end
end
