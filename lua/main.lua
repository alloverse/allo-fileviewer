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

--Checks fileviewer refresh every 3 seconds
app:scheduleAction(3, true, function()
  fileviewer:update()
end)

app:connect()
app:run()