# T-196 environment

Source: `build.py`, using only Python's standard library and the existing
`Scene` serializer from `art_source/floor4/build_floor4.py` (import only).

From the repository root:

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/ch4_environment/build.py
pwsh tools/test.ps1 -Filter ch4_environment
```

The generator writes only its library, hospital, chapter-4 anchors, west exit,
ink texture and manifest. It patches three existing scenes narrowly: removes
the old solid Library subtree from `campus/shells.tscn`; adds Library and Ch4
instances to `campus/campus.tscn`; replaces only `Side170` of the canteen with
the approved west exit. It does not regenerate BuildingB, Floor4 or outdoor
navigation. Regenerating legacy campus/canteen art requires applying T-192
first, then this generator, and reviewing the diff. Never run the legacy
`build_campus.py` alone.

`manifest.json` records world anchor coordinates and box-mesh triangle totals
(slats additionally have one two-triangle ink quad each; library additionally
instances the existing 12-triangle iron bar). Navigation polygons are not
rendered. All furniture is native editable low-poly geometry. Shelves: 516
triangles each; map board: 708; counter including bar: 84; damaged door: 204;
one slat: 14; one hospital bed including covered patient: 132.

## Integration

- Add the existing Floor4 and Campus as siblings, like chapter 3. The default
  `Campus.floor4_path` is `../Floor4`; set it if the scene hierarchy differs.
- All T-194 anchors are under `Campus/Anchors/Ch4`, including Room407/Slat1,
  Slat2, Slat4, FakeLocker, FakeCeiling, FakeVent and Door. `manifest.json`
  contains the coordinates. Starts and zombie markers are foot positions.
- Library is `Campus/Library`, origin `(45,-9.9,195)`, footprint 40 x 30 m.
  Floors are y=-9.9/-6.6/-3.3. Stairs are in local x=34..39, z=4..14.
  The main entry is permanently blocked; BackDoor is at `(65,-9.9,225)`.
- `Campus/Library/BackDoor` uses RoomDoor. The 407 adapter is
  `Campus/Anchors/Ch4/Room407/Door`, centered on the old leaf's hinge at
  `(32.44,.01,0)`. Both expose room/is_open/set_open/Blocker/blocker and join
  room_doors. Wait one deferred frame after attaching Campus before binding
  ZombieDoor: the 407 adapter resolves the sibling Floor4 then. Without
  Floor4 it stays inactive with no collider or group entry.
- The 407 adapter delegates opening to Floor4/Door407, replaces only its
  leaf collision while attached, and restores collision/visibility when
  removed. The old interaction, latch, door-gap and rules-paper marker remain
  on Floor4/Door407. Never attach two ZombieDoor instances to both aliases.
- `door_damage_changed(&"407", fraction)` selects cracks at .3, a real visual
  aperture at .6, and a hand at .8. Collision stays closed until `set_open`.
  `set_damage_fraction(0)` restores the original leaf. No damage timers here.
- Slat markers expose `set_flipped(bool)`; `bed_slat_flipped(bed)` lifts the
  correct board. Only that bed's mosquito net is hidden while lifted; reset
  and scene removal restore its original visibility. Lane A attaches the
  hold interaction to each marker, and its search interaction to fake spots.
- Hospital root has all T-194 nodes. `set_companions_visible(bool)` changes
  only Bed_Nhat/Patient and Bed_Ngu/Patient. Core chooses the ending; lane D
  attaches labels to each Bed_*/Card; lane E uses MonitorAudio. Covered
  low-poly patient shapes implement the explicitly allowed simple variant.
- Navigation intentionally remains connected across closed doors so zombies
  can approach and bash. Physical world-layer blockers stop capsules. Main
  building entry still goes through the crouch-only manager window.

## Offline visual review

Open `res://scenes/levels/ch4/review.tscn` in Godot to capture nine images under
`build/t196/review/`. This is a static art capture, not a chapter bot or FPS
profile. It includes library floors/map/stairs/back door, slat, damaged 407,
and hospital. Final integrated chapter screenshots remain the integrator's
review, as requested by the task card.

## Verification

`game/tests/levels/test_ch4_environment.gd` checks capsule collision across
both doors, ZombieDoor compatibility, all four starts and library levels,
the west canteen opening, counter/reading desk approaches, six exterior
spawns, ten reachable spaced stair markers, bed mapping, signal thresholds,
legacy leaf restoration after Campus removal, hospital contracts/occupancy,
and per-prop triangle limits. Existing T-190 tests explicitly filter their
original 22 doors, keeping their original coverage intact.
