local Game = require("game")
local States = require("lib/stateful")

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  States.bootstrap()
  States.push(Game)
end
