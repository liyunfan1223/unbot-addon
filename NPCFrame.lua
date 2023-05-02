
function NPCCommand_OnEnter(self,tipType,title,text,command)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
	GameTooltip:AddLine(title,0,0.7,0.7,1);
	if (tipType == 1) then
		GameTooltip:AddLine("召唤一个机器人，这个机器人是一个"..text,0,1,0,1);
		-- GameTooltip:AddLine("非战斗状态下可以鼠标右键点击这个机器人打开它的操作菜单，设置它的战斗职责和装备。",0,1,0,1);
		-- GameTooltip:AddLine("使用命令前需要先选择自己。",1,0,0,1);
	elseif (tipType == 2) then
		GameTooltip:AddLine(text,0,1,0,1);
		GameTooltip:AddLine("使用命令前需要先选择自己或者是某个NPC机器人。",1,0,0,1);
	end
	-- GameTooltip:AddLine("战斗状态下无法使用该命令。",1,1,1,1);
	-- GameTooltip:AddLine(" ",1,1,1,1);
	if (command ~= nil) then
		GameTooltip:AddDoubleLine("执行命令：",command,0,0.85,0.85,0,0.85,0.85);
	end
	GameTooltip:Show();
end
