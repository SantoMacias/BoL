function EvolveSpell(spID)
	if (not VIP_USER) then
		print('[EvolveSpell] Non-VIP Not Supported!');
	end;
	
	local pOffsets = {
		[_Q] = {0x7D, 0x07},
		[_W] = {0x12, 0x06},
		[_E] = {0x76, 0x05},
		[_R] = {0x9C, 0x04},
	};
	
	local eP = CLoLPacket(0x00A2);
	eP.vTable = 0xF72190;
	eP:EncodeF(myHero.networkID);
	eP:Encode1(pOffsets[spID][1]);
	eP:Encode4(0xA4A4A4A4);
	eP:Encode4(0x4C4C4C4C);
	eP:Encode1(0x82);
	eP:Encode4(0x48484848);
	eP:Encode1(pOffsets[spID][2]);
	eP:Encode4(0x00000000);
	SendPacket(eP);
end;
