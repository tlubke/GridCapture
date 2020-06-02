GridCapture = {}

GridCapture.grid = nil
GridCapture.frames = nil
GridCapture.output_path = nil

local err_no_grid = "GridCapture has no set grid."

function GridCapture:set_grid(g)
  if self.grid ~= nil then return end
  
  local function clone_function(fn)
    local dumped = string.dump(fn)
    local cloned = load(dumped)
    local i = 1
    while true do
      local name = debug.getupvalue(fn, i)
      if not name then
        break
      end
      debug.upvaluejoin(cloned, i, fn, i)
      i = i + 1
    end
    return cloned
  end
  
  -- create state of grid leds
  g.led_state = {}
  for i=1, g.cols do
    g.led_state[i] = {}
    for j=1, g.rows do
      g.led_state[i][j] = 0
    end
  end
  -- extend g:led()
  if g.led2 == nil then
    g.led2 = clone_function(g.led)
    g.led = function(g, x, y, z) g:led2(x, y, z) g.led_state[x][y] = z end
  end
  self.grid = g
end

function GridCapture:render_led_state(led_state, export_path)
  local g = self.grid
  if g == nil then
    print(err_no_grid)
    return
  end
  local key_size = 9
  local key_spacing = 6
  local margin = 11
  local key_color = "#fbfbfb"
  local led_color = "#fff79a"
  local grid_color = "#e6e6e6"
  local grid_width =  (g.cols*(key_size+key_spacing))-key_spacing+(2*margin)
  local grid_height = (g.rows*(key_size+key_spacing))-key_spacing+(2*margin)
  
  local start = util.time()  
  local script = 
      'convert -size '
    ..grid_width
    ..'x'
    ..grid_height
    ..' xc:none'
    ..' -fill none'
    ..' -stroke black \\\n'
    
    
  -- draw grid
  script = 
      script
    ..'-draw "fill '
    ..grid_color
    ..'\troundrectangle '
    ..'0,0 ' -- corner 1 coordinate
    ..grid_width-1 -- corner 2 x
    ..',' 
    ..grid_height-1 -- corner 2 y
    ..' '
    ..key_size -- round corner 1 by x pixels
    ..','
    ..key_size -- round corner 2 by x pixels
    ..' " \\\n'
    
    
  -- draw keys' background
  for y = 1, g.rows do
    for x = 1, g.cols do
      local rect_size = 
          ((x-1)*(key_size+key_spacing))+margin
        ..','
        ..((y-1)*(key_size+key_spacing))+margin
        ..' '
        ..((x-1)*(key_size+key_spacing))+key_size-1+margin
        ..','
        ..((y-1)*(key_size+key_spacing))+key_size-1+margin
      script = 
          script
        ..'-draw "fill '
        ..key_color
        ..'\trectangle '
        ..rect_size
        ..' " \\\n'
    end
  end  
    
  -- draw leds over keys' background
  for y = 1, g.rows do
    for x = 1, g.cols do
      local fill_opacity = 
          'fill-opacity '
        ..led_state[x][y] * 0.07
      local rect_size = 
          ((x-1)*(key_size+key_spacing))+margin
        ..','
        ..((y-1)*(key_size+key_spacing))+margin
        ..' '
        ..((x-1)*(key_size+key_spacing))+key_size-1+margin
        ..','
        ..((y-1)*(key_size+key_spacing))+key_size-1+margin
      script = 
          script
        ..'-draw "fill '
        ..led_color
        ..' '
        ..fill_opacity
        ..'\trectangle '
        ..rect_size
        ..' " \\\n'
    end
  end
  script = script..export_path
  --print(script)
  os.execute(script)
  --print(util.time()-start)
end

function GridCapture:screenshot(output_path)
  local g = self.grid
  self:render_led_state(g.led_state, output_path)
end

function GridCapture:record(fps, duration, output_path)
  local timer = 0
  local delay_s = 1/fps
  local tempDir = "frames"
  local frame_count = 1
  local frames = {}
  local g = self.grid
  
  if g == nil then
    print(err_no_grid)
    return
  end

  local function clone (t)
    local new_t = {}
    local i, v = next(t, nil)  
    while i do
      if type(v) == "table" then
        new_t[i] = clone(v)
      else
        new_t[i] = v
      end
      i, v = next(t, i)
    end
    return new_t
  end

  os.execute("mkdir /tmp/frames")

  clock.run(
    function()
      local start = util.time()
      -- capture each frame
      while timer < duration do
        frames[frame_count] = clone(g.led_state)
        frame_count = frame_count + 1
        timer = timer + delay_s
        clock.sleep(delay_s)
      end
      self.frames = frames
      self.output_path = output_path
      self:render()
    end
  )
end

function GridCapture:render_frames()
  for i=1, #self.frames do
    self:render_led_state(self.frames[i], "/tmp/frames/"..string.format("%04d",i)..".gif")
  end
  os.execute("convert -delay 10 -dispose previous -loop 0 /tmp/frames/*.gif "..self.output_path)
  os.execute("rm -r /tmp/frames")
end

function GridCapture:render()
  norns.script.load('/home/we/dust/code/GridCapture/Renderer.lua')
end

return GridCapture