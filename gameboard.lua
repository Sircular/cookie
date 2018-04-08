local Utils  = require('utils')
local Tweens = require('lib/tween')
local Block  = require('block')

local Board = {}

function Board.init(width, height, tilesize, tileImg, curImg)
  Board.width    = width
  Board.height   = height
  Board.tilesize = tilesize
  Board.tileImg  = tileImg
  Board.curImg   = curImg

  Board.curX = math.ceil(width/2)
  Board.curY = math.ceil(height/2)

  Board.shiftTime = 0.2

  Board.tweens = Tweens:new()

  Board.quads = Utils.createSlices(tilesize, tilesize, tileImg:getDimensions())
  Board._generateAllPieces()
  Board._generateBoard()
  Board._updateDrawPieces()

  Board.rotate(0, 1)

end

function Board.getScreenWidth()
  return Board.width*Board.tilesize
end

function Board.getScreenHeight()
  return Board.height*Board.tilesize
end

function Board._generateAllPieces()
  Board.allPieces = {}

  local unique = math.min(Board.width, Board.height)
  -- make sure that there are extras
  local reps = 1 + math.floor((Board.width * Board.height)/unique)
  for i = 1, unique do
    for _ = 1, reps do
      table.insert(Board.allPieces, i)
    end
  end
end

function Board._generateBoard()
  if Board.pieces == nil then
    Board.pieces = {}
    for x = 1, Board.width do
      local col = {}
      for y = 1, Board.height do
        col[y] = 0
      end
      Board.pieces[x] = col
    end
  end

  local rem = Board._getUnusedPieces()
  Utils.shuffle(rem)

  for x = 1, Board.width do
    for y = 1, Board.height do
      if Board.pieces[x][y] <= 0 then
        Board.pieces[x][y] = table.remove(rem)
      end
    end
  end
end

function Board._getUsedPieces()
  local used = {}
  for x = 1, Board.width do
    for y = 1, Board.height do
      if Board.pieces[x][y] >= 1 then
        table.insert(used, Board.pieces[x][y])
      end
    end
  end
  return used
end

function Board._getUnusedPieces()
  return Utils.subtractTables(Board.allPieces, Board._getUsedPieces())
end

-- TODO: DEJANKIFY
function Board._updateDrawPieces()
  Board.drawPieces = {}
  -- initialize with nil for simplicity of later code
  for x = 0, Board.width + 1 do
    local row = {}
    for y = 0, Board.height + 1 do
      row[y] = nil
    end
    Board.drawPieces[x] = row
  end

  for x = 1, Board.width do
    for y = 1, Board.height do
      local q = Board.quads[Board.pieces[x][y]]
      if q then
        Board.drawPieces[x][y] = Block:new(Board.tileImg, q, x-1, y-1)
      end
    end
  end

  for x = 1, Board.width do
    local q = Board.quads[Board.pieces[x][Board.height]]
    if q then
      Board.drawPieces[x][Board.height+1] = Block:new(Board.tileImg, q, x-1, -1)
    end
    q = Board.quads[Board.pieces[x][1]]
    if q then
      Board.drawPieces[x][0] = Block:new(Board.tileImg, q, x-1, (Board.width+1) - 1)
    end
  end

  for y = 1, Board.height do
    local q = Board.quads[Board.pieces[Board.width][y]]
    if q then
      Board.drawPieces[Board.width+1][y] = Block:new(Board.tileImg, q, -1, y-1)
    end
    q = Board.quads[Board.pieces[1][y]]
    if q then
      Board.drawPieces[0][y] = Block:new(Board.tileImg, q, (Board.height+1) - 1, y-1)
    end
  end

end

function Board.rotate(x, y)
  x = x or 0
  y = y or 0

  if x ~= 0 then
    local dir
    if x < 0 then
      local tmp = Board.pieces[1][Board.curY]
      for xi = 1,Board.width - 1 do
        Board.pieces[xi][Board.curY] = Board.pieces[xi+1][Board.curY]
      end
      Board.pieces[Board.width][Board.curY] = tmp

      dir = -1
    else
      local tmp = Board.pieces[Board.width][Board.curY]
      for xi = Board.width,2,-1 do
        Board.pieces[xi][Board.curY] = Board.pieces[xi-1][Board.curY]
      end
      Board.pieces[1][Board.curY] = tmp

      dir = 1
    end

    for xi = 0, Board.width + 1 do
      local callback = nil
      if xi == 0 then
        callback = Board._updateDrawPieces
      end
      Board.tweens:addTween(0, dir, Board.shiftTime,
      function(v)
        Board.drawPieces[xi][Board.curY].xoff = v
      end,
      callback,
      "quad")
    end

  elseif y ~= 0 then
    local dir
    if y < 0 then
      local tmp = Board.pieces[Board.curX][1]
      for yi = 1, Board.height-1 do
        Board.pieces[Board.curX][yi] = Board.pieces[Board.curX][yi+1]
      end
      Board.pieces[Board.curX][Board.height] = tmp
      dir = -1
    else
      local tmp = Board.pieces[Board.curX][Board.height]
      for yi = Board.height,2,-1 do
        Board.pieces[Board.curX][yi] = Board.pieces[Board.curX][yi-1]
      end
      Board.pieces[Board.curX][1] = tmp

      dir = 1
    end

    for yi = 0, Board.height + 1 do
      local callback = nil
      if yi == 0 then
        callback = Board._updateDrawPieces
      end
      Board.tweens:addTween(0, dir, Board.shiftTime,
      function(v)
        Board.drawPieces[Board.curX][yi].yoff = v
      end,
      callback,
      "quad")
    end


  end
end

function Board.moveCursor(x, y)
  Board.curX = math.max(1, math.min(Board.curX + x, Board.width))
  Board.curY = math.max(1, math.min(Board.curY + y, Board.height))
end

function Board.update(dt)
  Board.tweens:update(dt)
end

function Board.draw()
  for x = 0, Board.width+1 do
    for y = 0, Board.height+1 do
      if Board.drawPieces[x][y] then
        Board.drawPieces[x][y]:draw()
      end
    end
  end

  local centerX = Board.tilesize * (Board.curX-0.5)
  local centerY = Board.tilesize * (Board.curY-0.5)
  local ci      = Board.curImg -- I got lazy

  love.graphics.draw(ci, centerX-(ci:getWidth()/2), centerY-(ci:getHeight()/2))
end

return Board
