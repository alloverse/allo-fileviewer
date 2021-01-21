package.path = string.format(
    package.path..";"
    .."lib/cairo/?.lua"
)



local FileViewer = require("fileviewer")

local client = Client(
    arg[2], 
    "allo-fileviewer"
)
local app = App(client)

print("+====================+")
print("+ ADDING FILE VIEWER +")
print("+====================+")

local fileviewer = FileViewer(ui.Bounds(-1, 2, -1,   1, 0.5, 0.01))

app.mainView = fileviewer

local allonet = app.client.client

allonet:set_asset_request_callback(function(name, offset, length)
  if string.sub(name, 1, -2) ~= "page" or fileviewer.fileSurface.image_data == nil or string.len(fileviewer.fileSurface.image_data) == 0 then 
    allonet:asset_send(name, nil, offset, 0)
  else
    local data = string.sub(fileviewer.fileSurface.image_data, offset, offset+length-1)
    allonet:asset_send(name, data, offset, string.len(data))
  end
end)

--Checks fileviewer refresh every second
app:scheduleAction(1, true, function()
  fileviewer:update()
end)

app:connect()
app:run()