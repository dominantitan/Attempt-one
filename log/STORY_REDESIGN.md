# Story Redesign - The Hunt for Revenge
**Date:** October 19, 2025  
**Status:** Concept/Design Phase

---

## 🎭 New Narrative Arc

### Opening Scene
**Current:** Player inherits uncle's cabin, starts farming/hunting life  
**NEW:** Player arrives at cabin and finds uncle **missing**

```
INTRO SEQUENCE:
1. Player arrives at remote forest's railway station then gets introduced to shopkeeper and goes to cabin
2. Door is open, signs of struggle
3. Blood trail leading into the forest
4. Player finds uncle's body near North Forest hunting zone
5. Claw marks, massive tiger prints
6. Uncle's dying words: "The beast... the tiger... run..."
7. Player inherits cabin with ZERO money (was $30)
```

### The Legendary Tiger
Not just another animal - **THE final boss**

**Lore:**
- Local legend - "The Hunter Killer"
- Massive scarred tiger that hunts humans
- Has killed multiple hunters over the years
- Uncle was tracking it when he was ambushed
- Other villagers warn player about revenge attempts
- Shopkeeper: "Your uncle tried... don't make the same mistake"

---

## 🎯 Two Ending Paths

### Path 1: ESCAPE 🚂
**Goal:** Earn enough money to buy train ticket and leave

**Requirements:**
- Accumulate $4500 (or higher amount - balance needed)
- Buy train ticket at railway station
- Leave the forest forever
- Uncle's death goes unavenged

**Gameplay:**
- Hunt smaller animals (rabbit, deer, boar)
- Sell pelts and meat at shop
- Farm crops for steady income
- Forage and sell rare herbs
- Avoid tiger encounters
- Focus on money grinding

**Ending:**
```
Player boards train with heavy heart
Uncle's grave left behind
Tiger still roams the forest
Haunted by not taking revenge
"Some beasts are better left alone..."
```

### Path 2: REVENGE 🐅
**Goal:** Hunt down and kill the legendary tiger

**Requirements:**
- Must have encountered tiger multiple times
- Need powerful weapons (rifle/shotgun)
- Stockpile ammunition (30+ bullets/shells)
- High risk - can die permanently
- Tiger fight in overworld (not hunting minigame)

**Gameplay:**
- Track tiger through hunting zones
- Learn its patterns and behaviors
- Upgrade weapons at shop
- Prepare for final confrontation
- Tiger appears in overworld when conditions met

**Ending (Victory):**
```
Tiger defeated, uncle avenged
Player becomes legendary hunter
Villagers celebrate "The Beast Slayer"
Can continue living in cabin
"The forest is finally safe..."
```

**Ending (Mercy):**
```
Tiger flees when HP < 10%
Player chooses to spare it
"Enough blood has been spilled..."
Uncle's spirit at peace
Tiger disappears forever
```

---

## 🎮 Final Boss Mechanics

### Tiger Encounter Trigger
**Not in hunting minigame - OVERWORLD BATTLE**

**Conditions to spawn:**
1. Player has killed 20+ animals in hunting (proves capability)
2. Player owns rifle OR shotgun (powerful enough)
3. Player has 30+ ammo for equipped weapon
4. Random spawn in overworld during dusk/night (time 0.7-0.9)
5. Dramatic warning: Screen shake, roar sound, "⚠️ THE TIGER APPROACHES"

### Boss Fight Mechanics

**Phase 1: Full Aggression (100% - 50% HP)**
- Tiger charges player at high speed (300 speed)
- Deals 25 damage per hit
- Player must shoot while dodging
- Roar attack: Slows player for 3 seconds
- Pounce attack: Leaps across screen

**Phase 2: Tactical (50% - 10% HP)**
- Tiger becomes more cautious
- Circles player, waits for openings
- Hit-and-run tactics
- Uses trees/bushes for cover
- Still dangerous but defensive

**Phase 3: Desperate Escape (< 10% HP)**
- Tiger tries to flee to map edge
- Speed DECREASES (wounded, 150 speed)
- Leaves blood trail
- Player can chase and finish it
- **OR let it escape - MERCY OPTION**

