--===================================================================================================================--
-- cEasyHealer, version 1                                                                                            --
-- Description: Basically you have a window that has a list of names of your current raid in. The names are          --
-- automatically arranged according to the player's remaining hp all the time. The player with the lowest hp is      --
-- on top, then descending from there. To flash heal, you just have to click on a name on the list. Thats it!        --
-- First created: 2005-09-06                                                                                         --
-- Developer: Christoffer Petterson, aka Corgrath, corgrath@corgrath.com                                             --
--===================================================================================================================--

-- Version number
CEASYHEALER_VERSION = 3.7;

-- The spell you wish to cast when you click on a playername.
CEASYHEALER_SPELL_TO_CAST = "Flash Heal(Rank 7)";
CEASYHEALER_SPELL_TO_CAST_SHIFT = "Power Word: Shield(Rank 10)";
CEASYHEALER_SPELL_TO_CAST_ALT = "Renew(Rank 9)";
CEASYHEALER_SPELL_TO_CAST_CTRL = "Greater Heal(Rank 4)";
CEASYHEALER_MAIN_TANK = "PlayerName";
CEASYHEALER_OFF_TANK = "PlayerName";

CEASYHEALER_MAIN_TANK_BREAKPOINT_ONE   = 90;
CEASYHEALER_MAIN_TANK_BREAKPOINT_TWO   = 80;
CEASYHEALER_MAIN_TANK_BREAKPOINT_THREE = 70;
CEASYHEALER_MAIN_TANK_BREAKPOINT_FOUR  = 50;
CEASYHEALER_MAIN_TANK_BREAKPOINT_FIVE  = 30;

CEASYHEALER_MAIN_TANK_BREAKPOINT_ONE_MODIFIER   = 3;
CEASYHEALER_MAIN_TANK_BREAKPOINT_TWO_MODIFIER   = 5;
CEASYHEALER_MAIN_TANK_BREAKPOINT_THREE_MODIFIER = 10;
CEASYHEALER_MAIN_TANK_BREAKPOINT_FOUR_MODIFIER  = 20;
CEASYHEALER_MAIN_TANK_BREAKPOINT_FIVE_MODIFIER  = 30;

--
CEASYHEALER_OFF_TANK_BREAKPOINT_ONE    = 90;
CEASYHEALER_OFF_TANK_BREAKPOINT_TWO    = 80;
CEASYHEALER_OFF_TANK_BREAKPOINT_THREE  = 70;
CEASYHEALER_OFF_TANK_BREAKPOINT_FOUR   = 50;
CEASYHEALER_OFF_TANK_BREAKPOINT_FIVE   = 30;

CEASYHEALER_OFF_TANK_BREAKPOINT_ONE_MODIFIER   = 3;
CEASYHEALER_OFF_TANK_BREAKPOINT_TWO_MODIFIER   = 5;
CEASYHEALER_OFF_TANK_BREAKPOINT_THREE_MODIFIER = 10;
CEASYHEALER_OFF_TANK_BREAKPOINT_FOUR_MODIFIER  = 20;
CEASYHEALER_OFF_TANK_BREAKPOINT_FIVE_MODIFIER  = 30;

CEASYHEALER_OFF_TANK = "PlayerName";

playerList = {};
petList    = {};
PlayerPetList = {};

-- Settings
CEASYHEALER_SETTINGS =
{
	-- Check the unit with CheckInteractDistance-function, around 30 yards.
	CHECK_DISTANCE = true
};

-- The units the list should show
CEASYHEALER_UNIT_FILTER =
{
	RAID = 1,

	PETS = 1,

	PALADIN = 1,
	ROGUE = 1,
	PRIEST = 1,
	HUNTER = 1,
	WARLOCK = 1,
	DRUID = 1, 
	WARRIOR = 1,
	MAGE = 1, 
	SHAMAN = 1
};

-- The lowest health-procentage a player needs until they get shown on the list. Range: 0.0-1.0.
CEASYHEALER_THRESHOLD = 75;

-- The lowest health-procentage a player needs until they get shown on the list. Range: 0.0-1.0.
CEASYHEALER_MANA_CONSERVER = 75;

-- Labels for keybindings
BINDING_HEADER_CEASYHEALER = "cEasyHealer " .. CEASYHEALER_VERSION;
BINDING_NAME_CEASYHEALER_CASTFIRST = "Heal first target";
BINDING_NAME_CEASYHEALER_ABORT_CAST = "Abort current spellcast.";

