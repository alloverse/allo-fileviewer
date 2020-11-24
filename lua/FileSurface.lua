local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local pretty = require('pl.pretty')

local BOARD_RESOLUTION = 256

require 'poppler'

class.FileSurface(ui.View)

function FileSurface:_init(bounds)

  file = "test.pdf"
  local doc = Document:open(file)
  local page = doc:getPage(1)
  local pageSize = page:size()
  
  print("Page size:", pageSize.width, " x ", pageSize.height)

  bounds.size.width = pageSize.width / BOARD_RESOLUTION
  bounds.size.height = pageSize.height / BOARD_RESOLUTION
  

  self:super(bounds)

  self.isDirty = false;

  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), pageSize.width, pageSize.height)

  self.cr = self.sr:context()

  self.cr:save();
  page:renderToCairoSurface(self.cr)
  self.cr:restore();
end

function FileSurface:specification()
  self.sr:save_png("fileSurface.png")

  local fh = io.open("fileSurface.png", "rb")
  local image_to_convert = fh:read("*a")
  fh:close()
  local encoded_image = ui.util.base64_encode(image_to_convert)


  
  local s = self.bounds.size
  local w2 = s.width / 2.0
  local h2 = s.height / 2.0
  local d2 = s.depth / 2.0
  local mySpec = tablex.union(ui.View.specification(self), {
      geometry = {
          type = "inline",
          --          #tl?                #tr?              #bl?               #br?
          vertices=   {{-w2, h2, 0.0},    {w2, h2, 0.0},    {-w2, -h2, 0.0},   {w2, -h2, 0.0}},
          uvs=        {{0.0, 1.0},        {1.0, 1.0},       {0.0, 0.0},        {1.0, 0.0}},
          triangles=  {{0, 1, 3},         {3, 2, 0},        {0, 2, 3},         {3, 1, 0}},
          texture= encoded_image
      },
      collider= {
          type= "box",
          width= s.width, height= s.height, depth= s.depth
      }
  })
  return mySpec
end

function FileSurface:broadcastTextureChanged()

  print("broadcastTextureChanged!")

  if self.app == nil then return end

  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
  self.isDirty = false
end

function FileSurface:sendIfDirty()
  -- if self.isDirty then
  self:broadcastTextureChanged()
  -- end
end

function FileSurface:resize(newWidth, newHeight)

  local oldWidth = self.bounds.size.width
  local oldHeight = self.bounds.size.height

  if (oldWidth == newWidth and oldHeight == newHeight) then return end

  local newCalculatedWidth = newWidth * BOARD_RESOLUTION
  local newCalculatedHeight = newHeight * BOARD_RESOLUTION
  local oldCalculatedWidth = oldWidth * BOARD_RESOLUTION
  local oldCalculatedHeight = oldHeight * BOARD_RESOLUTION

  local newSourceX = math.floor(((newCalculatedWidth - oldCalculatedWidth)/2)+0.5)
  local newSourceY = math.floor(((newCalculatedHeight - oldCalculatedHeight)/2)+0.5)
  
  local newsr = cairo.image_surface(cairo.cairo_format("rgb24"), newCalculatedWidth, newCalculatedHeight)  
  local newcr = newsr:context()

  newcr:source(self.sr, newSourceX, newSourceY)

  self.sr = newsr
  self.cr = newcr
  self.cr:paint()

  self.bounds.size.width = newWidth
  self.bounds.size.height = newHeight 

  self:updateComponents(
    self:specification()
  )
end


return FileSurface