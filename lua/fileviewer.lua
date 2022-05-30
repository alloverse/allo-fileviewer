local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local class = require('pl.class')
local FileSurface = require("FileSurface")

class.FileViewer(ui.View)

FileViewer.assets = {
  quit = Base64Asset("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAABHNCSVQICAgIfAhkiAAABUtJREFUeJztm+1TGlcUxp9dcEEQ1wFl7VjT5sXMRE3SWmOssUkax6oBtNM/r39DJ8bXWKNJG3XaRGPbqJlpY0zrS+sC4cUFFYHdfohaQMC9cLc6kOfj7p5nz/l593Dv3pX5dvapgiLVxMoy2JNO4qQ0sbIMAMUJ4KB4oAgBJBYPFBmA1OKBIgKQrnigSABkKh4oAgDZigcKHMBxxQMFDEBN8UCBAlBbPFCAAEiKBwB9LjfZDEm5hGmuRbdIHFNwI4BU7wFoaa4PhaAPBDNfoHYhrmi3YtcMQEkgAKF/EMLQCHThcPqLmON9TCtv8MF398Du7NJNcF+aAODcHlT3D0AvSdBLEuxDI2AjEWKf0r9WUTk+Ac7jhTAwqAkE6gCM6xuoHhxOSpbz+WEfeQAmFiPyqRobByPLhx7CwCB04W2q+VIFYF5+DWHkAZi9vSPnDJsi7GPjwH5B2WT4ZxP20TEw8XjScc7nR3X/fZQEs/QVQlEDYFl6icqHk0BK0okyrq6hcvJx+ua3f4xzu2EfHs04WvRbEoR7A+A8XgpZUwLAz83D+uOUqm5tfrUM68zM0RMM3j3rQ6Ngo9GsHrqdHQj3B2HY+DvXlA+VNwBdeBvlLxaIYiwvFsHPzScdK/H5IAyrb5ZsNApheBTGPCHkBCDx7xw3m+B2dEMuKSHyqHg2C8vSSwBASTAIYXCEuMtHbTbs2auIYlJF5RGICAI83Z1QWDI765NpWBaWYB8Yhm6brLvvVdoguu4Sg08VtSa4W1sLb2cHWZCiwDo1DX0oRBQWtVohupyQDQay+6VR/gASnoft8+fgu9met2U2RXkeossBudRIxS9vAErKdFZqbECwpTlf27SKlVsg9rkQN5uoeWoyFQ40fwbpciNVz1hZGcReF+JlZqq+mi2GfO03EK67QMUrbjLB3edErNxCxS9R2i2HGcDb8SV2z9TmZSOXGiH2OhDleUqJJUvbFyIsC3f3Vzn/VssGA0SXE1GrlXJi/0n7N0IsC5njcgqN2KuwZ7NRTihZ2gKQZVR+/xDG9Y2cwkvX1mGdmqacVLK0A6AoqJx4BNObP/OysSwuoWL2OZ2c0kgbAApge/QDzMuvqdjxs3OwLCxS8UoVfQCKAtuTKZT9/gdVW+vUDMyvyDY91Ig6AOvMTyjbX+XRlm3yMYyra1Q9qQKo+PkpLITvBkjEyDLsY+PgRDc1T2oAKuaeg5//lSyIYbB99mOykFgMwvAoOL+f7F4ZRAVA+S+/gX82Rxznb2uFp6cLW1evEMWxkQiqhkahl/Lfo6QCQDZwAKNilyNBgdbrh4X721oRvlhHFK8PhWBZzL/X5AQgtdRQ/SV4ujoBnU5VfLC5CcGmTxIMGXjv3MbOR2dU5yBdaYS/9brq6zMp7xFwAGP73FmIzh4ox0x7tz69ikDLtTSZsPB0dSJSXX3sPQMt1+Brv6Fqa+04Uf0V2K2pwWafE/HS0rTnpcuN8H/emjFe0evhdnQjasuw+GEY+G59gWBzE410AWgwD9irqoL4TR/i5uQXF6H6S/C1tx0b/24F6Di69tfp4O3sgNRQTzNdbabCUZ6H+LXrEEL4Yh3e3rqpulHGTSa4XY7DkaRwHERHD8IXzlPPVbPF0AEEqbEBb+/cJn5eozwPt/MuYuXl2Ox1YvfDGi3SBJPL/wv8n98IMbKser+hIL8RIt1sIdWpB6C13gM46QROWjl9KJlLszmtIh4BpJ+innYRASi04gECAIVYPKCiBxRq4QfKOgIKvXggC4BiKB7IAKBYigfSACim4oGEJlhshR+IBYq3eAD4FzLNyUTM0XqEAAAAAElFTkSuQmCC"),
  previousPage = Base64Asset("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAKFSURBVHgB7ZsxbxNBEIXfRnRxonQonYNkWqiQK2ynR6FGCJogIQqSUICEEoKJaPG5TYUEfyAClxEJFVAES3REAncWVEg56mPG9kWbxeXe7uR2P2m15zk382bW0s54FAyyLGvSdpPWCq0qykF/stpKqcHUb5DjC7Q6WflhHxdyv1XuPG0faF1FGHA2tCgb/sxMDNsIx3mGfWWfoSj6Vdp/6m+Hw9/YaSc4Pv6Bk5O/OO9cb9Sx8WgVi4sXzVctFuA1PdzNLez8ndsPS+G4TmVuFm/edk0RunwEruiWzqvd0jnPpOTTTrtrmldYgDNn/+PhZ5SV73SkDaozCIh0SmYHJcA0ogAInCgAAicKgMCJAiBwogAInAuwyKcv7858rl+7AVvM0XV2c2sdTx6/hE2sClAUDSpobD5bH4lgG9EC5FFvNOsoCrECFBl1HXECuIi6jigBXEVdR4QArqOu410AH1HX8SaAz6jreBHAd9R1nAogJeo6zgSQFHUdZ5ehSmUWaZpCGs4E6PX28eD+U/Te70MSTq/Do67zi2TUeR4Of0ECXuoBkrLBW0FESjZ4rwj5zgYRJTGf2SCqJugjG8QVRV1ng9iqsKtsEF0Wd5EN56IqzNlwdPQNq/duwTb8N7lMN9is5UvE7F3E1hgCJwqAwIkCIHCiAAicKAACJwpgGqQ1LoqGBRjohlrtEsoKD08Z9FmAPd2ytS2vfWWD+fnKaHLMoM/X4SbGQ5OncCEi6ezi8MDP/JBSCrbgYNYuL1FTdm3a2NxSPjma0LaGsEhI6I1QR2e/0lo+HZ3lB9patLooN1z94mxfnviM/w7bZJT2OcYDla4yIkOxDDD+sd8jxw/0F/8AwW/MYvMHEacAAAAASUVORK5CYII="),
  nextPage = Base64Asset("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAJ6SURBVHgB7Zu/b9NAFMe/V7ElqTqBsqVIYYUJdYKmjIDKH4BgYaYtM6GEVGIjzoJQYUACsVf8ATRMgaWZW6nNVqlTpbaz+15+VNert559Z7/7SKdzzlne933PvrP9FAziOF6k7hm1ZWo1FIPBpLWUUsPEf1Dgc9Q6cfHhGOemcatp8NT9oXYPMmA3NMgNxzOTgXXICZ7hWDlmKMp+jfoD/ezh4RHarQh7e/s4OTlD3nnwcAFrb16hWr1lnmqwAN/p4OV0hIN/8fx1IQLXKVdK+PGza4rQ5SlwVx/pfNosXPDMKcXUbnXN4WUW4NLc/9v7h6KyS1PaoDYDQZwmOFuUAEkEASCcIACEEwSAcIIAEE4QAMK5AYs0363i29dfoy21Lfr/f1/6vXD/KWxi1QGPnzzC5y8fR31esD4FqtWbIydw42PfSe0akBc3pHoRzIMbMrkL+OyGzG6Dvroh83WAb25wshDyyQ1OV4I+uMH5Uti1G7zZC7hyg1eboXK5lPjsPk2sboauQ2+7j412lPlrOecCcMAbHyL0en24wKkArrKu40QA11nXyVwAH7Kuk5kAPmVdJxMBfMu6TqoC+Jp1ndQE8DnrOtYFyEPWdawKkJes6/BncrE+YPu5u2+Y7xnCqzEIJwgA4QQBIJwgAIQTBIBwggDmQKVSgiRYgKE+UK/fRlHh4imDAQuwpY8011cL6YLZ2fKocsxgwNvhRYyLJi/gz9yizibt793UDymlYAtOZv3OPN42V5LK5uanlaMRdSuQRURCr0ktnd2htnRROssH1DWodVFs+OkXu31pEjOuTLZJKe17jAsqs3JEjHQZYnyx36LAt/UT5+KV2TiURS+aAAAAAElFTkSuQmCC"),
}

