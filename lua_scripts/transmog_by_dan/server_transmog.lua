-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║           Transmog System Eluna Script by DanielTheDeveloper           ║
-- ╚════════════════════════════════════════════════════════════════════════╝
--
--                        ╔══════════════════════════╗
-- ╔══════════════════════║ Transmog System Settings ║══════════════════════╗
-- ║                      ╚══════════════════════════╝                      ║
-- ║ Automatically adds transmog appearances to the players account-wide    ║
-- ║ transmog collection when they equip an item for the first time.        ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled.                        ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_NEWLY_EQUIPPED_ITEMS_TO_THE_TRANSMOG_LIST = true          --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Automatically adds transmog appearances to the players account-wide    ║
-- ║ transmog collection when they loot an item for the first time.         ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option disabled as it creates the      ║
-- ║ potential for a more healthy transmog economy to exist inside the      ║
-- ║ auction house.                                                         ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_NEWLY_LOOTED_ITEMS_TO_THE_TRANSMOG_LIST = false           --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Automatically adds all applicable quest reward items as transmog       ║
-- ║ appearances to the players account-wide transmog collection when       ║
-- ║ completing a quest, regardless of which quest reward the player        ║
-- ║ actually decided to select.                                            ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it eliminates the    ║
-- ║ dilemma of deciding between a potential transmog appearance or gear    ║
-- ║ that is useful for the character.                                      ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local ADD_QUEST_REWARD_ITEMS_TO_THE_TRANSMOG_LIST = true            --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Restricts armor transmog appearances to items made up of the same      ║
-- ║ material. As an example, with this option enabled, cloth chest pieces  ║
-- ║ can only be transmogrified to appear as other cloth chest pieces.      ║
-- ║ When this option is disabled, cloth chest pieces can be                ║
-- ║ transmogrified to appear as a cloth, leather, mail, or plate chest     ║
-- ║ piece.                                                                 ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it leaves the        ║
-- ║ class fantasy intact.                                                  ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS = true           --║
-- ╟────────────────────────────────────────────────────────────────────────╢
-- ║                                                                        ║
-- ║ Restricts weapon transmog appearances to the same weapon. As an        ║
-- ║ example, with this option enabled, two-handed swords can only be       ║
-- ║ transmogrified to appear as other two-handed swords. When this option  ║
-- ║ is disabled, two-handed swords can be transmogrified to appear as a    ║
-- ║ one-handed sword, staff, polearm, fishing pole, etc.                   ║
-- ║                                                                        ║
-- ║ It is recommended to leave this option enabled as it leaves the        ║
-- ║ class fantasy intact.                                                  ║
-- ╟────────────────────────────────────────────────────────────────────────╢
      local RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS = true            --║
-- ╚════════════════════════════════════════════════════════════════════════╝

local AIO = AIO or require("AIO")
local TransmogHandlers = AIO.AddHandlers("Transmog", {})

local SLOTS = 6
local CALC = 281
local PLAYER_VISIBLE_ITEM_1_ENTRYID = 283  -- Head
local PLAYER_VISIBLE_ITEM_3_ENTRYID = 287  -- Shoulder
local PLAYER_VISIBLE_ITEM_4_ENTRYID = 289  -- Shirt
local PLAYER_VISIBLE_ITEM_5_ENTRYID = 291  -- Chest
local PLAYER_VISIBLE_ITEM_6_ENTRYID = 293  -- Waist
local PLAYER_VISIBLE_ITEM_7_ENTRYID = 295  -- Legs
local PLAYER_VISIBLE_ITEM_8_ENTRYID = 297  -- Feet
local PLAYER_VISIBLE_ITEM_9_ENTRYID = 299  -- Wrist
local PLAYER_VISIBLE_ITEM_10_ENTRYID = 301 -- Hands
local PLAYER_VISIBLE_ITEM_15_ENTRYID = 311 -- Back
local PLAYER_VISIBLE_ITEM_16_ENTRYID = 313 -- Main
local PLAYER_VISIBLE_ITEM_17_ENTRYID = 315 -- Off
local PLAYER_VISIBLE_ITEM_18_ENTRYID = 317 -- Ranged
local PLAYER_VISIBLE_ITEM_19_ENTRYID = 319 -- Tabard
local UNUSABLE_INVENTORY_TYPES = {[2] = true, [11] = true, [12] = true, [18] = true, [24] = true, [27] = true, [28] = true}

