# Hunting Economy & Fear System

## Major Game Changes

This update adds **economic pressure** and **risk mechanics** to hunting, making it a challenging resource management system rather than a free money generator.

---

## 🎯 New Hunting Economy

### Starting Equipment
- **Bow**: Everyone starts with a bow (free, permanent)
- **10 Arrows**: Starting ammunition
- **No guns**: Rifle and shotgun must be purchased

### Limited Ammunition System
**Ammo is NO LONGER infinite!** You must buy ammunition to hunt:

| Item | Cost | Amount | Cost per Shot |
|------|------|--------|---------------|
| Arrows (Bow) | $15 | 10 | $1.50 |
| Bullets (Rifle) | $25 | 10 | $2.50 |
| Shells (Shotgun) | $30 | 10 | $3.00 |

**Key Mechanic:** 
- Ammo loads from your inventory when entering hunting mode
- Unused ammo returns to inventory when exiting
- Running out of ammo mid-hunt means you can't shoot!
- Must balance hunting costs vs hunting profits

---

## 💰 Weapon Purchase System

Weapons are **one-time purchases** that unlock permanently:

### 🏹 Bow (Starter)
- **Cost**: FREE (everyone has one)
- **Ammo**: $15 per 10 arrows
- **Reload**: 2.0 seconds
- **Range**: 300 pixels
- **Spread**: 5 pixels
- **Projectile**: Slow arrow (400 px/s)
- **Best for**: Beginners, cheap hunting

### 🔫 Rifle
- **Cost**: $200 (one-time purchase)
- **Ammo**: $25 per 10 bullets
- **Reload**: 0.5 seconds (fast!)
- **Range**: 600 pixels (long!)
- **Spread**: 2 pixels (accurate!)
- **Projectile**: Instant hitscan
- **Best for**: Precision hunters, fast kills

### 🔫 Shotgun
- **Cost**: $350 (one-time purchase)
- **Ammo**: $30 per 10 shells
- **Reload**: 1.5 seconds
- **Range**: 200 pixels (short)
- **Spread**: 30 pixels (wide!)
- **Projectile**: Instant hitscan
- **Best for**: Close range, guaranteed hits

---

## 🐅 Tiger Fear Mechanic

**NEW DANGER:** Tigers are too dangerous to hunt!

### How It Works
1. Tiger has **5% spawn chance** (rare but possible)
2. When tiger spawns, you **instantly flee** in fear
3. Hunting session **ends immediately**
4. You lose any progress in that session
5. Any ammo used is **gone** (not refunded)

### Why This Matters
- **Risk vs Reward**: Stay longer to hunt more, but risk tiger encounter
- **Economic Loss**: Wasted ammo costs money
- **Time Pressure**: Hunt efficiently before tiger appears
- **Strategic Exits**: Consider leaving early if you've had good hunts

### Tiger Warning
```
🐅 TIGER APPEARS! You flee in fear!
⚠️  You were too scared to hunt and ran away!
```

---

## 📊 Profit Analysis

### Cost-Benefit Breakdown

**Bow Hunting (Cheap, Safe Start)**
```
Investment: $15 (10 arrows)
Rabbit: Sells for $15-30 meat → Profit: $0-15 per kill
Deer: Sells for $60-120 meat → Profit: $45-105 per kill
Boar: Sells for $150-200 meat → Profit: $135-185 per kill
Break-even: 1 rabbit kill
Good hunt: 5 kills = $100+ profit
```

**Rifle Hunting (Expensive, High Efficiency)**
```
Investment: $200 (rifle) + $25 (10 bullets) = $225
First hunt needs: 8 rabbit kills to break even on rifle
After rifle paid off: $25 ammo, fast reload, instant hit
Break-even: 1 deer kill per ammo pack
Good hunt: 5 kills = $200+ profit
```

**Shotgun Hunting (Most Expensive, Guaranteed Hits)**
```
Investment: $350 (shotgun) + $30 (10 shells) = $380
First hunt needs: 13 rabbit kills to break even
After shotgun paid off: $30 ammo, wide spread, close range
Break-even: 1 deer kill per ammo pack
Good hunt: Wide spread makes hitting easier
```

### Economic Pressure
- **Early game**: Stick with bow, can't afford guns
- **Mid game**: Save up for rifle ($200), hunt more efficiently
- **Late game**: Buy shotgun ($350), never miss shots
- **Ammo cost**: Every shot costs money, accuracy matters!
- **Tiger risk**: Longer hunts = more profit BUT more tiger risk

---

## 🎮 Gameplay Loop

### Hunting Session Flow
```
1. Press ENTER to enter hunting
   ↓
2. Game checks: Do you own a weapon?
   ↓ (NO) → Exit: "Buy a weapon from shop"
   ↓ (YES)
3. Game checks: Do you have ammo?
   ↓ (NO) → Exit: "Buy ammo from shop"
   ↓ (YES)
4. Load all ammo from inventory
   ↓
5. Hunt animals (3 minute timer)
   ↓
6. Animals spawn randomly
   ↓ (Tiger spawns) → INSTANT EXIT (fear)
   ↓ (No tiger)
7. Shoot and collect meat
   ↓
8. Exit hunting (ENTER/ESC or timer ends)
   ↓
9. Unused ammo returns to inventory
   ↓
10. Sell meat at shop for profit
```

