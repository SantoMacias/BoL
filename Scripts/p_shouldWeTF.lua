-- LoL Patch: 5.14
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
local theMenu = nil;
local damageStates = {[1] = 'Initial', [2] = 'Follow', [3] = 'Max'};
local linesW = 280;
local linesS = 20;
local borderRadius = 2;
local linesD = (linesW / 100);

function OnLoad()
	InitMenu();
end;

function OnDraw()
	if ((theMenu.showIndicators) and (not myHero.dead)) then
		local enemiesDamage, enemiesCount = CalculateTeamDamageInRange(myHero, theMenu.teamfightRange, TEAM_ENEMY);
		if (enemiesCount >= 1) then
			local alliesDamage, alliesCount = CalculateTeamDamageInRange(myHero, theMenu.teamfightRange, myHero.team);
			local enemiesCurrentHealth, enemiesMaxHealth = CalculateTeamHPInRange(myHero, theMenu.teamfightRange, TEAM_ENEMY);
			local alliesCurrentHealth, alliesMaxHealth = CalculateTeamHPInRange(myHero, theMenu.teamfightRange, myHero.team);
			local enemiesHealthW = ((enemiesCount >= 1) and Round((linesD * ((enemiesCurrentHealth / enemiesMaxHealth) * 100))) or 0);
			local alliesHealthW = ((alliesCount >= 1) and Round((linesD * ((alliesCurrentHealth / alliesMaxHealth) * 100))) or 0);
			local enemiesDamageP = ((enemiesDamage / alliesCurrentHealth) * 100);
			local alliesDamageP = ((alliesDamage / enemiesCurrentHealth) * 100);
			local enemiesDamageW = ((enemiesDamage >= 1) and Round((linesD * enemiesDamageP)) or 0);
			local alliesDamageW = ((alliesDamage >= 1) and Round((linesD * alliesDamageP)) or 0);
			local winningChance = Round((alliesDamageP / (enemiesDamageP + alliesDamageP)) * 100);
			local enemyString = tostring(Round(alliesDamage)) .. ' / ' .. tostring(Round(enemiesCurrentHealth));
			local allyString = tostring(Round(enemiesDamage)) .. ' / ' .. tostring(Round(alliesCurrentHealth));
			
			if (enemiesDamageW > 100) then
				enemiesDamageW = 100;
			elseif (enemiesDamageW < 0) then
					enemiesDamageW = 0;
			end;
			if (alliesDamageW > 100) then
				alliesDamageW = 100;
			elseif (alliesDamageW < 0) then
					alliesDamageW = 0;
			end;
			if (winningChance > 100) then
				winningChance = 100;
			elseif (winningChance < 0) then
					winningChance = 0;
			end;
			
			local vsString = (winningChance .. '% - ' .. alliesCount .. 'vs' .. enemiesCount);
			DrawLine(theMenu.drawW - 1, theMenu.drawH + (linesS * 1.5), theMenu.drawW + linesW + 1, theMenu.drawH + (linesS * 1.5), linesS + borderRadius, RGBA(0, 0, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW - 1, theMenu.drawH, theMenu.drawW + linesW + 1, theMenu.drawH, linesS + borderRadius, RGBA(0, 0, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW - 1, theMenu.drawH + ((linesS * 1.5) * 2), theMenu.drawW + linesW + 1, theMenu.drawH + ((linesS * 1.5) * 2), linesS + borderRadius, RGBA(0, 0, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH, theMenu.drawW + linesW, theMenu.drawH, linesS, RGBA(50, 50, 50, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH + (linesS * 1.5), theMenu.drawW + linesW, theMenu.drawH + (linesS * 1.5), linesS, RGBA(50, 50, 50, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH + ((linesS * 1.5) * 2), theMenu.drawW + linesW, theMenu.drawH + ((linesS * 1.5) * 2), linesS, RGBA(20, 20, 20, theMenu.indicatorsOpacity));
			DrawText(vsString, 15, theMenu.drawW + (linesW / 2) - (vsString:len() * 2), theMenu.drawH - (linesS / 2) + ((linesS * 1.5) * 2) + 2, RGBA(255, 255, 255, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH, theMenu.drawW + enemiesHealthW, theMenu.drawH, linesS, RGBA(150, 0, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH + (linesS * 1.5), theMenu.drawW + alliesHealthW, theMenu.drawH + (linesS * 1.5), linesS, RGBA(0, 150, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH, theMenu.drawW + alliesDamageW, theMenu.drawH, linesS, RGBA(255, 255, 0, theMenu.indicatorsOpacity));
			DrawLine(theMenu.drawW, theMenu.drawH + (linesS * 1.5), theMenu.drawW + enemiesDamageW, theMenu.drawH + (linesS * 1.5), linesS, RGBA(255, 255, 0, theMenu.indicatorsOpacity));
			DrawText(enemyString, 15, theMenu.drawW + (linesW / 2) - (enemyString:len() * 2), theMenu.drawH - (linesS / 2) + 2, RGBA(255, 255, 255, theMenu.indicatorsOpacity));
			DrawText(allyString, 15, theMenu.drawW + (linesW / 2) - (allyString:len() * 2), theMenu.drawH - (linesS / 2) + (linesS * 1.5) + 2, RGBA(255, 255, 255, theMenu.indicatorsOpacity));
		end;
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_shouldWeTF', 'p_shouldWeTF');
	theMenu:addParam('showIndicators', 'Show Indicators', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('considerCooldowns', 'Consider Cooldowns', SCRIPT_PARAM_ONOFF, true);
	theMenu:addParam('indicatorsOpacity', 'Indicators Opacity', SCRIPT_PARAM_SLICE, 255, 80, 255, 0);
	theMenu:addParam('teamfightRange', 'Teamfight Range', SCRIPT_PARAM_SLICE, 2000, myHero.range, 3500, 0);
	theMenu:addParam('drawH', 'Screen H Position', SCRIPT_PARAM_SLICE, ((WINDOW_H - linesS) / 2), linesS, ((WINDOW_H - linesS) - (linesS * 1.5)), 0);
	theMenu:addParam('drawW', 'Screen W Position', SCRIPT_PARAM_SLICE, ((WINDOW_W - linesW) / 2), 0, (WINDOW_W - linesW), 0);
    theMenu:addParam('damageState', 'Damage State', SCRIPT_PARAM_LIST, 1, damageStates);
end;

function CalculateTeamHPInRange(theCoords, theDistance, theTeam)
	local currentHealth = 0;
	local maxHealth = 0;
	for I = 1, heroManager.iCount do
		local theHero = heroManager:GetHero(I);
		if ((theHero.team == theTeam) and (not theHero.dead) and (theHero.visible) and (GetDistance(theHero, theCoords) <= theDistance)) then
			currentHealth = currentHealth + theHero.health;
			maxHealth = maxHealth + theHero.maxHealth;
		end;
	end;
	
	return currentHealth, maxHealth;
end;

function CalculateAvgHeroDamage(theHero, theTargets)
	local totalDamage = 0;
	local totalTargets = 0;
	for _, theTarget in ipairs(theTargets) do
		local aaDamage, aaDamageType = getDmg('AD', theTarget, theHero, theMenu.damageState);
		local pDamage, pDamageType = getDmg('P', theTarget, theHero, theMenu.damageState);
		local qCanUse, wCanUse, eCanUse, rCanUse = (theHero:GetSpellData(_Q).currentCd == 0), (theHero:GetSpellData(_W).currentCd == 0), (theHero:GetSpellData(_E).currentCd == 0), (theHero:GetSpellData(_R).currentCd == 0);
		local qmCanUse, wmCanUse, emCanUse = qCanUse, wCanUse, eCanUse;
		local qDamage, qDamageType = getDmg('Q', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_Q).level);
		local qmDamage, qmDamageType = getDmg('QM', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_Q).level);
		local wDamage, wDamageType = getDmg('W', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_W).level);
		local wmDamage, wmDamageType = getDmg('WM', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_W).level);
		local eDamage, eDamageType = getDmg('E', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_E).level);
		local emDamage, emDamageType = getDmg('EM', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_E).level);
		local rDamage, rDamageType = getDmg('R', theTarget, theHero, theMenu.damageState, theHero:GetSpellData(_R).level);
		local secondForm = ((theHero:GetSpellData(_Q).name:lower() == 'elisespiderq') or (theHero:GetSpellData(_Q).name:lower() == 'elisespiderqcast') or (theHero:GetSpellData(_Q).name:lower() == 'takedown') or (theHero:GetSpellData(_Q).name:lower() == 'jayceshockblast'));
		local currentDamage = pDamage + aaDamage;
		if (theMenu.considerCooldowns) then
			if (not secondForm) then
				currentDamage = currentDamage + (qCanUse and qDamage or 0) + (wCanUse and wDamage or 0) + (eCanUse and eDamage or 0) + (rCanUse and rDamage or 0);
			else
				currentDamage = currentDamage + (qmCanUse and qmDamage or 0) + (wmCanUse and wmDamage or 0) + (emCanUse and emDamage or 0) + (rCanUse and rDamage or 0);
			end;
		else
			currentDamage = currentDamage + qDamage + wDamage + eDamage + rDamage;
		end;
		
		totalDamage = totalDamage + currentDamage;
		totalTargets = totalTargets + 1;
	end;
	
	if (totalTargets >= 1) then
		return (totalDamage / totalTargets);
	else
		return 0;
	end;
end;

function GetTeamMembersInRange(theCoords, theDistance, theTeam)
	local theMembers = {};
	for I = 1, heroManager.iCount do
		local theHero = heroManager:GetHero(I);
		if ((theHero.team == theTeam) and (not theHero.dead) and (theHero.visible) and (GetDistance(theHero, theCoords) <= theDistance)) then
			theMembers[#theMembers + 1] = theHero;
		end;
	end;
	
	return theMembers;
end;

function CalculateTeamDamageInRange(theCoords, theDistance, theTeam)
	local theDamage = 0;
	local teamMembers = GetTeamMembersInRange(theCoords, theDistance, theTeam);
	local enemyTeam = TEAM_ENEMY;
	if (theTeam == TEAM_ENEMY) then
		enemyTeam = myHero.team;
	end;
	local enemyMembers = GetTeamMembersInRange(theCoords, theDistance, enemyTeam);
	for _, theHero in ipairs(teamMembers) do
		theDamage = theDamage + CalculateAvgHeroDamage(theHero, enemyMembers);
	end;
	
	return theDamage, #teamMembers;
end;

function Round(tN, tIDP)
	local iMult = (10 ^ (tIDP or 0));
	return (math.floor(tN * iMult + 1/2) / iMult);
end;