-- TODO: Add further language support.
local localeMessages = {
	LOOT_ITEM_LOCALE = {
		[0] = " has been added to your appearance collection.", -- enUS/enGB
		[3] = " wurde deiner Transmog-Sammlung hinzugefügt.", -- deDE
	},
	QUERYING_SERVER = {
		[0] = "Querying the server for collected transmogrification appearances...", -- enUS/enGB
	},
	NO_APPEARANCES = {
		[0] = "No transmogrification appearances could be located for this account. If you believe this is an error, please contact a Game Master.", -- enUS/enGB
	},
	SYNC_SUCCESSFUL = {
		[0] = "Your transmogrification appearance collection has been successfully synchronized.", -- enUS/enGB
	},
	NUM_APPEARANCES = {
		[0] = "You have collected |cfff194f7%d|r transmogrification appearances.", -- enUS/enGB
	},
	RELOAD_RECOMMENDATION = {
		[0] = "It is recommended that you |c0000c0ff/reload |ryour interface to finalize any changes, otherwise the AddOn may not function correctly.", -- enUS/enGB
	}
}

local function GetLocalizedMessage(messageID, locale, ...)
	 local message = localeMessages[messageID][locale] or localeMessages[messageID][0]
	 if select("#", ...) > 0 then
		  return string.format(message, ...)
	 end
	 return message
end

function Transmog_CalculateSlot(slot)
	if (slot == 0) then
		slot = 1
	elseif (slot >= 2) then
		slot = slot + 1
	end
	return CALC + (slot * 2);
end

function Transmog_CalculateSlotReverse(slot)
	local reverseSlot = (slot - CALC) / 2
	if (reverseSlot == 1) then
		return 0;
	end
	return reverseSlot;
end

function Transmog_OnCharacterCreate(event, player)
	local playerGUID = player:GetGUIDLow()
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_1_ENTRYID .. "', '', '');")  -- Head
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_3_ENTRYID .. "', '', '');")  -- Shoulder
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_4_ENTRYID .. "', '', '');")  -- Shirt
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_5_ENTRYID .. "', '', '');")  -- Chest
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_6_ENTRYID .. "', '', '');")  -- Waist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_7_ENTRYID .. "', '', '');")  -- Legs
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_8_ENTRYID .. "', '', '');")  -- Feet
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_9_ENTRYID .. "', '', '');")  -- Wrist
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_10_ENTRYID .. "', '', '');") -- Hands
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_15_ENTRYID .. "', '', '');") -- Back
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_16_ENTRYID .. "', '', '');") -- Main
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_17_ENTRYID .. "', '', '');") -- Off
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_18_ENTRYID .. "', '', '');") -- Ranged
	CharDBQuery("INSERT IGNORE INTO `character_transmog` (`player_guid`, `slot`, `item`, `real_item`) VALUES (" .. playerGUID .. ", '" .. PLAYER_VISIBLE_ITEM_19_ENTRYID .. "', '', '');") -- Tabard
end

function Transmog_OnCharacterDelete(event, guid)
	CharDBQuery("DELETE FROM character_transmog WHERE player_guid = " .. guid .. "")
end

function TransmogHandlers.LootItemLocale(player, item, count, locale)
	local accountGUID = player:GetAccountId()
	local itemId
	local itemTemplate
	
	if type(item) == "number" then
		itemId = item
		itemTemplate = GetItemTemplate(itemId)
	else
		itemTemplate = item:GetItemTemplate()
		itemId = itemTemplate:GetItemId()
	end
	
	local inventoryType = itemTemplate:GetInventoryType()
	local inventorySubType = itemTemplate:GetSubClass()
	local class = itemTemplate:GetClass()

	if (class == 2 or class == 4) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
		local displayId = itemTemplate:GetDisplayId()
		local itemName = itemTemplate:GetName()
		local locItemName = itemTemplate:GetName(locale)
		
		itemName = itemName:gsub("'", "''")
		AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `inventory_type`, `inventory_subtype`,`display_id`, `item_name`) VALUES (" .. accountGUID .. ", " .. itemId .. ", " .. inventoryType .. ", " .. inventorySubType .. ", " .. displayId .. ", '" .. itemName .. "');")
		
		if locItemName == nil then
			locItemName = itemTemplate:GetName(0)
		end
		
		local itemLink = "|cfff194f7|Hitem:" .. itemId .. ":0:0:0:0:0:0:0:0|h[" .. locItemName .. "]|h|r"
		player:SendBroadcastMessage(GetLocalizedMessage("LOOT_ITEM_LOCALE", locale))
	end
