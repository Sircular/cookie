local Board = require('gameboard')

local boardcanvas

function love.load()
  local tileImg   = love.graphics.newImage("img/imgs.png")
  local cursorImg = love.graphics.newImage("img/cursor.png")
  Board.init(5, 5, 32, tileImg, cursorImg)
  
  boardcanvas = love.graphics.newCanvas(5*32, 5*32)
end

function love.update(dt)
  Board.update(dt)
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

function love.keypressed(keystr)
  local moves = {
    w = {0, -1},
    a = {-1, 0},
    s = {0, 1},
    d = {1, 0},
  }

  local movement = moves[keystr]
  if movement then
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
      Board.rotate(unpack(movement))
    else
      Board.moveCursor(unpack(movement))
    end
  end

end
