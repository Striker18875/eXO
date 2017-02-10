-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/constants.lua
-- *  PURPOSE:     Global clientside constants
-- *
-- ****************************************************************************
screenWidth, screenHeight = guiGetScreenSize()
screenSize = Vector2(screenWidth, screenHeight)
ASPECT_RATIO_MULTIPLIER = (screenWidth/screenHeight)/(16/9)

HTTP_DOWNLOAD = true
FILE_HTTP_SERVER_URL = "https://download.exo-reallife.de/files/master/vrp_assets/" -- Todo: move to config
HTTP_CONNECT_ATTEMPTS = 2 -- Todo: see above

NO_MUNITION_ITEMS = {
	[0] = true;
	[1] = true;
	[2] = true;
	[3] = true;
	[4] = true;
	[5] = true;
	[7] = true;
	[8] = true;
	[10] = true;
	[11] = true;
	[12] = true;
	[13] = true;
	[14] = true;
	[15] = true;
	[44] = true;
	[45] = true;
	[46] = true;
}

WeaponIcons = {
	[0] = "Fist.png",
	[1] = "BrassKnuckles.png",
	[2] = "Golf.png",
	[3] = "Nightstick.png",
	[4] = "Knife.png",
	[5] = "BaseballBat.png",
	[6] = "Shovel.png",
	[7] = "Cue.png",
	[8] = "Katana.png",
	[9] = "Chainsaw.png",
	[10] = "Dildo.png",
	[11] = "DildoSmall.png",
	[12] = "Vibrator.png",
	[14] = "Flowers.png",
	[15] = "Cane.png",
	[16] = "Grenade.png",
	[17] = "Teargas.png",
	[18] = "Molotov.png",
	[22] = "Pistol.png",
	[23] = "Taser.png",
	[24] = "Deagle.png",
	[25] = "Shotgun.png",
	[26] = "SawnOffShotgun.png",
	[27] = "SPAZ-12.png",
	[28] = "Uzi.png",
	[29] = "MP5.png",
	[30] = "AK-47.png",
	[31] = "M4.png",
	[32] = "TEC-9.png",
	[33] = "CountryRifle.png",
	[34] = "Sniper.png",
	[35] = "RPG.png",
	[36] = "RocketHS.png",
	[37] = "FlameThrower.png",
	[38] = "Minigun.png",
	[39] = "Satchel.png",
	[40] = "SatchelDetonator.png",
	[41] = "Spraycan.png",
	[42] = "FireExtinguisher.png",
	[43] = "Camera.png",
	[44] = "Nightvision.png",
	[45] = "Nightvision.png",
	[46] = "Parachute.png",
}
for k, v in pairs(WeaponIcons) do WeaponIcons[k] = "files/images/Weapons/"..v end

RadarDesign = {Monochrome = 1, GTA = 2, Default = 3}
for i, v in pairs(RadarDesign) do RadarDesign[v] = i end

BlipConversion =
{
	["AmmuNation.png"] = 6,
	["Bank.png"] = 52,
	["Bus.png"] = 56,
	["CarShop.png"] = 55,
	["Carshop.png"] = 55,
	["Marker.png"] = 0,
	["TreasureSeeker.png"] = 9,
	["Roadsweeper.png"] = 38,
	["Casino.png"] = 25,
	["Farmer.png"] = 40,
	["DrivingSchool.png"] = 36,
	["Garage.png"] = 53,
	["ForkLift.png"] = 11,
	["Gardener.png"] = 62,
	["Pizza.png"] = 29,
	["Logistician.png"] = 51,
	["PayNSpray.png"] = 63,
	["Shop.png"] = 17,
	["TuningGarage.png"] = 27,
	["Skinshop.png"] = 45,
	["Zombie.png"] = 37,
	["Waypoint.png"] = 41,
	["Wheel.png"] = 35,
	["Police.png"] = 30,
	["Mechanic.png"] = 48,
	["Trashman.png"] = 42,
	["Fire.png"] = 20,
	["Needhelp.png"] = 0,
	["Moneybag.png"] = 52,
	["Stadthalle.png"] = 36,
	["House.png"] = 32,
	["Zombie.png"] = 23,
	["SniperGame.png"] = 47,
	["Train.png"] = 56,
	["RoadSweeper.png"] = 11,
	["ServiceTechnician.png"] = 11,
	["Lumberjack.png"] = 11,
	["Trashman.png"] = 11,
	["Fishing.png"] = 37,
	["Locate.png"] = 0,
	["HeliTransport.png"] = 5,
	["Bar.png"] = 49,
	["RedSaw.png"] = 0,
	["Horse.png"] = 35,

}
UIStyle = {vRoleplay = 1, eXo = 2, Default = 3}
for i, v in pairs(UIStyle) do UIStyle[v] = i end