end

function Transmog_OnLootItem(event, player, item, count)
	local locale = player:GetDbLocaleIndex()
	TransmogHandlers.LootItemLocale(player, item, 1, locale)
end

function Transmog_OnQuestComplete(event, player, quest)
	local questID = quest:GetId()
	local locale = player:GetDbLocaleIndex()
	
	local questRewardsQuery = WorldDBQuery("SELECT RewardItem1, RewardItem2, RewardItem3, RewardItem4, RewardChoiceItemID1, RewardChoiceItemID2, RewardChoiceItemID3, RewardChoiceItemID4, RewardChoiceItemID5, RewardChoiceItemID6 FROM quest_template WHERE ID = " .. questID .. ";")
	
	if not questRewardsQuery then
		return
	end
	
	for i = 0, 9 do
		local itemId = questRewardsQuery:GetUInt32(i)
		if itemId and itemId > 0 then
			TransmogHandlers.LootItemLocale(player, itemId, 1, locale)
		end
	end
end

function Transmog_OnEquipItem(event, player, item, bag, slot)
	local accountGUID = player:GetAccountId()
	local playerGUID = player:GetGUIDLow()
	local class = item:GetClass()
	local inventoryType = item:GetItemTemplate():GetInventoryType()
	local inventorySubType = item:GetSubClass()
	
	if (class == 2 or class == 4) and not UNUSABLE_INVENTORY_TYPES[inventoryType] then
		local displayId = item:GetItemTemplate():GetDisplayId()
		local itemName = item:GetName()
		local itemId = item:GetItemTemplate():GetItemId()
		local locale = player:GetDbLocaleIndex()
		itemName = itemName:gsub("'", "''")
		
		local hasTransmogQuery = AuthDBQuery("SELECT 1 FROM `account_transmog` WHERE `account_id` = " .. accountGUID .. " AND `unlocked_item_id` = " .. itemId .. " LIMIT 1;")
		local isNewTransmog = (hasTransmogQuery == nil)
		
		AuthDBQuery("INSERT IGNORE INTO `account_transmog` (`account_id`, `unlocked_item_id`, `inventory_type`, `inventory_subtype`,`display_id`, `item_name`) VALUES (" .. accountGUID .. ", " .. itemId .. ", " .. inventoryType .. ", " .. inventorySubType .. ", " .. displayId .. ", '" .. itemName .. "');")
		
		if isNewTransmog then
			TransmogHandlers.LootItemLocale(player, itemId, 1, locale)
		end
		
		local constSlot = Transmog_CalculateSlot(slot)
		
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `real_item`) VALUES (" .. playerGUID .. ", '" .. constSlot .. "', " .. itemId .. ") ON DUPLICATE KEY UPDATE real_item = VALUES(real_item);")
		
		local transmog = CharDBQuery("SELECT item FROM character_transmog WHERE player_guid = " .. playerGUID .. " AND slot = " .. constSlot .. " AND item IS NOT NULL;")
		
		if transmog == nil then
			return;
		end
		
		local transmogItem = transmog:GetUInt32(0)
		local isPlayerInitDone = player:GetUInt32Value(147) -- Use unit padding
		
		if transmogItem == nil or (transmogItem == 0 and isPlayerInitDone ~= 1) then
			return;
		end
		
		player:SetUInt32Value(constSlot, transmogItem)
	end
end

-- TODO: add lua/c++ function for unequip!!
function TransmogHandlers.OnUnequipItem(player)
	local playerGUID = player:GetGUIDLow()

	local transmogs = CharDBQuery('SELECT item, real_item, slot FROM character_transmog WHERE player_guid = '..playerGUID..' AND item IS NOT NULL;') -- AND slot NOT IN ("313", "315", "317")
	if transmogs == nil then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local item = currentRow["item"]
		local slot = currentRow["slot"]
		local realItem = currentRow["real_item"] or "NULL"
		local validSlotItem = player:GetUInt32Value(tonumber(slot))
		if validSlotItem == 0 then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', "..item..", "..realItem..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
			player:SetUInt32Value(slot, item)
		end
		transmogs:NextRow()
	end