**Mercy Prompt:**
```
🐅 The tiger is fleeing, mortally wounded...
❤️  Press M to show mercy and let it go
🔫 Keep shooting to finish it
```

### Player Choice System

```lua
-- Pseudo-code for moral choice
if tiger.health < 10 and tiger.fleeing then
    showMercyPrompt = true
    
    if player.pressedM then
        -- MERCY ENDING
        tiger.escapes = true
        unlockEnding("Mercy")
        print("You lower your weapon...")
        print("The tiger disappears into the forest")
        print("Perhaps some cycles are meant to be broken")
    end
    
    if tiger.health <= 0 then
        -- REVENGE ENDING
        unlockEnding("Revenge")
        print("The tiger falls silent")
        print("Your uncle has been avenged")
        print("But at what cost?")
    end
end
```

---

## 💰 Economy Redesign

### Starting Conditions
**OLD:** $30, 10 arrows, 3 seeds, 2 water  
**NEW:** $0, 10 arrows, 3 seeds, 2 water, uncle's rifle (broken)

**Early Game Struggle:**
- Must hunt with bow only (harder)
- Sell first kills to afford seeds/water
- Very tight economy - every decision matters
- Can't afford rifle bullets until mid-game

### Train Ticket Pricing
**Escape Route Price:** $500 (or adjust based on testing)

**Income Breakdown:**
- Rabbit pelt: $8
- Deer pelt: $15
- Boar pelt: $25
- Tiger pelt: $200 (if revenge path chosen)
- Crops: $3-8 each
- Foraged items: $3-8 each

**Time to Escape:**
- ~25 successful hunts (mixed animals)
- ~70 crop harvests
- ~50 foraged items
- Realistically 3-5 in-game days of grinding

---

## 🗺️ Map Changes

### Uncle's Grave
New structure near North Forest hunting zone
- Small wooden cross
- Flowers player can place (optional)
- Interaction: "Uncle... I'm sorry"
- Updates dialogue based on player choices

### Train Station Enhancement
- NPC conductor appears when player has $500+
- Dialogue warns about leaving vs revenge
- "Your uncle mentioned a great beast... still out there"
- Ticket booth UI with confirmation

### Tiger Lair (Optional)
Hidden area in dense forest
- Only accessible after tiger spawns
- Contains uncle's belongings
- Clues about tiger's history
- Additional lore items

---

## 📊 Progression Tracking

### Game Flags
```lua
Game.story = {
    foundUncle = false,         -- Discovered uncle's body
    huntsCompleted = 0,         -- Track kill count
    tigerEncounters = 0,        -- Times tiger appeared in hunting
    hasPowerfulWeapon = false,  -- Owns rifle/shotgun
    readyForBoss = false,       -- All conditions met
    bossSpawned = false,        -- Tiger in overworld
    ending = nil,               -- "escape", "revenge", "mercy"
}
```

### Shopkeeper Dialogue Changes
**Early Game:**
- "Sorry about your uncle... terrible tragedy"
- "That tiger is still out there, be careful"

**Mid Game (10+ hunts):**
- "You're getting good... just like your uncle"
- "Don't get cocky - that beast is different"

**Late Game (ready for boss):**
- "I see that look in your eyes..."
- "Here, take these bullets. Make them count"
- (Gives 10 free rifle bullets)

### Death Consequences
**If player dies to boss tiger:**
- Permanent game over (or respawn at cabin?)
- Lose all progress towards either ending
- Tiger disappears, must rebuild conditions
- "You were not prepared..."

---

## 🎨 Visual/Audio Enhancements

### Cutscenes (Text-based for now)
1. **Opening:** Finding uncle's body
2. **Warning:** Shopkeeper's tale of the tiger
3. **Boss Spawn:** Tiger appears with dramatic flair
4. **Endings:** Different text based on choice

### Boss Fight Effects
- Screen shake during tiger attacks
- Slow-motion when HP < 10% (mercy decision)
- Red vignette when player is low HP
- Blood particles when tiger is hit
- Victory fanfare or somber music

### Atmospheric Changes
- Fog increases near boss spawn conditions
- Birds flee when tiger is near
- Eerie silence before encounter
- Thunder/lightning during fight (optional)

