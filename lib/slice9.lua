local Slice9 = {}

function Slice9:new(img, left, top, right, bottom, bleed)
  local sl = {}
  setmetatable(sl, self)
  self.__index = self

  -- specially hacky value that manipulates lots of things
  bleed = bleed or 0

  left   = (left or img:getWidth()/3) + bleed
  top = (top or left) + bleed
  right  = (right or left) + bleed
  bottom = (bottom or top) + bleed

  local w, h = img:getDimensions()

  sl.img    = img
  sl.width  = w
  sl.height = h
  sl.left   = left
  sl.right  = right
  sl.top    = top
  sl.bottom = bottom
  sl.bleed  = bleed

  sl.innerw = sl.width - (left + right)
  sl.innerh = sl.height - (top + bottom)

  -- quad layout --
  -- +---+---+---+
  -- | 1 | 2 | 3 |
  -- +---+---+---+
  -- | 4 | 5 | 6 |
  -- +---+---+---+
  -- | 7 | 8 | 9 |
  -- +---+---+---+

  local xpos = {0, left, w - right, w}
  local ypos = {0, top, h - bottom, h}

  sl.quads = {}

  for i = 1, 3 do
    for j = 1, 3 do
      local tw = xpos[j+1] - xpos[j]
      local th = ypos[i+1] - ypos[i]
      table.insert(sl.quads, love.graphics.newQuad(
        xpos[j], ypos[i], tw, th, img:getDimensions()
      ))
    end
  end

  return sl
end

function Slice9:getInnerDimensions()
  return self.width - (self.left + self.right), self.height - (self.top +
      self.bottom)
end

function Slice9:draw(x, y, w, h, scale)
  x = x + (scale*self.bleed)
  y = y + (scale*self.bleed)
  w     = (w or (self.width - (self.left + self.right))) - (scale*self.bleed * 2)
  h     = (h or (self.height - (self.top + self.bottom))) - (scale*self.bleed * 2)
  scale = scale or 1

  local oldScissor = {love.graphics.getScissor()}

  -- draw the corners
  love.graphics.draw(self.img, self.quads[1], x - (self.left*scale), y - (self.top*scale), 0, scale, scale)
  love.graphics.draw(self.img, self.quads[3], x+w, y - (self.top*scale), 0, scale, scale)
  love.graphics.draw(self.img, self.quads[7], x - (self.left*scale), y + h, 0, scale, scale)
  love.graphics.draw(self.img, self.quads[9], x+w, y + h, 0, scale, scale)

  -- draw the top and bottom
  -- clipping makes things easy
  love.graphics.setScissor(x, y - (self.top*scale), w, h + ((self.top + self.bottom)*scale))
  for i = 1, math.ceil(w/(self.innerw*scale)) do
    love.graphics.draw(self.img, self.quads[2],
      x + ((i-1)*self.innerw*scale), y - (self.top*scale), 0, scale, scale
    )
    love.graphics.draw(self.img, self.quads[8],
      x + ((i-1)*self.innerw*scale), y + h, 0, scale, scale
    )
  end

  -- draw the left and right
  love.graphics.setScissor(x - (self.left*scale), y, w + ((self.left + self.right)*scale), h)
  for i = 1, math.ceil(h / (self.innerh*scale)) do
    love.graphics.draw(self.img, self.quads[4],
      x - (self.left*scale), y + ((i-1)*self.innerh*scale), 0, scale, scale
    )
    love.graphics.draw(self.img, self.quads[6],
      x + w, y + ((i-1)*self.innerh*scale), 0, scale, scale
    )
  end

  -- draw the center
  love.graphics.setScissor(x, y, w, h)
  for i = 1, math.ceil(w / (self.innerw*scale)) do
    for j = 1, math.ceil(h / (self.innerh*scale)) do
      love.graphics.draw(self.img, self.quads[5],
        x + ((i-1) * self.innerw*scale), y + ((j-1)*self.innerh*scale), 0, scale, scale
      )
    end
  end

  love.graphics.setScissor(table.unpack(oldScissor))
end

return Slice9