end

function Transmog_Load(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery("SELECT item, slot FROM character_transmog WHERE player_guid = "..playerGUID..";")
	if (transmogs == nil) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local slot = currentRow["slot"]
		local item = currentRow["item"]
		if (item ~= nil and item ~= '') then
			player:SetUInt32Value(tonumber(slot), item)
		end
		transmogs:NextRow()
	end
	AIO.Handle(player, "Transmog", "LoadTransmogsAfterSave")
end

function Transmog_OnLogin(event, player)
	-- Apply transmog on login
	-- Transmog_Load(player)
	--local item = player:GetEquippedItemBySlot(4)
	--print(item:GetName())
end

function TransmogHandlers.LoadPlayer(player)
	Transmog_Load(player)
	player:SetUInt32Value(147, 1) -- use unit padding
end

function TransmogHandlers.EquipTransmogItem(player, item, slot)
	local playerGUID = player:GetGUIDLow()
	
	if item == nil and item ~= 0 then
		local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
		local oldItemId = oldItem:GetUInt32(0)
		if oldItemId == nil or oldItemId == 0 then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', NULL) ON DUPLICATE KEY UPDATE item = VALUES(item);")
			player:SetUInt32Value(tonumber(slot), 0)
			return
		end

		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', NULL, "..oldItemId..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		player:SetUInt32Value(tonumber(slot), oldItemId)
		return
	end
	
	local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	local oldItemId = oldItem:GetUInt32(0)
	if oldItemId == nil or oldItemId == 0 then
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	else
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', "..item..", "..oldItemId..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
	end
	player:SetUInt32Value(tonumber(slot), item)
end

function TransmogHandlers.EquipAllTransmogItems(player, transmogPreview)
	if (transmogPreview == {}) then
		return;
	end
	
	local playerGUID = player:GetGUIDLow()
	
	for slot, item in ipairs(transmogPreview) do
		player:SetUInt32Value(tonumber(slot), item)
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`) VALUES ("..playerGUID..", '"..slot.."', "..item..") ON DUPLICATE KEY UPDATE item = VALUES(item);")
	end
end

function TransmogHandlers.UnequipTransmogItem(player, slot)
	local playerGUID = player:GetGUIDLow()
	
	local oldItem = CharDBQuery("SELECT real_item FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = "..slot..";")
	local oldItemId = oldItem:GetUInt32(0)
	if (oldItemId == nil or oldItemId == 0) then
		CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, 0) ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		player:SetUInt32Value(tonumber(slot), 0)
		return;
	end
	
	CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, '"..oldItemId.."') ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
	player:SetUInt32Value(tonumber(slot), oldItemId)
end

function TransmogHandlers.displayTransmog(player, spellid)
	AIO.Handle(player, "Transmog", "TransmogFrame")
	return false
end

function TransmogHandlers.Print(player, ...)
	print(...)
end

function TransmogHandlers.SetTransmogItemIds(player)
	local playerGUID = player:GetGUIDLow()
	
	local transmogs = CharDBQuery('SELECT item, real_item, slot FROM character_transmog WHERE player_guid = '..playerGUID..';') -- AND slot NOT IN ("313", "315", "317")
	if (transmogs == nil) then
		return;
	end
	
	for i = 1, transmogs:GetRowCount(), 1 do
		local currentRow = transmogs:GetRow()
		local item = currentRow["item"]
		local slot = currentRow["slot"]
		local real_item = currentRow["real_item"]
		local validSlotItem = player:GetUInt32Value(tonumber(slot))
		if (validSlotItem == 0) then
			CharDBQuery("INSERT INTO character_transmog (`player_guid`, `slot`, `item`, `real_item`) VALUES ("..playerGUID..", '"..slot.."', 0, "..real_item..") ON DUPLICATE KEY UPDATE item = VALUES(item), real_item = VALUES(real_item);")
		end
		if (not item or item == 0 and real_item ~= nil and real_item ~= 0 and (validSlotItem ~= 0 or not validSlotItem)) then
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, 0, real_item)
		else
			AIO.Handle(player, "Transmog", "SetTransmogItemIdClient", slot, item, real_item)
		end
		transmogs:NextRow()
	end
end

function TransmogHandlers.SetCurrentSlotItemIds(player, slot, page)
	local accountGUID = player:GetAccountId()

	-- Define inventory type mapping
	local inventoryTypesMapping = {
		[PLAYER_VISIBLE_ITEM_1_ENTRYID] = "= 1",
		[PLAYER_VISIBLE_ITEM_3_ENTRYID] = "= 3",
		[PLAYER_VISIBLE_ITEM_4_ENTRYID] = "= 4",
		[PLAYER_VISIBLE_ITEM_5_ENTRYID] = "IN (5, 20)",
		[PLAYER_VISIBLE_ITEM_6_ENTRYID] = "= 6",
		[PLAYER_VISIBLE_ITEM_7_ENTRYID] = "= 7",
		[PLAYER_VISIBLE_ITEM_8_ENTRYID] = "= 8",
		[PLAYER_VISIBLE_ITEM_9_ENTRYID] = "= 9",
		[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "= 10",
		[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "= 16",
		[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "IN (13, 17, 21)",
		[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "IN (13, 17, 22, 23, 14)",
		[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "IN (15, 25, 26)",
		[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "= 19"
	}

	-- Get the inventory type for the given slot
	local inventoryTypes = inventoryTypesMapping[slot]
	if not inventoryTypes then
		return -- Slot not valid, exit early
	end
	
	local equipmentSlot = nil
	
	if slot == PLAYER_VISIBLE_ITEM_3_ENTRYID then
		equipmentSlot = 2 -- Shoulder
	elseif slot == PLAYER_VISIBLE_ITEM_4_ENTRYID then
		equipmentSlot = 3 -- Shirt
	elseif slot == PLAYER_VISIBLE_ITEM_10_ENTRYID then
		equipmentSlot = 9 -- Hands
	elseif slot == PLAYER_VISIBLE_ITEM_15_ENTRYID then
		equipmentSlot = 14 -- Back
	elseif slot == PLAYER_VISIBLE_ITEM_16_ENTRYID then
		equipmentSlot = 15 -- Main
	elseif slot == PLAYER_VISIBLE_ITEM_17_ENTRYID then
		equipmentSlot = 16 -- Off
	elseif slot == PLAYER_VISIBLE_ITEM_18_ENTRYID then
		equipmentSlot = 17 -- Ranged
	else
		equipmentSlot = Transmog_CalculateSlotReverse(slot)
	end
	
	local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
	local equippedItemType = nil
	local equippedItemSubType = nil
	
	if currentItem then
		equippedItemType = currentItem:GetClass()
		equippedItemSubType = currentItem:GetSubClass()
	end

	-- Calculate page offset for pagination
	local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0
	
	local queryConditions = "account_id = " .. accountGUID .. " AND inventory_type " .. inventoryTypes
	
	if (RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS and equippedItemType == 4) or (RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS and equippedItemType == 2) and equippedItemSubType then
		queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
	end

	-- Query to count matching transmogs
	local countQuery = string.format(
		"SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE %s",
		queryConditions
	)
	local countResult = AuthDBQuery(countQuery)
	if not countResult then
		AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
		return
	end

	-- Get the total number of transmogs
	local totalTransmogs = countResult:GetUInt32(0)
	local hasMorePages = (totalTransmogs > SLOTS * page)

	-- Query to retrieve transmogs for the current page
	local transmogQuery = string.format(
		"SELECT unlocked_item_id FROM account_transmog WHERE %s LIMIT %d OFFSET %d;",
		queryConditions, SLOTS, pageOffset
	)
	local transmogs = AuthDBQuery(transmogQuery)
	if not transmogs then
		AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
		return
	end

	-- Collect the unlocked item IDs
	local currentSlotItemIds = {}
	for i = 1, transmogs:GetRowCount() do
		local currentRow = transmogs:GetRow()
		local item = currentRow["unlocked_item_id"]
		table.insert(currentSlotItemIds, item)
		transmogs:NextRow()
	end

	-- Return the result to the player
	AIO.Handle(player, "Transmog", "InitTab", currentSlotItemIds, page, hasMorePages)
end

function TransmogHandlers.SetSearchCurrentSlotItemIds(player, slot, page, search)
	-- Ensure search is not empty or nil
	if ( search == nil or serach == '' ) then
		return;
	end

	-- Escape special characters in search string
	search = search:gsub("[%'`&\"]", "%%")

	-- Define slot-to-inventory type mapping
	local inventoryTypesMapping = {
		[PLAYER_VISIBLE_ITEM_1_ENTRYID] = "= 1",
		[PLAYER_VISIBLE_ITEM_3_ENTRYID] = "= 3",
		[PLAYER_VISIBLE_ITEM_4_ENTRYID] = "= 4",
		[PLAYER_VISIBLE_ITEM_5_ENTRYID] = "IN (5, 20)",
		[PLAYER_VISIBLE_ITEM_6_ENTRYID] = "= 6",
		[PLAYER_VISIBLE_ITEM_7_ENTRYID] = "= 7",
		[PLAYER_VISIBLE_ITEM_8_ENTRYID] = "= 8",
		[PLAYER_VISIBLE_ITEM_9_ENTRYID] = "= 9",
		[PLAYER_VISIBLE_ITEM_10_ENTRYID] = "= 10",
		[PLAYER_VISIBLE_ITEM_15_ENTRYID] = "= 16",
		[PLAYER_VISIBLE_ITEM_16_ENTRYID] = "IN (13, 17, 21)",
		[PLAYER_VISIBLE_ITEM_17_ENTRYID] = "IN (13, 17, 22, 23, 14)",
		[PLAYER_VISIBLE_ITEM_18_ENTRYID] = "IN (15, 25, 26)",
		[PLAYER_VISIBLE_ITEM_19_ENTRYID] = "= 19"
	}

	-- Get inventory type for the given slot
	local inventoryTypes = inventoryTypesMapping[slot]
	if not inventoryTypes then
		return -- Slot not valid
	end
	
	local equipmentSlot = nil
	
	if slot == PLAYER_VISIBLE_ITEM_3_ENTRYID then
		equipmentSlot = 2 -- Shoulder
	elseif slot == PLAYER_VISIBLE_ITEM_4_ENTRYID then
		equipmentSlot = 3 -- Shirt
	elseif slot == PLAYER_VISIBLE_ITEM_10_ENTRYID then
		equipmentSlot = 9 -- Hands
	elseif slot == PLAYER_VISIBLE_ITEM_15_ENTRYID then
		equipmentSlot = 14 -- Back
	elseif slot == PLAYER_VISIBLE_ITEM_16_ENTRYID then
		equipmentSlot = 15 -- Main
	elseif slot == PLAYER_VISIBLE_ITEM_17_ENTRYID then
		equipmentSlot = 16 -- Off
	elseif slot == PLAYER_VISIBLE_ITEM_18_ENTRYID then
		equipmentSlot = 17 -- Ranged
	else
		equipmentSlot = Transmog_CalculateSlotReverse(slot)
	end
	
	local currentItem = player:GetEquippedItemBySlot(equipmentSlot)
	local equippedItemType = nil
	local equippedItemSubType = nil
	
	if currentItem then
		equippedItemType = currentItem:GetClass()
		equippedItemSubType = currentItem:GetSubClass()
	end

	-- Calculate page offset
	local pageOffset = (page > 1) and (SLOTS * (page - 1)) or 0
	
	local queryConditions = "account_id = " .. player:GetAccountId() .. " AND inventory_type " .. inventoryTypes .. " AND (display_id LIKE '%" .. search .. "%' OR item_name LIKE '%" .. search .. "%')"
	
	if (RESTRICT_ARMOR_TRANSMOG_TO_SIMILAR_MATERIALS and equippedItemType == 4) or (RESTRICT_WEAPON_TRANSMOG_TO_SIMILAR_WEAPONS and equippedItemType == 2) and equippedItemSubType then
		queryConditions = queryConditions .. " AND inventory_subtype = " .. equippedItemSubType
	end
	
	-- Query to count matching transmogs
	local countQuery = string.format(
		"SELECT COUNT(unlocked_item_id) FROM account_transmog WHERE %s;", 
		queryConditions
	)
	local countResult = AuthDBQuery(countQuery)
	if not countResult then
		AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
		return
	end

	local totalTransmogs = countResult:GetUInt32(0)
	local hasMorePages = (totalTransmogs > SLOTS * page)

	-- Query to get transmogs
	local transmogQuery = string.format(
		"SELECT unlocked_item_id FROM account_transmog WHERE %s LIMIT %d OFFSET %d;", 
		queryConditions, SLOTS, pageOffset
	)
	local transmogs = AuthDBQuery(transmogQuery)
	if not transmogs then
		AIO.Handle(player, "Transmog", "InitTab", {}, page, false)
		return
	end

	-- Collect the unlocked item IDs
	local currentSlotItemIds = {}
	for i = 1, transmogs:GetRowCount() do
		local currentRow = transmogs:GetRow()
		local item = currentRow["unlocked_item_id"]
		table.insert(currentSlotItemIds, item)
		transmogs:NextRow()
	end

	-- Return the result
	AIO.Handle(player, "Transmog", "InitTab", currentSlotItemIds, page, hasMorePages)
