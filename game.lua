local States = require('lib/stateful')

local Game = States.newState()

local Board = require("board")

local scale = 2

local boardcanvas
local bg

function Game.enter()
  local tileImg   = love.graphics.newImage("img/imgs.png")
  local cursorImg = love.graphics.newImage("img/cursor.png")
  Board.init(5, 5, 32, tileImg, cursorImg)

  local bgImg = love.graphics.newImage("img/bg.png")
  bg = love.graphics.newSpriteBatch(bgImg)
  for x = 0, Board.width-1 do
    for y = 0, Board.height-1 do
      bg:add(x*Board.tilesize, y*Board.tilesize)
    end
  end

  boardcanvas = love.graphics.newCanvas(5*32, 5*32)

end

function Game.update(dt)
  Board.update(dt)
end

function Game.draw()
  love.graphics.setColor(255, 255, 255, 255)


  love.graphics.setCanvas(boardcanvas)
  love.graphics.clear()
  Board.draw()
  love.graphics.setCanvas()

  -- center it on the screen
  local w, h = love.graphics.getDimensions()

  -- scaled values
  local bw = Board.getScreenWidth()*scale
  local bh = Board.getScreenWidth()*scale
  love.graphics.draw(bg, (w-bw)/2, (h-bh)/2, 0, scale, scale)
  love.graphics.draw(boardcanvas, (w-bw)/2, (h-bh)/2, 0, scale, scale)

end

function Game.keypressed(keystr)
  local moves = {
    w = {0, -1},
    a = {-1, 0},
    s = {0, 1},
    d = {1, 0},
  }

  local movement = moves[keystr]
  if movement then
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
      Board.rotate(table.unpack(movement))
    else
      Board.moveCursor(table.unpack(movement))
    end
  end

end

function Game.handlers.clearedLines(count)
end

return Game