-- The table we store all units. Do not alter.
CEASYHEALER_TABLE_UNITS = {};

--===================================================================================================================--
function cEasyHealer_Function_OnLoad()

	tinsert( UISpecialFrames, "cEasyHealer_Frame_Settings" );
	tinsert( UISpecialFrames, "cEasyHealer_Frame_Filter" );

	this:RegisterForDrag("LeftButton");
	this:RegisterEvent( "VARIABLES_LOADED" );

	SlashCmdList["CEASYHEALER"] = cEasyHealer_Function_OnSlash;
	SLASH_CEASYHEALER1 = "/ceasyhealer";

	cEasyHealer_Frame_Status1:ClearAllPoints();
	cEasyHealer_Frame_Status1:SetPoint( "TOPLEFT", "cEasyHealer_Frame_Main", "TOPLEFT", 8, -8 );
	
	cEasyHealer_Frame_Status2:ClearAllPoints();
	cEasyHealer_Frame_Status2:SetPoint( "TOPLEFT", "cEasyHealer_Frame_Status1", "BOTTOMLEFT", 0, 0 );
	cEasyHealer_Frame_Status3:ClearAllPoints();
	cEasyHealer_Frame_Status3:SetPoint( "TOPLEFT", "cEasyHealer_Frame_Status2", "BOTTOMLEFT", 0, 0 );
	cEasyHealer_Frame_Status4:ClearAllPoints();
	cEasyHealer_Frame_Status4:SetPoint( "TOPLEFT", "cEasyHealer_Frame_Status3", "BOTTOMLEFT", 0, 0 );
	cEasyHealer_Frame_Status5:ClearAllPoints();
	cEasyHealer_Frame_Status5:SetPoint( "TOPLEFT", "cEasyHealer_Frame_Status4", "BOTTOMLEFT", 0, 0 );

	ChatFrame1:AddMessage( "cEasyHealer loaded. Type /ceasyhealer to use." );
	cEasyHealer_Function_HideFrame();
end

function cEasyHealer_Function_OnEvent( event )
	if( event == "VARIABLES_LOADED" )
	then

		cEasyHealer_EditBox_SpellNormal:SetText( CEASYHEALER_SPELL_TO_CAST );
		cEasyHealer_EditBox_SpellShift:SetText( CEASYHEALER_SPELL_TO_CAST_SHIFT );
		cEasyHealer_EditBox_SpellAlt:SetText( CEASYHEALER_SPELL_TO_CAST_ALT );
		cEasyHealer_EditBox_SpellCtrl:SetText( CEASYHEALER_SPELL_TO_CAST_CTRL );
		cEasyHealer_EditBox_mainTank:SetText( CEASYHEALER_MAIN_TANK );
		cEasyHealer_EditBox_offTank:SetText( CEASYHEALER_OFF_TANK );

		cEasyHealer_Slider_Threshold:SetValue( CEASYHEALER_THRESHOLD );
		cEasyHealer_Slider_ManaConserver:SetValue( CEASYHEALER_MANA_CONSERVER );
		EasyHealer_CheckButton_CheckDistance:SetChecked( CEASYHEALER_SETTINGS.CHECK_DISTANCE );

		EasyHealer_CheckButton_IncludeRaid:SetChecked( CEASYHEALER_UNIT_FILTER.RAID );
		EasyHealer_CheckButton_IncludePets:SetChecked( CEASYHEALER_UNIT_FILTER.PETS );
		EasyHealer_CheckButton_IncludePaladin:SetChecked( CEASYHEALER_UNIT_FILTER.PALADIN );
		EasyHealer_CheckButton_IncludeRogue:SetChecked( CEASYHEALER_UNIT_FILTER.ROGUE );
		EasyHealer_CheckButton_IncludePriest:SetChecked( CEASYHEALER_UNIT_FILTER.PRIEST );
		EasyHealer_CheckButton_IncludeHunter:SetChecked( CEASYHEALER_UNIT_FILTER.HUNTER );
		EasyHealer_CheckButton_IncludeWarlock:SetChecked( CEASYHEALER_UNIT_FILTER.WARLOCK );
		EasyHealer_CheckButton_IncludeDruid:SetChecked( CEASYHEALER_UNIT_FILTER.DRUID );
		EasyHealer_CheckButton_IncludeWarrior:SetChecked( CEASYHEALER_UNIT_FILTER.WARRIOR );
		EasyHealer_CheckButton_IncludeMage:SetChecked( CEASYHEALER_UNIT_FILTER.MAGE );
		EasyHealer_CheckButton_IncludeShaman:SetChecked( CEASYHEALER_UNIT_FILTER.SHAMAN );

	end
