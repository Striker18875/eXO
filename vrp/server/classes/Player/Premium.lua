-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Premium.lua
-- *  PURPOSE:     Premium class
-- *
-- ****************************************************************************
Premium = inherit(Object)
inherit(DatabasePlayer, Premium)

function Premium:constructor()
	local row = sqlPremium:asyncQueryFetchSingle("SELECT * FROM user WHERE Name LIKE ?", self:getName()) -- Todo change to ID
	if row then
		self.m_Premium = toboolean(row.premium)
		self.m_PremiumUntil = row.premium_bis
	else
		self.m_Premium = false
		self.m_PremiumUntil = 0
	end
	self:setPublicSync("Premium", self.m_Premium)

	if self.m_Premium then
		if self:getRank() > 0 then
			self:setPublicSync("DeathTime", DEATH_TIME_PREMIUM)
		end
		setTimer(function()
			self:sendShortMessage(_([[
			Dein Premiumaccount ist gültig
			bis %s
			]], self, getOpticalTimestamp(self.m_PremiumUntil)), _("Premium", self), {50, 200, 255})
		end, 1500, 1)
	end
end

function Premium:isPremium()
	return self.m_Premium
end
