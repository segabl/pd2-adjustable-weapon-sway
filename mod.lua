local mod_path = ModPath
local settings = {
	horizontal_mul = 1,
	vertical_mul = 1,
	unified = false,
	stance_mul = {
		standard = 1,
		steelsight = 1,
		crouched = 1
	}
}
local settings_params = {
	horizontal_mul = { 
		priority = 4,
		min = -50,
		max = 50,
		step = 1
	},
	vertical_mul = { 
		priority = 3,
		min = -50,
		max = 50,
		step = 1
	},
	unified = { priority = 2 },
	stance_mul = {
		priority = 1,
		min = -1,
		max = 1,
		step = 0.05
	},
	standard = { priority = 3 },
	steelsight = { priority = 2 },
	crouched = { priority = 1 }
}
local builder = MenuBuilder:new("weapon_sway", settings, settings_params)

local function set_multipliers(playertweakdata)
	for weapon_name, stance_type in pairs(playertweakdata.stances) do
		for stance_name, stance in pairs(stance_type) do
			if stance.vel_overshot then
				stance.vel_overshot.yaw_neg_orig = stance.vel_overshot.yaw_neg_orig or stance.vel_overshot.yaw_neg
				stance.vel_overshot.yaw_pos_orig = stance.vel_overshot.yaw_pos_orig or stance.vel_overshot.yaw_pos
				stance.vel_overshot.pitch_neg_orig = stance.vel_overshot.pitch_neg_orig or stance.vel_overshot.pitch_neg
				stance.vel_overshot.pitch_pos_orig = stance.vel_overshot.pitch_pos_orig or stance.vel_overshot.pitch_pos

				local hmul = settings.horizontal_mul * (settings.stance_mul[stance_name] or settings.stance_mul.standard)
				local vmul = settings.vertical_mul * (settings.stance_mul[stance_name] or settings.stance_mul.standard)
				if settings.unified then
					stance.vel_overshot.yaw_neg = hmul
					stance.vel_overshot.yaw_pos = -hmul
					stance.vel_overshot.pitch_neg = -vmul
					stance.vel_overshot.pitch_pos = vmul
				else
					stance.vel_overshot.yaw_neg = stance.vel_overshot.yaw_neg_orig and stance.vel_overshot.yaw_neg_orig * hmul
					stance.vel_overshot.yaw_pos = stance.vel_overshot.yaw_pos_orig and stance.vel_overshot.yaw_pos_orig * hmul
					stance.vel_overshot.pitch_neg = stance.vel_overshot.pitch_neg_orig and stance.vel_overshot.pitch_neg_orig * vmul
					stance.vel_overshot.pitch_pos = stance.vel_overshot.pitch_pos_orig and stance.vel_overshot.pitch_pos_orig * vmul
				end
			end
		end
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitAdjustableWeaponSway", function (loc)
	HopLib:load_localization(mod_path .. "loc/", loc)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusPlayerWeaponSway", function (menu_manager, nodes)
	builder:create_menu(nodes)
end)

Hooks:PostHook(PlayerTweakData, "init", "init_sway", set_multipliers)
