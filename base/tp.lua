local tpId = 1387

local tps = {
["Arceus MVP"] = {pos = {x=2656, y=2661, z=8}, toPos = {x=2631, y=2661, z=8}, time = 30},
["Deoxys Mvp"] = {pos = {x=488, y=135, z=15}, toPos = {x=498, y=130, z=15}, time = 30},
["Shiny Regigigas MVP"] = {pos = {x=1085, y=501, z=14}, toPos = {x=1086, y=514, z=14}, time = 30},
["Shiny Zekrom MVP"] = {pos = {x=840, y=15, z=7}, toPos = {x=842, y=13, z=7}, time = 30},
["Reshiram MVP"] = {pos = {x=808, y=53, z=7}, toPos = {x=800, y=52, z=7}, time = 30},
["Phione MVP"] = {pos = {x=596, y=21, z=14}, toPos = {x=606, y=21, z=13}, time = 30},
["Mewtwo M1"] = {pos = {x=521, y=556, z=13}, toPos = {x=519, y=563, z=13}, time = 30},
["Shiny Lugia MVP"] = {pos = {x=786, y=565, z=14}, toPos = {x=415, y=510, z=13}, time = 15},
["Lugia MVP"] = {pos = {x=787, y=563, z=14}, toPos = {x=797, y=564, z=14}, time = 15},
["Ho-Oh MVP"] = {pos = {x=458, y=537, z=13}, toPos = {x=460, y=522, z=11}, time = 15},
["Shiny Genesect MVP"] = {pos = {x=562, y=390, z=14}, toPos = {x=568, y=399, z=14}, time = 15},
["Shiny Victini Mvp"] = {pos = {x=1178, y=360, z=13}, toPos = {x=1182, y=357, z=13}, time = 15},
["Shiny Darkrai MVP"] = {pos = {x=971, y=617, z=14}, toPos = {x=985, y=603, z=14}, time = 15},
["Heatran MVP Nv2"] = {pos = {x=351, y=388, z=14}, toPos = {x=276, y=472, z=14}, time = 15},
["Hoopa Unbound Star"] = {pos = {x=887, y=501, z=14}, toPos = {x=1042, y=397, z=14}, time = 15},
["Green Dialga MVP"] = {pos = {x=485, y=41, z=15}, toPos = {x=498, y=29, z=15}, time = 15},
["Giratina MVP"] = {pos = {x=446, y=380, z=14}, toPos = {x=453, y=380, z=14}, time = 15},
["Giratina Star"] = {pos = {x=446, y=370, z=14}, toPos = {x=432, y=380, z=14}, time = 15},
["Magmar Tower"] = {pos = {x=3158, y=2340, z=15}, toPos = {x=3203, y=2340, z=15}, time = 15},
["Metagross Tower"] = {pos = {x=3158, y=2342, z=14}, toPos = {x=3203, y=2340, z=14}, time = 15},
["Terrakion Tower"] = {pos = {x=3158, y=2343, z=13}, toPos = {x=3203, y=2341, z=13}, time = 15},
["Jirachi Tower"] = {pos ={x=3157, y=2344, z=12}, toPos = {x=3203, y=2341, z=12}, time = 15},
["Genesect Tower"] = {pos = {x=3157, y=2346, z=11}, toPos = {x=3203, y=2341, z=11}, time = 15},
["Mew Tower"] = {pos = {x=3156, y=2345, z=10}, toPos = {x=3203, y=2341, z=10}, time = 15},
["Mewtwo Tower"] = {pos = {x=3157, y=2346, z=9}, toPos = {x=3203, y=2341, z=9}, time = 15},
["Zarude Tower"] = {pos = {x=3157, y=2346, z=8}, toPos = {x=3203, y=2341, z=8}, time = 15},
["Carnage Tower"] = {pos = {x=3162, y=2346, z=7}, toPos = {x=3203, y=2341, z=7}, time = 15},
["Venom Tower"] = {pos = {x=3171, y=2357, z=6}, toPos = {x=3204, y=2342, z=6}, time = 15},
["Arceus Boss Tower"] = {pos = {x=3164, y=2345, z=5}, toPos = {x=3204, y=2342, z=5}, time = 15},
["Fusion Latios Boss Tower"] = {pos = {x=3158, y=2348, z=4}, toPos = {x=3204, y=2342, z=4}, time = 15},
["Perfect Zygarde Boss Tower"] = {pos = {x=3156, y=2347, z=3}, toPos = {x=3204, y=2342, z=3}, time = 15},
["Gyarados Boss Tower"] = {pos = {x=3158, y=2347, z=2}, toPos = {x=3204, y=2342, z=2}, time = 15},
["Red Gyarados Boss Tower"] = {pos = {x=3158, y=2348, z=1}, toPos = {x=3204, y=2342, z=1}, time = 15},
["Charizard MVP"] = {pos = {x=3545, y=2873, z=9}, toPos = {x=3537, y=2890, z=8}, time = 15},
["Dragonite MVP"] = {pos = {x=3536, y=2889, z=9}, toPos = {x=3554, y=2890, z=8}, time = 15},
["Machoke MVP"] = {pos = {x=3553, y=2889, z=9}, toPos = {x=3528, y=2906, z=8}, time = 15},
["Magmortar MVP"] = {pos = {x=3527, y=2905, z=9}, toPos = {x=3545, y=2906, z=8}, time = 15},
["Majestic MVP"] = {pos = {x=3544, y=2905, z=9}, toPos = {x=3562, y=2906, z=8}, time = 15},
["Metagross MVP"] = {pos = {x=3561, y=2905, z=9}, toPos = {x=3545, y=2869, z=8}, time = 15},
["Mega Metagross MVP"] = {pos = {x=3067, y=3574, z=8}, toPos = {x=3061, y=3578, z=8}, time = 15},
["Hoopa Unbound MVP"] = {pos = {x=1026, y=396, z=13}, toPos = {x=1032, y=397, z=13}, time = 15},
["Kyurem Boos"] = {pos = {x=3412, y=3422, z=8}, toPos = {x=3427, y=3397, z=8}, time = 15},
["Ultra Lucario MVP"] = {pos = {x=3014, y=2838, z=8}, toPos = {x=3026, y=2837, z=8}, time = 15},
["Mega Lucario Mvp"] = {pos = {x=3026, y=2839, z=8}, toPos = {x=2984, y=2844, z=9}, time = 15},
["Ultra Hydreigon MVP"] = {pos = {x=2899, y=2801, z=9}, toPos = {x=2984, y=2849, z=9}, time = 15},
["Ultra Hydreigon MVP2"] = {pos = {x=2925, y=2875, z=9}, toPos = {x=2990, y=2843, z=9}, time = 15},
["Ultra Hydreigon MVP3"] = {pos = {x=3059, y=2886, z=9}, toPos = {x=2984, y=2843, z=10}, time = 30},
["Terrakion MVP"] = {pos = {x=2990, y=2919, z=13}, toPos = {x=2981, y=2926, z=13}, time = 30},
["Legendary Virizion MVP"] = {pos = {x=2926, y=2860, z=15}, toPos = {x=2940, y=2879, z=15}, time = 15},
["Meloetta Star MVP"] = {pos = {x=3231, y=2613, z=14}, toPos = {x=3231, y=2611, z=14}, time = 15},
["Yveltal MVP"] = {pos = {x=3068, y=3398, z=13}, toPos = {x=3054, y=3408, z=13}, time = 15},
["PXM PRO"] = {pos = {x=2628, y=2750, z=8}, toPos = {x=2624, y=2710, z=8}, time = 15},
["Zoroark MVP"] = {pos = {x=2506, y=2355, z=8}, toPos = {x=2510, y=2335, z=8}, time = 15},
["Shiny Lunala MVP"] = {pos = {x=3367, y=2846, z=15}, toPos = {x=3426, y=2844, z=15}, time = 15},
["Ultra Lunala MVP"] = {pos = {x=3549, y=2753, z=15}, toPos = {x=3583, y=2753, z=15}, time = 15},
["Ancient Metagross MVP"] = {pos = {x=3586, y=2754, z=15}, toPos = {x=3584, y=2776, z=15}, time = 15},
["Melmetal MVP"] = {pos = {x=3584, y=2777, z=15}, toPos = {x=3509, y=2746, z=15}, time = 15},
["Guzzlord Mvp"] = {pos = {x=3584, y=2754, z=12}, toPos = {x=3596, y=2750, z=12}, time = 15},
["Nagadel MVP"] = {pos = {x=2990, y=3186, z=14}, toPos = {x=3031, y=3143, z=15}, time = 15},
["Tapu Koko MVP"] = {pos = {x=1263, y=1619, z=8}, toPos = {x=1288, y=1615, z=8}, time = 15},
["Xurkitree MVP"] = {pos = {x=2011, y=1846, z=8}, toPos = {x=2018, y=1847, z=8}, time = 15},
["Xerneas MVP"] = {pos = {x=840, y=2346, z=10}, toPos = {x=866, y=2325, z=10}, time = 15},
["Celesteela Mvp"] = {pos = {x=296, y=2248, z=4}, toPos = {x=306, y=2239, z=7}, time = 15},
["Tapu Lele MVP"] = {pos = {x=3517, y=3185, z=9}, toPos = {x=3555, y=3198, z=9}, time = 15},
["Legendary Zapdos MVP"] = {pos = {x=615, y=1853, z=2}, toPos = {x=606, y=1861, z=1}, time = 15},
["Tapu Fini MVP"] = {pos = {x=480, y=2500, z=8}, toPos = {x=474, y=2540, z=8}, time = 15},
["Magearna MVP"] = {pos = {x=407, y=2309, z=8}, toPos = {x=396, y=2332, z=8}, time = 15},
["Espectral Arceus MVP"] = {pos = {x=1404, y=1682, z=9}, toPos = {x=1496, y=1641, z=10}, time = 30},
["Espectral Zygarde MVP"] = {pos = {x=1418, y=1686, z=15}, toPos = {x=1419, y=1702, z=15}, time = 15},
["Papai Noel MVP"] = {pos = {x=3442, y=3475, z=7}, toPos = {x=3485, y=3540, z=8}, time = 30},
["Rayquaza Natalino MVP"] = {pos = {x=3483, y=3610, z=8}, toPos = {x=3463, y=3620, z=8}, time = 15},
["Plasma Mewtwo"] = {pos = {x=4199, y=1451, z=6}, toPos = {x=4233, y=1635, z=6}, time = 15},
["Marshadow MVP"] = {pos = {x=4273, y=2361, z=2}, toPos = {x=4284, y=2361, z=2}, time = 15},
["Marshadow Rgb Mvp"] = {pos = {x=4284, y=2334, z=0}, toPos = {x=4231, y=2361, z=1}, time = 30},
["Marshadow Rgb MVP 2"] = {pos = {x=4231, y=2361, z=1}, toPos = {x=4232, y=2362, z=0}, time = 30},
["Mega Mewtwo MVP"] = {pos = {x=3038, y=2709, z=8}, toPos = {x=3037, y=2710, z=9}, time = 15},
["Mech Metapod MVP"] = {pos = {x=4078, y=2589, z=8}, toPos = {x=4146, y=2634, z=8}, time = 30},
["Perfect Zoroark MVP"] = {pos = {x=3003, y=2210, z=3}, toPos = {x=3003, y=2214, z=3}, time = 30},
["Black Golurk MVP"] = {pos = {x=3130, y=2148, z=7}, toPos = {x=3212, y=2225, z=7}, time = 30},
["Hoopa Unbound M1"] = {pos = {x=3196, y=3069, z=8}, toPos = {x=3213, y=3007, z=8}, time = 30},
["Hoopa Unbound M2"] = {pos = {x=3221, y=3022, z=8}, toPos = {x=3703, y=2376, z=15}, time = 30},
["Hoopa Unbound M3"] = {pos = {x=3673, y=2332, z=14}, toPos = {x= 3534, y=3257, z=8}, time = 30},
["Hoopa Unbound M4"] = {pos = {x=3482, y=3298, z=8}, toPos = {x=3672, y=2307, z=14}, time = 30},
}
function removeTp(tp)

local t = getTileItemById(tp.pos, tpId)

if t then
	
-- doRemoveItem(t.uid, 1)
doRemoveItem(t.uid)

doSendMagicEffect(tp.pos, CONST_ME_POFF)

end

end

 

function onDeath(cid)
monster = Creature(cid)
local tp = tps[getCreatureName(monster:getId())]

if tp then

doCreateTeleport(tpId, tp.toPos, tp.pos)

doCreatureSay(monster:getId(), "O teleport irá sumir em "..tp.time.." segundos.", TALKTYPE_ORANGE_1)

addEvent(removeTp, tp.time*1000, tp)

end

return TRUE

end