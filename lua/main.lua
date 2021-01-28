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

local assetManager = app.assetManager
local fileviewer = FileViewer(ui.Bounds(-1, 2, -1,   1, 0.5, 0.01), assetManager)

app.mainView = fileviewer



--Checks fileviewer refresh every second
app:scheduleAction(0.1, true, function()
  if app.connected then 
    fileviewer:update()
  end
end)

app:connect()
app:run()