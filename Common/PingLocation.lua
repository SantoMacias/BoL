function PingLocation(theLocation, pingType)
	if ((GetGame().map.index ~= 11) and (GetGame().map.index ~= 15)) then
		print('[PingLocation] Map Not Supported');
		return;
	end;

	local teamBlueH = {
		['Blue'] = {0xB8, 0xFF, 0x4A, 0x85, 0x60, 0x35, 0xE3, 0x85},
		['Red'] = {0x78, 0x06, 0xC6, 0x85, 0xF4, 0x9B, 0xEE, 0x85},
	};
	
	local teamRedH = {
		['Blue'] = {0xCB, 0x5D, 0x8C, 0xDD, 0xC4, 0x39, 0x7F, 0x85},
		['Red'] = {0xE9, 0xD5, 0x71, 0x85, 0xA0, 0x3E, 0x1C, 0xDD},
	};
	
	local locationsH = {
		['Baron'] = {0x02, 0xE3, 0x8E, 0x85, 0x98, 0x39, 0x3E, 0xDD},
		['Dragon'] = {0xD4, 0x53, 0xA2, 0xDD, 0x27, 0xB0, 0x88, 0x85},
	};
	
	if (GetMyHero().team == TEAM_BLUE) then
		locationsH['OurBlue'] = teamBlueH['Blue'];
		locationsH['OurRed'] = teamBlueH['Red'];
		locationsH['EnemyBlue'] = teamRedH['Blue'];
		locationsH['EnemyRed'] = teamRedH['Red'];
	elseif (GetMyHero().team == TEAM_RED) then
		locationsH['OurBlue'] = teamRedH['Blue'];
		locationsH['OurRed'] = teamRedH['Red'];
		locationsH['EnemyBlue'] = teamBlueH['Blue'];
		locationsH['EnemyRed'] = teamBlueH['Red'];
	end;
	
	if (locationsH[theLocation] == nil) then
		print('[PingLocation] Location Not Found (' .. theLocation .. ')');
		return;
	end;
	
	local eP = CLoLPacket(0x00AB);
	eP.vTable = 0xF3DC4C;
	eP:Encode4(0x00000000);
	eP:Encode4(0xE4E4E4E4);
	if (pingType == 'Danger') then
		eP:Encode1(0xE8);
	elseif (pingType == 'On My Way') then
		eP:Encode1(0xE9);
	elseif (pingType == 'Assist Me') then
		eP:Encode1(0x68);
	elseif (pingType == 'Enemy Missing') then
		eP:Encode1(0x08);
	elseif (pingType == 'Alert') then
		eP:Encode1(0x69);
	elseif (pingType == 'Retreat') then
		eP:Encode1(0x09);
	else
		print('[PingLocation] Ping Type Not Found (' .. pingType .. ')');
		return;
	end;
	
	for I = 1, #locationsH[theLocation] do
		eP:Encode1(locationsH[theLocation][I]);
	end;
	
	for I = 1, 5 do
		eP:Encode1(0x00);
	end;
	
	SendPacket(eP);
end;

--[[

  Example Usage
  
  PingLocation('Baron', 'Danger');
  PingLocation('Dragon', 'On My Way');
  PingLocation('OurBlue', 'Assist Me');
  PingLocation('EnemyRed', 'Retreat');

]]--
