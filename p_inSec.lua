-- LoL Patch: 5.14
if (not VIP_USER) then
	print('<font color="#FF1493"><b>[p_inSec]</b> </font><font color="#FF0000">Non-VIP Not Supported</font>');
	return;
elseif (myHero.charName ~= 'LeeSin') then
	print('<font color="#FF1493"><b>[p_inSec]</b> </font><font color="#FF0000">Champion Not Supported</font>');
	return;
elseif (not FileExist(LIB_PATH .. 'Collision.lua')) then
	print('<font color="#FF1493"><b>[p_inSec]</b> </font><font color="#FF0000">Collision Library Not Found</font>');
	return;
end;

require 'Collision';

local theMenu = nil;
local flashSpell = nil;
local smiteSpell = nil;
local _QCollision = nil;
local myTarget = nil;
local behindTarget = nil;
local allyPointed = nil;
local lastTarget = nil;
local doKick = false;
local checkW = false;
local checkFL = false;
local doFlash = false;
local timeInsecCalled = 0;
local timeKickCalled = 0;
local timeMoveCalled = 0;
local smiteDamage = 0;
local insecDelay = 50;
local kickDelay = 100;
local moveDelay = 300;
local wardSpells = {'TrinketTotemLvl1', 'TrinketTotemLvl2', 'TrinketTotemLvl3', 'TrinketTotemLvl4', 'ItemGhostWard', 'SightWard', 'VisionWard'};
local wardObjects = {'SightWard', 'VisionWard', 'YellowTrinket', 'YellowTrinketUpgrade'};
local activeWards = {};

function OnLoad()
	_QCollision = Collision(1000, 1750, 0.25, 70);
	
	if (GetSpellName(SUMMONER_1) == 'summonerflash') then
		flashSpell = SUMMONER_1;
	elseif (GetSpellName(SUMMONER_2) == 'summonerflash') then
			flashSpell = SUMMONER_2;
	end;
	
	if (GetSpellName(SUMMONER_1) == 'summonersmite') then
		smiteSpell = SUMMONER_1;
	elseif (GetSpellName(SUMMONER_2) == 'summonersmite') then
			smiteSpell = SUMMONER_2;
	end;
	
	InitMenu();
	
	print('<font color="#FF1493"><b>[p_inSec]</b> </font><font color="#00EE00">Loaded Successfully</font>');
end;

function OnTick()
	if (myHero.level >= 15) then
		smiteDamage = 800 + ((myHero.level - 14) * 50);
	elseif (myHero.level >= 10) then
		smiteDamage = 600 + ((myHero.level - 9) * 40);
	elseif (myHero.level >= 6) then
		smiteDamage = 480 + ((myHero.level - 5) * 30);
	elseif (myHero.level >= 1) then
		smiteDamage = 370 + ((myHero.level) * 20);
	end;
	DoInsec();
end;

function OnDraw()
	if ((theMenu.drawCircles) and (not doKick)) then
		if (myHero:CanUseSpell(_R) == READY) then
			if ((myTarget ~= nil) and (behindTarget ~= nil) and (allyPointed ~= nil)) then
				DrawCircle3D(myTarget.x, myTarget.y, myTarget.z, 100, 3, RGB(255, 0, 0), 100);
				DrawCircle3D(allyPointed.x, allyPointed.y, allyPointed.z, 100, 3, RGB(0, 255, 0), 100);
				DrawCircle3D(behindTarget.x, behindTarget.y, behindTarget.z, 40, 3, RGB(255, 255, 0), 100);
			end;
		end;
	end;
end;

function OnProcessSpell(theUnit, theSpell)
	if (theUnit.networkID == myHero.networkID) then
		if ((theSpell.name:lower() == 'blindmonkr') or (theSpell.name:lower() == 'blindmonkrkick')) then
			doKick = false;
				if (doFlash) then
					CastSpell(flashSpell, behindTarget.x, behindTarget.z);
				end;
		elseif (((theSpell.name:lower() == 'blindmonkwone') or (theSpell.name:lower() == 'blindmonkwonechaos')) and (checkW)) then
				checkW = false;
				doKick = true;
		elseif ((theSpell.name:lower() == 'summonerflash') and (checkFL) or (doFlash)) then
				if (checkFL) then
					checkFL = false;
					doKick = true;
				end;
				if (doFlash) then
					doFlash = false;
				end;
		end;
	end;
end;

function OnCreateObj(theObject)
	if (theObject.type == 'obj_AI_Minion') then
		if (SearchTable(theObject.name, wardObjects, true)) then
			if ((theObject.team == myHero.team) and (theObject.valid)) then
				table.insert(activeWards, {
					['networkID'] = theObject.networkID,
					['x'] = theObject.x,
					['y'] = theObject.y,
					['z'] = theObject.z,
					['rawObject'] = theObject,
				});
			end;
		end;
	end;
end;

