# Ammo System Fix - Testing Guide

## ✅ What Was Fixed

### The Bug
Previously, ammo was being **added back** to inventory on exit, meaning:
- Enter hunt with 10 arrows
- Use 5 arrows (5 shots)
- Exit hunt → 5 arrows return to inventory
- **Next hunt**: Still have 5 arrows (should have 0!)
- This made ammo infinite!

### The Fix
Now ammo is **consumed on entry**:
- Enter hunt with 10 arrows → **Removed from inventory**
- Use 5 arrows (5 shots) → 5 arrows consumed
- Exit hunt → 5 remaining arrows return
- **Next hunt**: Have 5 arrows (correct!)
- Must buy more when you run out

---

## 🧪 How to Test

### Test 1: Basic Ammo Consumption
1. **Start game** → You have 10 arrows
2. Press **I** to check inventory (should show 10 arrows)
3. Press **ENTER** to enter hunting
4. **Shoot 3 times** (left-click 3 times)
5. Press **ENTER** to exit hunting
6. Press **I** to check inventory
   - ✅ **Should show 7 arrows** (10 - 3 = 7)
   - ❌ If it shows 10, bug still exists

### Test 2: Run Out of Ammo
1. Enter hunting with remaining arrows
2. **Shoot until you run out** (ammo reaches 0)
3. Exit hunting
4. Press **I** to check inventory
   - ✅ **Should show 0 arrows**
5. Try to enter hunting again (press ENTER)
   - ✅ **Should be blocked** with message: "No ammo! Buy arrows/bullets/shells from the shop."

### Test 3: Buy More Ammo
1. Press **B** to open shop
2. **Buy "Arrows (10x)"** for $15
3. Press **I** to check inventory
   - ✅ **Should show 10 arrows**
4. Enter hunting (ENTER)
   - ✅ **Should work** (have ammo now)

### Test 4: Partial Ammo Use
1. Enter hunt with 10 arrows
2. **Shoot only 1 arrow**
3. Exit immediately (ENTER)
4. Check inventory (I)
   - ✅ **Should show 9 arrows**
5. Enter hunt again
6. Shoot 2 arrows
7. Exit
8. Check inventory
   - ✅ **Should show 7 arrows** (9 - 2 = 7)

### Test 5: Multiple Hunts
1. **Hunt 1**: Start with 10 arrows, use 5 → End with 5
2. **Hunt 2**: Start with 5 arrows, use 3 → End with 2
3. **Hunt 3**: Start with 2 arrows, use 2 → End with 0
4. **Hunt 4**: Try to enter → **BLOCKED** (no ammo)
5. Buy arrows from shop ($15)
6. **Hunt 5**: Start with 10 arrows → Works!

---

## 📊 Expected Behavior

### Ammo Flow (CORRECT)
```
Game Start: 10 arrows in inventory
    ↓
Enter Hunt: 10 arrows CONSUMED from inventory (removed)
           Hunting mode: ammo.bow = 10
    ↓
Shoot 3 times: ammo.bow = 7
    ↓
Exit Hunt: 7 arrows RETURNED to inventory
    ↓
Inventory: 7 arrows

Enter Hunt Again: 7 arrows CONSUMED
                 Hunting mode: ammo.bow = 7
    ↓
Shoot 7 times: ammo.bow = 0
    ↓
Exit Hunt: 0 arrows returned
    ↓
Inventory: 0 arrows

Try Enter Hunt: BLOCKED - "No ammo!"
```

### Ammo Flow (INCORRECT - OLD BUG)
```
Game Start: 10 arrows
    ↓
Enter Hunt: Load 10 arrows (still in inventory)
    ↓
Shoot 5 times: ammo.bow = 5
    ↓
Exit Hunt: 5 arrows returned
    ↓
Inventory: 10 + 5 = 15 arrows ❌ BUG!

OR

Inventory: 10 arrows (never consumed) ❌ BUG!
```

---

## 🔍 Technical Details

### Before Fix
```lua
-- Enter hunting:
hunting.ammo.bow = playerEntity.getItemCount("arrows")
-- Ammo stays in inventory! ❌

-- Exit hunting:
playerEntity.removeItem("arrows", 999) -- Remove all
playerEntity.addItem("arrows", hunting.ammo.bow) -- Add back
-- This could ADD extra arrows! ❌
```

### After Fix
```lua
-- Enter hunting:
local arrowCount = playerEntity.getItemCount("arrows")
playerEntity.removeItem("arrows", arrowCount) -- CONSUME ✅
hunting.ammo.bow = arrowCount

-- Exit hunting:
playerEntity.addItem("arrows", hunting.ammo.bow) -- Return unused ✅
```

---

## ✅ Success Criteria

The fix is working if:
1. ✅ Arrows decrease after each hunt based on shots fired
2. ✅ Running out of arrows blocks hunting entry
3. ✅ Buying arrows from shop adds them to inventory
4. ✅ Can't hunt without ammo (must buy from shop)
5. ✅ Ammo doesn't mysteriously reappear or duplicate
6. ✅ Each shot costs real ammo that must be purchased

---

## 🎮 Player Impact

### Before Fix (Broken)
- Infinite ammo exploit
- No economic pressure
- Hunting was free money
- No need to buy ammo from shop
- Trivial difficulty

### After Fix (Working)
- ✅ Every shot costs money ($1.50 per arrow)
- ✅ Must manage ammo carefully
- ✅ Hunting has real costs
- ✅ Must buy ammo regularly
- ✅ Economic pressure creates strategy
- ✅ Risk/reward balance restored

---

## 🐛 If Bug Still Exists

Check these files:
1. `states/hunting.lua` - Lines 145-165 (enter function)
2. `states/hunting.lua` - Lines 475-490 (exit function)
3. `entities/player.lua` - Lines 34 (should only be in load())

Make sure:
- Ammo is REMOVED on enter (removeItem)
- Ammo is ADDED on exit (addItem)
- player.load() only runs once at game start
- No other code is adding arrows automatically

---

The game is now running with the fix applied. Test it out! 🎯
