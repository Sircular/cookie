local States = {
  stateStack  = {},
  exitOnEmpty = false
}

local eventNames = {"draw", "focus", "keypressed", "keyreleased", "mousefocus",
    "mousemoved", "mousepressed", "mousereleased", "wheelmoved", "resize",
    "textinput", "visible", "update"}

-- I got tired of typing this same pattern over and over
local function _runSafe(a, b, ...)
  if type(a) == "function" then
    return a(b, ...)
  elseif type(a) == "table" and type(b) == "string" and a[b] then
    return a[b](...)
  end
end

-- called from push and pop

function States._bootstrap(state)
  if state then
    for _, name in pairs(eventNames) do
      if state[name] then
        love[name] = state[name]
      end
    end
    if state.handlers then
      for k, v in pairs(state.handlers) do
        love.handlers[k] = v
      end
    end
  end
end

-- hopefully this doesn't break anything important
function States._unbootstrap(state)
  if state then
    for _, name in pairs(eventNames) do
      if state[name] then
        love[name] = nil
      end
    end
    if state.handlers then
      for k, _ in pairs(state.handlers) do
        love.handlers[k] = nil
      end
    end
  end
end

function States.push(state)
  local stack = States.stateStack

  States._unbootstrap(stack[#stack])
  _runSafe(stack[#stack], "suspend")

  States._bootstrap(state)
  stack[#stack] = state
  _runSafe(stack[#stack], "enter")
end

function States.pop()
  local stack = States.stateStack

  _runSafe(stack[#stack], "exit")
  States._unbootstrap(stack[#stack])
  stack[#stack] = nil

  States._bootstrap(stack[#stack])
  _runSafe(stack[#stack], "resume")

  if #stack == 0 and States.exitOnEmpty then
    love.event.quit()
  end
end

return States
