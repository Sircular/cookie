local Board = require('gameboard')

function love.load()
  local img = love.graphics.newImage("img/imgs.png")
  Board.init(5, 5, 32, img)
end

function love.update(dt)
  -- do nothing
end

function love.draw()
  love.graphics.print("Hello world!", 100, 100)
  Board.draw()
end
