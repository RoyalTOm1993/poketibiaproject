function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	addEvent(function() createRandomHeavenBoss() end, 60 * 1000 * 15)
    return true
end
