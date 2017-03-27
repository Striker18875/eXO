-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Guns/Guns.lua
-- *  PURPOSE:     Server Gun Class
-- *
-- ****************************************************************************

Guns = inherit(Singleton)

function Guns:constructor()
	local weaponSkills = {"std","pro","poor"}

	for index,skill in pairs(weaponSkills) do
		-- Taser:
		setWeaponProperty (23, skill, "weapon_range", 10 )
		setWeaponProperty (23, skill, "maximum_clip_ammo", 9999 )
		setWeaponProperty (23, skill, "anim_loop_stop", 0 )
	end

	addRemoteEvents{"onTaser", "onClientDamage", "onClientKill", "onClientWasted", "gunsLogMeleeDamage"}
	addEventHandler("onTaser", root, bind(self.Event_onTaser, self))
	addEventHandler("onClientDamage", root, bind(self.Event_onClientDamage, self))
	addEventHandler("gunsLogMeleeDamage", root, bind(self.Event_logMeleeDamage, self))
	addEventHandler("onPlayerWeaponSwitch", root, bind(self.Event_WeaponSwitch, self))

end


function Guns:destructor()

end

function Guns:Event_WeaponSwitch( pw, cw) --// sync bug fix "schlagbug"
	local slot = getSlotFromWeapon(cw)
	if slot >= 2 and slot <= 6 then
		giveWeapon(source, cw, 0)
	end
end

function Guns:Event_onTaser(target)
	if client.vehicle or target.vehicle then return end
	client:giveAchievement(65)

	target:setAnimation("crack", "crckdeth2",-1,true,true,false)
	toggleAllControls(target,false)
	target:sendInfo(_("Du wurdest von %s getazert!", target, client:getName()))
	target.isTasered = true
	setElementData(target, "isTasered", true)
	setTimer ( function(target)
		setElementData(target, "isTasered", false)
		target:setAnimation()
		target:setFrozen(false)
		toggleAllControls(target,true)
		target.isTasered = false
	end, 15000, 1, target )
end

function Guns:Event_onClientDamage(target, weapon, bodypart, loss)
	local attacker = client
	if weapon == 34 and bodypart == 9 then
		if not target.m_SupMode and not attacker.m_SupMode then
			target:triggerEvent("clientBloodScreen")
			target:setHeadless(true)
			StatisticsLogger:getSingleton():addKillLog(attacker, target, weapon)
			target:kill(attacker, weapon, bodypart)
		end
	else
		if not target.m_SupMode and not attacker.m_SupMode then
			target:triggerEvent("clientBloodScreen")
			local basicDamage = WEAPON_DAMAGE[weapon]
			local multiplier = DAMAGE_MULTIPLIER[bodypart] and DAMAGE_MULTIPLIER[bodypart] or 1
			local realLoss = basicDamage*multiplier
			self:damagePlayer(target, realLoss, attacker, weapon, bodypart)
		end
	end
end

function Guns:Event_logMeleeDamage(target, weapon, bodypart, loss)
	StatisticsLogger:getSingleton():addDamageLog(client, target, weapon, bodypart, loss)
end

function Guns:Event_onClientKill(kill, weapon, bodypart, loss)

end


function Guns:damagePlayer(player, loss, attacker, weapon, bodypart)
	local armor = getPedArmor ( player )
	local health = getElementHealth ( player )
	if armor > 0 then
		if armor >= loss then
			player:setArmor(armor-loss)
		else
			loss = math.abs(armor-loss)
			player:setArmor(0)

			if health - loss <= 0 then
				StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
				if not player:getData("isInDeathMatch") then
					player:setReviveWeapons()
				end
				player:kill(attacker, weapon, bodypart)
			else
				player:setHealth(health-loss)
			end
		end
	else
		if player:getHealth()-loss <= 0 then
			StatisticsLogger:getSingleton():addKillLog(attacker, player, weapon)
			if not player:getData("isInDeathMatch") then
				player:setReviveWeapons()
			end
			player:kill(attacker, weapon, bodypart)
		else
			player:setHealth(health-loss)
		end
	end
	StatisticsLogger:getSingleton():addDamageLog(attacker, player, weapon, bodypart, loss)
	--StatisticsLogger:getSingleton():addTextLog("damage", ("%s wurde von %s mit Waffe %s am %s getroffen! (Damage: %d)"):format(player:getName(), attacker:getName(), WEAPON_NAMES[weapon], BODYPART_NAMES[bodypart], loss))
end
