local Board = require('gameboard')

local boardcanvas

function love.load()
  local img = love.graphics.newImage("img/imgs.png")
  Board.init(5, 5, 32, img)
  
  boardcanvas = love.graphics.newCanvas(5*32, 5*32)
end

function love.update(dt)
  -- do nothing
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.setCanvas(boardcanvas)
  love.graphics.clear()
  Board.draw()
  love.graphics.setCanvas()

  -- center it on the screen
  local w, h = love.graphics.getDimensions()
  love.graphics.draw(boardcanvas, (w-Board.getScreenWidth())/2,
      (h-Board.getScreenHeight())/2)

end
