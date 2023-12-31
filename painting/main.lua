local lib = include("JosephMcKean.lib")
local ui = lib.ui

local configDefaults = { mod = { id = "painting", name = "Painting" }, logLevel = "INFO" }
local mod = lib.Mod:new(configDefaults)
local log = mod.log()

---@param e tes3uiEventData
local function onMouseStillPressed(e)
	local canvas = e.source
	log:info("mouseStillPressed on %s", canvas.id)
	local pixelBuffer = {}
	local offset = 0
	local white = { 1, 1, 1 }
	for _ = 0, 511 do
		for _ = 0, 511 do
			pixelBuffer[offset + 1] = white[1]
			pixelBuffer[offset + 2] = white[2]
			pixelBuffer[offset + 3] = white[3]
			pixelBuffer[offset + 4] = 1
			offset = offset + 4
		end
	end
	canvas.texture.pixelData:setPixelsFloat(pixelBuffer)
	canvas:getTopLevelMenu():updateLayout()
end

---@param root tes3uiElement
---@return tes3uiElement canvas
local function createCanvas(root)
	local canvas = root:createRect({ id = "MenuPainting_canvas" })
	canvas.texture = ui.createTexture(512, 512)
	canvas:register(tes3.uiEvent.mouseDown, function() tes3ui.captureMouseDrag(true) end)
	canvas:register(tes3.uiEvent.mouseRelease, function() tes3ui.captureMouseDrag(false) end)
	canvas:register(tes3.uiEvent.mouseStillPressed, onMouseStillPressed)
	return root
end

event.register("initialized", function(_)
	event.register("uiActivated", function(_)
		local _, root = ui.createMenu({ id = "MenuPainting", size = { width = 512, height = 512 } })
		createCanvas(root)
		local parent = root
		while (parent) do
			parent:register("mouseStillPressed", function(e) 
				log:info("mouseStillPressed on %s", e.source.id)
			end)
			parent = parent.parent
		end
	end, { filter = "MenuOptions" })
end)
