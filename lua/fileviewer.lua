local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local class = require('pl.class')
local FileSurface = require("FileSurface")

class.FileViewer(ui.View)

function FileViewer:_init(bounds)
  self:super(bounds)

  self.fileSurface = FileSurface(ui.Bounds{size=bounds.size})
  self:addSubview(self.fileSurface)

  self.half_width = self.fileSurface.bounds.size.width/2
  self.half_height = self.fileSurface.bounds.size.height/2
  self.BUTTON_SIZE = 0.2
  self.SPACING = 0.13;
  
  -- RESIZE HANDLE
  self.resizeHandle = ui.ResizeHandle(ui.Bounds(self.half_width+self.SPACING, self.half_height+self.SPACING, 0, self.BUTTON_SIZE, self.BUTTON_SIZE, self.BUTTON_SIZE), {1, 1, 0}, {0, 0, 0})
  self:addSubview(self.resizeHandle)

  -- QUIT BUTTON
  self.quitButton = ui.Button(ui.Bounds{size=ui.Size(0.12,0.12,0.05)}:move( 0.52,0.25,0.025))
  self.quitButton:setDefaultTexture("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAABHNCSVQICAgIfAhkiAAABUtJREFUeJztm+1TGlcUxp9dcEEQ1wFl7VjT5sXMRE3SWmOssUkax6oBtNM/r39DJ8bXWKNJG3XaRGPbqJlpY0zrS+sC4cUFFYHdfohaQMC9cLc6kOfj7p5nz/l593Dv3pX5dvapgiLVxMoy2JNO4qQ0sbIMAMUJ4KB4oAgBJBYPFBmA1OKBIgKQrnigSABkKh4oAgDZigcKHMBxxQMFDEBN8UCBAlBbPFCAAEiKBwB9LjfZDEm5hGmuRbdIHFNwI4BU7wFoaa4PhaAPBDNfoHYhrmi3YtcMQEkgAKF/EMLQCHThcPqLmON9TCtv8MF398Du7NJNcF+aAODcHlT3D0AvSdBLEuxDI2AjEWKf0r9WUTk+Ac7jhTAwqAkE6gCM6xuoHhxOSpbz+WEfeQAmFiPyqRobByPLhx7CwCB04W2q+VIFYF5+DWHkAZi9vSPnDJsi7GPjwH5B2WT4ZxP20TEw8XjScc7nR3X/fZQEs/QVQlEDYFl6icqHk0BK0okyrq6hcvJx+ua3f4xzu2EfHs04WvRbEoR7A+A8XgpZUwLAz83D+uOUqm5tfrUM68zM0RMM3j3rQ6Ngo9GsHrqdHQj3B2HY+DvXlA+VNwBdeBvlLxaIYiwvFsHPzScdK/H5IAyrb5ZsNApheBTGPCHkBCDx7xw3m+B2dEMuKSHyqHg2C8vSSwBASTAIYXCEuMtHbTbs2auIYlJF5RGICAI83Z1QWDI765NpWBaWYB8Yhm6brLvvVdoguu4Sg08VtSa4W1sLb2cHWZCiwDo1DX0oRBQWtVohupyQDQay+6VR/gASnoft8+fgu9met2U2RXkeossBudRIxS9vAErKdFZqbECwpTlf27SKlVsg9rkQN5uoeWoyFQ40fwbpciNVz1hZGcReF+JlZqq+mi2GfO03EK67QMUrbjLB3edErNxCxS9R2i2HGcDb8SV2z9TmZSOXGiH2OhDleUqJJUvbFyIsC3f3Vzn/VssGA0SXE1GrlXJi/0n7N0IsC5njcgqN2KuwZ7NRTihZ2gKQZVR+/xDG9Y2cwkvX1mGdmqacVLK0A6AoqJx4BNObP/OysSwuoWL2OZ2c0kgbAApge/QDzMuvqdjxs3OwLCxS8UoVfQCKAtuTKZT9/gdVW+vUDMyvyDY91Ig6AOvMTyjbX+XRlm3yMYyra1Q9qQKo+PkpLITvBkjEyDLsY+PgRDc1T2oAKuaeg5//lSyIYbB99mOykFgMwvAoOL+f7F4ZRAVA+S+/gX82Rxznb2uFp6cLW1evEMWxkQiqhkahl/Lfo6QCQDZwAKNilyNBgdbrh4X721oRvlhHFK8PhWBZzL/X5AQgtdRQ/SV4ujoBnU5VfLC5CcGmTxIMGXjv3MbOR2dU5yBdaYS/9brq6zMp7xFwAGP73FmIzh4ox0x7tz69ikDLtTSZsPB0dSJSXX3sPQMt1+Brv6Fqa+04Uf0V2K2pwWafE/HS0rTnpcuN8H/emjFe0evhdnQjasuw+GEY+G59gWBzE410AWgwD9irqoL4TR/i5uQXF6H6S/C1tx0b/24F6Di69tfp4O3sgNRQTzNdbabCUZ6H+LXrEEL4Yh3e3rqpulHGTSa4XY7DkaRwHERHD8IXzlPPVbPF0AEEqbEBb+/cJn5eozwPt/MuYuXl2Ox1YvfDGi3SBJPL/wv8n98IMbKser+hIL8RIt1sIdWpB6C13gM46QROWjl9KJlLszmtIh4BpJ+innYRASi04gECAIVYPKCiBxRq4QfKOgIKvXggC4BiKB7IAKBYigfSACim4oGEJlhshR+IBYq3eAD4FzLNyUTM0XqEAAAAAElFTkSuQmCC")
  self.quitButton.onActivated = function()
    self.app:quit()
  end
  self:addSubview(self.quitButton)
  
  self:layout()

end

function FileViewer:specification()
  return ui.View.specification(self)
end

function FileViewer:update()

  -- Looks at the resizeHandle's position (if it exists)
  if self.resizeHandle ~= nil then 
    local m = mat4.new(self.resizeHandle.entity.components.transform.matrix) 
    local resizeHandlePosition = m * vec3(0,0,0)

    local newWidth = resizeHandlePosition.x*2 - self.SPACING*2
    local newHeight = resizeHandlePosition.y*2 - self.SPACING*2

    if newWidth <= 1.13 then newWidth = 1.13 end
    if newHeight <= 0.5 then newHeight = 0.5 end

    self:resize(newWidth, newHeight)
  end

end

function FileViewer:resize(newWidth, newHeight)
  self.fileSurface:resize(newWidth, newHeight)
  self:layout()
end

function FileViewer:layout()
  -- Sets the correct position of all buttons, in relation to the size of the FileSurface
  self.half_width = self.fileSurface.bounds.size.width/2
  self.half_height = self.fileSurface.bounds.size.height/2
  
  self.quitButton:setBounds(ui.Bounds{pose=ui.Pose(self.half_width+self.SPACING - self.BUTTON_SIZE, self.half_height+self.SPACING, 0), size=self.quitButton.bounds.size})
end


return FileViewer