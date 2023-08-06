import bpy

import sys
argv = sys.argv[sys.argv.index("--") + 1:]
target = argv[0]

objects = bpy.context.scene.objects
boolean_objs = set()

def apply_modifiers(obj):
    print('apply_modifiers: ', obj.name)
    boolean_obj = None
    bpy.context.view_layer.objects.active = obj
    for mod in obj.modifiers:
        boolean_obj = None
        print('  modifier', mod)
        
        if mod.type == 'BOOLEAN':
            boolean_obj = mod.object
            boolean_objs.add(boolean_obj)
            apply_modifiers(boolean_obj)
            bpy.context.view_layer.objects.active = obj

        bpy.ops.object.modifier_apply(modifier=mod.name)

for obj in objects: 
    apply_modifiers(obj)

for obj in boolean_objs:
    bpy.data.objects.remove(obj, do_unlink=True)


bpy.ops.export_scene.fbx(filepath=target, use_selection=False)