-- LoL Patch: 5.14
function PingLocation(theLocation, pingType)
	if ((GetGame().map.index ~= 11) and (GetGame().map.index ~= 15)) then
		print('[PingLocation] Map Not Supported');
		return;
	end;
	
	local locationsH = {
		['Baron'] = {0x02, 0xE3, 0x8E, 0x85, 0x98, 0x39, 0x3E, 0xDD},
		['Dragon'] = {0xD4, 0x53, 0xA2, 0xDD, 0x27, 0xB0, 0x88, 0x85},
		['Top'] = {0x11, 0x46, 0xCC, 0x85, 0xF5, 0x9D, 0x20, 0xDD},
		['Mid'] = {0x93, 0xD5, 0xBE, 0x85, 0x8C, 0x9C, 0x6F, 0x85},
		['Bot'] = {0x2D, 0xA0, 0xDD, 0xDD, 0x4C, 0x35, 0x40, 0x85},
	};

	local teamBlueH = {
		['Blue'] = {0xB8, 0xFF, 0x4A, 0x85, 0x60, 0x35, 0xE3, 0x85},
		['Red'] = {0x78, 0x06, 0xC6, 0x85, 0xF4, 0x9B, 0xEE, 0x85},
	};
	
	local teamRedH = {
		['Blue'] = {0xCB, 0x5D, 0x8C, 0xDD, 0xC4, 0x39, 0x7F, 0x85},
		['Red'] = {0xE9, 0xD5, 0x71, 0x85, 0xA0, 0x3E, 0x1C, 0xDD},
	};
	
	if (GetMyHero().team == TEAM_BLUE) then
		locationsH['Our Blue'] = teamBlueH['Blue'];
		locationsH['Our Red'] = teamBlueH['Red'];
		locationsH['Enemy Blue'] = teamRedH['Blue'];
		locationsH['Enemy Red'] = teamRedH['Red'];
	elseif (GetMyHero().team == TEAM_RED) then
		locationsH['Our Blue'] = teamRedH['Blue'];
		locationsH['Our Red'] = teamRedH['Red'];
		locationsH['Enemy Blue'] = teamBlueH['Blue'];
		locationsH['Enemy Red'] = teamBlueH['Red'];
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
  
  PingLocation('Mid', 'Enemy Missing');
  PingLocation('Baron', 'Danger');
  PingLocation('Dragon', 'On My Way');
  PingLocation('Our Blue', 'Assist Me');
  PingLocation('Enemy Red', 'Retreat');

]]--
