--- Poppler pdf
-- Requires luajit and ffi
-- @module Poppler

--- CDEF ---
local ffi = require 'ffi'
ffi.cdef[[
typedef struct {
  int       domain;
  int         code;
  char       *message;
} GError;
typedef void cairo_t;
typedef char gchar;
typedef void PopplerDocument;
typedef void PopplerPage;


const char *poppler_get_version(void);

// document
PopplerDocument *poppler_document_new_from_file(const char *uri, const char *password, GError **error);
int poppler_document_get_n_pages(PopplerDocument *document);
PopplerPage *poppler_document_get_page(PopplerDocument *document, int index);
gchar *poppler_document_get_title(PopplerDocument *document);

// page
void poppler_page_get_size(PopplerPage *page, double *width, double *height);
void poppler_page_render(PopplerPage *page, cairo_t *cairo);
]]

--- objects --- 
local poppler = ffi.load("poppler-glib")

--- Error ---

local Error = {}
function Error:new()
  local t = { err = ffi.new("GError *[1]") }
  setmetatable(t, self)
  self.__index = self
  return t
end

function Error:throw() 
  if self.err[0] ~= nil then
    error(ffi.string(self.err[0].message))
  end
end

--- Document ---

Document = {}

--- Open a document
-- @tparam string uri A full format uri locating a file to open. 
-- @raise Throws a string message on error
function Document:open(uri)
  local err = Error:new()
  local doc = poppler.poppler_document_new_from_file(file, nil, err.err)
  err:throw()
  
  local t = {
    doc = doc
  }
  setmetatable(t, self)
  self.__index = self
  return t
end

--- Get the document title
-- @treturn string The title
function Document:title()
  local title = poppler.poppler_document_get_title(self.doc)
  return ffi.string(title)
end

--- Get the number of pages in the document
-- @treturns int The number of pages
function Document:pageCount()
  local pagecount = poppler.poppler_document_get_n_pages(self.doc)
  return pagecount
end

--- Get a page of the document.
-- @int index The page index. Starts at 1. Must not be larger than `Document:pageCount`.
-- @see Document:pageCount
function Document:getPage(index)
  page = poppler.poppler_document_get_page(self.doc, index - 1)
  return Page:new(page)
end

--- PAGE ---

--- Object wriapping a Poppler page
-- @classmod Page
Page = {}

--- Get a new Page object with from poppler page
-- @param page A PopplerPage
-- @see Document:getPage
function Page:new(page)
  local t = {
    page = page
  }
  setmetatable(t, self)
  self.__index = self
  return t
end

--- Get the size of the page
-- @treturn {width, height} Table with width and height
function Page:size() 
  local width = ffi.new("double[1]")
  local height = ffi.new("double[1]")
  poppler.poppler_page_get_size(self.page, width, height)
  return { width = width[0], height = height[0]}
end

--- Render the page to a Cairo surface
-- @param surcace A cairo surface
function Page:renderToCairoSurface(surface)
  poppler.poppler_page_render(self.page, surface)
end


local function example()
  file = "file:///System/Applications/Utilities/System Information.app/Contents/Resources/ProductGuides/ENERGY STAR.pdf"

  doc = Document:open(file)
  print(doc:title())
  print("Title: " .. doc:title())
  print(doc:pageCount() .. " pages")
  page = doc:getPage(1)
  size = page:size()
  print("size: " .. size.width .. "x" .. size.height)
end