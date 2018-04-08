local Game = require("game")
local States = require("lib/stateful")

-- hack until I update to the newest version of LOVE
table.unpack = unpack

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  States.bootstrap()
  States.push(Game)
end