function FileViewer:_init(bounds, assetManager)
  self:super(bounds)

  self.assetManager = assetManager
  self.fileSurface = FileSurface(ui.Bounds{size=bounds.size}, assetManager)
  self:addSubview(self.fileSurface)

  self.half_width = self.fileSurface.bounds.size.width/2
  self.half_height = self.fileSurface.bounds.size.height/2
  self.BUTTON_SIZE = 0.2
  self.BUTTON_DEPTH = 0.05
  self.SPACING = 0.13;

  self.TITLE_LABEL_HEIGHT = 0.05
  
  -- FILE TITLE LABEL
  self.fileTitleLabel = ui.Label{
    bounds= ui.Bounds(0, self.half_height + self.TITLE_LABEL_HEIGHT, 0,   self.fileSurface.bounds.size.width, self.TITLE_LABEL_HEIGHT, 0.025),
    text= self.fileSurface.currentFileName
  }
  self.fileTitleLabel.color = {0,0,0,1}
  self:addSubview(self.fileTitleLabel)

  -- RESIZE HANDLE
  self.resizeHandle = ui.ResizeHandle(ui.Bounds(self.half_width-self.BUTTON_SIZE/2, self.half_height-self.BUTTON_SIZE/2, 0.01, self.BUTTON_SIZE, self.BUTTON_SIZE, 0.001), {1, 1, 0}, {0, 0, 0})
  self:addSubview(self.resizeHandle)

  -- QUIT BUTTON
  self.quitButton = ui.Button(ui.Bounds{size=ui.Size(0.12,0.12, self.BUTTON_DEPTH )}:move( 0.52,0.25,0.025))
  self.quitButton:setDefaultTexture(FileViewer.assets.quit)
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
  if self.resizeHandle and self.resizeHandle.entity and self.resizeHandle.active then 
    local m = mat4.new(self.resizeHandle.entity.components.transform.matrix)
    local resizeHandlePosition = m * vec3(0,0,0)

    local newWidth = resizeHandlePosition.x*2 + self.BUTTON_SIZE
    local newHeight = resizeHandlePosition.y*2 + self.BUTTON_SIZE

    if newWidth <= 1 then newWidth = 1 end
    if newHeight <= 0.5 then newHeight = 0.5 end

    self:resize(newWidth, newHeight)
  end

