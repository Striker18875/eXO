-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Jobs/JobPizzaDelivery.lua
-- *  PURPOSE:     Pizza-Delivery Job class
-- *
-- ****************************************************************************

JobPizza = inherit(Job)
JobPizza.ValidVehicleModels = {509, 448}

addRemoteEvents{ "nextPizzaDelivery" }

local PickupX, PickupY, PickupZ =  2098.50, -1808.93, 13.07
local objID = 1582
function JobPizza:constructor()
	Job.constructor(self, 155, 2108.99, -1790.68, 13.55, 0, "Pizza.png", {170, 150, 100}, "files/images/Jobs/HeaderPizzaDelivery.png", _(HelpTextTitles.Jobs.PizzaDelivery):gsub("Job: ", ""), _(HelpTexts.Jobs.PizzaDelivery), self.onInfo)
	self:setJobLevel(JOB_LEVEL_PIZZA)

	addEventHandler("nextPizzaDelivery", localPlayer, bind(JobPizza.nextDeliver, self))
end


function JobPizza:start()
	self:nextDeliver()
	HelpBar:getSingleton():setLexiconPage(LexiconPages.JobPizzaDelivery)
end

function JobPizza:throwPizza()
	local obj = getPedOccupiedVehicle( localPlayer ) or localPlayer
	local x, y, z = getElementPosition( obj )
	local _,_,rot = getElementRotation( obj )
	local x2, y2 = getPointFromDistanceRotation(x, y, 1.5, rot-90)
	self.m_PizzaObj = createObject ( objID, x, y , z+ 1)
	setElementCollisionsEnabled( self.m_PizzaObj, false)
	moveObject( self.m_PizzaObj, 500,x2, y2, z-0.5 ,0,0,0,"OutBack")
	setTimer( bind( JobPizza.destroyThrow, self), 700, 1 )
end

function JobPizza:destroyThrow()
	if self.m_PizzaObj then
		destroyElement( self.m_PizzaObj )
	end
end

function JobPizza:stop( )
	if self.m_PizzaJobBlip then
		self.m_PizzaJobBlip:delete()
	end
	if isElement(self.m_PizzaJobMarker) then
		destroyElement( self.m_PizzaJobMarker )
	end
	if isElement(self.m_PizzaPickupMarker) then
		destroyElement( self.m_PizzaPickupMarker )
	end
	HelpBar:getSingleton():setLexiconPage(nil)
end

