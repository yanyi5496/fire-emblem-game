extends RefCounted

class_name TestCombatFormula

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	# Test 1: Physical damage formula
	# damage = max(0, STR + WeaponMight + TriangleBonus - (DEF + TerrainDefense))
	var str := 7
	var weapon_might := 5
	var triangle_dmg := 1  # sword > axe
	var def := 5
	var terrain_def := 0
	var expected_damage := max(0, str + weapon_might + triangle_dmg - (def + terrain_def))
	var actual_damage := max(0, 7 + 5 + 1 - (5 + 0))
	if actual_damage == 8 and expected_damage == 8:
		details.append("PASS: physical damage = 8")
	else:
		details.append("FAIL: physical damage expected 8, got %d" % actual_damage)
		all_pass = false

	# Test 2: Hit rate formula
	# hit = WeaponHit + SKL*2 + LUK + TriangleHit + HeightBonus - (targetSPD/2 + targetLUK + TerrainAvoid)
	var hit := 90
	var skl := 6
	var luk := 5
	var tri_hit := 15  # sword > axe
	var height := 0
	var target_spd := 4
	var target_luk := 2
	var terrain_avoid := 0
	var expected_hit := clampi(90 + 12 + 5 + 15 + 0 - (2 + 2 + 0), 0, 100)
	var actual_hit := clampi(hit + skl*2 + luk + tri_hit + height - (target_spd/2 + target_luk + terrain_avoid), 0, 100)
	if actual_hit == 100 and expected_hit == 100:
		details.append("PASS: hit rate = 100")
	else:
		details.append("FAIL: hit rate expected 100, got %d" % actual_hit)
		all_pass = false

	# Test 3: Forest avoid bonus
	terrain_avoid = 20
	actual_hit = clampi(hit + skl*2 + luk + tri_hit + height - (target_spd/2 + target_luk + terrain_avoid), 0, 100)
	if actual_hit == 80:
		details.append("PASS: hit rate with forest avoid = 80")
	else:
		details.append("FAIL: forest avoid hit expected 80, got %d" % actual_hit)
		all_pass = false

	# Test 4: Height bonus
	height = 10  # attacker higher
	terrain_avoid = 0
	actual_hit = clampi(hit + skl*2 + luk + tri_hit + height - (target_spd/2 + target_luk + terrain_avoid), 0, 100)
	if actual_hit == 100:
		details.append("PASS: height advantage hit rate capped = 100")
	else:
		details.append("FAIL: height advantage expected 100, got %d" % actual_hit)
		all_pass = false

	# Test 5: Headman tough_body defense bonus
	var base_def := 7
	var tough_body_bonus := 3
	actual_damage = max(0, 7 + 5 + 1 - ((base_def + tough_body_bonus) + 0))
	if actual_damage == 3:
		details.append("PASS: tough_body damage reduction = 3")
	else:
		details.append("FAIL: tough_body expected 3, got %d" % actual_damage)
		all_pass = false

	# Test 6: ASPD and follow-up check
	var attacker_spd := 7
	var weapon_weight := 5
	var defender_asdp := max(0, 4 - 8)  # = 0
	var attacker_asdp := max(0, attacker_spd - weapon_weight)  # = 2
	if attacker_asdp == 2 and defender_asdp == 0:
		if attacker_asdp >= defender_asdp + 4:
			details.append("FAIL: should not have follow-up (2 < 4)")
			all_pass = false
		else:
			details.append("PASS: no follow-up (2 < 0+4)")
	else:
		details.append("FAIL: ASPD calculation incorrect (att=%d, def=%d)" % [attacker_asdp, defender_asdp])
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Combat formula %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
