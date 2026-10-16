"""Procedural ageing and dried blood, baked with the CC0 MakeHuman skin.

Coordinates are metres in the unscaled MPFB mesh, before the final 1.70 m fit.
No new material slot is needed: albedo and tangent normal share the skin atlas.
"""
import bpy
import numpy as np


def add_surface(mat):
    size = 2048
    x, z = np.meshgrid(np.linspace(-0.12, 0.12, size, dtype=np.float32),
                       np.linspace(1.36, 1.66, size, dtype=np.float32))
    rng = np.random.default_rng(219)
    grain = rng.random((size, size), dtype=np.float32)
    folds = np.zeros_like(x)
    # Three broken forehead lines follow the brow, rather than straight stripes.
    for index, level in enumerate((1.542, 1.553, 1.564)):
        curve = level + 0.008 * (x / 0.07)**2 + 0.0002*np.sin(x*340+index)
        fade = np.exp(-((x+index*0.003)/(0.056-index*0.006))**6)
        folds += np.exp(-((z-curve)/0.00055)**2) * fade * (0.70+0.20*np.sin(x*91+index))
    for side in (-1, 1):
        sx = x * side
        # Crow's feet: fan out from the outer canthus.
        for slope in (-0.38, 0.0, 0.36):
            line = 1.507 + slope*(sx-0.048)
            folds += 0.65*np.exp(-((z-line)/0.0006)**2) * ((sx > 0.046) & (sx < 0.073))
        # Nasolabial fold and lower lid crease.
        curve = 0.020 + (1.480-z)*0.38 + 3*(1.480-z)**2
        fade = np.clip((z-1.440)/0.012, 0, 1)*np.clip((1.483-z)/0.008, 0, 1)
        folds += 0.55*np.exp(-((sx-curve)/0.0013)**2) * fade
        folds += 0.45*np.exp(-((z-(1.493+1.8*(sx-0.034)**2))/0.0008)**2) * ((sx > 0.018) & (sx < 0.053))
    # Several irregular rivulets, not a vertex-colour stripe.
    blood = np.zeros_like(x)
    for index, (centre, bottom, width) in enumerate([(-0.052, 1.475, 0.0038), (-0.062, 1.492, 0.0022), (-0.044, 1.515, 0.0013)]):
        path = centre + 0.001*np.sin(z*(73+index*29)) + 0.0005*np.sin(z*670+index)
        edge = width * (0.6 + 0.25*np.sin(z*380+index) + 0.15*np.sin(z*1170))
        blood = np.maximum(blood, np.clip((edge-abs(x-path))*2500+0.5, 0, 1) * ((z > bottom) & (z < 1.607)))
    blood *= np.clip(0.65 + grain*0.65, 0, 1)
    face_mask = np.clip((z-1.40)/0.035, 0, 1) * np.clip((1.625-z)/0.025, 0, 1)
    pores = np.sin(x*2200)*np.sin(z*2600) * 0.0015
    height = np.clip(0.5 + (-folds*0.14 + pores + blood*0.025)*face_mask, 0, 1)
    tone = np.ones((size, size, 4), dtype=np.float32)
    mottling = 0.025*np.sin(x*170+np.sin(z*99))*np.sin(z*211)
    tone[:, :, :3] = (1 - np.clip(folds, 0, 1)*0.16 + (grain-0.5)*0.045 + mottling*face_mask)[:, :, None]
    tone[:, :, :3] *= 1 - blood[:, :, None]
    tone[:, :, :3] += blood[:, :, None]*np.array([0.14, 0.025, 0.014])
    bump_rgba = np.ones_like(tone)
    bump_rgba[:, :, :3] = height[:, :, None]
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    geometry = nodes.new('ShaderNodeNewGeometry')
    split = nodes.new('ShaderNodeSeparateXYZ')
    links.new(geometry.outputs['Position'], split.inputs[0])
    combine = nodes.new('ShaderNodeCombineXYZ')
    for axis, lower, span, destination in [('X', -0.12, 0.24, 'X'), ('Z', 1.36, 0.30, 'Y')]:
        remap = nodes.new('ShaderNodeMapRange')
        remap.clamp = False
        remap.inputs['From Min'].default_value = lower
        remap.inputs['From Max'].default_value = lower+span
        links.new(split.outputs[axis], remap.inputs['Value'])
        links.new(remap.outputs[0], combine.inputs[destination])
    textures = []
    for name, pixels in [('FaceTone', tone), ('FaceHeight', bump_rgba)]:
        image = bpy.data.images.new(name, width=size, height=size, float_buffer=False)
        image.colorspace_settings.name = 'Non-Color'
        image.pixels.foreach_set(pixels.ravel())
        image.pack()
        tex = nodes.new('ShaderNodeTexImage')
        tex.image = image
        tex.extension = 'EXTEND'
        links.new(combine.outputs[0], tex.inputs['Vector'])
        textures.append(tex)
    front = nodes.new('ShaderNodeMath')
    front.operation = 'LESS_THAN'
    front.inputs[1].default_value = -0.055
    links.new(split.outputs['Y'], front.inputs[0])
    bsdf = nodes.get('Principled BSDF')
    base = bsdf.inputs['Base Color'].links[0].from_socket
    mix = nodes.new('ShaderNodeMixRGB')
    mix.blend_type = 'MULTIPLY'
    links.new(front.outputs[0], mix.inputs[0])
    links.new(base, mix.inputs[1])
    links.new(textures[0].outputs['Color'], mix.inputs[2])
    links.new(mix.outputs[0], bsdf.inputs['Base Color'])
    bump = nodes.new('ShaderNodeBump')
    bump.inputs['Distance'].default_value = 0.0018
    links.new(front.outputs[0], bump.inputs['Strength'])
    links.new(textures[1].outputs['Color'], bump.inputs['Height'])
    links.new(bump.outputs[0], bsdf.inputs['Normal'])
