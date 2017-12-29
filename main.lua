local modDagger = RegisterMod("Dagger of the Pact",1)

local game = Game()
local sfx = SFXManager()
local r = RNG()
r:SetSeed(Random(),1)

local Dagger = {
	COSTS = {
		0,
		5,
		5,
		5,
		5
	},
	ODDS = {
		{0,0,0,100,0,0},
		{0,0,0,100,0,0},
		{0,0,0,100,0,0},
		{0,0,0,100,0,0},
		{0,0,0,100,0}
	},
	-- ODDS = {
		-- {80,10,10,0,0,0},
		-- {40,30,20,5,4,1},
		-- {20,20,25,20,10,5},
		-- {10,10,20,30,20,10},
		-- {5,10,15,20,30,20}
	-- },
	Given = {},
	THRESHOLDS = {},
	OVERCAP = 100,
	Threshold = 1,
	KillingNow = true,
	BloodCharge = 0
}

Dagger.Given["Abel"] = 0
Dagger.Given["Brother Bobby"] = 0
Dagger.Given["Dark Bum"] = 0
Dagger.Given["Demon Baby"] = 0
Dagger.Given["Dry Baby"] = 0
Dagger.Given["Ghost Baby"] = 0
Dagger.Given["Headless Baby"] = 0
Dagger.Given["Leech"] = 0
Dagger.Given["Lil Brimstone"] = 0
Dagger.Given["Lil Haunt"] = 0
Dagger.Given["Rotten Baby"] = 0
Dagger.Given["Sister Maggy"] = 0
Dagger.Given["Incubus"] = 0
Dagger.Given["Succubus"] = 0
Dagger.Given["Lil Delirium"] = 0
Dagger.Given["Shade"] = 0
Dagger.Given["7 Seals"] = 0
Dagger.Given["Multidimensional Baby"] = 0

modDagger.COLLECTIBLE_DAGGER_ONE = Isaac.GetItemIdByName("Dagger of the Pact")
modDagger.COLLECTIBLE_DAGGER_TWO = Isaac.GetItemIdByName(" Dagger of the Pact ")
modDagger.COLLECTIBLE_DAGGER_THREE = Isaac.GetItemIdByName("  Dagger of the Pact  ")
modDagger.COLLECTIBLE_DAGGER_FOUR = Isaac.GetItemIdByName("   Dagger of the Pact   ")
modDagger.COLLECTIBLE_DAGGER_FIVE = Isaac.GetItemIdByName("    Dagger of the Pact    ")

Dagger.THRESHOLDS[1] = Dagger.COSTS[1]
Dagger.THRESHOLDS[2] = Dagger.THRESHOLDS[1] + Dagger.COSTS[2]
Dagger.THRESHOLDS[3] = Dagger.THRESHOLDS[2] + Dagger.COSTS[3]
Dagger.THRESHOLDS[4] = Dagger.THRESHOLDS[3] + Dagger.COSTS[4]
Dagger.THRESHOLDS[5] = Dagger.THRESHOLDS[4] + Dagger.COSTS[5]

