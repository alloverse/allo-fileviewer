local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local pretty = require('pl.pretty')
local ffi = require('ffi')

local PIXELS_PER_METER = 256

require 'poppler'

class.FileSurface(ui.View)

function FileSurface:_init(bounds, assetManager)
  -- ? Sets the bounds of "ui.View" to be that which was passed to this init function
  self:super(bounds)

  -- Define the default file to be used
  self.defaultFileName = "alloverse_pitch_deck.pdf"
  
  -- Uses poppler to load the pdf file and read info about it
  file = self.defaultFileName
  local doc = Document:open(file)
  self.doc = doc

  local pageSizePx = doc:getPage(1):size()
  -- Sets the size of the FileSurface
  bounds.size.width = pageSizePx.width/PIXELS_PER_METER
  bounds.size.height = pageSizePx.height/PIXELS_PER_METER

  self.assets = {}
  for i = 1, doc:pageCount() do
    local asset = self:_render(i)
    table.insert(self.assets, asset)
    assetManager:add(asset)
  end
  
  --self.documentTitle = doc:title() 
  self.pageCount = doc:pageCount() or 1
  self.currentPage = 1
end

-- Render a page to an asset
function FileSurface:_render(pagenr)
  local page = self.doc:getPage(pagenr)
  local pageSizePx = page:size()
  
  -- Creates a cairo image surface matching the pixel size of the actual file
  local sr = cairo.image_surface(cairo.cairo_format("rgb24"), pageSizePx.width, pageSizePx.height)
  local cr = sr:context()
  cr:rgb(255, 255, 255)
  cr:paint()
  page:renderToCairoSurface(cr)

  local data = ""
  local ret = sr:save_png(function(_, bytes, len)
      data = data..ffi.string(bytes, len)
      return 0
  end, nil)
  return Asset(data)
end

function FileSurface:_material()
  return {
    asset_texture = self.assets[self.currentPage]:id()
  }
end

function FileSurface:specification()
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
      },
      collider= {
          type= "box",
          width= s.width, height= s.height, depth= s.depth
      },
      material = self:_material(),
      grabbable = {
        grabbable = true,
        actuate_on= "$parent"
      }
  })

  return mySpec
end

function FileSurface:update()
  self:updateComponents({material = self:_material()})
end


function FileSurface:resize(newWidth, newHeight)
  local oldWidth = self.bounds.size.width
  local oldHeight = self.bounds.size.height

  -- On proceed with resizing if a meaningful resize (more than 1cm) has been made
  if math.abs(oldWidth - newWidth) < 0.01 and math.abs(oldHeight - newHeight) < 0.01 then return end

  self.bounds.size.width = newWidth
  self.bounds.size.height = newHeight

  print("resized")
  self:updateComponents(self:specification())
end

function FileSurface:goToNextPage()
  self.currentPage = self.currentPage + 1
  if self.currentPage < 1 then self.currentPage = #self.assets end
  if self.currentPage > #self.assets then self.currentPage = 1 end
  self:update()
end

function FileSurface:goToPreviousPage()
  self.currentPage = self.currentPage - 1
  if self.currentPage < 1 then self.currentPage = #self.assets end
  if self.currentPage > #self.assets then self.currentPage = 1 end
  self:update()
end

return FileSurface