end

function cEasyHealer_Function_ToggleSettings()
    if cEasyHealer_Frame_Settings:IsVisible() then
        cEasyHealer_Function_HideSettings();
    else
        cEasyHealer_Function_ShowSettings();
    end
end

function cEasyHealer_Function_ShowSettings()
    PlaySound("igMainMenuOption");
    ShowUIPanel(cEasyHealer_Frame_Settings);
end

function cEasyHealer_Function_HideSettings()
    PlaySound("igMainMenuOption");
    HideUIPanel(cEasyHealer_Frame_Settings);
end

function cEasyHealer_Function_OnSlash(arguments)
    if arguments == "settings" then
        cEasyHealer_Function_ToggleSettings();  -- This will toggle the settings window.
    else
        cEasyHealer_Function_ToggleMenu();  -- Default behavior if no argument is passed
    end
end

function cEasyHealer_Function_OnDragStart()

	cEasyHealer_Frame_Main:StartMoving();

end

function cEasyHealer_Function_OnDragStop()

	cEasyHealer_Frame_Main:StopMovingOrSizing();

end

function cEasyHealer_Function_Update()

	-- get the valid targets
	cEasyHealer_Function_GetTargets();

	-- prioritize the targets
	cEasyHealer_Function_PrioritizeTargets();
		
	-- build the list
	cEasyHealer_Function_BuildList();

end
--===================================================================================================================--



--===================================================================================================================--
function cEasyHealer_Function_ToggleMenu()

	if( cEasyHealer_Frame_Main:IsVisible() )
	then
		cEasyHealer_Function_HideFrame();
	else
		cEasyHealer_Function_ShowFrame();
	end
end

function cEasyHealer_Function_ShowFrame()
	PlaySound( "igMainMenuOption" );
	ShowUIPanel( cEasyHealer_Frame_Main );
end

function cEasyHealer_Function_HideFrame()
	PlaySound( "igMainMenuOption" );
	HideUIPanel( cEasyHealer_Frame_Main );
end

--===================================================================================================================--



--===================================================================================================================--
function cEasyHealer_Function_GetTargets()

	-- we reset the table, making it empty
	CEASYHEALER_TABLE_UNITS = {};
	--ChatFrame2:AddMessage( "table reseted " .. table.getn(CEASYHEALER_TABLE_UNITS) );

	if( UnitInRaid("player") )
	then

		for i = 1, GetNumRaidMembers(), 1
		do
			cEasyHealer_Function_CheckUnit( "raid"..i );
			if (CEASYHEALER_UNIT_FILTER.PETS == true) then
			    cEasyHealer_Function_CheckUnit( "raidpet"..i );
			end
		end

	elseif( GetNumPartyMembers() > 0 )
	then

		cEasyHealer_Function_CheckUnit( "player" );
		if (CEASYHEALER_UNIT_FILTER.PETS == true) then
		    cEasyHealer_Function_CheckUnit( "pet" );
		end

		for i = 1, GetNumPartyMembers(), 1
		do
			cEasyHealer_Function_CheckUnit( "party"..i );
			if (CEASYHEALER_UNIT_FILTER.PETS == true) then
			    cEasyHealer_Function_CheckUnit( "partypet"..i );
			end
		end

	else

		cEasyHealer_Function_CheckUnit( "player" );
		if (CEASYHEALER_UNIT_FILTER.PETS == true) then
		    cEasyHealer_Function_CheckUnit( "pet" );
		end

	end
end

