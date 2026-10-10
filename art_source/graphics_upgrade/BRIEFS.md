# Brief và prompt T-209 — G0

Các đoạn tiếng Anh dưới đây là brief theo card, **chưa gửi Meshy**. Không phải lệnh/API hoặc cam kết budget. Dùng số đo của `measured_assets.json` và transform `asset_manifest.json`; nếu chưa có kết quả đo thì không tạo asset phụ thuộc. Mẫu đầu đề xuất balo vì không có bản lề/rig; bình cứu hỏa là mẫu thứ hai có tương tác để kiểm contract khi G1/G2 đủ.

## Quy ước chung (English)

Create a grounded, moderately worn Vietnamese student dormitory prop. Use meters and +Y up after the Blender-to-glTF export. Match the supplied measured bounds and preserve the supplied gameplay root; place any normalization below that root. Keep the complete back and underside, outward normals, clean UVs, and readable silhouettes. Separate moving parts. No text, logos, invented clues, floating fragments, baked lighting, or baked shadows. Supply source files and GLB with reusable PBR materials. Do not invent attachment markers or animation names. Triangle and texture budgets remain provisional until G1 approval. No paid generation is authorized by this brief.

## Backpack — candidate for one paid trial after G2 authorization

An inexpensive used student backpack with two shoulder straps, a carry loop and one front pocket. The fabric is slightly faded olive gray with subtle seam wear; avoid decorative branding. It rests on the dorm floor, seen from 0.7 to 2 meters and from behind when the player walks past. Use the measured current backpack bounds, not a generic human scale. Keep straps attached and the underside closed. No belongings protruding into the walking route. One fabric material and one shared hardware material are sufficient for the proposal; final limits await G1. Preserve the current placement and rotation, with a normalization wrapper if needed.

## Extinguisher — interaction prop, contract required

A wall-mounted red steel fire extinguisher with a black hose, handle, safety pin and a blank label area. Preserve the measured body and handle envelope and the existing interaction anchor offset. Do not move the gameplay anchor to the cylinder center. Include the rear bracket and underside. Keep the hose inside the agreed envelope. Produce the blank label surface separately so approved localized artwork can be applied later. The impact event and crowd reaction remain existing gameplay; do not add animation timing or audio to the model. Confirm the front direction at the stair landing before final export.

## Bunk / door / locker — Blender modules, not generative geometry

Build the steel bunks, hinged wooden door and steel locker from measured dimensions. Preserve the door hinge origin, negative-X closed leaf direction and negative-Y-axis rotation convention from the supplied Godot scene. Bunk mattress heights remain 0.43 and 1.20 meters. Keep all eight damaged-bedding sections independent and preserve existing view, exit, corpse and interaction markers. Do not scale the gameplay root, fill walking gaps, change collision, or merge switchable parts into a static bake. Use subtle edge bevels and wear at contact points instead of random heavy damage.

## Wall / tile / iron / cloth — local G0 material study

Compare painted plaster with broad low-contrast discoloration, small glazed floor tiles with recessed grout, worn iron with restrained highlights, and matte woven bedding. Keep lighting and camera identical within each before/after pair. New textures are deterministic 256-pixel procedural samples for G0, not the final realistic texture budget. Use neutral light to inspect roughness and a copy of the game's lighting to inspect readability. Do not add blood, writing or story clues to the material samples.

## Alarm button and remote bell — self-authored after G1

The existing wall button is a 0.22 x 0.28 x 0.06 meter red box centered at its existing anchor. Model a readable casing with a blank face for approved localized artwork. The bell is a separate object at the remote audio position, not part of the button assembly. Its dimensions, mounting direction and final node path require the B/F/web contract. No generation or production modeling for the bell until those details are agreed.

## Student — deferred to adapter A

Create one student visual only after the approved adapter contract supplies skeleton, rest pose, clip names, root motion policy, head/hand/audio markers and supported states. Preserve gameplay capsule and head position. Validate standing, walking, lying, sitting and head turns using real renders of face, hands and joint deformation. Do not rename or assume the existing procedural rig paths are compatible with a Skeleton3D import.
