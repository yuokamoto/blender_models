import bpy
from collections import defaultdict

import sys
argv = sys.argv[sys.argv.index("--") + 1:]
target = argv[0]

boolean_objs = set()

def create_single_copy():
    scene = bpy.context.scene
    data_links = defaultdict(list)
    
    # create dictionary with duplicate objects
    for ob in scene.objects:
        data_links[ob.data].append(ob)
    
    # make a single user copy
    for k, v in data_links.items():
        if len(v) > 1:
            # get the original obj
            original_obj = v[0]
            new_mesh = original_obj.data.copy()

            bpy.context.view_layer.objects.active = v[0]
            bpy.ops.object.make_single_user(object=True, obdata=True, material=False, animation=False)
            for i in range(1, len(v)):
                v[i].data = new_mesh
                bpy.context.view_layer.objects.active = v[i]
                bpy.ops.object.make_single_user(object=True, obdata=True, material=False, animation=False)

    # Repeat until all multi user data become single object
    # todo avoid unnecessary loops
    data_links = defaultdict(list)
    
    # create dictionary with duplicate objects
    for ob in scene.objects:
        data_links[ob.data].append(ob)
        
    for k, v in data_links.items():
        if len(v) > 1:
            create_single_copy()
            break

def apply_modifiers(obj):
    if not obj:
        return
        
    print('apply_modifiers: ', obj.name, obj.type)

    boolean_obj = None
    bpy.context.view_layer.objects.active = obj

    if obj.type == 'CURVE':
        bpy.ops.object.select_all(action='DESELECT')
        bpy.data.objects[obj.name].select_set(True)
        bpy.ops.object.convert(target='MESH')
        bpy.ops.object.select_all(action='DESELECT')


    for mod in obj.modifiers:
        boolean_obj = None
        print('  modifier', mod, mod.type)
        
        if mod.type == 'BOOLEAN':
            boolean_obj = mod.object
            boolean_objs.add(boolean_obj)
            apply_modifiers(boolean_obj)
            bpy.context.view_layer.objects.active = obj

        bpy.ops.object.modifier_apply(modifier=mod.name)

create_single_copy()

for obj in bpy.context.scene.objects: 
    apply_modifiers(obj)


for obj in boolean_objs:
    bpy.data.objects.remove(obj, do_unlink=True)

for obj in bpy.context.scene.objects: 
    if not obj.visible_get():
        bpy.data.objects.remove(obj, do_unlink=True)


bpy.ops.export_scene.fbx(filepath=target, use_selection=False)