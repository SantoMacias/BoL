-- LoL Patch: 5.14
-- Developer: PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
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