NametagStyle = {Default = 1, vRoleplay = 2}
for i, v in pairs(NametagStyle) do NametagStyle[v] = i end

MATERIAL_TYPES =
{
	[1] = 	--// GRASS
	{
		9,
		10,
		11,
		12,
		13,
		14,
		15,
		16,
		17,
		20,
		80,
		81,
		82,
		115,
		116,
		117,
		118,
		119,
		120,
		121,
		122,
		125,
		146,
		147,
		148,
		149,
		150,
		151,
		152,
		153,
		160,
	},
	[2] = 	--// DIRT
	{
		19,
		21,
		22,
		24,
		25,
		26,
		27,
		40,
		83,
		84,
		87,
		88,
		100,
		110,
		123,
		124,
		126,
		128,
		129,
		130,
		132,
		133,
		141,
		142,
		145,
		155,
		156,
	}
}


HelpTextTitles = {
	General = {
		Main = "eXo-Reallife";
		LoginRegister = "Login/Registration";
		Team = "Team";
	};
	Freizeit = {
		Kart = "Kartstrecke";
		Angeln = "Angeln";
		Boxhalle = "Boxhalle";
		Bars = "Bars";
		Pferdewetten = "Pferdewetten";
		Minispiele = "Minispiele";
	};
	Jobs = {
		BusDriver = "Job: Busfahrer";
		Farmer = "Job: Bauer";
		Logistician = "Job: Logistik";
		Lumberjack = "Job: Holzfäller";
		Mechanic = "Job: Mechaniker";
		Police = "Job: Polizist";
		RoadSweeper = "Job: Straßenkehrer";
		Trashman = "Job: Müllmann";
		ServiceTechnician = "Job: Service-Techniker";
		PizzaDelivery = "Job: Pizza-Lieferant";
		HeliTransport = "Job: Helikopter-Pilot";
		ForkLift = "Job: Gabelstapler-Fahrer";
		TreasureSeeker = "Job: Schatz Sucher";
	};
	Gameplay = {
		Cars = "Fahrzeuge";
		Beggar = "Gameplay: Bettler";
	};
	Minigames = {
		ZombieSurvival = "Minigame: Zombie Survival";
		GoJump = "Minigame: GoJump";
		SideSwipe = "Minigame: SideSwipe";
		SniperGame = "Minigame: Sniper Game";
		TCars = "Minigame: 2Cars";
	};
	Actions = {
		WeaponTruck = "Aktionen: Waffen-Truck";
		WeedTruck = "Aktionen: Weed-Truck";
		Bankrob = "Aktionen: Bank-Überfall";
		StateWeaponTruck = "Aktionen: Staats Waffen Truck";

	};
	Events = {
		Deathmatch = "Event: Deathmatch";
		DMRace = "Event: DM-Race";
		StreetRace = "Event: Street Race";
	};
	Credits = {
		OldVRPTeam = "vRP-Team";
		Other = "sonstige Credits";
	};
	Settings = {
		ShortMessageCTC = "Information - ShortMessage-CTC";
	};
}

