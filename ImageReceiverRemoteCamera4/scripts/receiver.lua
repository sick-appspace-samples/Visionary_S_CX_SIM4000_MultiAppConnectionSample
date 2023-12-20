--[[----------------------------------------------------------------------------
  Information:
  With this App standalone running you won't see anything.
  If you want more or less cameras connected duplicate this app or remove some.
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------
-- set the wanted log level - default is WARNING
Log.setLevel("INFO")
-- Variables, constants, serves etc. should be declared here.

-- create a timer to measure the received frames per second
fps_t = Timer.create()
Timer.setExpirationTime(fps_t, 10000)
Timer.setPeriodic(fps_t, true)

-- setup remote camera, configure as Visionary-S CX (V3SXX2) and define IP address
local cam = Image.Provider.RemoteCamera.create()
cam:setType("V3SXX2")
cam:setIPAddress("192.168.3.10")

-- generate point cloud converter for Planar conversion from Z image to point cloud
local pc_converter = Image.PointCloudConversion.PlanarDistance.create()

---function to connect to a camera and initialize the point cloud converter
function main()
  -- connect to device
  if cam:connect() then
    -- request config from remote camera to extract the camera model needed for the pointcloud conversion
    local cam_cfg = cam:getConfig()
    -- do not use "cam_cfg:getCameraModel()" that will not work!
    local cam_model = Image.Provider.RemoteCamera.V3SXX2Config.getCameraModel(cam_cfg)
    -- initialize the point cloud converter with the matching camera model
    pc_converter:setCameraModel(cam_model)
    -- start the image acquisition of the remote camera
    cam:start()
  else
    Log.severe('Conection to cam failed')
  end
end

Script.register("Engine.OnStarted", main)

-- count the received images per camera
local imageCnt = 0

---@param image Image[]
---@param sensordata SensorData
local function handleOnNewImage(image, sensordata)
  -- calculate the point cloud and color it with the distance values
  local pointCloud = pc_converter:toPointCloud(image[1], image[1])  -- , _pixelRegion)

  -- notify a event, so other Apps can continue with the processing of the point cloud
  Script.notifyEvent("OnNewPointCloud", image, pointCloud, sensordata)

  -- function to save pointcloud to filesystem - handle carefully since space is limited
  --PointCloud.save(pointCloud, "public/cam" .. num .. "pointCloud" .. imageCnt .. ".pcd", false)
  imageCnt = imageCnt + 1
end

---display the received and processed framerate
function handleOnExpiredFPSCount()
  Log.info("fps of cam #4: " .. imageCnt/10)
  imageCnt = 0
end
Timer.register(fps_t, "OnExpired", "handleOnExpiredFPSCount")
Timer.start(fps_t)

-- register/serve events --------------------------------------------------------------
Script.serveEvent("ImageReceiverRemoteCamera4.OnNewPointCloud", "OnNewPointCloud")

-- Event queue handling to prevent receiving queues to generate memory overflows
eventQueueHandle = Script.Queue.create()
eventQueueHandle:setMaxQueueSize(1)
eventQueueHandle:setFunction(handleOnNewImage)
Image.Provider.RemoteCamera.register(cam, 'OnNewImage', handleOnNewImage)

-- serve functions --------------------------------------------------------------------
