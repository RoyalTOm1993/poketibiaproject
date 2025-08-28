-- background.lua
local background
local defaultImage = '/images/background'
local charListImage = '/images/background2'

local function getBackground()
  if not background then
    background = g_ui.displayUI('background')
    background:lower()
  end
  return background
end

function init()
  local bg = getBackground()
  bg:setImageSource(defaultImage)
  bg:show()
end

function terminate()
  if background then
    background:destroy()
    background = nil
  end
end

function setBackgroundToDefault()
  local bg = getBackground()
  bg:setImageSource(defaultImage)
  bg:show()
end

function setBackgroundToCharacterList()
  local bg = getBackground()
  bg:setImageSource(charListImage)
  bg:show()
end

function hide()
  local bg = getBackground()
  bg:hide()
end

function show()
  local bg = getBackground()
  bg:show()
end