HelpTexts = {
	General = {
		Main = [[
			eXo-Reallife ist ein Server-Projekt für die Multiplayer Modifikation Multi Theft Auto: San Andreas für GTA: San Andreas.
			Ziel des Projekts ist ein möglichst umfangreiches, neuartiges Rollenspiel zu schaffen.

			Wir befinden uns derzeit in der Alpha Testphase, was bedeutet, dass es momentan hauptsächlich darum geht,
			das richtige Balancing zu finden und fehlende Features auszumachen.
		]],
		LoginRegister = [[
			Dies ist das Login Fenster. Im Tab 'Login' kannst Du dich einloggen, im Tab 'Registrieren' demzufolge registrieren.
		]];
		Team = [[
			Entwicklung:
			[eXo]Stumpy
			Heisi
			StiviK
			Jusonex (kleinere Unterstüzung)
			Strobe
			PewX
			MegaThorx

			Projektleitung:
			[eXo]Stumpy
			Heisi

			stellv. Projektleitung:
			[eXo]Clausus
			[eXo]StiviK

			Servermanagement:
			[eXo]xXKing
			[eXo]Chris

			Administration:
			[eXo]Luka
			[eXo]John_Rambo
			[eXo]StrongVan

			Moderation:
			[eXo]Phil
			[eXo]High5
			[eXo]Gamer64

			Support:
			[eXo]Bonez
			[eXo]Janni_Morita
			[eXo]AfGun
			[eXo]Burmtim
			[eXo]Risi

			Informationen zum damaligen vRP-Team und Unterstützer unter "vRP-Team".
		]];

	};
	Freizeit = {
		Kart = [[
		Die Kartstrecke befindet sich in Montgomery (Reifen Blip auf der Karte). Du kannst dort auf täglich wechselnden
		Strecken dein Fahrkönnen unter Beweis stellen.
		Natürlich gibt es ein Highscore System für die schnellsten Runden.

		In den nächsten Updates wird zudem ein Ghostmode hinzugefügt um rauszufinden wo du deine Zeit liegen lässt.
		]];
		Angeln = [[
		Am Pier in Los Santos (am Riesenrad) gibt es mehrere Angeln um Meeresbewohner oder andere Gegenstände aus dem
		Wasser zu angeln. Je besser du auswirfst und einholst, desto wertvoller deine Beute.

		Verkaufe diese einfach an Angeler Lutz der direkt daneben seinen Stand aufgebaut hat!
		]];
		Boxhalle = [[
		Im Fitness-Center Los Santos kannst du andere Spieler zum Boxkampf herausfordern! Dabei könnt ihr einfach aus
		Spaß kämpfen oder aber einen Geldeinsatz vereinbaren.
		Du findest das Fitness-Center nahe der Green Bottle bar!

		Möge der stärkste Kämpfer gewinnen!
		]];
		Bars = [[
		Bars können von privaten Firma (Können in der Stadthalle gegründet werden) gekauft werden.
		Diese bieten den Angestellten der Firma viele Funktionen wie z.B die Verwaltung der Kasse
		(in der die Einnahmen gehen),das Abspielen von Musik oder das Engagieren von
		professionellen Tänzerinnen.

		Der perfekten Party steht damit nichts im Wege!
		]];
		Pferdewetten = [[
		Täglich um 20:00 Uhr findet das eXo-Pferderennen statt. Du kannst im Wettlokal (Pferd auf der Karte)
		einen gewünschten Geldbetrag auf das Pferd deiner Wahl setzen.

		Mit etwas Glück kannst du damit deinen Einsatz verdreifachen!
		]];
		Minispiele = [[
		Auf eXo-Reallife gibt es zahlreiche Minispiele die du teilweise alleine, teilweise mit anderen Usern
		spielen kannst.
		Klicke einen Spieler an und wähle "Spielen" im Klickmenü, dort gibt es eine Auswahl
		an Spielen zu denen du den Spieler herausfordern kannst.

		Unter anderem mit von der Partie sind Schach, Pong und Schere, Stein, Papier

		Weitere Spiele findest du im Casino. (Spielkarten Symbol auf der Karte)
		Dort findest du z.B. 2 Cars, Go-Jump oder SideSwipe.
		]];
	};
	Jobs = {
		BusDriver = [[
			Als Busfahrer musst du die Bürger von Los Santos von A nach B transportieren.
			Im Grunde musst du nur dem roten Marker mit dem grauen Dreieck folgen und
			kurz an den jeweiligen Bushaltestellen anhalten.

			Wenn du keine Lust mehr hast und dine Tour beenden willst,
			musst du nur aus dem Bus aussteigen und weglaufen.
		]];
		Farmer = [[
			Als Farmer hast du 3 Aufgaben: sähen, ernten und beliefern.
			Spawne zu Anfang im roten Marker einen Traktor um mit diesem auf dem Feld hinter dem Marker zu sähen.
			Anschließend spawnst du dir einen Mähdrescher, mit welchem du nun deine Ernte einholst.
			Anschließend holst du dir deinen kleinen Pick up Truck (ebenfalls im roten Marker) und
			belieferst den auf der Karte angezeigten Supermarkt ("Waypoint"-Blip).
		]];
		Logistician = [[
			Als Logistiker ist es dein Job, Container zum anderen Verladezentrum zu fahren.
			Dazu hast du einen DFT-300 zur Verfügung, den du dir am roten Marker erstellen kannst.
			Anschließend musst du unter den Ladekran fahren und warten bis der Container aufgeladen wurde.
			Dein Ziel wird dir auf der Karte markiert.
		]];
		Lumberjack = [[
			Als Holzfäller musst du die Bäume am Hügel (gelb markiert auf der Karte)
			fällen und sie zum Sägewerk fahren.
			Sofern du genug Bäume gefällt hast schnappst du dir einen Flatbed und fährst in den blauen Marker, neben welchem sich ein Haufen von Bäumen angesammelt hat (deine gefällten Bäume).
			Nun werden diese Bäume aufgeladen. Nachdem sie aufgeladen wurden musst du zum Sägewerk fahren (die rote Säge oder Punkt auf der Karte). Dort lieferst du sie ab.
		]];
		Mechanic = [[
			Als Mechaniker musst du die Autos deiner Mitbürger reparieren. Du reparierst sie, indem du auf das gewünschte Auto klickst und "reparieren" wählst.

			ACHTUNG: im Fahrzeug muss sich ein Fahrer befinden!
		]];
		Police = [[
			Als Polizist hast du die Aaufgabe die bösen Buben zu jagen.
			Mithilfe deines Schlagstocks kannst du sie in das Gefängnis befördern.
			Du kannst allerdings keine Wanteds verteilen, da diese automatisch vom System vergeben werden.
			Um die Wanteds deiner Mitspieler einzusehen musst du den Polizeicomputer (F2) öffnen.

			ACHTUNG: wenn dein Karma in den negativen Bereich fällt wirst du automatisch gefeuert!
		]];
		RoadSweeper = [[
			Als Straßenkehrer hast du die Aufgabe mithilfe der Kehrmaschine die Straßen von Los Santos sauberzuhalten.
			Laufe in den roten Marker und hole dir dein benötigtes Fahrzeug.
			Sofern du es hast kannst du nun losfahren und über den auf der Straße liegenden Müll fahren um ihn aufzukehren.
		]];
		HeliTransport = [[
			Du bist der Pilot eines Helikopters und musst Waren transportieren.
			Deinen Helikopter bekommst du beim roten Marker.
			Mit diesem begibst du dich dann zum markierten Ort an den LS-Docks, wo Waren auf dich warten.
			Lande darauf und fliege anschließend zum angegebenen Zielort!
		]];
		Trashman = [[
			Als Müllmann musst du mit deinem Müllwagen Abfalltonnen & Container abholen.
			Im roten Marker bekommst du dein benötigtes Fahrzeug.
			In den Straßen von Los Santos sind Mülltonnen verteilt, neben denen du halten musst.
			Fahre Anschließend zur Deponie zurück und lade deinen Müll in der Dump-Area aus.
		]];
		ServiceTechnician = [[Todo]];
		PizzaDelivery = [[
			Als Pizzalieferant hast du die Aufgabe die Ware des Pizza Stacks an die jeweiligen Orte zu liefern.
			Du erhälst deine Ware beim Pizza Stack ( Marker ) und lieferst Sie zum Ziel ( Ziel-Icon beim Radar ) ab.
			Desto schneller du dies schaffst, desto höher ist dein Bonus.
		]];
		ForkLift = [[
			Wenn du Gabelstaplerfahrer bist, kannst du mit deinem Forklift Kisten aufladen.
			Diese musst du anschließend bei den LKW's abliefern.
			Deinen Forklift kannst du dir am roten Marker erstellen.
		]];
		TreasureSeeker = [[
			Als Schatzsucher fährst du hinaus aufs Meer um den Grund des Meeres nach Wertgegenständen
			abzusuchen. Anschließend hebst du diese in dein Schiff und entlädst sie am Hafen!

			Drücke 'Leertaste' um den "Schatz" aufzunehmen.
		]]
	};
	Events = {
		Deathmatch = [[
		In diesem Event geht es darum, die anderen Teilnehmer mit Waffengewalt zu eliminieren. Wer die meisten Spieler
		eleminiert gewinnt. ]];
		DMRace = [[
		Der von Race Servern bekannte Gamemode mit DM Maps.
		Ziel ist es, das Ziel vor allen anderen zu erreichen während sich auf dem Weg viele Hindernisse befinden.
		Einmal ein kaputtes Auto führt und du hast verloren.]];
		StreetRace = [[
		Dieses Event ist ein Sprint-Rennen, welches gewonnen werden kann, indem als Erster das Ziel erreicht wird.
		]];
	};
	Gameplay = {
		Cars = [[
			Fahrzeuge können in folgende Kategorien unterteilt werden.

			Leihfahrzeuge:
			Du kannst Fahrzeuge an bestimmten Stellen wie zB. dem Krankenhaus oder der Stadthalle ausleihen.
			Hierzu musst du lediglich in den blauen Marker vor dem Fahrzeugverleih-NPC treten und das
			auszuleihende Fahrzeug auswählen.

			Private Fahrzeuge:
			Private Fahrzeuge kannst du an Autohäusern oder durch Handel mit anderen Usern erwerben. Autohäuser
			sind auf der Karte mit einem Auto-Blip markiert.
			Du bist selbst verantwortlich für den Zustand des Fahrzeuges und musst es ggf. reparieren, betanken.
			Unter F2 kann das Fahrzeug kostenpflichtig respawnt werden, wobei ausgewählt werden kann ob es an der
			Parkposition oder, falls vorhanden, in deiner Garage respawnt werden soll. Sollte dein Fahrzeug einen
			Totalschaden erleiden, so musst du entweder selbst mit einem Reperaturset versuchen dein Fahrzeug
			zum Laufen zu bringen oder du verständigst das Mech&Tow, welches einen Mechaniker zur ersten Hilfe
			sendet.

			Fraktionsfahrzeuge:
			Fraktionsfahrzeuge sind wie im Namen erwähnt Eigentum der jeweiligen Fraktionen und ihr Zustand wird
			vom Fraktionsanführer verwaltet.

			Firmen-/Gangfahrzeuge:
			Du kannst falls du einen Firma oder eine Gang besitzt, deine privaten Fahrzeuge in den Bestand dieser aufnehmen.
			Drücke hierzu F2 und navigiere zu deinem Firmen-/Gangpanel. Unter dem Reiter Fahrzeuge findest du einen blauen
			Button, welcher dir erlaubt deine privaten Fahrzeuge zur Gang/Firma hinzuzufügen.
			]];
		Beggar = [[
			Wenn du einen Bettler antriffst, kann es passieren, dass dieser dich nach Geld fragt. Es liegt
			an dir ob du ihn ignorierst, bezahlst oder ausraubst. Bedenke jedoch, dass solche Aktionen einen
			Einfluss auf dein Karma haben.
		]];
	};
	Minigames = {
		ZombieSurvival = [[
			Kämpfe gegen Zombies bis zu deinem bitteren Tod! In der Area spawnen immer wieder gute Waffen,
			die du dringend für deinen Überlebenskampf brauchst!
		]];
		GoJump = [[
			Minigame: GoJump
		]];
		SideSwipe = [[
			Minigame: SideSwipe (Keine Highscores, da noch nicht fertig!)
		]];
		SniperGame = [[
			Erledige alle gespawnten Peds mit gezielten Kopfschüssen bevor sie die gelbe Linie übertreten!
		]];
		TCars = [[
			Steuere beide Autos mit den Tasten 'a' und 'd' oder Pfeilsten links, rechts. Weiche den Kästchen aus und sammel jeden Punkt.
		]];

	};
	Actions = {
		WeaponTruck = [[
			Wählt die Waffen die ihr benötigt aus und ladet diese auf den Truck.
			Fahrt nun mit dem Truck zu eurer Base und versucht die Kisten abzugeben.
			Die Cops werden versuchen euren Truck zu zerstören. Falls ihnen das gelingt, könnt ihr
			eure Kisten mit einem kleinem Lieferwagen aus eurer Base weitertransportieren.
		]];
		StateWeaponTruck = [[
			Wählt die Waffen die ihr benötigt aus und ladet diese auf den Staatswaffentruck.
			Fahrt nun den Truck vor die FBI-Base und versucht die Kisten abzugeben.
			Die Bösen Fraktionisten werden versuchen den SWT zu zerstören.
			Falls ihnen das gelingt, könnt ihr die Waffen mit einem Enforcer vom LSPD weitertransportieren.
		]];
		WeedTruck = [[
			Dieser illegale Transport versorgt eure Fraktion mit Drogen (Cannabis). Gegen eine Bezahlung von 10000$
			erhaltet ihr den Truck. Er wird beladen und anschließend bereit gestellt. Fahrt zu eurem Versteck um ihn
			dann zu entladen!
		]];
		Bankrob = [[
		Nachdem ihr den Kassierer mit einer Waffe bedroht oder ein Loch in die Wand gesprengt habt, müsst ihr
		zum Kontrollraum laufen und die Tresortür knacken. Außerdem könnt ihr dort den Alarm ausschalten.
		Sobald der Tresorraum offen ist, knackt einen Safe in dem ihr auf einen klickst. Nach einem weiteren
		Klick nehmt ihr das Geld aus ihm heraus. Die Taschen auf dem Boden füllen sich mit Geld. Wenn ihr genug habt,
		oder der Tresorraum leer ist, könnt ihr die Taschen via. Klicksystem auf den Rücken schnallen.
		Lauft zum Boxville um die Ecke und ladet durch einen klick auf ihn die Taschen ein.
		Fahrt nun schnell zu einem der Abgabepunkte!
		]];
	};
	Credits = {
		OldVRPTeam = [[
			Dies ist das ehemalige Team des vRP-Gamemodes, die uns freundlicherweise den Gamemode überlassen haben.

			Entwicklung und Administration:
			Jusonex
			sbx320
			Revelse
			StiviK

			Administration:
			Doneasty (außerdem Grafik und Design)

			Moderation:
			Sarcasm (außerdem Webauftritt)
			Johnny (außerdem Mapping)
			Toxsi (außerdem Mapping)

			Vielen Dank an:
			Sam@ke (für seine wunderschönen Shader)
			thefleshpound (für seine Zeit als Grafiker)
			Schlumpf (für seine kurze Zeit als Mapper)
			ReZ (für seine kurze Zeit als Mapper)
			Alex (für seine Zeit als Mapper)
			Audifire (für das Verteilen von Müll)
			Poof (für das Schreiben von Hilfetexten)

			Alpha-Tester:
			Gibaex
		]];
		Other = [[
			Wir danken folgenden Personen/Teams für zur Verfügung gestellte Scripts:

			dem iLife-Team für:
			Slotmaschinen
			Zug

			Bonus für
			Anti c-Bug
			realdriveby
		]];
	};
	Settings = {
		ShortMessageCTC = "ShortMessage-CTC (Click-to-Close) ist eine Option mit der eingestellt werden kann, ob eine ShortMessage-Box (wie diese) durch ein einfaches klicken geschlossen werden kann oder nur durch den Timeout.\n\nNote: Callback-clicks are always working!";
	};
};

