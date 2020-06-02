local gcap = require 'GridCapture/GridCapture'

function init()
  print('rendering to '..gcap.output_path)
  gcap:render_frames()
  print('render complete!')
end