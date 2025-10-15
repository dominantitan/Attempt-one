# Weapon System Visual Update

## Completed Improvements (Latest)

### ✅ 1. Weapon Points at Crosshair
The weapon now **dynamically rotates** to point at the crosshair position, creating a realistic 3D aiming effect.

**Implementation:**
```lua
local weaponAngle = math.atan2(hunting.crosshair.y - hunting.gunY, hunting.crosshair.x - hunting.gunX)
lg.push()
lg.translate(hunting.gunX, hunting.gunY)
lg.rotate(weaponAngle)
-- Draw weapon...
lg.pop()
```

**Result:** Weapon follows your mouse cursor smoothly, giving proper visual feedback of where you're aiming.

---

### ✅ 2. Bow Shows Arrow When Ready
When using the bow, an **arrow is visible** on the weapon when it's loaded (not reloading).

**Visual Elements:**
- **Bow body**: Brown wooden bow (50px long)
- **Bow tip**: Darker brown tip
- **Arrow shaft**: Light brown (35px long) - visible when ready
- **Arrow head**: Silver metal triangle - visible when ready

**Reload State:** Arrow disappears during reload, reappears when ready to shoot.

---

### ✅ 3. Projectiles Origin from Gun Position
Arrows and bullets now **shoot from the gun** at the bottom-center of the screen (480, 480), not from a random position.

**Before:**
```lua
x = 480, y = 270  -- Center of screen
```

**After:**
```lua
x = hunting.gunX,  -- 480 (bottom-center)
y = hunting.gunY   -- 480 (player position)
```

**Result:** Realistic trajectory from weapon to target.

---

### ✅ 4. Rotating Arrow Graphics
Arrows in flight now have **proper rotation** and visual design.

**Arrow Components:**
- **Shaft**: Brown wooden rectangle (20px long, 2px wide)
- **Head**: Silver triangle (5px forward)
- **Rotation**: Matches velocity direction

**Before:** Simple circle
**After:** Proper arrow shape with rotation

---

### ✅ 5. Animals Peek from Bushes
Hidden animals occasionally **peek out** from behind bushes, creating brief shooting opportunities.

**Peeking Mechanics:**
- **Frequency**: 0.1% chance per frame when hidden
- **Duration**: 0.3-0.8 seconds
- **Visual**: 70% size, 50% opacity
- **Position**: Behind nearest bush
- **Tiger eyes**: Still glow when peeking

**Gameplay Impact:** Adds skill-based challenge - shoot during peek or wait for full visibility.

---

### ✅ 6. Animals Drawn Behind Bushes
When hiding, animals are rendered **behind the bush layer**, not in front.

**Layer Order:**
1. Background (dark green)
2. Bushes (darker green)
3. **Peeking animals (behind bushes)**
4. Visible animals (foreground)
5. Player + weapon
6. Projectiles
7. UI + crosshair

---

## Weapon Visual Designs

### 🏹 Bow
- **Color**: Brown wood (0.5, 0.3, 0.2)
- **Length**: 50px
- **Arrow visible**: When loaded
- **Arrow shaft**: 35px brown
- **Arrow head**: Silver triangle

### 🔫 Rifle
- **Color**: Dark gray (0.2, 0.2, 0.2)
- **Body**: 60px long, 8px tall
- **Barrel**: Additional 15px extension, 4px tall
- **Style**: Sleek, military

### 🔫 Shotgun
- **Color**: Dark brown (0.25, 0.2, 0.15)
- **Body**: 55px long, 10px tall (thicker)
- **Barrel**: 20px long, 6px tall (wider)
- **Style**: Heavy, powerful

---

## Technical Details

### Projectile Physics
```lua
angle = atan2(crosshair.y - gunY, crosshair.x - gunX)
vx = cos(angle) * speed
vy = sin(angle) * speed
```

### Arrow Rendering
```lua
angle = atan2(proj.vy, proj.vx)
translate(proj.x, proj.y)
rotate(angle)
-- Draw shaft and head
```

### Animal Peeking
```lua
if not animal.peekingOut and math.random() < 0.001 then
    animal.peekingOut = true
    animal.peekTimer = random(0.3, 0.8)
end
```

---

## Gameplay Experience

### Before
- ❌ Static horizontal weapon
- ❌ No arrow visible
- ❌ Bullets from random spots
- ❌ Simple circle projectiles
- ❌ Animals just hidden or visible

### After
- ✅ Weapon follows crosshair
- ✅ Arrow visible when ready
- ✅ Bullets from gun position
- ✅ Rotating arrow graphics
- ✅ Animals peek strategically

---

## Next Steps

Future enhancements for even better visuals:
- [ ] Muzzle flash when firing
- [ ] Smoke trail for rifle/shotgun bullets
- [ ] Impact particles when hitting animals
- [ ] Bush rustling animation when animal is hiding
- [ ] Weapon recoil animation
- [ ] Empty shell casings ejected
- [ ] Screen shake on shotgun blast
- [ ] Blood splatter effect on hit
- [ ] Animal sprites (replace rectangles)
- [ ] Detailed bush sprites

---

## Controls Reminder

- **Mouse**: Aim (weapon follows cursor)
- **Left Click**: Shoot
- **1/2/3**: Switch weapons
- **ENTER**: Enter/Exit hunting mode
- **ESC**: Exit hunting mode

The weapon system now provides excellent visual feedback and creates a much more immersive hunting experience!
