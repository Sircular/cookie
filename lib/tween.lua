local Tweens = {}

local tweenFuncs = {
  linear = function(x)
    return x
  end,
  quad = function(x)
    if x < 0.5 then
      return 2*x*x
    else
      return -1 + (4-2*x) * x
    end
  end,
  quadOut = function(x)
    return -((x-1)*(x-1)) + 1
  end
}

function Tweens:new()
  local tw = {}
  setmetatable(tw, self)
  self.__index = self

  tw.tweens = {}

  return tw
end

function Tweens:addTween(start, stop, length, updateCallback, endCallback, method)
  local newTween = {
    start          = start,
    stop           = stop,
    length         = length,
    elapsed        = 0,
    updateCallback = updateCallback,
    endCallback    = endCallback,
    method         = method,
  }

  -- make sure that it is at this value on the next draw
  updateCallback(start)

  table.insert(self.tweens, newTween)
end

function Tweens:tweenCount()
  return #self.tweens
end

function Tweens:update(dt)
  -- update all the tweens
  --
  -- we need to do it backwards so that if and when elements get removed, the
  -- other indices don't shift in wacky ways
  for i = #self.tweens,1,-1 do
    local tw       = self.tweens[i]
    tw.elapsed     = tw.elapsed + dt
    local progress = math.min(1, tw.elapsed/tw.length)
    local func     = tweenFuncs[tw.method] or tweenFuncs.linear
    local val      = tw.start+((tw.stop-tw.start)*func(progress))
    if tw.updateCallback then
      tw.updateCallback(val)
    end

    -- remove it if it is complete
    if tw.elapsed >= tw.length then
      if tw.updateCallback then
        tw.updateCallback(tw.stop)
      end
      if tw.endCallback then
        tw.endCallback()
      end
      table.remove(self.tweens, i)
    end
  end
end

function Tweens:cancelAll()
  self.tweens = {}
end

return Tweens