end

function TransmogHandlers.SetEquipmentTransmogInfo(player, slot, currentTooltipSlot)
	local playerGUID = player:GetGUIDLow()
	
	local transmog = CharDBQuery("SELECT COUNT(item) FROM character_transmog WHERE player_guid = "..playerGUID.." AND slot = '"..slot.."';")
	if (transmog == nil) then
		return;
	end
	
	if (transmog:GetUInt32(0) ~= 0) then
		AIO.Handle(player, "Transmog", "SetEquipmentTransmogInfoClient", currentTooltipSlot)
	end
end

function TransmogHandlers.SendCollectedTransmogItemIds(player)
	local accountGUID = player:GetAccountId()
	local locale = player:GetDbLocaleIndex()
	
	player:SendBroadcastMessage(GetLocalizedMessage("QUERYING_SERVER", locale))
	player:SendBroadcastMessage(" ")
	
	-- Query to retrieve collected transmog item IDs
	local collectedTransmogsQuery = "SELECT unlocked_item_id FROM account_transmog WHERE account_id = " .. accountGUID .. ";"
	local transmogs = AuthDBQuery(collectedTransmogsQuery)
	
	if not transmogs then
		player:SendBroadcastMessage(GetLocalizedMessage("NO_APPEARANCES", locale))
		return
	end
	
	-- Collect the item IDs into a table
	local collectedTransmogs = {}
	for i = 1, transmogs:GetRowCount() do
		local currentRow = transmogs:GetRow()
		local itemId = currentRow["unlocked_item_id"]
		table.insert(collectedTransmogs, itemId)
		transmogs:NextRow()
	end
	
	-- Send the collected transmogs to the client
	AIO.Handle(player, "Transmog", "ReceiveCollectedAppearances", collectedTransmogs)
	player:SendBroadcastMessage(GetLocalizedMessage("SYNC_SUCCESSFUL", locale))
	player:SendBroadcastMessage(GetLocalizedMessage("NUM_APPEARANCES", locale, #collectedTransmogs))
	player:SendBroadcastMessage(" ")
	player:SendBroadcastMessage(GetLocalizedMessage("RELOAD_RECOMMENDATION", locale))
end

RegisterPlayerEvent(1, Transmog_OnCharacterCreate)
RegisterPlayerEvent(2, Transmog_OnCharacterDelete)

if ADD_NEWLY_EQUIPPED_ITEMS_TO_THE_TRANSMOG_LIST then
	RegisterPlayerEvent(29, Transmog_OnEquipItem)
end

if ADD_NEWLY_LOOTED_ITEMS_TO_THE_TRANSMOG_LIST then
	RegisterPlayerEvent(32, Transmog_OnLootItem)
	RegisterPlayerEvent(51, Transmog_OnLootItem)
	RegisterPlayerEvent(52, Transmog_OnLootItem)
	RegisterPlayerEvent(53, Transmog_OnLootItem)
	RegisterPlayerEvent(56, Transmog_OnLootItem)
end

if ADD_QUEST_REWARD_ITEMS_TO_THE_TRANSMOG_LIST then
	RegisterPlayerEvent(54, Transmog_OnQuestComplete)
end

RegisterPlayerEvent(42, function(event, player, command)
	if command:lower() == "transmog sync" then
		TransmogHandlers.SendCollectedTransmogItemIds(player)
		return false
	end
	return true
end)

print("[Eluna] Transmog System loaded successfully.")