function cEasyHealer_Function_PrioritizeTargets()
	-- Assumes CEASYHEALER_TABLE_UNITS is already populated
	for i, unit in ipairs(CEASYHEALER_TABLE_UNITS) do
		local currentHealth = UnitHealth(unit.name);
		local maxHealth = UnitHealthMax(unit.name);
		local hp = currentHealth / maxHealth * 100; -- Calculate HP percentage

		-- Check if the unit is a main or off tank and adjust their hp for sorting
		-- Adjust HP percentage for tanks, prioritizing them if under certain break points
		if (unit.playerName == CEASYHEALER_MAIN_TANK) then
			if hp < CEASYHEALER_MAIN_TANK_BREAKPOINT_ONE then              -- default is 90
				hp = hp - CEASYHEALER_MAIN_TANK_BREAKPOINT_ONE_MODIFIER;   -- default is 3
			elseif hp < CEASYHEALER_MAIN_TANK_BREAKPOINT_TWO then          -- default is 80
				hp = hp - CEASYHEALER_MAIN_TANK_BREAKPOINT_TWO_MODIFIER;   -- default is 5
			elseif hp < CEASYHEALER_MAIN_TANK_BREAKPOINT_THREE then        -- default is 70
				hp = hp - CEASYHEALER_MAIN_TANK_BREAKPOINT_THREE_MODIFIER; -- default is 10
			elseif hp < CEASYHEALER_MAIN_TANK_BREAKPOINT_FOUR then         -- default is 50
				hp = hp - CEASYHEALER_MAIN_TANK_BREAKPOINT_FOUR_MODIFIER;  -- default is 20
			elseif hp < CEASYHEALER_MAIN_TANK_BREAKPOINT_FIVE then         -- default is 30
				hp = hp - CEASYHEALER_MAIN_TANK_BREAKPOINT_FIVE_MODIFIER;  -- default is 30
			end
		end

		if (unit.playerName == CEASYHEALER_OFF_TANK) then
			if hp < CEASYHEALER_OFF_TANK_BREAKPOINT_ONE then              -- default is 90
				hp = hp - CEASYHEALER_OFF_TANK_BREAKPOINT_ONE_MODIFIER;   -- default is 3
			elseif hp < CEASYHEALER_OFF_TANK_BREAKPOINT_TWO then          -- default is 80
				hp = hp - CEASYHEALER_OFF_TANK_BREAKPOINT_TWO_MODIFIER;   -- default is 5
			elseif hp < CEASYHEALER_OFF_TANK_BREAKPOINT_THREE then        -- default is 70
				hp = hp - CEASYHEALER_OFF_TANK_BREAKPOINT_THREE_MODIFIER; -- default is 10
			elseif hp < CEASYHEALER_OFF_TANK_BREAKPOINT_FOUR then         -- default is 50
				hp = hp - CEASYHEALER_OFF_TANK_BREAKPOINT_FOUR_MODIFIER;  -- default is 20
			elseif hp < CEASYHEALER_OFF_TANK_BREAKPOINT_FIVE then         -- default is 30
				hp = hp - CEASYHEALER_OFF_TANK_BREAKPOINT_FIVE_MODIFIER;  -- default is 30
			end
		end

		hp = math.max(hp, 0.01);
		-- Update the unit table with the adjusted or actual hp
		unit.sortedHp = hp;
	end

	-- Now, sort the table by the adjusted hp values
	table.sort(CEASYHEALER_TABLE_UNITS, function(a, b)
		return a.sortedHp < b.sortedHp; -- Sort so that units with lower hp (including adjusted tanks) are prioritized
	end)
end

