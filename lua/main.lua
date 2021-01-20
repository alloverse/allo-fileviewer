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

local fileviewer = FileViewer(ui.Bounds(-1, 2, -1,   1, 0.5, 0.1))

app.mainView = fileviewer

client.client:set_asset_send_callback(function(name, offset, length)
  if name ~= "page" then return false end
  local data = string.sub(fileviewer.image_data, offset, offset+length)
  app.client.client.asset_send(name, fileviewer.image_data, offset, string.len(data))
end)

--Checks fileviewer refresh every second
app:scheduleAction(1, true, function()
  fileviewer:update()
end)

app:connect()
app:run()