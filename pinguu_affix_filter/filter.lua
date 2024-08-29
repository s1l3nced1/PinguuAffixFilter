-- 1 Affix = Red, 2 Affixes = Orange, 3 Affixes = Green

local filter = {}

filter.helm_affix_filter = {

}

filter.chest_affix_filter = {
    { sno_id = 1829562, affix_name = "Dexterity", required = true },
    { sno_id = 1873229, affix_name = "Ranks To Dark Shroud" },
    { sno_id = 1829592, affix_name = "Max. Life" },
}

filter.gloves_affix_filter = {
    { sno_id = 1873211, affix_name = "Ranks To Rapid Fire" },
    { sno_id = 1829586, affix_name = "Critical Strike Damage" },
    { sno_id = 1829556, affix_name = "Attack Speed" },
}

filter.pants_affix_filter = {
    { sno_id = 1829562, affix_name = "Dexterity" },
    { sno_id = 1829592, affix_name = "Max. Life" },
    { sno_id = 1834117, affix_name = "Dodge Chance" },
}

filter.boots_affix_filter = {
    { sno_id = 1829598, affix_name = "Movement Speed" },
    { sno_id = 1829592, affix_name = "Max. Life" },
    { sno_id = 1829554, affix_name = "Armor" },
}

filter.two_hand_weapons_affix_filter = {
    { sno_id = 1829562, affix_name = "Dexterity" },
    { sno_id = 1829586, affix_name = "Critical Strike Damage", required = true },
    { sno_id = 1829592, affix_name = "Max. Life" },
}

filter.one_hand_weapons_affix_filter = {
    { sno_id = 1829562, affix_name = "Dexterity" },
    { sno_id = 1829586, affix_name = "Critical Strike Damage" },
    { sno_id = 1829592, affix_name = "Max. Life" },
}

filter.amulet_affix_filter = {
    { sno_id = 1829562, affix_name = "Dexterity" },
    { sno_id = 1927657, affix_name = "Ranks To Frigid Finesse" },
    { sno_id = 1927475, affix_name = "Ranks To Weapon Mastery" },
}

filter.ring_affix_filter = {
    { sno_id = 1829586, affix_name = "Critical Strike Damage" },
    { sno_id = 1829556, affix_name = "Attack Speed" },
    { sno_id = 1829562, affix_name = "Dexterity" },
}

-- Weapon filters (Direct)
filter.focus_weapons_affix_filter = {
    { sno_id = 1829566, affix_name = "Intelligence" },
    { sno_id = 1829560, affix_name = "Cooldown Reduction"}
}

filter.dagger_weapons_affix_filter = {
    
}

filter.shield_weapons_affix_filter = {
    
}


return filter