---

## 🔧 Technical Implementation Plan

### Phase 1: Story Framework (2 hours)
- [ ] Add Game.story table with flags
- [ ] Create intro sequence (text-based)
- [ ] Add uncle's grave structure
- [ ] Modify starting money to $0
- [ ] Update player.load() starting items

### Phase 2: Economy Rebalance (1 hour)
- [ ] Adjust animal pelt values
- [ ] Set train ticket price
- [ ] Add money tracking for escape route
- [ ] Create ticket purchase dialogue

### Phase 3: Boss Trigger System (2 hours)
- [ ] Track hunting kill count
- [ ] Check weapon/ammo requirements
- [ ] Boss spawn probability during dusk/night
- [ ] Warning messages before spawn

### Phase 4: Boss Fight Mechanics (4 hours)
- [ ] Tiger entity in overworld (not hunting state)
- [ ] Three-phase AI behavior
- [ ] Collision detection with player
- [ ] Health bar rendering
- [ ] Attack patterns and damage

### Phase 5: Moral Choice System (2 hours)
- [ ] Flee behavior at < 10% HP
- [ ] Mercy prompt UI
- [ ] M key to spare tiger
- [ ] Continue shooting to kill
- [ ] Different ending text

### Phase 6: Endings Implementation (2 hours)
- [ ] Escape ending (buy ticket)
- [ ] Revenge ending (kill tiger)
- [ ] Mercy ending (spare tiger)
- [ ] Credits or final screen
- [ ] Option to continue or restart

### Phase 7: Polish & Testing (2 hours)
- [ ] Balance tuning (prices, HP, damage)
- [ ] Playtest both paths
- [ ] Fix edge cases
- [ ] Add atmospheric effects

**TOTAL ESTIMATED TIME:** 15 hours (3-4 days of work)

---

## 🎯 Design Goals

### Emotional Impact
- Player feels loss of uncle
- Genuine choice between safety and revenge
- Moral weight of mercy decision
- Multiple valid endings

### Gameplay Balance
- Escape route: Safer but feels incomplete
- Revenge route: Dangerous but satisfying
- Mercy option: Unexpected third path
- No "correct" choice - player decides

### Replayability
- Try different ending paths
- Challenge: Can you beat tiger with bow only?
- Speedrun: Fastest escape time
- Pacifist: Never enter hunting, farm only

---

## 💭 Alternative Ideas

### Uncle Survives (Softer Version)
- Uncle is badly wounded, not dead
- Player must earn money for medicine ($300)
- OR hunt tiger for rare healing herb
- Uncle recovers based on player choice
- Less dark but still compelling

### Tiger Has Cubs
- After defeating tiger, find cubs
- Player must decide to kill or spare them
- Adds another moral dimension
- Cubs grow up if spared (time-skip?)

### Multiplayer Twist
- Co-op mode: Two players hunt tiger together
- One distracts while other shoots
- Shared ending decision
- (Future feature - much more work)

---

## 📝 Notes for Implementation

**Keep in Mind:**
- Don't break existing systems
- Hunting minigame still works for smaller animals
- Boss fight uses different code path
- Story is optional flavor - core gameplay intact
- Can still play "peaceful" if avoiding tiger

**Testing Checklist:**
- [ ] Can complete escape route
- [ ] Can trigger boss fight
- [ ] All three endings work
- [ ] No softlocks (stuck states)
- [ ] Economy balanced for both paths

**Player Feedback:**
- Clear objective from start
- Track progress (kill count, money)
- Warnings before boss spawns
- Obvious choice prompts

---

## 🎬 Conclusion

This redesign transforms the game from "peaceful forest sim" to **"revenge thriller with choice"**.

**Core Appeal:**
✅ Emotional hook (uncle's death)  
✅ Clear goals (escape vs revenge)  
✅ Player agency (meaningful choice)  
✅ Replayability (multiple endings)  
✅ Challenge escalation (boss fight)  
✅ Moral depth (mercy option)  

**Next Steps:**
1. Get player approval on concept
2. Start with Phase 1 (story framework)
3. Iterate based on playtesting
4. Polish and balance

---

**STATUS:** Awaiting approval to begin implementation 🚀
