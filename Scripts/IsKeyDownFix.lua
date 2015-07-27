-- LoL Patch: 5.14 (Irrelevant)
local originalKD = _G.IsKeyDown;
_G.IsKeyDown = function(theKey)
	if (type(theKey) ~= 'number') then
		local theNumber = tonumber(theKey);
		if (theNumber ~= nil) then
			return originalKD(theNumber);
		else
			return originalKD(GetKey(theKey));
		end;
	else
		return originalKD(theKey);
	end;
end;
