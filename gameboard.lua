local Utils = require('utils')

local Board = {}

local colors = {
  {255, 0, 0},
  {0, 255, 0},
  {0, 0, 255},
  {255, 255, 0},
  {128, 128, 128}
}

function Board.init(width, height, tilesize, img)
  Board.width    = width;
  Board.height   = height;
  Board.tilesize = tilesize;
  Board.img      = img

  Board.quads = Utils.createSlices(tilesize, tilesize, img:getDimensions())
  Board._generatePieces()
end

function Board._generatePieces()
  local unique = math.min(Board.width, Board.height)
  local reps   = 1+(Board.width*Board.height)/unique

  local pieces = {}
  for i = 1, unique do
    for _ = 1, reps do
      table.insert(pieces, i)
    end
  end
  Utils.shuffle(pieces)

  local cur = 1
  Board.contents = {}
  for i = 1, Board.width do
    local row = {}
    for j = 1, Board.height do
      row[j] = pieces[cur]
      cur = cur + 1
    end
    Board.contents[i] = row
  end
end

function Board.draw()
  for i = 1, Board.width do
    for j = 1, Board.height do
      local size    = Board.tilesize
      local quad = Board.quads[Board.contents[i][j]]
      love.graphics.draw(Board.img, quad, (i-1)*Board.tilesize, (j-1)*Board.tilesize)
    end
  end
end

return Board
