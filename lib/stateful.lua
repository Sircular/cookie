local States = {
  stateStack  = {},
  exitOnEmpty = false
}

-- I got tired of typing this same pattern over and over
local function _runSafe(a, b, ...)
  if type(a) == "function" then
    return a(b, ...)
  elseif type(a) == "table" and type(b) == "string" and a[b] then
    return a[b](...)
  end
end


-- register most of the love events
-- only uses ones that I need at the moment
function States.bootstrap()
  local events = {"draw", "focus", "keypressed", "keyreleased", "mousefocus",
      "mousemoved", "mousepressed", "mousereleased", "wheelmoved", "resize",
      "textinput", "visible", "update"}
  for i = 1, #events do
    local name = events[i]

    love[name] = function(...)
      local curState = States.stateStack[#States.stateStack]
      _runSafe(curState, name, ...)
    end

  end
end

function States.push(state)
  local stack = States.stateStack
  _runSafe(stack[#stack], "suspend")
  stack[#stack] = state
  _runSafe(stack[#stack], "enter")
end

function States.pop()
  local stack = States.stateStack
  _runSafe(stack[#stack], "exit")
  stack[#stack] = nil
  _runSafe(stack[#stack], "resume")

  if #stack == 0 and States.exitOnEmpty then
    love.event.quit()
  end
end

return States
