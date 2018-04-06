local Utils = {}

function Utils.createSlices(w, h, imgw, imgh, xspace, yspace, xoff, yoff)
  if w == nil or imgw == nil or h == nil or imgh == nil then
    return nil
  end

  xspace = xspace or 0
  yspace = yspace or 0
  xoff   = xoff or 0
  yoff   = yoff or 0

  local xcount = (imgw-xoff)/(w+(2*xspace))
  local ycount = (imgh-yoff)/(h+(2*yspace))

  local quads = {}

  for x = 1,xcount do
    local xpos = (x-1)*(w+(xspace*2)) + xoff
    for y = 1, ycount do
      local ypos = (y-1)*(w+(yspace*2)) + yoff
      table.insert(quads, love.graphics.newQuad(xpos, ypos, w, h, imgw, imgh))
    end
  end

  return quads
end

-- shuffles in-place
function Utils.shuffle(t)
  for i = 1, #t do
    local rnd = love.math.random(i)
    local tmp = t[i]
    t[i] = t[rnd]
    t[rnd] = tmp
  end
end

return Utils
