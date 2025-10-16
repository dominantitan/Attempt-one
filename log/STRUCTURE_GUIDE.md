# Structure Reference Guide

## 🏗️ **Current Game Structures & Positions**

### 🏠 **Uncle's Cabin**
- **Position**: (460, 310) - Center-right area
- **Color**: Brown building with darker brown roof
- **Size**: 80x80 pixels
- **Interaction**: Press ENTER to enter cabin interior
- **Features**: Sleep, storage, fireplace inside

### 🌾 **Farm Area** 
- **Position**: (565, 325) - Right of cabin
- **Color**: Brown rectangular area with grid lines
- **Size**: 120x80 pixels (2x3 plot layout)
- **Interaction**: Press E to plant/harvest, Q to water
- **Features**: 6 individual farming plots arranged in 2 columns, 3 rows

### 🏞️ **Pond**
- **Position**: (580, 450) - Bottom-right area (**FIXED - moved up from 545**)
- **Color**: Blue ellipse with darker blue outline
- **Size**: 100x60 pixels
- **Interaction**: Press F to fish, G to get water
- **Features**: Fishing and water collection

### 🏪 **Shop**
- **Position**: (190, 620) - Bottom-left area
- **Color**: Gray rectangular building
- **Size**: 80x60 pixels
- **Interaction**: Press ENTER to enter shop interior
- **Features**: Trade with merchant inside

### 🚂 **Railway Station** (**NEW VISUAL**)
- **Position**: (130, 410) - Southwestern area
- **Color**: Dark brown building with:
  - Darker brown roof
  - Very dark door in center
  - Yellow windows on sides
  - Gray railway tracks extending from building
- **Size**: 120x80 pixels
- **Interaction**: Press S to trade with Station Master Ellis, E to examine
- **Features**: Trading post with travel supplies

### 🌲 **Hunting Zones** (3 circular areas)
- **Northwestern Woods**: (130, 130) - Top-left, gray circle
- **Northeastern Grove**: (830, 130) - Top-right, gray circle  
- **Southeastern Wilderness**: (830, 410) - Bottom-right, gray circle
- **Interaction**: Press ENTER when near edge to enter hunting area
- **Features**: Dense animal spawning, different difficulty levels

---

## 🎯 **What You Should See Now:**

1. **Green player character** that moves with WASD
2. **Brown cabin** with roof in center-right
3. **Brown farm** with 2x3 grid lines to the right of cabin
4. **Blue oval pond** in bottom-right (now visible!)
5. **Gray shop** in bottom-left
6. **Detailed railway station** in bottom-left with tracks, windows, door
7. **Three gray hunting zone circles** in corners
8. **Colorful wild crops** scattered around (small colored dots)

---

## 🐛 **If You Still Don't See The Pond:**

The pond was originally positioned at y=545, which is outside the 540-pixel game height. I've moved it to y=450, so it should now be visible as a blue ellipse in the bottom-right area, near the farm.

**Pond Details:**
- Should appear as blue oval shape
- Located at coordinates (580, 450) 
- Has darker blue outline
- Name "Pond" should appear above it
- Should be right of the farm area

If it's still not visible, the issue might be with the ellipse drawing or color values.