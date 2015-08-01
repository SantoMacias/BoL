-- LoL Patch: 5.14
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)

local sVersion = '1.0';
local rVersion = GetWebResult('raw.githubusercontent.com', '/pvpsuite/BoL/master/Versions/Scripts/p_blockPings.version?no-cache=' .. math.random(1, 25000));

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FFFF00">An update has been found and it is now downloading!</font>');
		DownloadFile('https://raw.githubusercontent.com/pvpsuite/BoL/master/Scripts/p_blockPings.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#00FF00">Script successfully updated, please double-press F9 to reload!</font>');
		end);
		return;
	end;
else
	print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FF0000">Update Error</font>');
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

function GetAllies()
	local myAllies = {};
	for I = 1, heroManager.iCount do
		local theHero = heroManager:GetHero(I);
		if (theHero.team == myHero.team) then
			myAllies[#myAllies + 1] = theHero;
		end;
	end;
	return myAllies;
end;

local allyHeroes = GetAllies();
local supportedMaps = {8, 10, 12, 15};

if (not VIP_USER) then
	print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FF0000">Non-VIP Not Supported</font>');
	return;
elseif (#allyHeroes <= 1) then
		print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FF0000">No Allies Found</font>');
		return;
elseif (#allyHeroes >= 6) then
		print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FF0000">Too Many Allies</font>');
		return;
elseif (not SearchTable(GetGame().map.index, supportedMaps)) then
		print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#FF0000">Map Not Supported</font>');
		return;
end;

local pH = {
	[0x95] = 1,
	[0x97] = 1,
	[0x09] = 1,
	[0x12] = 1,
	[0xF4] = 2,
	[0xF6] = 2,
	[0x68] = 2,
	[0xF3] = 2,
	[0x14] = 3,
	[0x16] = 3,
	[0x88] = 3,
	[0x13] = 3,
	[0xF5] = 4,
	[0x73] = 4,
	[0x72] = 4,
	[0x15] = 5,
	[0x93] = 5,
	[0x92] = 5,
};
local oneH = {0x95, 0x97, 0x09, 0x12};
local twoH = {0xF4, 0xF6, 0x68, 0xF3};
local threeH = {0x14, 0x16, 0x88, 0x13};
local fourH = {0xF5, 0x73, 0x72};
local fiveH = {0x15, 0x93, 0x92};
local lastPingTime = {0, 0, 0, 0, 0};

function OnLoad()
	InitMenu();
	
	theMenu.blocksMenu.One = false;
	theMenu.blocksMenu.Two = false;
	theMenu.blocksMenu.Three = false;
	theMenu.blocksMenu.Four = false;
	theMenu.blocksMenu.Five = false;
	theMenu.delaysMenu.One = false;
	theMenu.delaysMenu.Two = false;
	theMenu.delaysMenu.Three = false;
	theMenu.delaysMenu.Four = false;
	theMenu.delaysMenu.Five = false;
	
	print('<font color="#FF1493"><b>[p_blockPings]</b> </font><font color="#00EE00">Loaded Successfully</font>');
end;

function OnRecvPacket(sPacket)
	if (sPacket.header == 0xAE) then
		sPacket.pos = 23;
		local thePinger = sPacket:Decode1();
		if (((theMenu.blocksMenu.One) and (SearchTable(thePinger, oneH))) or ((theMenu.blocksMenu.Two) and (SearchTable(thePinger, twoH))) or ((theMenu.blocksMenu.Three) and (SearchTable(thePinger, threeH))) or ((theMenu.blocksMenu.Four) and (SearchTable(thePinger, fourH))) or ((theMenu.blocksMenu.Five) and (SearchTable(thePinger, fiveH)))) then
			sPacket:Replace4(0x00, 8);
		elseif (((theMenu.delaysMenu.One) and (SearchTable(thePinger, oneH))) or ((theMenu.delaysMenu.Two) and (SearchTable(thePinger, twoH))) or ((theMenu.delaysMenu.Three) and (SearchTable(thePinger, threeH))) or ((theMenu.delaysMenu.Four) and (SearchTable(thePinger, fourH))) or ((theMenu.delaysMenu.Five) and (SearchTable(thePinger, fiveH)))) then
				if (GetTickCount() - lastPingTime[pH[thePinger]] > (theMenu.delaysMenu.delayTime * 1000)) then
					lastPingTime[pH[thePinger]] = GetTickCount();
				else
					sPacket:Replace4(0x00, 8);
				end;
		end;
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_blockPings', 'p_blockPings');
	theMenu:addSubMenu('Blocks', 'blocksMenu');
	theMenu:addSubMenu('Delays', 'delaysMenu');
	for _, allyHero in ipairs(allyHeroes) do
		if (allyHero.charName ~= myHero.charName) then
			theMenu.blocksMenu:addParam(GetWordFromNumber(_), 'Block ' .. GetChampionFriendlyName(allyHeroes[_].charName) .. ' Pings', SCRIPT_PARAM_ONOFF, true);
			theMenu.delaysMenu:addParam(GetWordFromNumber(_), 'Delay ' .. GetChampionFriendlyName(allyHeroes[_].charName) .. ' Pings', SCRIPT_PARAM_ONOFF, true);
		end;
	end;
	theMenu.delaysMenu:addParam('delayTime', 'Delay Time (Seconds)', SCRIPT_PARAM_SLICE, 60, 1, 300, 0);
end;

function GetWordFromNumber(theNumber)
	if (theNumber == 1) then
		return 'One';
	elseif (theNumber == 2) then
			return 'Two';
	elseif (theNumber == 3) then
			return 'Three';
	elseif (theNumber == 4) then
			return 'Four';
	elseif (theNumber == 5) then
			return 'Five';
	end;
	
	return 'Unknown';
end;

function GetChampionFriendlyName(rName)
	if (string.lower(rName) == string.lower('ChoGath')) then
		return 'Cho\'Gath';
	elseif (string.lower(rName) == string.lower('DrMundo')) then
		return 'Dr. Mundo';
	elseif (string.lower(rName) == string.lower('FiddleSticks')) then
		return 'Fiddlesticks';
	elseif (string.lower(rName) == string.lower('JarvanIV')) then
		return 'Jarvan IV';
	elseif (string.lower(rName) == string.lower('KhaZix')) then
		return 'Kha\'Zix';
	elseif (string.lower(rName) == string.lower('KogMaw')) then
		return 'Kog\'Maw';
	elseif (string.lower(rName) == string.lower('LeeSin')) then
		return 'Lee Sin';
	elseif (string.lower(rName) == string.lower('MasterYi')) then
		return 'Master Yi';
	elseif (string.lower(rName) == string.lower('MissFortune')) then
		return 'Miss Fortune';
	elseif (string.lower(rName) == string.lower('MonkeyKing')) then
		return 'Wukong';
	elseif (string.lower(rName) == string.lower('RekSai')) then
		return 'Rek\'Sai';
	elseif (string.lower(rName) == string.lower('TahmKench')) then
		return 'Tahm Kench';
	elseif (string.lower(rName) == string.lower('TwistedFate')) then
		return 'Twisted Fate';
	elseif (string.lower(rName) == string.lower('VelKoz')) then
		return 'Vel\'Koz';
	elseif (string.lower(rName) == string.lower('XinZhao')) then
		return 'Xin Zhao';
	end;
	return rName;
end;
