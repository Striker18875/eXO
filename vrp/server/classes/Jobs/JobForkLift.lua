-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobForkLift.lua
-- *  PURPOSE:     Fork Lift Job
-- *
-- ****************************************************************************
JobForkLift = inherit(Job)

function JobForkLift:constructor()
	self.m_Spawner = VehicleSpawner:new( 89.82, -248.20, 0.6, {"Forklift"}, 90, bind(Job.requireVehicle, self))
	self.m_Spawner.m_Hook:register(bind(self.onVehicleSpawn,self))
	self:generateBoxes()

	addRemoteEvents{"JobForkLiftonBoxLoad"}
	addEventHandler("JobForkLiftonBoxLoad", root, bind(self.onBoxLoad, self))
end

function JobForkLift:start(player)

end

function JobForkLift:onVehicleSpawn(player,vehicleModel,vehicle)

end

function JobForkLift:onBoxLoad(box)
	if isElement(box) and table.find(self.m_Boxes, box) then
		box:destroy()
		client:giveMoney(50)
	end
end

function JobForkLift:generateBoxes()
	self.m_Boxes = {
	createObject(1558, 105.9, -249.8, 1.2, 0, 0, 6),
	createObject(1558, 105.4, -243, 1.2, 0, 0, 6),
	createObject(1558, 105.5, -244.3, 1.2, 0, 0, 6),
	createObject(1558, 105.6, -245.7, 1.2, 0, 0, 6),
	createObject(1558, 105.7, -247, 1.2, 0, 0, 6),
	createObject(1558, 105.7, -248.5, 1.2, 0, 0, 6),
	createObject(1558, 169.7, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 105.5, -244.3, 2.3, 0, 0, 6),
	createObject(1558, 105.6, -245.7, 2.3, 0, 0, 6),
	createObject(1558, 105.7, -247, 2.3, 0, 0, 6),
	createObject(1558, 105.8, -248.5, 2.3, 0, 0, 6),
	createObject(1558, 105.9, -249.8, 2.3, 0, 0, 6),
	createObject(1558, 105.4, -243, 2.3, 0, 0, 6),
	createObject(1558, 153.8, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 155, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 156.2, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 152.1, -289.4, 1.2, 0, 0, 90),
	createObject(1558, 158.6, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 159.8, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 161, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 162.2, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 163.4, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 164.6, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 165.8, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 167, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 168.3, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 153.8, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 154.9, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 156, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 157.1, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 158.2, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 159.3, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 160.4, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 161.5, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 162.6, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 163.7, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 164.9, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 166, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 167.1, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 168.2, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 169.3, -247.2, 2.8, 0, 0, 90),
	createObject(1558, 157.4, -249.6, 2.8, 0, 0, 90),
	createObject(1558, 153.3, -289.4, 1.2, 0, 0, 90),
	createObject(1558, 154.6, -289.3, 1.2, 0, 0, 90),
	createObject(1558, 155.8, -289.2, 1.2, 0, 0, 90),
	createObject(1558, 151, -289.4, 1.2, 0, 0, 90),
	createObject(1558, 151, -289.4, 2.3, 0, 0, 90),
	createObject(1558, 152.1, -289.4, 2.3, 0, 0, 90),
	createObject(1558, 153.3, -289.4, 2.3, 0, 0, 90),
	createObject(1558, 154.6, -289.4, 2.3, 0, 0, 90),
	createObject(1558, 155.8, -289.4, 2.3, 0, 0, 90),
	createObject(1558, 18.5, -231, 2.1, 0, 0, 1805),
	createObject(1558, 18.5, -228.6, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -229.8, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -237, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -232.2, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -233.4, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -234.6, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -235.8, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -240.6, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -238.2, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -239.4, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -241.9, 2.1, 0, 0, 180),
	createObject(1558, 18.5, -243.1, 2.1, 0, 0, 180),
	createObject(1558, 26.6, -242.2, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -241, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -239.8, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -238.6, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -237.4, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -236.2, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -235, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -233.8, 1.9, 0, 0, 180),
	createObject(1558, 26.7, -232.5, 1.9, 0, 0, 180),
	createObject(1558, 26.6, -242.2, 3, 0, 0, 180),
	createObject(1558, 26.7, -241, 3, 0, 0, 180),
	createObject(1558, 26.7, -239.8, 3, 0, 0, 180),
	createObject(1558, 26.7, -238.6, 3, 0, 0, 180),
	createObject(1558, 26.7, -237.4, 3, 0, 0, 180),
	createObject(1558, 26.7, -236.2, 3, 0, 0, 180),
	createObject(1558, 26.7, -235, 3, 0, 0, 180),
	createObject(1558, 26.7, -233.8, 3, 0, 0, 180),
	createObject(1558, 26.7, -232.5, 3, 0, 0, 180),
	createObject(1558, 26.6, -243.4, 1.9, 0, 0, 180),
	createObject(1558, 27.9, -243.5, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -242.2, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -241, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -239.7, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -238.5, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -237.2, 1.8, 0, 0, 180),
	createObject(1558, 28, -232, 1.8, 0, 0, 180),
	createObject(1558, 27.9, -234.6, 1.8, 0, 0, 180),
	createObject(1558, 27.96582, -233.3, 1.79406, 0, 0, 180),
	createObject(1558, 27.9, -243.5, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -242.2, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -241, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -239.7, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -238.5, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -237.2, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -235.9, 2.9, 0, 0, 180),
	createObject(1558, 27.9, -234.6, 2.9, 0, 0, 180),
	createObject(1558, 28, -233.3, 2.9, 0, 0, 180),
	createObject(1558, 28, -232, 2.9, 0, 0, 180),
	createObject(1558, 18.5, -243.1, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -241.9, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -240.6, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -239.4, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -238.2, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -237, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -235.8, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -234.6, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -233.4, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -232.2, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -231, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -229.8, 3.2, 0, 0, 180),
	createObject(1558, 18.5, -228.6, 3.2, 0, 0, 180),
	createObject(1558, 37.5, -244, 1.5, 0, 0, 180),
	createObject(1558, 36.1, -242.6, 1.6, 0, 0, 180),
	createObject(1558, 36.1, -241.3, 1.6, 0, 0, 180),
	createObject(1558, 36.2, -240.1, 1.6, 0, 0, 180),
	createObject(1558, 36.2, -238.9, 1.6, 0, 0, 180),
	createObject(1558, 36.2, -237.7, 1.6, 0, 0, 180),
	createObject(1558, 36.2, -236.5, 1.6, 0, 0, 180),
	createObject(1558, 36.3, -235.3, 1.6, 0, 0, 180),
	createObject(1558, 36.3, -234.1, 1.6, 0, 0, 180),
	createObject(1558, 36.4, -232.8, 1.6, 0, 0, 180),
	createObject(1558, 36.4, -232.8, 2.7, 0, 0, 180),
	createObject(1558, 36.3, -234.1, 2.7, 0, 0, 180),
	createObject(1558, 36.3, -235.3, 2.7, 0, 0, 180),
	createObject(1558, 36.2, -236.5, 2.7, 0, 0, 180),
	createObject(1558, 36.2, -237.7, 2.7, 0, 0, 180),
	createObject(1558, 36.2, -238.9, 2.7, 0, 0, 180),
	createObject(1558, 36.2, -240.1, 2.7, 0, 0, 180),
	createObject(1558, 36.1, -241.3, 2.7, 0, 0, 180),
	createObject(1558, 36.1, -242.6, 2.7, 0, 0, 180),
	createObject(1558, 36.1, -243.9, 2.7, 0, 0, 180),
	createObject(1558, 36.1, -243.9, 1.6, 0, 0, 180),
	createObject(1558, 37.5, -232.9, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -242.6, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -241.3, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -240.1, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -238.9, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -237.7, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -236.6, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -235.4, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -234.2, 1.5, 0, 0, 180),
	createObject(1558, 37.5, -244, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -242.6, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -241.3, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -240.1, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -238.9, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -237.7, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -236.6, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -235.4, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -234.2, 2.6, 0, 0, 180),
	createObject(1558, 37.5, -232.9, 2.6, 0, 0, 180),
	createObject(1558, 25.4, -223.9, 1.9, 0, 0, 90),
	createObject(1558, 26.6, -224, 1.9, 0, 0, 90),
	createObject(1558, 27.9, -224.1, 1.9, 0, 0, 90),
	createObject(1558, 29.1, -224.2, 1.9, 0, 0, 90),
	createObject(1558, 30.4, -224.3, 1.9, 0, 0, 90),
	createObject(1558, 31.6, -224.4, 1.9, 0, 0, 90),
	createObject(1558, 32.8, -224.5, 1.9, 0, 0, 90),
	createObject(1558, 34, -224.6, 1.9, 0, 0, 90),
	createObject(1558, 35.3, -224.7, 1.9, 0, 0, 90),
	createObject(1558, 36.6, -224.8, 1.9, 0, 0, 90),
	createObject(1558, 37.9, -224.9, 1.9, 0, 0, 90),
	createObject(1558, 39.3, -225, 1.9, 0, 0, 90),
	createObject(1558, 40.7, -225.1, 1.9, 0, 0, 90),
	createObject(1558, 40.7, -225.1, 1.9, 0, 0, 90),
	createObject(1558, 42, -225.1, 1.9, 0, 0, 90),
	createObject(1558, 25.4, -223.9, 3, 0, 0, 90),
	createObject(1558, 26.6, -224, 3, 0, 0, 90),
	createObject(1558, 27.9, -224.1, 3, 0, 0, 90),
	createObject(1558, 29.1, -224.2, 3, 0, 0, 90),
	createObject(1558, 30.4, -224.3, 3, 0, 0, 90),
	createObject(1558, 31.6, -224.4, 3, 0, 0, 87.979),
	createObject(1558, 32.8, -224.5, 3, 0, 0, 90),
	createObject(1558, 34, -224.6, 3, 0, 0, 90),
	createObject(1558, 35.3, -224.7, 3, 0, 0, 90),
	createObject(1558, 36.6, -224.8, 3, 0, 0, 90),
	createObject(1558, 37.9, -224.9, 3, 0, 0, 90),
	createObject(1558, 39.3, -225, 3, 0, 0, 90),
	createObject(1558, 40.7, -225.1, 3, 0, 0, 90),
	createObject(1558, 42, -225.1, 3, 0, 0, 90),
	createObject(1558, 26.6, -243.4, 3, 0, 0, 180),
	createObject(1558, 50.9, -256.6, 2.2, 0, 0, 180),
	createObject(1558, 50.9, -257.9, 2.2, 0, 0, 180),
	createObject(1558, 50.9, -259.3, 2.2, 0, 0, 180),
	createObject(1558, 48.7, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 48.7, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 47.6, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 46.5, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 45.4, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 43.2, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 44.3, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 42.1, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 41, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 39.9, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 38.8, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 37.7, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 36.6, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 35.5, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 34.4, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 33.3, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 32.2, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 31.1, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 30, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 28.9, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 27.8, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 26.7, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 25.6, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 24.5, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 22.3, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 23.4, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 21.2, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 18.9, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 20.1, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 49.9, -255.5, 2.2, 0, 0, 90),
	createObject(1558, 49.8, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 46.4, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 47.5, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 45.3, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 44.2, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 43.1, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 42, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 40.9, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 39.8, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 38.7, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 35.4, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 51.2, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 36.5, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 33.2, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 34.3, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 32.1, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 29.9, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 31, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 28.8, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 27.7, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 26.6, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 25.5, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 24.4, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 23.3, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 22.2, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 21.1, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 20, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 18.9, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 32.2, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 31.1, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 30, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 28.9, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 27.8, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 26.7, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 25.6, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 24.5, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 23.4, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 22.3, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 21.2, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 20.1, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 18.9, -255.5, 3.3, 0, 0, 90),
	createObject(1558, 32.1, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 31, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 29.9, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 28.8, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 27.7, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 26.6, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 25.5, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 24.4, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 23.3, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 22.2, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 21.1, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 20, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 18.9, -259.5, 3.3, 0, 0, 90),
	createObject(1558, 37.6, -259.5, 2.2, 0, 0, 90),
	createObject(1558, 43, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 48.6, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 47.3, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 46, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 44.7, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 43.4, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 42.1, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 40.8, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 39.6, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 38.4, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 37.2, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 36, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 34.8, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 33.6, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 32.4, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 31.2, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 30, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 28.7, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 27.5, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 26.3, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 25.1, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 23.9, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 22.7, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 31.2, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 30, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 28.7, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 27.5, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 26.3, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 25.1, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 23.9, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 22.7, -271.6, 3.3, 0, 0, 90),
	createObject(1558, 51.1, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 49.9, -271.6, 2.2, 0, 0, 90),
	createObject(1558, 50, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 48.7, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 44.3, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 23.5, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 41.8, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 40.6, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 40.6, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 39.3, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 38, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 36.8, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 35.5, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 31.5, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 30.3, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 29.1, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 28, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 26.8, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 25.7, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 24.6, -275.6, 2.2, 0, 0, 90),
	createObject(1558, 23.5, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 24.6, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 25.7, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 26.8, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 28, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 29.1, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 30.3, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 31.5, -275.6, 3.3, 0, 0, 90),
	createObject(1558, 61.2, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 60, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 62.4, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 63.6, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 64.8, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 66, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 67.2, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 68.4, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 72.9, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 69.6, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 75.3, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 60, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 61.2, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 62.4, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 63.6, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 64.8, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 66, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 67.2, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 68.4, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 69.6, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 74.1, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 76.5, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 77.7, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 78.9, -277.5, 1.2, 0, 0, 90),
	createObject(1558, 82.6, -277.4, 1.2, 0, 0, 90),
	createObject(1558, 80.1, -277.4, 1.2, 0, 0, 90),
	createObject(1558, 81.4, -277.4, 1.2, 0, 0, 90),
	createObject(1558, 72.9, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 74.1, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 75.3, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 76.5, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 77.7, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 78.9, -277.5, 2.3, 0, 0, 90),
	createObject(1558, 80.1, -277.4, 2.3, 0, 0, 90),
	createObject(1558, 81.4, -277.4, 2.3, 0, 0, 90),
	createObject(1558, 82.6, -277.4, 2.3, 0, 0, 90),
	createObject(1558, 110.9, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 112, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 113.1, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 114.2, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 115.3, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 116.4, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 117.5, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 136.2, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 119.7, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 120.8, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 121.9, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 123, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 124.1, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 125.2, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 126.3, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 127.4, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 128.5, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 129.6, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 130.7, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 131.8, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 132.9, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 134, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 135.1, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 145.1, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 137.3, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 138.4, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 139.5, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 140.6, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 141.7, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 142.8, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 143.9, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 112.3, -273, 3.6, 0, 0, 90),
	createObject(1558, 114.5, -273, 3.6, 0, 0, 90),
	createObject(1558, 113.4, -273, 3.6, 0, 0, 90),
	createObject(1558, 115.6, -273, 3.6, 0, 0, 90),
	createObject(1558, 116.7, -273, 3.6, 0, 0, 90),
	createObject(1558, 117.8, -273, 3.6, 0, 0, 90),
	createObject(1558, 118.9, -273, 3.6, 0, 0, 90),
	createObject(1558, 120, -273, 3.6, 0, 0, 90),
	createObject(1558, 121.1, -273, 3.6, 0, 0, 90),
	createObject(1558, 123.3, -273, 3.6, 0, 0, 90),
	createObject(1558, 122.2, -273, 3.6, 0, 0, 90),
	createObject(1558, 124.4, -273, 3.6, 0, 0, 90),
	createObject(1558, 125.5, -273, 3.6, 0, 0, 90),
	createObject(1558, 126.6, -273, 3.6, 0, 0, 90),
	createObject(1558, 127.7, -273, 3.6, 0, 0, 90),
	createObject(1558, 128.8, -273, 3.6, 0, 0, 90),
	createObject(1558, 129.9, -273, 3.6, 0, 0, 90),
	createObject(1558, 131, -273, 3.6, 0, 0, 90),
	createObject(1558, 133, -273, 3.6, 0, 0, 90),
	createObject(1558, 132.1, -273, 3.6, 0, 0, 90),
	createObject(1558, 136.5, -273, 3.6, 0, 0, 90),
	createObject(1558, 134.3, -273, 3.6, 0, 0, 90),
	createObject(1558, 135.4, -273, 3.6, 0, 0, 90),
	createObject(1558, 138.7, -273, 3.6, 0, 0, 90),
	createObject(1558, 137.6, -273, 3.6, 0, 0, 90),
	createObject(1558, 139.8, -273, 3.6, 0, 0, 90),
	createObject(1558, 140.9, -273, 3.6, 0, 0, 90),
	createObject(1558, 142, -273, 3.6, 0, 0, 90),
	createObject(1558, 143.1, -273, 3.6, 0, 0, 90),
	createObject(1558, 144.3, -273, 3.6, 0, 0, 90),
	createObject(1558, 145.5, -273, 3.6, 0, 0, 90),
	createObject(1558, 146.7, -273, 3.6, 0, 0, 90),
	createObject(1558, 110.9, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 112, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 113.1, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 114.2, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 115.3, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 116.4, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 117.5, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 118.6, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 119.7, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 120.8, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 121.9, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 123, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 124.1, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 125.2, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 126.3, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 127.4, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 128.5, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 129.6, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 130.7, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 131.8, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 132.9, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 134, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 135.1, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 136.2, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 137.3, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 138.4, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 139.5, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 140.6, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 141.7, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 142.8, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 143.9, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 145.1, -259.7, 4.7, 0, 0, 90),
	createObject(1558, 146.7, -273, 4.7, 0, 0, 90),
	createObject(1558, 145.5, -273, 4.7, 0, 0, 90),
	createObject(1558, 144.3, -273, 4.7, 0, 0, 90),
	createObject(1558, 143.1, -273, 4.7, 0, 0, 90),
	createObject(1558, 142, -273, 4.7, 0, 0, 90),
	createObject(1558, 140.9, -273, 4.7, 0, 0, 90),
	createObject(1558, 139.8, -273, 4.7, 0, 0, 90),
	createObject(1558, 138.7, -273, 4.7, 0, 0, 90),
	createObject(1558, 137.6, -273, 4.7, 0, 0, 90),
	createObject(1558, 136.5, -273, 4.7, 0, 0, 90),
	createObject(1558, 135.4, -273, 4.7, 0, 0, 90),
	createObject(1558, 134.3, -273, 4.7, 0, 0, 90),
	createObject(1558, 133.2, -273, 4.7, 0, 0, 90),
	createObject(1558, 132.1, -273, 4.7, 0, 0, 90),
	createObject(1558, 131, -273, 4.7, 0, 0, 90),
	createObject(1558, 129.9, -273, 4.7, 0, 0, 90),
	createObject(1558, 128.8, -273, 4.7, 0, 0, 90),
	createObject(1558, 127.7, -273, 4.7, 0, 0, 90),
	createObject(1558, 126.6, -273, 4.7, 0, 0, 90),
	createObject(1558, 125.5, -273, 4.7, 0, 0, 90),
	createObject(1558, 124.4, -273, 4.7, 0, 0, 90),
	createObject(1558, 123.3, -273, 4.7, 0, 0, 90),
	createObject(1558, 122.2, -273, 4.7, 0, 0, 90),
	createObject(1558, 121.1, -273, 4.7, 0, 0, 90),
	createObject(1558, 120, -273, 4.7, 0, 0, 90),
	createObject(1558, 118.9, -273, 4.7, 0, 0, 90),
	createObject(1558, 117.8, -273, 4.7, 0, 0, 90),
	createObject(1558, 116.7, -273, 4.7, 0, 0, 90),
	createObject(1558, 115.6, -273, 4.7, 0, 0, 90),
	createObject(1558, 114.5, -273, 4.7, 0, 0, 90),
	createObject(1558, 113.4, -273, 4.7, 0, 0, 90),
	createObject(1558, 112.3, -273, 4.7, 0, 0, 90),
	createObject(1558, 111.2, -273, 4.7, 0, 0, 90),
	createObject(1558, 112.5, -266, 3.6, 0, 0, 90),
	createObject(1558, 111.2, -266, 3.6, 0, 0, 90),
	createObject(1558, 113.8, -266, 3.6, 0, 0, 90),
	createObject(1558, 115.1, -266, 3.6, 0, 0, 90),
	createObject(1558, 116.3, -266, 3.6, 0, 0, 90),
	createObject(1558, 118.8, -266, 3.6, 0, 0, 90),
	createObject(1558, 117.5, -266, 3.6, 0, 0, 90),
	createObject(1558, 120.1, -266, 3.6, 0, 0, 90),
	createObject(1558, 121.4, -266, 3.6, 0, 0, 90),
	createObject(1558, 123.8, -266, 3.6, 0, 0, 90),
	createObject(1558, 122.6, -266, 3.6, 0, 0, 90),
	createObject(1558, 125.1, -266, 3.6, 0, 0, 90),
	createObject(1558, 126.4, -266, 3.6, 0, 0, 90),
	createObject(1558, 127.6, -266, 3.6, 0, 0, 90),
	createObject(1558, 128.9, -266, 3.6, 0, 0, 90),
	createObject(1558, 131.6, -266, 3.6, 0, 0, 90),
	createObject(1558, 130.2, -266, 3.6, 0, 0, 90),
	createObject(1558, 138.4, -266, 3.6, 0, 0, 90),
	createObject(1558, 139.8, -266, 3.6, 0, 0, 90),
	createObject(1558, 141.1, -266, 3.6, 0, 0, 90),
	createObject(1558, 142.4, -266, 3.6, 0, 0, 90),
	createObject(1558, 143.9, -266, 3.6, 0, 0, 90),
	createObject(1558, 145.4, -266, 3.6, 0, 0, 90),
	createObject(1558, 146.8, -266, 3.6, 0, 0, 90),
	createObject(1558, 146.8, -266, 4.7, 0, 0, 90),
	createObject(1558, 145.4, -266, 4.7, 0, 0, 90),
	createObject(1558, 143.9, -266, 4.7, 0, 0, 90),
	createObject(1558, 142.4, -266, 4.7, 0, 0, 90),
	createObject(1558, 141.1, -266, 4.7, 0, 0, 90),
	createObject(1558, 139.8, -266, 4.7, 0, 0, 90),
	createObject(1558, 138.4, -266, 4.7, 0, 0, 90),
	createObject(1558, 131.6, -266, 4.7, 0, 0, 90),
	createObject(1558, 27.9, -235.9, 1.8, 0, 0, 180),
	createObject(1558, 118.6, -259.7, 3.6, 0, 0, 90),
	createObject(1558, 111.2, -273, 3.6, 0, 0, 90)
}
end
