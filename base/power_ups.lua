POWERUP = {

    [ID] = {
        ["ATTACK"] = {bonus = 20, time = 60}, -- seconds time
        ["DEFENSE"] = {bonus = 10, time = 60}, -- seconds time
    }

}

-- add condition

TYPES_POWERUP = {
   ["ATTACK"] = "ATTRIBUTE_BONUS_ATTACK",
   ["DEFENSE"] = "ATTRIBUTE_BONUS_DEFENSE",
   ["HEALTH"] = "ATTRIBUTE_BONUS_HEALTH",
   ["COOLDOWN"] = "ATTRIBUTE_BONUS_COOLDOWN",
   ["REVIVE"] = "ATTRIBUTE_BONUS_REVIVE",
}

POWERUP.convertType = function(type)
    return TYPES_POWERUP[type]
end


function Item.addPowerUp(self, type)
    self:setSpecialAttribute(POWERUP.convertType(type), bonus)
    return
end