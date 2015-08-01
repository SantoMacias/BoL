-- LoL Patch: 5.14
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)

local sVersion = '1.0';
local rVersion = GetWebResult('raw.githubusercontent.com', '/pvpsuite/BoL/master/Versions/Scripts/p_masterFlash.version?no-cache=' .. math.random(1, 25000));

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FFFF00">An update has been found and it is now downloading!</font>');
		DownloadFile('https://raw.githubusercontent.com/pvpsuite/BoL/master/Scripts/p_masterFlash.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#00FF00">Script successfully updated, please double-press F9 to reload!</font>');
		end);
		return;
	end;
else
	print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FF0000">Update Error</font>');
end;

local theMenu = nil;
local flashSpell = nil;
local canBeUsed = false;
local lastKP = 0;

function OnLoad()
	if (GetSpellName(SUMMONER_1) == 'summonerflash') then
		flashSpell = SUMMONER_1;
	elseif (GetSpellName(SUMMONER_2) == 'summonerflash') then
			flashSpell = SUMMONER_2;
	end;
	
	if (flashSpell ~= nil) then
		canBeUsed = true;
	else
		print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FF0000">Flash Not Found</font>');
		return;
	end;
	
	InitMenu();
end;

function OnDraw()
	if (canBeUsed) then
		if (theMenu.showFlashRange) then
			if (myHero:CanUseSpell(flashSpell) == READY) then
				local maxLocation = GetMaxLocation(450);
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 400, 3, RGBA(200, 200, 0, 254), 100);
				DrawCircle3D(maxLocation.x, maxLocation.y, maxLocation.z, 50, 3, RGBA(200, 80, 0, 254), 100);
			end;
		end;
	end;
end;

function OnTick()
	if (canBeUsed) then
		if (theMenu.flashKey) then
			if ((GetTickCount() - lastKP) > 250) then
				lastKP = GetTickCount();
				if (myHero:CanUseSpell(flashSpell) == READY) then
					MasterFlash();
				end;
			end;
		end;
	end;
end;

function OnSendPacket(sPacket)
	if (canBeUsed) then
		if ((theMenu.replaceOriginal) and (VIP_USER)) then
			if (sPacket.header == 0x0007) then		
				if (myHero:CanUseSpell(flashSpell) == READY) then
					sPacket.pos = 18;
					if (sPacket:Decode1() == 0x00B0) then
						if (not flashPlease) then
							sPacket:Block();
							MasterFlash();
						end;
					end;
				end;
			end;
		end
	end;
end;

function OnProcessSpell(theUnit, theSpell)
	if (canBeUsed) then
		if (flashPlease) then
			if (theSpell.name:lower() == 'summonerflash') then
				flashPlease = false;
			end;
		end;
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_masterFlash', 'p_masterFlash');
	theMenu:addParam('flashKey', 'Master Flash Key', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'));
	if (VIP_USER) then
		theMenu:addParam('replaceOriginal', 'Replace Original Flash', SCRIPT_PARAM_ONOFF, true);
	end;
	theMenu:addParam('showFlashRange', 'Show Flash Range', SCRIPT_PARAM_ONOFF, false);
end;

function MasterFlash()
	local maxLocation = GetMaxLocation(425);
	flashPlease = true;
	CastSpell(flashSpell, maxLocation.x, maxLocation.z);
end;

function GetSpellName(whatSpell)
	local theSpell = myHero:GetSpellData(whatSpell);
	if (theSpell ~= nil) then
		return theSpell.name;
	end;
	
	return nil;
end;

function GetMaxLocation(tR)
	local mVector = Vector(mousePos.x, mousePos.z, mousePos.y);
	local hVector = Vector(myHero.x, myHero.z, myHero.y);
	local bVector = ((mVector - hVector):normalized() * tR) + hVector;
	
	local theX, theZ, theY = bVector:unpack();
	return {x = theX, y = theY, z = theZ};
end;
