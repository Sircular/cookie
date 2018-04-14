local States = require('lib/stateful')
local Slice9 = require('lib/slice9')
local TiledImg = require('tiledimg')

local Game = States.newState()

local Board = require("board")

local scale = 2

local boardcanvas
local bg
local boardBg
local border

function Game.enter()
  local tileImg   = love.graphics.newImage("img/imgs.png")
  local cursorImg = love.graphics.newImage("img/cursor.png")
  local borderImg = love.graphics.newImage("img/border.png")
  Board.init(5, 5, 32, tileImg, cursorImg)

  local bbgImg = love.graphics.newImage("img/boardbg.png")
  boardBg      = TiledImg.new(bbgImg, 5*32, 5*32)

  local bgImg = love.graphics.newImage("img/levelbg.png")
  bg          = TiledImg.new(bgImg, love.graphics.getDimensions())

  boardcanvas = love.graphics.newCanvas(5*32, 5*32)

  border = Slice9:new(borderImg, 5, 5, 5, 5, 5)

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
  love.graphics.draw(bg, 0, 0, 0, scale, scale)
  love.graphics.draw(boardBg, (w-bw)/2, (h-bh)/2, 0, scale, scale)
  love.graphics.draw(boardcanvas, (w-bw)/2, (h-bh)/2, 0, scale, scale)
  border:draw((w-bw)/2, (h-bh)/2, 320, 320, 2)

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