end

function FileViewer:resize(newWidth, newHeight)
  if self.fileSurface:resize(newWidth, newHeight) then
    self:layout()
  end
end

function FileViewer:goToNextPage()
  self.fileSurface:goToNextPage()
end

function FileViewer:goToPreviousPage()
  self.fileSurface:goToPreviousPage()
end

function FileViewer:layout()
  -- Sets the correct position of buttons & labels in relation to the size of the FileSurface
  
  self.half_width = self.fileSurface.bounds.size.width/2
  self.half_height = self.fileSurface.bounds.size.height/2
  
  self.quitButton:setBounds(ui.Bounds{pose=ui.Pose(self.half_width+self.SPACING - self.BUTTON_SIZE, self.half_height+self.SPACING, 0.05), size=self.quitButton.bounds.size})

  if not self.resizeHandle.active then
    self.resizeHandle.bounds:moveToOrigin():move(self.half_width-self.BUTTON_SIZE/2, self.half_height-self.BUTTON_SIZE/2, 0.01, self.BUTTON_SIZE, self.BUTTON_SIZE, 0.001)
    self.resizeHandle:markAsDirty()
  end

  if self.fileSurface and self.fileSurface.currentFileName and  self.fileTitleLabel then
    self.fileTitleLabel.text = self.fileSurface.currentFileName
    self.fileTitleLabel.bounds:moveToOrigin():move(0, self.half_height + self.TITLE_LABEL_HEIGHT, 0,   self.fileSurface.bounds.size.width, self.TITLE_LABEL_HEIGHT, 0.025)
    self.fileTitleLabel:markAsDirty()
  end

end


return FileViewer