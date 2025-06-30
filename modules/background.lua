-- private variables
local background
local clientVersionLabel

function parseColoredText(input)
  local result = {}
  local pattern = "<color=([#%w]+)>(.-)<color/>"
  local lastEnd = 1

  for color, text, start in input:gmatch(pattern) do
      start = input:find("<color=", lastEnd)

      if start > lastEnd then
          local precedingText = input:sub(lastEnd, start - 1):gsub("^%s+", "")
          if precedingText ~= "" then
              table.insert(result, precedingText)
              table.insert(result, "#ffffff")
          end
      end

      table.insert(result, text)
      table.insert(result, color)

      lastEnd = start + #text + #color + 17
  end

  if lastEnd <= #input then
      local remainingText = input:sub(lastEnd):gsub("^%s+", "")
      if remainingText ~= "" then
          table.insert(result, remainingText)
          table.insert(result, "#ffffff")
      end
  end

  return result
end

-- public functions
function init()
  background = g_ui.displayUI('background')
  background:lower()

  connect(g_game, { onGameStart = hide })
  connect(g_game, { onGameEnd = show })
end

function terminate()
  disconnect(g_game, { onGameStart = hide })
  disconnect(g_game, { onGameEnd = show })

  g_effects.cancelFade(background:getChildById('clientVersionLabel'))
  background:destroy()

  Background = nil
end

function hide()
  background:hide()
end

function show()
  background:show()
end

function hideVersionLabel()
  background:getChildById('clientVersionLabel'):hide()
end

function setVersionText(text)
  clientVersionLabel:setText(text)
end

function getBackground()
  return background
end