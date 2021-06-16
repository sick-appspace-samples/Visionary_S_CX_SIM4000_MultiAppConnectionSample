--[[----------------------------------------------------------------------------

  Application Name: MultiPointCloudProcessing
  
  Summary:
  Register to receiver apps for further processing of data. In this sample only the point cloud is displayed.
  
  Description:
  Register to 4 different 'ImageReceiverRemoteCamera' Apps to do further processing with the point clouds calculated by these apps.
  To do your own processing with the data just extend the provided functions.
  
  How to run:
  Start by running the app (F5) or debugging (F7+F10).
  Set a breakpoint on the first row inside the main function to debug step-by-step.
  See the results in the different image viewer on the DevicePage.
  
  More Information:
  This App works only in combination with the other Apps. It's completly eventdriven and only reacts to the Receiver Apps
  If you want more or less receivers change the number in this App and the names of the Apps.
  
------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------
-- set the wanted log level - default is WARNING
Log.setLevel("INFO")
-- Variables, constants, serves etc. should be declared here.

-- setup the 4 different viewers
local viewers = 
  { View.create("v1"),
    View.create("v2"),
    View.create("v3"),
    View.create("v4") }

function handleOnNewPointCloud1(images, pointCloud, sensordata)
  -- send only point cloud to viewer, no further processing
  viewers[1]:clear()
  viewers[1]:addPointCloud(pointCloud, nil)
  viewers[1]:present()
end

function handleOnNewPointCloud2(images, pointCloud, sensordata)
  -- send only point cloud to viewer, no further processing
  viewers[2]:clear()
  viewers[2]:addPointCloud(pointCloud, nil)
  viewers[2]:present()
end

function handleOnNewPointCloud3(images, pointCloud, sensordata)
  -- send only point cloud to viewer, no further processing
  viewers[3]:clear()
  viewers[3]:addPointCloud(pointCloud, nil)
  viewers[3]:present()
end

function handleOnNewPointCloud4(images, pointCloud, sensordata)
  -- send only point cloud to viewer, no further processing
  viewers[4]:clear()
  viewers[4]:addPointCloud(pointCloud, nil)
  viewers[4]:present()
end

-- Generate callbacks for 4 pointcloud receivers
-- Event queue handling to prevent receiving queues to generate memory overflows
eventQueueHandles = {Script.Queue.create(), Script.Queue.create(), Script.Queue.create(), Script.Queue.create()}
for i = 1, 4, 1 do
  eventQueueHandles[i]:setMaxQueueSize(1)
  eventQueueHandles[i]:setFunction('handleOnNewPointCloud' .. i)
  Script.register('ImageReceiverRemoteCamera' .. i .. '.OnNewPointCloud', 'handleOnNewPointCloud' .. i)
end
