return {
  new = function(...)
    local args = {...}
    local i, q, w, h, imgW, imgH, _

    if #args == 3 then
      i = args[1]
      w = args[2]
      h = args[3]
      imgW, imgH = i:getDimensions()
    elseif #args == 4 then
      i = args[1]
      q = args[2]
      w = args[3]
      h = args[4]
      _, _, imgW, imgH = q:getViewport()
    else
      return nil
    end

    local canvas = love.graphics.newCanvas(w, h)
    local blend, alphaMode = love.graphics.getBlendMode()
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setCanvas(canvas)

    for x = 1, math.ceil(w/imgW) do
      for y = 1, math.ceil(h/imgH) do
        if q then
          love.graphics.draw(i, q, (x-1)*imgW, (y-1)*imgH)
        else
          love.graphics.draw(i, (x-1)*imgW, (y-1)*imgH)
        end
      end
    end

    love.graphics.setCanvas()
    love.graphics.setBlendMode(blend, alphaMode)

    return canvas
  end
}
