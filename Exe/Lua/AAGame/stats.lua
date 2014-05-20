require "AAGame/characterClasses"

stats = {
	char = {
		armorLevel = 5,
		attackDamage = 125,
		attackSpeed = 78500,
		attributes = {
			accuracy = 25,
			constitution = 25,
			magic = 25,
			speed = 25,
			stealth = 25,
			strength = 25
		},
		class = "Citizen",
		classType = 0,
		climbHeight = 40,
		food = 2000,
		foodMax = 2000,
		health = 2200,
		healthMax = 2200,
		heartRate = 0,
		isAlive = true,
		jumpPower = 19200,
		jumpPowerMod = 0,
		level = 1,
		load = 88,
		loadMax = 500,
		mana = 2500,
		manaMax = 2500,
		name = "Undefined",
		password = "",
		poison = 0,
		regenHealth = 150,
		regenMana = 150,
		spellSystem = "arcane",
		tallness = 50,
		title = "Serviceman",
		velFallingMax = 31000,
		velRunningMax = 22,
		velWalkingMax = 7,
		water = 2000,
		waterMax = 2000,
		weaponBaseDamage = 10,
		weaponBaseSpeed = 10,
		xp = 0,
		xpNeeded = 2000,
	}
};

local aastats = require "aastats";

function stats.getCharacterList()
	-- Creates a table of characters with { name, password, status, mail }
	local chars = aastats.GetCharacterList()
	local i;
	charList = {};
	for i=0,4 do
		local char = stats.loadCharacter(i);
		if (char ~= nil) then
			-- Check for a few extras
			if (char.mail == nil) then
				char.mail = 0;
			end
			if (char.status == nil) then
				char.status = "ok";
			end
		else
			char = {};
			print("  Empty");
			char.name = "<empty>";
			char.password = "";
			char.mail = 0;
			char.status = "undefined";
		end
		charList[#charList+1] = char;
	end

	return charList;
end

function stats.setActiveCharacterList(charList)
print("stats.setActiveCharacterList");
print(inspect(charList));
print(inspect(stats.charList));
	stats.charList = charList;
print(inspect(stats.charList));
	aastats.SetSavedCharacterList(charList)
end

function stats.getActiveCharacterList()
	return stats.charList 
end

function stats.makeActive(charSelected)
	aastats.MakeActive(charSelected)
end

function stats.getActive()
	return aastats.GetActive();
end

function stats.getSavedCharacterIDStruct(c)
	return stats.charList[c+1];
end

function stats.get()
	return aastats.Get()
end

function stats.init()
	aastats.Init();
	stats.char = stats.get();
end

------------------------------------------------------------------------------
-- Load a character based on it's slot
-- @param [in] slotNum -- Slot number to load
-- @return Character loaded or nil if not found 
------------------------------------------------------------------------------
function stats.loadCharacter(slotNum)
	local char = nil;
	--stats.char = aastats.Get();
	local filename = sprintf("Characters/CharSlot%d.json", slotNum);
	local file = io.open(filename, "r");
	if (file ~= nil) then
		local chardata = file:read("*all");
		char = JSON:decode(chardata);
		file:close();
	end
		
	return char;
end

function stats.drawCharacterPortrait(x, y)
	if (stats.char) then
		--local stmp = string.format("UI/CREATEC/CHAR%02d", stats.char.classType);
		local stmp = characterClasses.find(stats.char.class).portrait_name;
		graphics.fillRect(x, y, x+115, y+102, 0);
		local pic = pics.lockBitmap(stmp);
		graphics.drawPic(pic, x, y);
		color.update(0);
		pics.unlockAndUnfind(pic);
	end	
end

function stats.setPassword(c, newPassword)
	stats.char.password = newPassword;
end

-- Store the version of the character in Lua into the A&A engine underneath.
-- TODO: Remove this step
function stats.set()
	aastats.Set(stats.char);
end

-- Save the currently active character to the given save slot
function stats.saveCharacter(c)
	printf("SaveCharacter to slot %d with password %s", c, stats.char.password);
	stats.set();
--	aastats.SaveCharacter(c);
	local filename = sprintf("Characters/CharSlot%d.json", c);
	local file = assert(io.open(filename, "w"));
	file:write(JSON:encode_pretty(stats.char));
	file:close();
	
	-- Update the list info
	stats.charList[c+1].name = stats.char.name;
	stats.charList[c+1].password = stats.char.password;
	stats.charList[c+1].mail = stats.char.mail;
	stats.charList[c+1].status = stats.char.status;
end

function stats.deleteCharacter(c)
	printf("DeleteCharacter slot %d", c);
	aastats.DeleteCharacter(c);
end

return stats
