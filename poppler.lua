
--- CDEF ---
ffi = require 'ffi'
ffi.cdef[[
typedef struct {
  int       domain;
  int         code;
  char       *message;
} GError;
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
]]

--- globals --- 
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

function Document:title()
  local title = poppler.poppler_document_get_title(self.doc)
  return ffi.string(title)
end

function Document:pageCount()
  local pagecount = poppler.poppler_document_get_n_pages(self.doc)
  return pagecount
end

function Document:getPage(index)
  page = poppler.poppler_document_get_page(self.doc, index - 1)
  return Page:new(page)
end

--- PAGE ---
Page = {}

function Page:new(page)
  local t = {
    page = page
  }
  setmetatable(t, self)
  self.__index = self
  return t
end

function Page:size() 
  local width = ffi.new("double[1]")
  local height = ffi.new("double[1]")
  poppler.poppler_page_get_size(self.page, width, height)
  return { width = width[0], height = height[0]}
end

file = "file:///System/Applications/Utilities/System Information.app/Contents/Resources/ProductGuides/ENERGY STAR.pdf"

doc = Document:open(file)
print(doc:title())
print("Title: " .. doc:title())
print(doc:pageCount() .. " pages")
page = doc:getPage(1)
size = page:size()
print("size: " .. size.width .. "x" .. size.height)