# Files to Remove/Cleanup

**Purpose:** Identify obsolete, duplicate, and unnecessary files cluttering the workspace  
**Created:** October 15, 2025  
**Action:** Review and delete/consolidate as needed

---

## 🗑️ High Priority - Safe to Delete

### 1. Old Hunting System (Already Disabled)
- **systems/hunting.lua** (89 lines)
  - Old top-down hunting implementation
  - Already commented out in main.lua (lines 64, 125)
  - Replaced by states/hunting.lua (799 lines)
  - **Action:** DELETE or rename to `systems/hunting.lua.backup`

---

## 📝 Medium Priority - Consider Consolidating

### 2. Duplicate Hunting Documentation (5 files)
These files likely overlap and should be merged into ONE comprehensive guide:

- **HUNTING_SYSTEM_TEST.md** - Test notes from implementation
- **HUNTING_FIX_COMPLETE.md** - Bug fix logs
- **HUNTING_GUIDE.md** - Player guide
- **HUNTING_ZONES_GUIDE.md** - Zone documentation
- **HUNTING_ECONOMY.md** - Economy balance notes

**Recommendation:** Merge into single **HUNTING.md** with sections:
- Overview
- Weapons & Ammo
- Animals & Zones
- Economy & Balance
- Known Issues
- Testing Guide

---

### 3. Status Documentation (3 files)
These files may overlap:

- **CURRENT_STATE.md** (273 lines) - Main status file (KEEP THIS)
- **MVP_STATUS.md** - May be redundant
- **GAME_ASSESSMENT.md** - May be outdated

**Recommendation:** 
- Review MVP_STATUS.md and GAME_ASSESSMENT.md
- Merge relevant info into CURRENT_STATE.md
- Delete or archive the others

---

### 4. Development Logs
- **REFACTOR_LOG.md** - May be outdated
- **SESSION_WRAPUP.md** (NEW - just created today)

**Recommendation:** Keep SESSION_WRAPUP.md, review REFACTOR_LOG.md for relevance

---

## ⚠️ Low Priority - Review Before Deleting

### 5. Entity Files (Check Usage First)
- **entities/animals.lua**
  - Top-down animal entities for old hunting system
  - Check if used anywhere else in game
  - May be repurposed for world animals
  - **Action:** Grep search for usage before deleting

### 6. Asset Folders (Check Contents)
- **assets/sprites/animals/** - Check if empty
- **assets/sprites/crops/** - May have unused files
- **assets/sprites/environment/** - May have unused files

**Recommendation:** 
```powershell
# Check folder contents
ls "assets/sprites/animals/"
ls "assets/sprites/crops/"
ls "assets/sprites/environment/"
```

---

## ✅ Keep These Files (Important)

### Core Game Files
- **main.lua** - Game entry point
- **states/*.lua** - All state files (gameplay, hunting, shop, inventory)
- **systems/*.lua** - All system files (except hunting.lua)
- **entities/*.lua** - All entity files (check animals.lua usage)
- **utils/*.lua** - All utility files
- **libs/*.lua** - All library files

### Documentation (Keep)
- **README.md** - Project overview
- **CURRENT_STATE.md** - Main status file
- **CODE_STANDARDS.md** - Coding guidelines
- **STRUCTURE_GUIDE.md** - Architecture guide
- **TESTING_GUIDE.md** - Testing instructions
- **DEVELOPMENT_CHECKLIST.md** - Dev tasks

### Asset Files
- **ASSET_GUIDE.md** - Asset documentation
- **ASSET_MAP.md** - Asset mapping
- **assets/** folder - All asset folders (check for unused files)

---

## 🔍 Commands to Check Usage

Before deleting any file, run these commands to check if it's used:

```powershell
# Check if systems/hunting.lua is used
cd "c:\dev\Attempt one"
grep -r "systems/hunting" . --exclude-dir=node_modules

# Check if entities/animals.lua is used (outside of old hunting)
grep -r "entities/animals" . --exclude-dir=node_modules

# Check if old hunting system is referenced
grep -r "huntingSystem" . --exclude-dir=node_modules

# List all markdown files
ls *.md
```

---

## 📋 Cleanup Checklist

- [ ] Delete `systems/hunting.lua` (confirm not used)
- [ ] Merge 5 hunting docs into one `HUNTING.md`
- [ ] Review and consolidate `MVP_STATUS.md` into `CURRENT_STATE.md`
- [ ] Review and consolidate `GAME_ASSESSMENT.md` into `CURRENT_STATE.md`
- [ ] Check `REFACTOR_LOG.md` relevance
- [ ] Check `entities/animals.lua` usage
- [ ] Clean up empty asset folders
- [ ] Archive old documentation files instead of deleting (safer)

---

## 🗂️ Suggested Archive Folder

Create an `_archive/` folder to store old files instead of deleting:

```powershell
# Create archive folder
mkdir "_archive"
mkdir "_archive/old_hunting_system"
mkdir "_archive/old_docs"

# Move old files there
mv systems/hunting.lua _archive/old_hunting_system/
mv HUNTING_SYSTEM_TEST.md _archive/old_docs/
mv HUNTING_FIX_COMPLETE.md _archive/old_docs/
# etc...
```

This way files are preserved but not cluttering workspace.

---

**End of Cleanup Guide**
