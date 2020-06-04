# GridCapture
screenshot and record grid led states in norns

## functions
- `GridCapture:set_grid(g)` where g is an instance from grid.connect()
- `GridCapture:set_colors(key, led, grid, outline)` strings of format `"#xxxxxx"` where `x` is a hexadecimal number
- `GridCapture:set_theme(t)` see [Themes](Themes.lua) for theme names or to add your own.
- `GridCapture:screenshot(export_path)` works with .jpg, .png, .gif, and more.
- `GridCapture:record(fps, duration, export_path)` must be a .gif

*NOTE: `screenshot()` and `record` require that `GridCapture` has used `set_grid()` with a valid grid instance. 

## themes
- "default"
- "bw"