Tipps = {
	{"", "Schon ein paar eXo-Points bekommen? Nein? Dann suche auf der Karte nach schwebenden eXo Logos oder bekomme Archievements! Mithilfe der eXo-Points kannst du dir diverse Premiumdinge holen oder sie in XP eintauschen."};
	{"wie ändere ich mein Karma", "Um auf die gute Seite zu wechseln kannst du a.) gute Taten vollbringen oder b.) ein paar deiner gesammelten XP in Karmapunkte eintauschen. Wenn dein Karma im positiven Bereich ist kannst du dich als Polizist versuchen und weiter positives Karma sammeln. Wenn du auf die böse Seite wechseln willst musst du im Grunde nur böses tun. Raube Läden aus, überfalle Leute und lebe ein Gangsterleben."};
	{"wie komme ich in eine Gang", "Um in eine Gang zu kommen muss der Gangboss dir eine Einladung senden. Diese wird dir auf dein Handy (Hotkey 'U') geschickt. Du findest sie in der Dashboard App."};
	{"wie gründe ich eine Gang", "Um eine Gang zu gründen brauchst du a.) reichlich XP und b.) ein großes Vermögen, denn die Gründung kostet 100.000$! Du kannst sie im Self-Menü unter 'Firma / Gang' gründen. Als Boss hast du Rang 2 und kannst die Ränge nach belieben verwalten. Natürlich kannst du die Firma/Gang jederzeit verlassen und/oder löschen."};
	{"wo parke ich meine Autos", "Das Garagensymbol auf der Map zeigt dir die Standorte für die Garagen. Anfangs hast du eine Garage mit 3 Standplätzen. Diese Garage kannst du jederzeit unter 'Fahrzeuge' gegen Geld upgraden. Übrigens kannst du nur in der Garage geparkte Fahrzeuge respawnen!"};
	{"welche Jobs eignen sich für den Anfang", "Anfangs stehen dir durch dein geringes Level wenige Jobs zur Auswahl. Du kannst anfangs nur den Kehrmaschinen und den Farmerjob machen. Je nachdem wieviel XP du hast stehen dir weitere Jobs wie der Holzfäller oder der Müllfahrer zur Auswahl."};
	{"wie erreiche ich das Team", "Um das Team zu erreichen kannst du das Support System auf dem Hotkey 'hierderkrassehotkey' öffnen und ein Ticket schreiben."};
	{"was macht man als Gang", "Als Firma / Gang mit positivem Durchschnittskarma kann man besipielsweise auf Verbecherjagd gehen (sofern man Polizist ist). Mit negativem Karma kann man diverse Raubüberfälle auf Läden, Häuser oder Banken starten, Ganggebiete erobern, seine 'Brüder' aus dem Knast holen, mit Drogen dealen und die Stadt nach und nach erobern."};
}