### Weapon Switching (1/2/3 Keys)
```
Press 1: Bow
  ↓ Check: Do you own bow? (Everyone does)
  ↓ Result: Switch to bow

Press 2: Rifle
  ↓ Check: Do you own rifle?
  ↓ (NO) → Message: "Buy rifle from shop ($200)"
  ↓ (YES) → Check: Do you have bullets?
  ↓ (NO) → Message: "Buy bullets from shop"
  ↓ (YES) → Switch to rifle

Press 3: Shotgun
  ↓ Check: Do you own shotgun?
  ↓ (NO) → Message: "Buy shotgun from shop ($350)"
  ↓ (YES) → Check: Do you have shells?
  ↓ (NO) → Message: "Buy shells from shop"
  ↓ (YES) → Switch to shotgun
```

---

## 🛒 Shop Updates

### New Items Available
```
📦 HUNTING SUPPLIES
├─ Arrows (10x) ............ $15
├─ Rifle ................... $200 (one-time)
├─ Bullets (10x) ........... $25
├─ Shotgun ................. $350 (one-time)
└─ Shells (10x) ............ $30

💰 SELL PRICES (unchanged)
├─ Rabbit Meat ............. $15 each
├─ Deer Meat ............... $30 each
├─ Boar Meat ............... $50 each
└─ Tiger Meat .............. $100 each (can't hunt!)
```

---

## 🎯 Strategic Tips

### Early Game (Starting with $30)
1. **Use your 10 starting arrows wisely**
2. **Hunt rabbits/deer (safe, common)**
3. **Sell meat immediately** for $15-60
4. **Buy more arrows** ($15) with profits
5. **Avoid wasting shots** - accuracy is profit!

### Mid Game ($200+ saved)
1. **Buy rifle** ($200) for efficiency
2. **Fast reload** = more kills per session
3. **Instant hitscan** = better accuracy
4. **Hunt deer/boar** for bigger profits
5. **Tiger risk increases** with longer sessions

### Late Game ($350+ saved)
1. **Buy shotgun** ($350) for guaranteed hits
2. **Wide spread** = hard to miss
3. **Hunt boar** (high profit, easier to hit)
4. **Multiple weapons** = switch based on ammo
5. **Calculate ammo costs** vs expected profits

### Risk Management
- **Short sessions**: Less profit, safer (low tiger risk)
- **Long sessions**: More profit, riskier (high tiger risk)
- **Ammo tracking**: Don't run out mid-hunt
- **Weapon choice**: Match weapon to target type
- **Exit timing**: Leave before timer ends to save ammo

---

## ⚠️ Common Mistakes

### ❌ Don't Do This
- **Spray and pray**: Wasting ammo = wasting money
- **Hunting without ammo check**: Will be kicked out
- **Overstaying timer**: Risk tiger encounter
- **Buying expensive guns early**: Can't afford ammo
- **Ignoring ammo costs**: Every shot has a price

### ✅ Do This
- **Aim carefully**: Each shot costs money
- **Buy ammo in bulk**: Stock up before long sessions
- **Track your spending**: Know your break-even point
- **Exit strategically**: Don't get greedy
- **Upgrade progressively**: Bow → Rifle → Shotgun

---

## 📈 Progression Path

### Beginner ($0-200)
- Weapon: **Bow only**
- Ammo: **$15 per hunt** (10 arrows)
- Targets: **Rabbits and deer**
- Profit: **$50-100 per session**
- Goal: **Save $200 for rifle**

### Intermediate ($200-500)
- Weapon: **Bow + Rifle**
- Ammo: **$25 per hunt** (rifle bullets)
- Targets: **Deer and boar**
- Profit: **$150-300 per session**
- Goal: **Save $350 for shotgun**

### Advanced ($500+)
- Weapon: **All three**
- Ammo: **Mix based on availability**
- Targets: **Boar for max profit**
- Profit: **$300-500 per session**
- Goal: **Maximize efficiency**

---

## 🔧 Technical Implementation

### Player Inventory Changes
```lua
-- Starting inventory now includes:
player.addItem("bow_weapon", 1)  -- Bow (permanent)
player.addItem("arrows", 10)      -- Starting ammo
```

### Weapon Ownership Check
```lua
-- Must own weapon to use it
if playerEntity.hasItem("rifle_weapon") then
    -- Can switch to rifle
else
    print("Buy rifle from shop first!")
end
```

### Ammo Loading System
```lua
-- Load ammo from inventory on enter
hunting.ammo.bow = playerEntity.getItemCount("arrows")
hunting.ammo.rifle = playerEntity.getItemCount("bullets")
hunting.ammo.shotgun = playerEntity.getItemCount("shells")

-- Return unused ammo on exit
playerEntity.addItem("arrows", hunting.ammo.bow)
```

### Tiger Fear System
```lua
if chosenType == "tiger" then
    print("🐅 TIGER APPEARS! You flee in fear!")
    hunting:exitHunting()  -- Instant exit
    return
end
```

---

## 🎮 Player Experience

### Tension Created
- **Every shot matters** (costs money)
- **Stay too long** = tiger risk
- **Leave too early** = wasted ammo cost
- **Ammo runs out** = hunt ends (pressure!)
- **Bad accuracy** = loss of money

### Skill Rewards
- **Good aim** = more profit
- **Smart timing** = avoid tigers
- **Resource planning** = consistent income
- **Weapon choice** = match target to tool
- **Risk assessment** = when to push luck

---

This system transforms hunting from "free money" to a **high-risk, high-reward** minigame with meaningful economic choices!
