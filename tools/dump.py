"""dump.py <spell id> [more ids...]

Mechanical dump of spells from Spell.csv: school, effect types, aura types, values,
radius, tick interval, and the spells they trigger (followed recursively). Use it to
write a description for a spell that has no tooltip text. Read-only.
"""
import csv, os, sys
READER = os.environ.get("SPELL_READER", r"C:\Users\Leon_\Desktop\Wow stuff\Spell.csv reader")
sys.path.insert(0, READER)
import gen_custom_spell_tooltips as g
C = os.path.join(READER, "CSV's")
durs = g.load_durations(os.path.join(C, "SpellDuration.csv"))
radii = g.load_radii(os.path.join(C, "SpellRadius.csv"))
SCHOOL = "Physical Holy Fire Nature Frost Shadow Arcane".split()
EFF = {1: "InstaKill", 2: "SchoolDamage", 3: "Dummy", 5: "Teleport", 6: "ApplyAura", 7: "EnvDamage", 8: "PowerDrain",
       9: "HealthLeech", 10: "Heal", 16: "QuestComplete", 17: "WeaponDmgNoSchool", 24: "CreateItem", 27: "PersistentAreaAura",
       28: "Summon", 29: "Leap", 30: "Energize", 31: "WeaponPctDmg", 35: "ApplyAreaAuraParty", 36: "LearnSpell", 38: "Dispel",
       41: "SummonWild", 42: "SummonGuardian", 53: "EnchantItem", 58: "WeaponDamage", 62: "PowerBurn", 63: "Threat",
       64: "TriggerSpell", 67: "HealMaxHealth", 68: "InterruptCast", 74: "SummonTotem? ", 77: "ScriptEffect",
       85: "SummonDemon?", 87: "SummonObjSlot1", 96: "Charge", 98: "KnockBack", 101: "FeedPet", 113: "ResurrectNew",
       121: "NormalizedWeaponDmg", 125: "ModifyThreatPercent", 126: "StealBeneficialBuff", 76: "SummonObjectWild",
       33: "OpenLock", 34: "SummonChangeItem", 45: "AddHonor", 48: "Stealth", 50: "TransDoor", 56: "SummonPet",
       80: "AddComboPoints", 90: "KillCreditPersonal", 99: "DisenchantItem", 104: "SummonObjSlot1", 124: "PullTowards"}
AURA = {3: "PeriodicDamage", 4: "Dummy", 5: "Confuse", 7: "Fear", 8: "PeriodicHeal", 9: "ModAttackSpeed", 10: "ModThreat",
        12: "Stun", 13: "ModDamageDone", 14: "ModDamageTaken", 15: "DamageShield", 18: "Invisibility", 20: "ObsModHealth",
        22: "ModResistance(armor=1)", 23: "PeriodicTriggerSpell", 24: "PeriodicEnergize", 25: "Pacify", 26: "Root",
        27: "Silence", 29: "ModStat", 31: "IncreaseSpeed", 33: "DecreaseSpeed", 34: "IncreaseHealth", 36: "Shapeshift",
        39: "SchoolImmunity", 42: "ProcTriggerSpell", 43: "ProcTriggerDamage", 47: "ModParry", 49: "ModDodge",
        52: "ModCrit", 53: "PeriodicLeech", 54: "ModHitChance", 56: "Transform", 60: "PacifySilence", 61: "ModScale",
        62: "HealthFunnel", 64: "PeriodicManaLeech", 65: "ModCastingSpeed", 67: "Disarm", 69: "SchoolAbsorb",
        77: "MechanicImmunity", 79: "ModDamagePercentDone", 80: "ModPercentStat", 84: "ModRegen", 85: "ModPowerRegen",
        87: "ModDamagePercentTaken", 89: "PeriodicDamagePercent", 94: "InterruptRegen", 99: "ModAttackPower",
        101: "ModResistancePct", 103: "ModTotalThreat", 115: "ModHealing", 118: "ModHealingPct", 122: "ModOffhandDmgPct",
        133: "IncreaseHealthPct", 136: "ModHealingDonePct", 137: "ModTotalStatPct", 138: "ModMeleeHaste",
        140: "ModRangedHaste", 142: "ModBaseResistancePct"}

want = [int(a) for a in sys.argv[1:]]
rows = {}
for r in csv.reader(open(os.path.join(C, "Spell.csv"), encoding="utf-8")):
    if r and r[0].isdigit():
        rows[int(r[0])] = r


def col(r, i):
    s = 0
    for k in range(120, 126):
        if r[k] and not g.NUM_RE.match(r[k]):
            s = k - 120
            break
    j = i + (s if i >= 70 else 0)
    return r[j] if j < len(r) else ""


def show(sid, depth=0, seen=None):
    seen = seen if seen is not None else set()
    if sid in seen or sid not in rows:
        return
    seen.add(sid)
    r = rows[sid]
    ind = "    " * depth
    dur = durs.get(g._int(col(r, 30)), (None,))[0]
    print(f"{ind}{sid} {col(r, 120)} [{SCHOOL[int(r[1])] if r[1].isdigit() and int(r[1]) < 7 else r[1]}] dur={dur}ms cd={r[20]} stacks={col(r, 39)} desc={col(r, 138)[:80]!r}")
    for e in range(3):
        et = g._int(r[61 + e])
        if not et:
            continue
        bp, die = g._int(col(r, 76 + e)), g._int(col(r, 64 + e))
        val = f"{bp + 1}" if die <= 1 else f"{bp + 1}..{bp + die}"
        au = g._int(col(r, 91 + e))
        rad = radii.get(g._int(col(r, 88 + e)))
        amp = g._int(col(r, 94 + e))
        trig = g._int(col(r, 109 + e))
        misc = col(r, 103 + e)
        print(f"{ind}  e{e+1} {EFF.get(et, et)}" + (f" aura={AURA.get(au, au)}" if au else "") + f" value={val}"
              + (f" radius={rad}yd" if rad else "") + (f" tick={amp}ms" if amp else "")
              + (f" chain={col(r, 100 + e)}" if col(r, 100 + e) not in ("0", "") else "")
              + (f" misc={misc}" if misc not in ("0", "0x0", "") else "") + (f" trig={trig}" if trig else ""))
        if trig:
            show(trig, depth + 1, seen)


for s in want:
    show(s)
    print()