--Selects a random index from a table
function math.randomchoiceindex(t) 
    local keys = {}
    for key, value in pairs(t) do
        keys[#keys+1] = key --Store keys in another table
    end
    index = keys[r:RandomInt(#keys)+1]
    return index
end

function PlayerHasDagger()
	player = game:GetPlayer(0)
	item = player:GetActiveItem()
	
	return (item == modDagger.COLLECTIBLE_DAGGER_ONE or item == modDagger.COLLECTIBLE_DAGGER_TWO or item == modDagger.COLLECTIBLE_DAGGER_THREE or 
		item == modDagger.COLLECTIBLE_DAGGER_FOUR or item == modDagger.COLLECTIBLE_DAGGER_FIVE)
		
end

-- Choose and execute a random "reward" for the current threshold
function RewardRandom()
	local i = r:RandomInt(99)
	if i < Dagger.ODDS[Dagger.Threshold][1] then
		RewardHarm()
	elseif i < (Dagger.ODDS[Dagger.Threshold][1] + Dagger.ODDS[Dagger.Threshold][2]) then
		RewardHearts()
	elseif i < (Dagger.ODDS[Dagger.Threshold][1] + Dagger.ODDS[Dagger.Threshold][2] + Dagger.ODDS[Dagger.Threshold][3]) then
		RewardPickups()
	elseif i < (Dagger.ODDS[Dagger.Threshold][1] + Dagger.ODDS[Dagger.Threshold][2] + Dagger.ODDS[Dagger.Threshold][3] + Dagger.ODDS[Dagger.Threshold][4]) then
		RewardAllies()
	elseif i < (Dagger.ODDS[Dagger.Threshold][1] + Dagger.ODDS[Dagger.Threshold][2] + Dagger.ODDS[Dagger.Threshold][3] + Dagger.ODDS[Dagger.Threshold][4] + Dagger.ODDS[Dagger.Threshold][5]) then
		RewardStats()
	else
		RewardDevil()
	end
end

-- Harm the player based on the threshold, add a bit of blood charge (cost of tier 2)
function RewardHarm()
	player = game:GetPlayer(0)
	player:AnimateSad()
	if Dagger.Threshold == 1 then
		player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
	elseif Dagger.Threshold == 2 then
		player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
	elseif Dagger.Threshold == 3 then
		if player:GetSoulHearts() > 0 then
			player:TakeDamage(1, 0, EntityRef(player), 0)
		else
			player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
		end
	elseif Dagger.Threshold == 4 then
		if player:GetSoulHearts() > 0 then
			player:TakeDamage(2, 0, EntityRef(player), 0)
		else
			player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
		end
	else
		for i = 1, 2 do 
			if player:GetSoulHearts() > 0 then
				player:AddSoulHearts(-1)
			else
				player:AddHearts(-1)
			end
		end
		if player:GetSoulHearts() > 0 then
			player:TakeDamage(2, 0, EntityRef(player), 0)
		else
			player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
		end
	end
	Dagger.BloodCharge = Dagger.BloodCharge + Dagger.COSTS[2]
end

-- Spawn black hearts based on the threshold, reduce bloodcharge by COSTS[Threshold]
function RewardHearts()
	player = game:GetPlayer(0)
	player:AnimateHappy()
	for i = 1, Dagger.Threshold do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, Isaac.GetFreeNearPosition(player.Position,10), Vector(0,0), nil):ToPickup()
	end
	Dagger.BloodCharge = Dagger.BloodCharge - Dagger.COSTS[Dagger.Threshold]
end

-- Spawn random pickups based on the threshold, reduce bloodcharge by COSTS[Threshold]
function RewardPickups()

	Dagger.BloodCharge = Dagger.BloodCharge - Dagger.COSTS[Dagger.Threshold]
end

-- Spawn mostly-temporary allies (spiders, flies and passive items) based on threshold, reduce bloodcharge by COSTS[Threshold]
function RewardAllies()
	player = game:GetPlayer(0)
	player:AnimateHappy()	
	local rand = 1
	if Dagger.Threshold == 1 then
		for i = 1, 2 do
			player:AddBlueSpider(player.Position)
		end
	elseif Dagger.Threshold == 2 then
		for i = 1, 4 do
			player:AddBlueSpider(player.Position)
		end
		player:AddBlueFlies(3, player.Position, player)
		AddTempAlly()
	elseif Dagger.Threshold == 3 then
		for i = 1, 8 do
			player:AddBlueSpider(player.Position)
		end
		player:AddBlueFlies(8, player.Position, player)
		AddTempAlly()
	elseif Dagger.Threshold == 4 then
		for i = 1, 5 do
			player:AddBlueSpider(player.Position)
		end
			player:AddBlueFlies(5, player.Position, player)
		AddTempAlly()
		AddTempAlly()
	else
		for i = 1, 12 do
			player:AddBlueSpider(player.Position)
		end
		player:AddBlueFlies(8, player.Position, player)
		AddTempAlly()
		AddPermAlly()
	end

	Dagger.BloodCharge = Dagger.BloodCharge - Dagger.COSTS[Dagger.Threshold]
end

-- Add a temporary ally (Give the item and increment its count, to be removed next floor/on run exit)
function AddTempAlly()
	player = game:GetPlayer(0)
	local itemID = math.randomchoiceindex(Dagger.Given)
	if Dagger.Given[itemID] <= 9 then
		Dagger.Given[itemID] = Dagger.Given[itemID] + 1
		player:AddCollectible(Isaac.GetItemIdByName(itemID), 0, false)
	end
end

-- Loop through and remove all temporary allies
function RemoveTempAllies()
	player = game:GetPlayer(0)
	
	for key, value in pairs(Dagger.Given) do
		while value > 0 do
			player:RemoveCollectible(Isaac.GetItemIdByName(key))
			value = value - 1
			Dagger.Given[key] = value
		end
	end
end

function AddPermAlly()
	player = game:GetPlayer(0)
	local itemID = math.randomchoiceindex(Dagger.Given)
	player:AddCollectible(Isaac.GetItemIdByName(itemID), 0, false)
end

-- Permanently increase the player's stats based on threshold, reduce bloodcharge by COSTS[Threshold]
function RewardStats()

	Dagger.BloodCharge = Dagger.BloodCharge - Dagger.COSTS[Dagger.Threshold]
end

-- Spawn devil deals based on threshold, reduce bloodcharge by COSTS[Threshold]
function RewardDevil()

	Dagger.BloodCharge = Dagger.BloodCharge - Dagger.COSTS[Dagger.Threshold]
end

function modDagger:OnUpdate(player)
	player = game:GetPlayer(0)
	if PlayerHasDagger() then
		-- If KillingNow - that is, we're swiping with the dagger - check for NPC deaths and add to BloodCharge based on their health
		if Dagger.KillingNow then
			for i, entity in pairs(Isaac.GetRoomEntities()) do
				local data = entity:GetData()
				entity = entity:ToNPC()
				if entity and entity:IsActiveEnemy(true) then
					if entity:IsDead() and not data.Died then
						data.Died = true
						Dagger.BloodCharge = Dagger.BloodCharge + math.max(1, math.floor(math.log(entity.MaxHitPoints)/math.log(1.75)))
					end
				end
			end
		end
		-- Cap BloodCharge just beyond the last threshold
		if Dagger.BloodCharge > Dagger.THRESHOLDS[5] + Dagger.OVERCAP then
			Dagger.BloodCharge = Dagger.THRESHOLDS[5] + Dagger.OVERCAP
		end
		
		-- Readjust Dagger.Threshold as appropriate for Dagger.BloodCharge
		Dagger.Threshold = 0
		for i = 1, 5 do
			if Dagger.BloodCharge >= Dagger.THRESHOLDS[i] then
				Dagger.Threshold = i
			end
			i = i + 1
		end
		
		-- Replace item to change sprite based on threshold
		local charge = player:GetActiveCharge()
		if player:GetActiveItem() ~= modDagger.COLLECTIBLE_DAGGER_ONE and Dagger.Threshold == 1 then
			player:AddCollectible(modDagger.COLLECTIBLE_DAGGER_ONE, charge, true)
		end
		if player:GetActiveItem() ~= modDagger.COLLECTIBLE_DAGGER_TWO and Dagger.Threshold == 2 then
			player:AddCollectible(modDagger.COLLECTIBLE_DAGGER_TWO, charge, true)
		end
		if player:GetActiveItem() ~= modDagger.COLLECTIBLE_DAGGER_THREE and Dagger.Threshold == 3 then
			player:AddCollectible(modDagger.COLLECTIBLE_DAGGER_THREE, charge, true)
		end
		if player:GetActiveItem() ~= modDagger.COLLECTIBLE_DAGGER_FOUR and Dagger.Threshold == 4 then
			player:AddCollectible(modDagger.COLLECTIBLE_DAGGER_FOUR, charge, true)
		end
		if player:GetActiveItem() ~= modDagger.COLLECTIBLE_DAGGER_FIVE and Dagger.Threshold == 5 then
			player:AddCollectible(modDagger.COLLECTIBLE_DAGGER_FIVE, charge, true)
		end
	end
end

function modDagger:ActivateDagger()
	RewardRandom()
end

function modDagger:OnRender()
	Isaac.RenderText("The Blood Charge is: " .. tostring(Dagger.BloodCharge) .. ", the threshold is: " .. tostring(Dagger.Threshold),50, 0, 1, 1, 1, 1)
end

function modDagger:OnExit()
	RemoveTempAllies()
end

function modDagger:OnNewLevel()
	RemoveTempAllies()
end

modDagger:AddCallback(ModCallbacks.MC_POST_RENDER, modDagger.OnRender)
modDagger:AddCallback(ModCallbacks.MC_POST_UPDATE, modDagger.OnUpdate)
modDagger:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, modDagger.OnExit)
modDagger:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, modDagger.OnNewLevel)
modDagger:AddCallback(ModCallbacks.MC_USE_ITEM, modDagger.ActivateDagger, modDagger.COLLECTIBLE_DAGGER_ONE)
modDagger:AddCallback(ModCallbacks.MC_USE_ITEM, modDagger.ActivateDagger, modDagger.COLLECTIBLE_DAGGER_TWO)
modDagger:AddCallback(ModCallbacks.MC_USE_ITEM, modDagger.ActivateDagger, modDagger.COLLECTIBLE_DAGGER_THREE)
modDagger:AddCallback(ModCallbacks.MC_USE_ITEM, modDagger.ActivateDagger, modDagger.COLLECTIBLE_DAGGER_FOUR)
modDagger:AddCallback(ModCallbacks.MC_USE_ITEM, modDagger.ActivateDagger, modDagger.COLLECTIBLE_DAGGER_FIVE)