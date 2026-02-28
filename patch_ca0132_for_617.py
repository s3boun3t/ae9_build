#!/usr/bin/env python3
"""
patch_ca0132_for_617.py — Adapte patch_ca0132.c (kernel 6.14) pour le kernel 6.17

Le kernel 6.17 a refactoré le sous-système HDA :
- codec->patch_ops n'existe plus
- Les ops sont dans hda_codec_driver.ops (struct hda_codec_ops)
- La fonction patch_XX() devient le callback .probe()
- codec->spec est alloué avec kzalloc_obj() ou kzalloc()
- pcm_format_first et no_sticky_stream ont peut-être changé

Ce script transforme automatiquement le code.
"""

import re
import sys

def transform(source):
    lines = source.split('\n')
    output = []
    
    # Track state
    in_patch_ca0132 = False
    in_ca0132_patch_ops = False
    in_dbpro_patch_ops = False
    brace_depth = 0
    
    # Collect the ops from the old patch_ops structs
    ca0132_ops = {}
    dbpro_ops = {}
    
    # First pass: extract the old patch_ops definitions
    current_ops = None
    for i, line in enumerate(lines):
        if 'static const struct hda_codec_ops ca0132_patch_ops' in line or \
           'static struct hda_codec_ops ca0132_patch_ops' in line:
            current_ops = ca0132_ops
        elif 'static const struct hda_codec_ops dbpro_patch_ops' in line or \
             'static struct hda_codec_ops dbpro_patch_ops' in line:
            current_ops = dbpro_ops
        elif current_ops is not None:
            if '};' in line:
                current_ops = None
            else:
                m = re.match(r'\s*\.(\w+)\s*=\s*(\w+)', line)
                if m:
                    current_ops[m.group(1)] = m.group(2)
    
    print(f"Found ca0132_patch_ops: {ca0132_ops}", file=sys.stderr)
    print(f"Found dbpro_patch_ops: {dbpro_ops}", file=sys.stderr)
    
    # Second pass: transform the code
    skip_until_brace_close = False
    skip_struct = False
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # --- Remove old patch_ops struct definitions ---
        if ('static const struct hda_codec_ops ca0132_patch_ops' in line or
            'static struct hda_codec_ops ca0132_patch_ops' in line or
            'static const struct hda_codec_ops dbpro_patch_ops' in line or
            'static struct hda_codec_ops dbpro_patch_ops' in line):
            # Skip until closing };
            while i < len(lines) and '};' not in lines[i]:
                i += 1
            i += 1  # skip the };
            continue
        
        # --- Transform patch_ca0132() to ca0132_codec_probe() ---
        if re.match(r'^static int patch_ca0132\(struct hda_codec \*codec\)', line):
            output.append('static int ca0132_codec_probe(struct hda_codec *codec, const struct hda_device_id *id)')
            i += 1
            continue
        
        # --- Remove codec->patch_ops assignments ---
        if 'codec->patch_ops' in line:
            i += 1
            continue
        
        # --- Remove codec->pcm_format_first (doesn't exist in 6.17) ---
        if 'codec->pcm_format_first' in line:
            i += 1
            continue
        
        # --- Remove codec->no_sticky_stream (doesn't exist in 6.17) ---
        if 'codec->no_sticky_stream' in line:
            i += 1
            continue
            
        # --- Fix HDA_CODEC_ENTRY -> HDA_CODEC_ID ---
        if 'HDA_CODEC_ENTRY' in line:
            line = re.sub(
                r'HDA_CODEC_ENTRY\(0x11020011,\s*"CA0132",\s*patch_ca0132\)',
                'HDA_CODEC_ID(0x11020011, "CA0132")',
                line
            )
        
        # --- Add .ops to driver struct ---
        if '.id = snd_hda_id_ca0132,' in line:
            output.append(line)
            # Build the ops struct based on what we found
            # Map old names to new callback names
            # The probe callback is our transformed patch_ca0132
            ops_lines = []
            ops_lines.append('\t.ops = &(const struct hda_codec_ops) {')
            ops_lines.append('\t\t.probe = ca0132_codec_probe,')
            
            # Map the callbacks from the old ca0132_patch_ops
            callback_map = {
                'build_controls': 'build_controls',
                'build_pcms': 'build_pcms',
                'init': 'init',
                'free': 'remove',  # free -> remove in new API
                'unsol_event': 'unsol_event',
                'suspend': 'suspend',
                'check_power_status': 'check_power_status',
                'stream_pm': 'stream_pm',
            }
            
            for old_name, new_name in callback_map.items():
                if old_name in ca0132_ops:
                    func = ca0132_ops[old_name]
                    ops_lines.append(f'\t\t.{new_name} = {func},')
            
            ops_lines.append('\t},')
            output.extend(ops_lines)
            i += 1
            continue
        
        # --- Add AE-9 quirk after AE-7 line ---
        if 'SND_PCI_QUIRK(0x1102, 0x0081, "Sound Blaster AE-7", QUIRK_AE7),' in line:
            output.append(line)
            output.append('\tSND_PCI_QUIRK(0x1102, 0x0071, "Sound Blaster AE-9", QUIRK_AE7),')
            i += 1
            continue
        
        output.append(line)
        i += 1
    
    return '\n'.join(output)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.c output.c")
        sys.exit(1)
    
    with open(sys.argv[1], 'r') as f:
        source = f.read()
    
    result = transform(source)
    
    with open(sys.argv[2], 'w') as f:
        f.write(result)
    
    print(f"Transformation complete. Output: {sys.argv[2]}")
