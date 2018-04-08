local Block = {}

function Block:new(img, quad, x, y)
  local b = {}
  setmetatable(b, self)
  self.__index = self

  b.img  = img
  b.quad = quad

  b.x    = x
  b.y    = y
  b.xoff = 0
  b.yoff = 0

  return b
end

function Block:setPos(x, y)
  self.x = x
  self.y = y
end

function Block:setOffset(xoff, yoff)
  self.xoff = xoff
  self.yoff = yoff
end

function Block:draw()
  local _, _, w, h = self.quad:getViewport()
  local tilex = self.x + self.xoff
  local tiley = self.y + self.yoff
  love.graphics.draw(self.img, self.quad, tilex*w, tiley*h)
end

return Block
