local cairo = require("cairo")
local class = require('pl.class')
local tablex = require('pl.tablex')
local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local pretty = require('pl.pretty')

local PIXELS_PER_METER = 256

require 'poppler'

class.FileSurface(ui.View)

function readall(filename)
  local fh = assert(io.open(filename, "rb"))
  local contents = assert(fh:read(_VERSION <= "Lua 5.2" and "*a" or "a"))
  fh:close()
  return contents
end

function FileSurface:redraw()
  -- Saves the cairo surface context to disk as a png
  self.sr:save_png("fileSurface.png")

  -- Opens said png into memory
  self.image_data = readall("fileSurface.png")
  print(string.len(self.image_data))
end

function FileSurface:_init(bounds)
  -- ? Sets the bounds of "ui.View" to be that which was passed to this init function
  self:super(bounds)

  -- Define the default file to be used
  self.defaultFileName = "test_multipage.pdf"
  
  -- Uses poppler to load the pdf file and read info about it
  file = self.defaultFileName
  local doc = Document:open(file)
  

  print("Opening '" .. self.defaultFileName .. "' with " .. doc:pageCount() .. " pages" )
  
  --self.documentTitle = doc:title() 
  self.pageCount = doc:pageCount() or 1
  self.currentPage = 1

  local page = doc:getPage(1)
  local pageSizePx = page:size()
  --print("Page size (px):", pageSizePx.width, " x ", pageSizePx.height)

  -- Sets the size of the FileSurface
  bounds.size.width = pageSizePx.width/PIXELS_PER_METER
  bounds.size.height = pageSizePx.height/PIXELS_PER_METER

  -- print("bounds.size.width:", bounds.size.width)
  -- print("bounds.size.height:", bounds.size.height)

  -- Creates a cairo image surface matching the pixel size of the actual file
  self.sr = cairo.image_surface(cairo.cairo_format("rgb24"), pageSizePx.width, pageSizePx.height)
  self.cr = self.sr:context()

  -- Renders the file to the surface.
  self.cr:save();
  self.cr:rgb(255, 255, 255)
  self.cr:paint()
  page:renderToCairoSurface(self.cr)
  self.cr:restore();

  self.cr:source(self.sr)
  self.cr:paint()

  self:redraw()

  self:updateComponents(
    self:specification()
  )
end


function FileSurface:specification()
  self:redraw()
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
      material = {
        asset_texture = "page"..self.currentPage
      },
      grabbable = {
        grabbable = true,
        actuate_on= "$parent"
      }
  })

  return mySpec

end


function FileSurface:resize(newWidth, newHeight)

  local oldWidth = self.bounds.size.width
  local oldHeight = self.bounds.size.height

  -- On proceed with resizing if a meaningful resize (more than 1cm) has been made
  if math.abs(oldWidth - newWidth) < 0.01 and math.abs(oldHeight - newHeight) < 0.01 then return end

  print("Resizing...")

  self.bounds.size.width = newWidth
  self.bounds.size.height = newHeight

  self:loadPdfToSurface(self.defaultFileName)
end

function FileSurface:goToNextPage()
  self.currentPage = (self.currentPage % self.pageCount) + 1
  self:loadPdfToSurface(self.defaultFileName)
end

function FileSurface:goToPreviousPage()
  
  local i = self.currentPage - 1
  -- LUL it's late and I couldn't get my modulo formula to work
  if i == 0 then
    i = self.pageCount
  end
  self.currentPage = i  

  self:loadPdfToSurface(self.defaultFileName)
end


function FileSurface:loadPdfToSurface(file)
  local doc = Document:open(file)
  local page = doc:getPage(self.currentPage)
  local pageSizePx = page:size()

  -- print("Page size:", pageSizePx.width, " x ", pageSizePx.height)
  -- print("Current page: ", self.currentPage)

  self.cr:save()
  self.cr:rgb(255, 255, 255)
  self.cr:paint()
  page:renderToCairoSurface(self.cr)
  self.cr:restore()

  self:redraw()

  self.cr:source(self.sr)
  self.cr:paint()

  self:redraw()
  self:updateComponents(
    self:specification()
  )
end

function FileSurface:broadcastTextureChanged()
  if self.app == nil then return end

  local geom = self:specification().geometry
  self:updateComponents({geometry = geom})
  self.isDirty = false
end

function FileSurface:sendIfDirty()
  if self.isDirty then
    self:broadcastTextureChanged()
  end
end


return FileSurface