local g = grid.connect()
local gcap = require 'GridCapture/GridCapture'

function init()
  gcap:set_grid(g)
end

function g.key(x,y,z)
  g:led(x,y,15)
  g:refresh()
end

function key(n,z)
  if n == 2 then
    gcap:record(24, 5, 'home/we/image.gif')
  elseif n == 3 then
    gcap:screenshot('home/we/screenshot.png')
  end
end