SkinShops = {
	{
		Marker = Vector3(218.2, -98.5, 1004.3);
		MarkerInt = 15;
		PlayerPos = Vector3(217.922, -98.563, 1005.258);
		PlayerRot = Vector3(0.000, 0.000, 299);
		CameraMatrix = {216.056396484375, -99.181800842285156, 1006.8388061523437, 216.90571594238281, -98.900047302246094, 1006.3923950195312, 0, 70}
	};
	{
		Marker = Vector3(177.179, -86.714, 1000.805);
		MarkerInt = 18;
		PlayerPos = Vector3(181.724, -88.541, 1002.023);
		PlayerRot = Vector3(0.000, 0.000, 90);
		CameraMatrix = {177.40980529785, -87.031700134277, 1003.7614746094, 178.3257598877, -87.35213470459, 1003.5198974609, 0, 70}
	};
}

SHADERS = {
	["SkyBox"] = {["event"] = "switchSkyBox" },
	["Detail"] = {["event"] = "switchDetail" },
	["Contrast"] = {["event"] = "switchContrast" },
	["Carpaint"] = {["event"] = "switchCarPaint" },
	["Roadshine"] = {["event"] = "switchRoadshine" },
	["Water"] = {["event"] = "switchWaterRefract" },
	["WetRoads"] = {["event"] = "switchWetRoads" },
	["Bloom"] = {["event"] = "switchBloom" },
	["Sun"] = {["event"] = "switchSunShader"},
	["DoF"] = {["event"] = "switchDoF"}
}


GUNBOX_CRATES = {
	createObject(2977, 1366.06, -1286.34, 12.4),
	createObject(2977, 2397.80, -1980.82, 12.4),
	createObject(2977, 1328.33, -1560.27, 12.6)
}

for i = 1,#GUNBOX_CRATES do
	setElementFrozen( GUNBOX_CRATES[i], true)
	setObjectBreakable( GUNBOX_CRATES[i], false)
end


AREA51_WARNING = createColCuboid( -32.87, 1667.50, 14.62, 450, 450,40)
addEventHandler("onClientColShapeHit",AREA51_WARNING,function(hE)
	if hE == localPlayer then
		if ShortMessage then
			if localPlayer:getFactionId() ~= 1 or localPlayer:getFactionId() ~= 2 then
				ShortMessage:new(_"Du betrittst ein militärisches Sperrgebiet! Sei vorsichtig!")
			end
		end
	end
end)

NOTIFICATION_TYPE_INVATION = 1
NOTIFICATION_TYPE_GAME     = 2
