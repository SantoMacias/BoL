-- LoL Patch: 5.14
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)

local sVersion = '1.0';
local rVersion = GetWebResult('raw.githubusercontent.com', '/pvpsuite/BoL/master/Versions/Scripts/Common/EvolveSpell.version?no-cache=' .. math.random(1, 25000));

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		print('<font color="#FF1493"><b>[EvolveSpell]</b> </font><font color="#FFFF00">An update has been found and it is now downloading!</font>');
		DownloadFile('https://raw.githubusercontent.com/pvpsuite/BoL/master/Scripts/Common/EvolveSpell.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			print('<font color="#FF1493"><b>[EvolveSpell]</b> </font><font color="#00FF00">Script successfully updated, please double-press F9 to reload!</font>');
		end);
		return;
	end;
else
	print('<font color="#FF1493"><b>[EvolveSpell]</b> </font><font color="#FF0000">Update Error</font>');
end;

function EvolveSpell(spID)
	if (not VIP_USER) then
		print('[EvolveSpell] Non-VIP Not Supported!');
	end;
	
	local pOffsets = {
		[_Q] = 0xAA,
		[_W] = 0xAB,
		[_E] = 0xAC,
		[_R] = 0xAD,
	};
	
	local eP = CLoLPacket(0x009C);
	eP.vTable = 0xEE6D00;
	eP:EncodeF(myHero.networkID);
	for I = 1, 4 do
		eP:Encode1(0xB4);
	end;
	for I = 1, 4 do
		eP:Encode1(0x69);
	end;
	for I = 1, 4 do
		eP:Encode1(0x09);
	end;
	eP:Encode1(pOffsets[spID]);
	eP:Encode1(0x43);
	eP:Encode1(0x88);
	for I = 1, 4 do
		eP:Encode1(0x00);
	end;
	
	SendPacket(eP);
end;
