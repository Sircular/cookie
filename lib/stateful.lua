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
  setmetatable(love, {__index = state and state or nil})
  setmetatable(love.handlers, {__index = (state and state.handlers) and state.handlers or nil})
end

function States.push(state)
  local stack = States.stateStack

  _runSafe(stack[#stack], "suspend")

  States._bootstrap(state)
  stack[#stack] = state
  _runSafe(stack[#stack], "enter")
end

function States.pop()
  local stack = States.stateStack

  _runSafe(stack[#stack], "exit")
  stack[#stack] = nil

  if #stack == 0 and States.exitOnEmpty then
    love.event.quit()
  end

  States._bootstrap(stack[#stack])
  _runSafe(stack[#stack], "resume")

end

function States.newState()
  return {
    handlers = {}
  }
end

return States