function OnDeleteObj(theObject)
	if (theObject.type == 'obj_AI_Minion') then
		if (SearchTable(theObject.name, wardObjects, true)) then
			if (theObject.team == myHero.team) then
				for _, theWard in ipairs(activeWards) do
					if (theWard.networkID == theObject.networkID) then
						table.remove(activeWards, _);
						break;
					end;
				end;
			end;
		end;
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_inSec', 'PvPSuite')
	theMenu:addParam('insecKey', 'inSec Key (Normal)', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
	theMenu:addParam('insecKeyInverted', 'inSec Key (Inverted)', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('H'))
	theMenu:addParam('useQ', 'Use Q', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('useSmite', 'Use Smite', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('useWards', 'Use Wards', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('useFlash', 'Use Flash', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('drawCircles', 'Draw Circles', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('followMouse', 'Follow Mouse', SCRIPT_PARAM_ONOFF, true);
end;

function DoInsec()
	local tempTarget = GetTarget();
	if ((tempTarget ~= nil) and (tempTarget.team ~= myHero.team) and (tempTarget.type ~= 'obj_AI_Minion') and (tempTarget.type ~= 'obj_AI_Turret') and (tempTarget.valid) and (ValidTarget(tempTarget, 2500))) then
		myTarget = GetTarget();
		allyPointed = GetAllyToPoint(myTarget);
		behindTarget = GetLocationBehindTarget(myTarget, allyPointed);
		if (myTarget.charName ~= lastTarget) then
			lastTarget = myTarget.charName;
			doKick = false;
			checkFL = false;
			checkW = false;
		end;
	else
		myTarget = nil;
		lastTarget = nil;
		doKick = false;
		checkFL = false;
		checkW = false;
	end;

	if ((theMenu.insecKey) or (theMenu.insecKeyInverted)) then
		if (theMenu.insecKeyInverted) then
			checkFL = false;
			checkW = false;
		end;
	
		if ((theMenu.followMouse) and (not doKick) and (not checkW) and (not checkFL)) then
			if ((GetTickCount() - timeMoveCalled) > moveDelay) then
				timeMoveCalled = GetTickCount();
				if (GetDistance(myHero, mousePos) >= 100) then
					myHero:MoveTo(mousePos.x , mousePos.z);
				end;
			end;
		end;
		
		if ((GetTickCount() - timeInsecCalled) > insecDelay) then
			timeInsecCalled = GetTickCount();
			if (myHero:CanUseSpell(_R) == READY) then
				local wardSlot = GetWardSlot();
				local canUseW = ((myHero:CanUseSpell(_W) == READY) and (myHero:GetSpellData(_W).name:lower() == 'blindmonkwone'));
				
				if (myTarget ~= nil) and (GetDistance(myHero, myTarget) <= 1000) then
					if ((doKick) or ((theMenu.insecKeyInverted) and (theMenu.useFlash) and (flashSpell ~= nil) and (myHero:CanUseSpell(flashSpell) == READY) and (GetDistance(myHero, behindTarget) <= 400))) then
						if (theMenu.insecKeyInverted) then
							CastSpell(_R, myTarget);
							doFlash = true;
						else
							if ((GetTickCount() - timeKickCalled) > kickDelay) then
								CastSpell(_R, myTarget);
								timeKickCalled = GetTickCount();
							end;
						end;
					elseif ((not checkFL) and (not checkW)) then
						if (GetDistance(myHero, myTarget) >= 401) then
							if ((theMenu.useQ) and (((theMenu.useFlash) and (flashSpell ~= nil) and (myHero:CanUseSpell(flashSpell) == READY)) or ((theMenu.useWards) and (wardSlot ~= nil) and (canUseW))))  then
								if (myHero:GetSpellData(_Q).name:lower() == 'blindmonkqone') then
									if (myHero:CanUseSpell(_Q) == READY) then
										if (GetDistance(myHero, myTarget) <= 1000) then
											local minionCollide, minionsCollision = _QCollision:GetMinionCollision(myHero, myTarget);
											local heroesCollide, heroesCollision = _QCollision:GetHeroCollision(myHero, myTarget);
											if ((theMenu.useSmite) and (smiteSpell ~= nil) and (not heroesCollide) and (minionCollide)) then
												if ((myHero:CanUseSpell(smiteSpell) == READY) and (#minionsCollision == 1)) then
													local theMinion = minionsCollision[1];
													if (theMinion.health <= smiteDamage) then
														CastSpell(smiteSpell, theMinion);
													end;
												end;
											elseif ((not minionCollide) and (not heroesCollide)) then
													CastSpell(_Q, myTarget.x, myTarget.z);
											end;
										end;
									end;
								elseif (myHero:GetSpellData(_Q).name:lower() == 'blindmonkqtwo') then
									if ((GetBuff('blindmonkqone', myTarget) ~= nil) or (GetBuff('blindmonkqonechaos', myTarget) ~= nil)) then
										CastSpell(_Q, myTarget);
									end;
								end;
							end;
						elseif ((GetDistance(myHero, behindTarget) <= 400) and (theMenu.insecKey)) then
							if (GetDistance(myHero, behindTarget) >= 101) then
								if ((theMenu.useWards) or (theMenu.useFlash)) then
									if (theMenu.useWards) then
										local closestWard = GetClosestWard(behindTarget, myTarget);
										if (canUseW) then
											if (closestWard ~= nil) then
												timeKickCalled = GetTickCount();
												checkW = true;
												CastSpell(_W, closestWard);
												return;
											elseif (wardSlot ~= nil) then
												CastSpell(wardSlot, behindTarget.x, behindTarget.z);
												return;
											end;
										end;
									end;
									
									if ((theMenu.useFlash) and (flashSpell ~= nil)) then
										if (myHero:CanUseSpell(flashSpell) == READY) then
											timeKickCalled = GetTickCount();
											checkFL = true;
											CastSpell(flashSpell, behindTarget.x, behindTarget.z);
											return;
										end;
									end;
								end;
							elseif (GetDistance(myHero, behindTarget) <= 100) then
								doKick = true;
							end;
						end;
					end;
				end;
			else
				doKick = false;
				doFlash = false;
				checkFL = false;
				checkW = false;
			end;
		end;
	end;
end;

function GetWardSlot()
	local iSlots = {ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7};
	
	for I = 1, 7 do
		local theSpell = GetSlotSpell(iSlots[I]);
		if ((theSpell ~= nil) and (SearchTable(theSpell.name, wardSpells, true)) and (myHero:CanUseSpell(iSlots[I]) == READY)) then
			return iSlots[I];
		end;
	end;
	
	return nil;
end;

function GetClosestWard(whatLoc, forWhom)
	local theWard = nil;
	local wardDistance = 600;
	
	for _, tempWard in ipairs(activeWards) do
		local tempDistance = GetDistance(whatLoc, tempWard);
		if ((tempDistance <= wardDistance) and (GetDistance(tempWard, forWhom) <= 350)) then
			wardDistance = tempDistance;
			theWard = tempWard.rawObject;
		end;
	end;
	
	return theWard;
end;

function GetAllyToPoint(whoTarget)
	for I = 1, heroManager.iCount do
		local tempTarget = heroManager:getHero(I);
		if ((tempTarget.team == myHero.team) and (tempTarget.charName ~= myHero.charName)) then
			if ((tempTarget.dead == false) and (GetDistance(myHero, tempTarget) <= 1000) and (GetDistance(whoTarget, tempTarget) >= 400)) then
				return tempTarget;
			end;
		end;
	end;
	
	local closestAllyTower = GetClosestAllyTower(1000);
	if (closestAllyTower ~= nil) then
		return closestAllyTower;
	end;
	
	return myHero;
end;

function GetAllyTowers()
	local theTowers = {};
	for I = 1, objManager.maxObjects do
		local theTower = objManager:getObject(I);
		if ((theTower ~= nil) and (theTower.valid) and (theTower.type == 'obj_AI_Turret') and (theTower.visible) and (theTower.team == myHero.team)) then
			table.insert(theTowers, theTower);
		end;
	end;
	return theTowers;
end;

function GetClosestAllyTower(maxRange)
	local theTower = nil;
	local towerDistance = maxRange;
	for I, allyTower in pairs(GetAllyTowers()) do
		local tempDistance = GetDistance(myHero, allyTower);
		if (tempDistance <= towerDistance) then
			towerDistance = tempDistance;
			theTower = allyTower;
		end;
	end;
	return theTower;
end;

function GetLocationBehindTarget(theTarget, toWhom)
	local wVector = Vector(toWhom.x, toWhom.z, toWhom.y);
	local tVector = Vector(theTarget.x, theTarget.z, theTarget.y);
	local bVector = (tVector - wVector):normalized() * 180 + tVector;
	
	local theX, theZ, theY = bVector:unpack();
	return {x = theX, y = theY, z = theZ};
end;

function GetSlotSpell(theSlot)
	return (myHero:GetSpellData(theSlot));
end;

function GetSpellName(whatSpell)
	local theSpell = myHero:GetSpellData(whatSpell);
	if (theSpell ~= nil) then
		return theSpell.name;
	end;
	
	return nil;
end;

function GetBuff(buffName, theUnit)
	for I = 1, theUnit.buffCount do
		local theBuff = theUnit:getBuff(I);
		if ((theBuff ~= nil) and (theBuff.name ~= nil)) then
			if (theBuff.name:lower() == buffName) then
				return theBuff;
			end;
		end;
	end;
	
	return nil;
end;

function SearchTable(toCheck, theTable, iC)
	if (type(toCheck) == 'table') then
		for tK, tV in pairs(theTable) do
			for cK, cV in pairs(toCheck) do
				if ((cV == tV) or ((type(cV) == 'string') and (iC) and (string.lower(cV) == string.lower(tV)))) then
					return true;
				end;
			end;
		end;
	else
		for tK, tV in pairs(theTable) do
			if ((toCheck == tV) or ((type(cV) == 'string') and (iC) and (string.lower(toCheck) == string.lower(tV)))) then
				return true;
			end;
		end;
	end;
end;
