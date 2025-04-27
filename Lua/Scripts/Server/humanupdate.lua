--define afflictions for humanupdate
NTEYE.Afflictions = {

	--surgery afflictions
	sr_removedeyes = {},
	sr_heldlid = {},
	sr_poppedeye = {},
	sr_eyeconnector = {},
	sr_corneaincision = {},
	sr_emulsification = {},
	sr_eyedrops = {},
	sr_lasersurgery = {},
	--mechanical afflictions
	mc_deadeyes = {},
	mc_oneeye = {},
	mc_eyedamage = {
		update = function(c, i)
			if c.stats.stasis then
				return
			end
			c.afflictions[i].strength = NT.organDamageCalc(
				c,
				c.afflictions.mc_eyedamage.strength
					+ NTC.GetMultiplier(c.character, "eyedamagegain") * c.stats.neworgandamage
			)
		end,
	},
	mc_retinopathy = {},
	mc_cataract = {},
	mc_visionsickness = {},
	mc_mismatch = {},
	--eye type afflictions
	et_cyber = {},
	et_enhanced = {},
	et_plastic = {},
	et_crawler = {},
	et_mudraptor = {},
	et_watcher = {},
	et_husk = {},
	et_charybdis = {},
	et_latcher = {},
	et_terror = {},
	--lens afflictions
	et_medical = {},
	et_electrical = {},
	et_zoom = {},
	et_night = {},
	et_thermal = {},
}