function cEasyHealer_Function_CheckUnit( unit )
	-- check if the user exists
	if( not UnitExists(unit) )
	then
		--ChatFrame2:AddMessage( unit .. " doesn't exists." );
		return false;
	end
    --print(UnitName(unit).." Unit: "..unit.." CEASYHEALER_UNIT_FILTER.PETS ="..tostring(CEASYHEALER_UNIT_FILTER.PETS));
	-- check if the unit has a name
	if( UnitName(unit) == nil )
	then
		--ChatFrame2:AddMessage( unit .. " doesn't have a name." );
		return false;
	end

	-- check if the unit is dead or a ghost
	if( UnitIsDeadOrGhost(unit) )
	then
		--ChatFrame2:AddMessage( UnitName(unit) .. " is dead or ghost." );
		return;
	end

	-- check if the unit is charmed
	if( UnitIsCharmed(unit) )
	then
		--ChatFrame2:AddMessage( UnitName(unit) .. " is charmed." );
		return;
	end					

	-- check if the unit is visible
	if( not UnitIsVisible(unit) )
	then
		--ChatFrame2:AddMessage( UnitName(unit) .. " is not visible." );
		return;
	end

	if( CEASYHEALER_SETTINGS.CHECK_DISTANCE and CheckInteractDistance(unit, 4) == nil )
	then
		ChatFrame2:AddMessage( UnitName(unit) .. " is beyond 30 yards." );
		return;
	end




	--
	-- Here we check if he is allowed to in the list
	--

	local playerClass, englishClass = UnitClass(unit);

	-- pet 
	if( cEasyHealer_Function_IsPet(unit) == true and CEASYHEALER_UNIT_FILTER.PETS == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc its a pet" );
		return;
	end
	-- raid
	if( cEasyHealer_Function_IsInSameGroup(unit) == false and CEASYHEALER_UNIT_FILTER.RAID == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc his is not in our party" );
		return;
	end

	-- paladin
	if( UnitClass(unit) == "Paladin" and CEASYHEALER_UNIT_FILTER.PALADIN == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is paladin" );
		return;
	end
	-- rogue
	if( UnitClass(unit) == "Rogue" and CEASYHEALER_UNIT_FILTER.ROGUE == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is rogue" );
		return;
	end
	-- priest
	if( UnitClass(unit) == "Priest" and CEASYHEALER_UNIT_FILTER.PRIEST == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is priest" );
		return;
	end
	-- hunter
	if( UnitClass(unit) == "Hunter" and CEASYHEALER_UNIT_FILTER.HUNTER == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is hunter" );
		return;
	end
	-- warlock
	if( UnitClass(unit) == "Warlock" and CEASYHEALER_UNIT_FILTER.WARLOCK == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is warlock" );
		return;
	end
	-- druid
	if( UnitClass(unit) == "Druid" and CEASYHEALER_UNIT_FILTER.DRUID == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is druid" );
		return;
	end
	-- warrior
	if( UnitClass(unit) == "Warrior" and CEASYHEALER_UNIT_FILTER.WARRIOR == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is Warrior" );
		return;
	end
	-- mage
	if( UnitClass(unit) == "Mage" and CEASYHEALER_UNIT_FILTER.MAGE == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is mage" );
		return;
	end
	-- shaman
	if( UnitClass(unit) == "Shaman" and CEASYHEALER_UNIT_FILTER.SHAMAN == false )
	then
		--ChatFrame2:AddMessage( "ignoring " .. UnitName(unit) .. " bc he is Shaman" );
		return;
	end



	-- calculate their health ratio
	local currentHealth = UnitHealth(unit);
	local maxHealth = UnitHealthMax(unit);
	local hp = currentHealth/maxHealth;
	local unitName = UnitName(unit);
	--ChatFrame2:AddMessage( UnitName(unit) .. " currentHealth= " .. hp .. "maxHealth=" .. maxHealth );
    if currentHealth == 1 and UnitClass(unit) == "Priest" then
	    return;
	end

	-- check if their hp is in the valid range
	if( hp > (CEASYHEALER_THRESHOLD/100) )
	then
		--ChatFrame2:AddMessage( UnitName(unit) .. " has too much health " .. hp .. " >= " .. (CEASYHEALER_THRESHOLD/100) );
		return;
	end

	-- create the member
	local tempUnit = { };
	tempUnit.name = unit
	if string.lower(unitName) == string.lower(CEASYHEALER_MAIN_TANK) then
		tempUnit.hp = hp - 0.002
    elseif string.lower(unitName) == string.lower(CEASYHEALER_OFF_TANK) then
		tempUnit.hp = hp - 0.001
	else
		tempUnit.hp = hp
	end

	-- add it to the table
	cEasyHealer_Function_BinaryInsert( CEASYHEALER_TABLE_UNITS, tempUnit );
	--ChatFrame2:AddMessage( "added " .. unit .. "->" .. UnitName(unit) .. " hp=" .. hp .. " into db" );
	return;

end

function cEasyHealer_Function_BuildList()

	-- build the list
	for i=1, 5, 1
	do
		if( (i <= table.getn(CEASYHEALER_TABLE_UNITS)) )
		then
			--ChatFrame2:AddMessage( i .. " (sorted) unit=" .. CEASYHEALER_TABLE_UNITS[i].name .. " name=" .. UnitName(CEASYHEALER_TABLE_UNITS[i].name) .. " hp=" .. CEASYHEALER_TABLE_UNITS[i].hp );
			getglobal("cEasyHealer_Frame_Status" .. i):Show();
			getglobal("cEasyHealer_Frame_Status" .. i).nickname = UnitName(CEASYHEALER_TABLE_UNITS[i].name);
			getglobal("cEasyHealer_Frame_Status" .. i).id = CEASYHEALER_TABLE_UNITS[i].name;
			local unitName = UnitName(CEASYHEALER_TABLE_UNITS[i].name)
			if string.lower(unitName) == string.lower(CEASYHEALER_MAIN_TANK) or string.lower(unitName) == string.lower(CEASYHEALER_OFF_TANK) then
				getglobal("cEasyHealer_Frame_Status" .. i .. "Text"):SetText( floor(CEASYHEALER_TABLE_UNITS[i].hp*100)+1 .. "% " .. UnitName(CEASYHEALER_TABLE_UNITS[i].name) );
			else
				getglobal("cEasyHealer_Frame_Status" .. i .. "Text"):SetText( floor(CEASYHEALER_TABLE_UNITS[i].hp*100) .. "% " .. UnitName(CEASYHEALER_TABLE_UNITS[i].name) );
			end
			local r, g, b = cEasyHealer_Function_GetHealthColor( CEASYHEALER_TABLE_UNITS[i].hp );
			getglobal("cEasyHealer_Frame_Status" .. i .. "Text"):SetTextColor( r, g, b );
		else
			getglobal("cEasyHealer_Frame_Status" .. i):Hide();
			getglobal("cEasyHealer_Frame_Status" .. i).nickname = "empty1";
			getglobal("cEasyHealer_Frame_Status" .. i).id = "emptyid";
			getglobal("cEasyHealer_Frame_Status" .. i .. "Text"):SetText( "empty2" );
			getglobal("cEasyHealer_Frame_Status" .. i .. "Text"):SetTextColor( 0.5, 0.5, 0.5 );
		end
	end

end

function cEasyHealer_Function_GetHealthColor( ratio )

	if( (ratio >= 0) and (ratio <= 1) )
	then
		if( ratio < 0.5 )
		then
			return 1, (ratio/0.5), 0;
		else
			return (1-ratio), 1, 0;
		end
	else
		return 1, 1, 1;
	end

end

function cEasyHealer_Function_CastOnTarget( targetName )

	TargetByName( targetName );

	if ( IsShiftKeyDown() ) then
		CastSpellByName( CEASYHEALER_SPELL_TO_CAST_SHIFT );
	elseif ( IsAltKeyDown() ) then
		CastSpellByName( CEASYHEALER_SPELL_TO_CAST_ALT ) ;
	elseif ( IsControlKeyDown() ) then
		CastSpellByName( CEASYHEALER_SPELL_TO_CAST_CTRL );
	else
		--print("Name: "..targetName.. " Health: ".. UnitHealth("target") .." Charmed: " .. (UnitIsCharmed("target") or "false") .. " UnitIsDeadOrGhost: " .. (UnitIsDeadOrGhost("target") or "false"));
		CastSpellByName( CEASYHEALER_SPELL_TO_CAST );
	end

end
--===================================================================================================================--



--===================================================================================================================--
function cEasyHealer_Function_BinaryInsert( t, value, fcomp )
	-- modified version of table.binsert( table, value [, comp] )
	-- source: http://lua-users.org/wiki/OrderedAssociativeTable

	-- Initialise Compare function
	local fcomp = fcomp or function( a, b ) return a < b; end

	--  Initialise Numbers
	local iStart, iEnd, iMid, iState =  1, table.getn( t ), 1, 0

	-- Get Insertposition
	while iStart <= iEnd do
		
		-- calculate middle
		iMid = math.floor( ( iStart + iEnd )/2 )

		-- compare
		if fcomp( value.hp , t[iMid].hp ) then
			iEnd = iMid - 1
			iState = 0
		else
			iStart = iMid + 1
			iState = 1
		end
	end

	local pos = iMid+iState
	table.insert( t, pos, value )
	return pos
end
--===================================================================================================================--



--===================================================================================================================--
function cEasyHealer_Function_GetSpellName()

	if ( IsShiftKeyDown() ) then
		return CEASYHEALER_SPELL_TO_CAST_SHIFT;
	elseif ( IsAltKeyDown() ) then
		return CEASYHEALER_SPELL_TO_CAST_ALT;
	elseif ( IsControlKeyDown() ) then
		return CEASYHEALER_SPELL_TO_CAST_CTRL;
	else
		return CEASYHEALER_SPELL_TO_CAST;
	end

end

function cEasyHealer_Function_IsPet( unit )

	if( strfind(unit,"pet") == nil )
	then
		return false;
	else
		return false;
	end

end

function cEasyHealer_Function_IsInSameGroup( unit )

	for i = 1, GetNumPartyMembers(), 1
	do
		if( UnitName("party"..i) == UnitName(unit) )
		then
			--ChatFrame2:AddMessage( UnitName("raid"..i) .. "=".. UnitName(unit) );
			return true;
		end
	end

	return false;
end
--===================================================================================================================--