function JobPizza:nextDeliver( )
	local randPosition = math.random(1, #JobPizza.DeliverPositions)
	local x,y,z = unpack(JobPizza.DeliverPositions[randPosition])
	local px,py = getElementPosition( localPlayer )
	self.m_PizzaJobMarker = createMarker(x, y, z,"checkpoint", 2, 0, 200, 200, 255)
	GPS:getSingleton():startNavigationTo(Vector3(x, y, z))
	self.m_DeliverDistance = math.floor( getDistanceBetweenPoints2D( px, py, x, y) )
	addEventHandler("onClientMarkerHit",self.m_PizzaJobMarker,bind( JobPizza.onMarkerHit, self))
	self.m_PizzaJobBlip = Blip:new("Marker.png",x , y,9999)
	self.m_PizzaJobBlip:setColor(BLIP_COLOR_CONSTANTS.Red)
	self.m_PizzaJobBlip:setDisplayText("Pizza-Lieferadresse")

	self.m_PizzaTick = getTickCount()
end

function JobPizza:onMarkerHit( element, bdim )
	if element == localPlayer or element == getPedOccupiedVehicle( localPlayer ) then
		local obj = getPedOccupiedVehicle( localPlayer )
		if not table.find(JobPizza.ValidVehicleModels, obj:getModel()) then return end

		if obj then
				local speedx, speedy, speedz = getElementVelocity ( obj )
				local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
				local kmh = actualspeed * 180
				if kmh > 25 then
					return triggerEvent("errorBox", localPlayer,"Zu schnell! Fahre langsamer heran.")
				end
			end
		self.m_PizzaJobBlip:delete()
		destroyElement( self.m_PizzaJobMarker )
		self:pickupDeliver( )
	end
end

function JobPizza:pickupDeliver( )
	triggerEvent("infoBox", localPlayer,"Fahre zurück zum Pizza-Stack!")
	self:throwPizza()
	self.m_PizzaPickupMarker = createMarker( PickupX, PickupY, PickupZ , "checkpoint", 2, 200, 200, 0, 255)
	GPS:getSingleton():startNavigationTo(Vector3(PickupX, PickupY, PickupZ))
	self.m_PizzaJobBlip = Blip:new("Marker.png", PickupX, PickupY, 9999)
	self.m_PizzaJobBlip:setColor(BLIP_COLOR_CONSTANTS.Red)
	self.m_PizzaJobBlip:setDisplayText("Pizza-Stack")
	addEventHandler("onClientMarkerHit",self.m_PizzaPickupMarker,bind( JobPizza.onNextDeliver, self))
end

function JobPizza:onNextDeliver( elem, dim )
	--// pay
	if elem == localPlayer or elem == getPedOccupiedVehicle( localPlayer ) then
		local duration = (getTickCount() - self.m_PizzaTick) / 1000 -- in seconds
		triggerServerEvent("onPizzaDelivered", localPlayer, self.m_DeliverDistance, duration)
		destroyElement( self.m_PizzaPickupMarker )
		self.m_PizzaJobBlip:delete()
		self:nextDeliver( )
	end
end

JobPizza.DeliverPositions = {
	{2308.986328125,-1715.6317138672,14.64959526062},
	{2326.3557128906,-1717.2272949219,13.907408714294},
	{2386.1469726563,-1713.0357666016,14.172848701477},
	{2401.6257324219,-1721.2291259766,13.610415458679},
	{2466.6235351563,-1742.0861816406,13.546875},
	{2481.3688964844,-1755.6170654297,13.546875},
	{2413.9721679688,-1649.4926757813,13.540514945984},
	{2393.7138671875,-1648.1705322266,13.539916992188},
	{2362.5419921875,-1646.267578125,13.529504776001},
	{2368.19140625,-1674.4412841797,13.906294822693},
	{2384.6486816406,-1674.2232666016,14.760807991028},
	{2409.0249023438,-1673.6724853516,13.602036476135},
	{2396.3979492188,-1796.4782714844,13.546875},
	{2322.6750488281,-1795.2807617188,13.546875},
	{2292.0080566406,-1723.4548339844,13.546875},
	{2140.0239257813,-1699.6578369141,15.078443527222},
	{2141.078125,-1705.8403320313,15.0859375},
	{2068.4169921875,-1703.3359375,14.1484375},
	{2069.0854492188,-1716.7545166016,13.554683685303},
	{2069.0854492188,-1716.7545166016,13.554683685303},
	{2068.6264648438,-1731.2281494141,13.87615776062},
	{2002.7038574219,-1782.6552734375,13.553680419922},
	{1787.9715576172,-1723.4560546875,13.546875},
	{1677.2243652344,-1635.2747802734,14.2265625},
	{1685.7164306641,-1585.6639404297,13.546875},
	{1672.0313720703,-1583.5185546875,13.546875},
	{1799.990234375,-1578.6193847656,14.077041625977},
	{1883.7069091797,-1271.3538818359,13.546875},
	{1987.0159912109,-1281.3837890625,23.980520248413},
	{2087.7175292969,-1267.4127197266,25.497245788574},
	{2103.2565917969,-1283.5972900391,24.922653198242},
	{2094.8903808594,-1285.7940673828,24.801000595093},
	{2144.7897949219,-1085.6418457031,24.691707611084},
	{2139.9724121094,-1083.6247558594,24.467641830444},
	{2109.6838378906,-1081.7596435547,24.856637954712},
	{2102.3312988281,-1075.3792724609,25.776292800903},
	{2092.0363769531,-1067.8430175781,27.599054336548},
	{2093.7575683594,-1047.8698730469,29.664241790771},
	{2099.697265625,-1052.9898681641,28.283710479736},
	{2082.8933105469,-1040.2099609375,31.801977157593},
	{2077.3706054688,-1056.1783447266,31.062377929688},
	{2000.3930664063,-992.77807617188,31.3203125},
	{2008.1223144531,-985.08337402344,33.986999511719},
	{2015.8748779297,-979.03179931641,36.48560333252},
	{2044.1599121094,-966.23889160156,43.849636077881},
	{2054.3359375,-969.01568603516,45.65306854248},
	{2072.7106933594,-966.96649169922,48.729873657227},
	{2089.3002929688,-995.30438232422,52.627464294434},
	{2115.6555175781,-1002.024230957,57.1188621521},
	{2122.9455566406,-981.38287353516,57.873546600342},
	{2140.1940917969,-1007.4830322266,61.75260925293},
	{2176.1586914063,-987.77197265625,64.46875},
	{2186.1633300781,-997.7490234375,66.46875},
	{2208.5686035156,-1025.9466552734,60.877010345459},
	{2218.9233398438,-1031.1732177734,59.968669891357},
	{2260.0971679688,-1019.8424072266,59.291194915771},
	{2279.1010742188,-1075.3188476563,47.638938903809},
	{2287.6135253906,-1079.4998779297,47.555992126465},
	{2284.5764160156,-1052.0047607422,49.317394256592},
	{2301.8786621094,-1056.6207275391,49.630382537842},
	{2324.6455078125,-1059.7692871094,52.3515625},
	{2361.68359375,-1048.59765625,54.1484375},
	{2373.7927246094,-1035.72265625,54.2421875},
	{2432.9982910156,-1014.6127929688,54.34375},
	{2457.0378417969,-1013.3954467773,59.7734375},
	{2484.1752929688,-1016.7845458984,65.173126220703},
	{2476.4731445313,-1055.8792724609,66.56233215332},
	{2501.7980957031,-1033.3078613281,69.556030273438},
	{2497.4104003906,-1062.6209716797,70.1328125},
	{2530.1091308594,-1059.9858398438,69.570770263672},
	{2569.7197265625,-1069.0078125,69.321884155273},
	{2567.4584960938,-1086.0052490234,67.510795593262},
	{2535.3122558594,-1104.7757568359,59.514476776123},
	{2469.4331054688,-1100.0284423828,44.25968170166},
	{2456.0112304688,-1098.3662109375,43.201538085938},
	{2440.4077148438,-1098.2082519531,42.614627838135},
	{2408.1013183594,-1100.9923095703,39.624187469482},
	{2408.7565917969,-1101.7497558594,39.71813583374},

	{1340.9881591797,-1063.7813720703,26.136180877686},
	{1337.7608642578,-1097.6398925781,23.621845245361},
	{1371.0822753906,-1089.2873535156,24.201076507568},
	{1291.2028808594,-1134.1947021484,23.413831710815},
	{1245.8909912109,-1133.6154785156,23.434101104736},
	{1198.8400878906,-1133.4521484375,23.503458023071},
	{1143.8514404297,-1133.4248046875,23.416662216187},
	{1062.5402832031,-1133.8762207031,23.41460609436},
	{986.15753173828,-1133.4194335938,23.421033859253},
	{962.31134033203,-1156.8543701172,23.428157806396},
	{1033.6727294922,-1156.8494873047,23.411487579346},
	{1088.6610107422,-1157.1697998047,23.417507171631},
	{1179.6470947266,-1157.2395019531,23.447456359863},
	{1235.1123046875,-1156.6005859375,23.148630142212},
	{1279.4685058594,-1156.5472412109,23.418849945068},
	{1305.0849609375,-1156.4210205078,23.417398452759},
	{1184.0134277344,-1231.1485595703,18.145778656006},
	{1183.9853515625,-1254.671875,14.765045166016},
	{1182.9522705078,-1323.1544189453,13.168405532837},
	{1204.9890136719,-1438.6945800781,12.999555587769},
	{1204.2296142578,-1459.6258544922,13.028402328491},
	{1188.884765625,-1504.4488525391,13.138871192932},
	{1100.6260986328,-1476.2780761719,15.391580581665},
	{1103.3958740234,-1456.2122802734,15.38436126709},
	{1152.1666259766,-1438.3848876953,15.386076927185},
	{1156.7194824219,-1507.4359130859,15.393368721008},
	{1021.5284423828,-1556.2470703125,13.177817344666},
	{1013.1497802734,-1483.1772460938,13.198309898376},
	{974.20770263672,-1482.4919433594,13.158429145813},
	{903.73266601563,-1473.2717285156,13.134621620178},
	{876.55963134766,-1519.8236083984,13.142701148987},
	{853.689453125,-1520.4299316406,13.136967658997},
	{827.84796142578,-1552.2145996094,13.081340789795},
	{808.94195556641,-1550.9619140625,13.15996837616},
	{784.63623046875,-1466.2280273438,13.177188873291},
	{514.17999267578,-1393.1254882813,15.722139358521},
	{486.06280517578,-1463.4820556641,18.076383590698},

	{486.70687866211,-1642.9440917969,23.703125},
	{436.90484619141,-1645.2916259766,25.279718399048},
	{370.8408203125,-1639.9979248047,32.481616973877},
	{350.33804321289,-1637.3133544922,32.750595092773},
	{374.69778442383,-1598.6411132813,30.872413635254},
	{459.06231689453,-1558.2058105469,26.584585189819},
	{458.74472045898,-1508.5998535156,30.575315475464},
	{451.77908325195,-1482.4639892578,30.50200843811},
	{303.84655761719,-1468.4135742188,33.223602294922},
	{457.63977050781,-1374.4967041016,23.066188812256},
	{481.74951171875,-1278.2419433594,15.206580162048},
	{695.12957763672,-1167.6146240234,15.058076858521},
	{746.18908691406,-1079.7379150391,22.497606277466},
	{776.75244140625,-1039.5804443359,23.813449859619},
	{810.83917236328,-1033.4855957031,24.583160400391},
	{844.17449951172,-1007.5111083984,28.447965621948},
	{1012.8063964844,-975.51696777344,41.401008605957},
	{1061.8132324219,-944.32458496094,42.549575805664},
	{1050.7225341797,-945.20355224609,42.468944549561},
	{1039.8745117188,-946.80596923828,42.381404876709},
	{1107.3786621094,-963.46081542969,42.258766174316},
	{1178.2553710938,-958.34191894531,42.477333068848},
	{1237.4248046875,-949.28356933594,42.298439025879},
	{1271.3499755859,-1018.9493408203,32.800701141357},
	{1324.1534423828,-1274.0161132813,13.127254486084},
	{1302.2799072266,-1274.0166015625,13.134342193604},
	{1364.0866699219,-1438.0849609375,13.128478050232},
	{1361.5513916016,-1450.8712158203,13.092702865601},
	{1347.7286376953,-1496.2060546875,13.137445449829},
	{1337.7973632813,-1512.3336181641,13.13885307312},
	{1286.4194335938,-1583.9019775391,13.132553100586},
	{1220.1726074219,-1705.2828369141,13.137693405151},
	{1181.0128173828,-1705.0224609375,13.446229934692},
	{1083.1508789063,-1703.3449707031,13.137319564819},
	{1139.5205078125,-1759.0119628906,13.177403450012},
	{1105.501953125,-1859.4937744141,13.141302108765},
	{1085.2182617188,-1859.8454589844,13.137584686279},
	{1132.9395751953,-1858.9508056641,13.167965888977},
	{1185.5133056641,-1858.5423583984,13.145547866821},
	{1240.2380371094,-1858.3341064453,13.136231422424},
	{1357.6900634766,-1855.8305664063,13.132098197937},
	{1397.0270996094,-1878.5236816406,13.133580207825},
	{1403.9796142578,-1878.4196777344,13.134928703308},
	{1440.4888916016,-1879.1971435547,13.139121055603},
	{1485.2354736328,-1864.5018310547,13.131511688232},
	{1504.6691894531,-1864.4488525391,13.133301734924},
	{1522.955078125,-1863.9995117188,13.131867408752},
	{1541.7882080078,-1863.85546875,13.130926132202},
	{1585.2448730469,-1863.7915039063,13.13950920105},
	{1650.3735351563,-1864.1916503906,13.124005317688},
	{1713.7994384766,-1865.095703125,13.157486915588},
	{1742.6906738281,-1861.1169433594,13.166991233826},
	{1848.2336425781,-1924.3741455078,13.132670402527},
	{1870.3054199219,-1924.2012939453,13.13452911377},
	{1913.1691894531,-1923.7407226563,13.139508247375},
	{1932.8049316406,-1924.0478515625,13.134082794189},
	{1972.2891845703,-1923.4949951172,13.165482521057},
	{1952.8397216797,-1983.3251953125,13.137073516846},
	{1954.5677490234,-2001.6020507813,13.13268661499},
	{1955.0950927734,-2031.384765625,13.135838508606},
	{1907.4494628906,-2044.2121582031,13.132598876953},
	{1873.7799072266,-2037.7908935547,13.13342666626},
	{1868.6586914063,-2031.4688720703,13.139041900635},
	{1855.4389648438,-2023.7232666016,13.134778022766},
	{1854.8332519531,-2000.7803955078,13.133460998535},
	{1864.4650878906,-1989.0681152344,13.13098526001},
	{1897.9578857422,-1990.6809082031,13.1374168396},
	{1974.4108886719,-2102.673828125,13.125140190125},
	{1939.3931884766,-2141.4189453125,13.147438049316},
	{1803.1569824219,-2122.2421875,13.132109642029},
	{1801.1364746094,-2103.6364746094,13.136755943298},
	{1784.6624755859,-2105.2487792969,13.135953903198},
	{1764.0520019531,-2105.3381347656,13.137120246887},
	{1729.4282226563,-2105.66796875,13.134680747986},
	{1714.8483886719,-2105.3334960938,13.134352684021},
	{1679.0145263672,-2119.0170898438,13.128891944885},
	{1691.1169433594,-2120.1335449219,13.143385887146},
	{1702.3432617188,-2119.9956054688,13.123766899109},
	{1723.3232421875,-2119.9509277344,13.131254196167},
	{1756.6042480469,-2120.0661621094,13.146190643311},
	{1771.8642578125,-2119.6813964844,13.148488044739},
	{1797.9389648438,-2118.9333496094,13.14226436615},
	{492.26614379883,-1733.3305664063,10.89666557312},
	{419.26947021484,-1726.4552001953,8.7447309494019},
	{305.84503173828,-1747.0939941406,4.1339411735535},
	{232.02488708496,-1741.0163574219,4.0211839675903},
	{198.51921081543,-1744.7786865234,4.0798602104187},
}
