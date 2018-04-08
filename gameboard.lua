local Utils  = require('utils')
local Tweens = require('lib/tween')
local Block  = require('block')

local Board = {}

function Board.init(width, height, tilesize, img)
  Board.width    = width;
  Board.height   = height;
  Board.tilesize = tilesize;
  Board.img      = img

  Board.curX = math.ceil(width/2)
  Board.curY = math.ceil(height/2)

  Board.tweens = Tweens:new()

  Board.quads = Utils.createSlices(tilesize, tilesize, img:getDimensions())
  Board._generateAllPieces()
  Board._generateBoard()
  Board._updateDrawPieces()

  Board.rotate(2, 0, 1)

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
  print("updating")
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
        Board.drawPieces[x][y] = Block:new(Board.img, q, x-1, y-1)
      end
    end
  end

  for x = 1, Board.width do
    local q = Board.quads[Board.pieces[x][Board.height]]
    if q then
      Board.drawPieces[x][Board.height+1] = Block:new(Board.img, q, x-1, -1)
    end
    q = Board.quads[Board.pieces[x][1]]
    if q then
      Board.drawPieces[x][0] = Block:new(Board.img, q, x-1, (Board.width+1) - 1)
    end
  end

  for y = 1, Board.height do
    local q = Board.quads[Board.pieces[Board.width][y]]
    if q then
      Board.drawPieces[Board.width+1][y] = Block:new(Board.img, q, -1, y-1)
    end
    q = Board.quads[Board.pieces[1][y]]
    if q then
      Board.drawPieces[0][y] = Block:new(Board.img, q, (Board.height+1) - 1, y-1)
    end
  end

end

function Board.rotate(row, col, dir)
  row = row or 0
  col = col or 0

  if row ~= 0 then
    if dir < 0 then
      local tmp = Board.pieces[1][row]
      for x = 1,Board.width - 1 do
        Board.pieces[x][row] = Board.pieces[x+1][row]
      end
      Board.pieces[Board.width][row] = tmp

      dir = -1
    else
      local tmp = Board.pieces[Board.width][row]
      for x = Board.width,2,-1 do
        Board.pieces[x][row] = Board.pieces[x-1][row]
      end
      Board.pieces[1][row] = tmp

      dir = 1
    end

    for x = 0, Board.width + 1 do
      local callback = nil
      if x == 0 then
        callback = Board._updateDrawPieces
      end
      Board.tweens:addTween(0, dir, 0.5,
      function(v)
        Board.drawPieces[x][row].xoff = v
      end,
      callback,
      "quad")
    end

  end
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
end

return Board
