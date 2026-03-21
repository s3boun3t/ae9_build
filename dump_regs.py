import mmap, os, struct

print("=== BAR2 ===")
fd = os.open('/sys/bus/pci/devices/0000:25:00.0/resource2', os.O_RDONLY)
m = mmap.mmap(fd, 0x1000, mmap.MAP_SHARED, mmap.PROT_READ)
r = lambda o: struct.unpack('<I', m[o:o+4])[0]
regs = [0x000,0x004,0x01c,0x088,0x100,0x200,0x204,0x208,0x20c,0x210,
        0x300,0x304,0x308,0x320,0x800,0x804,0x830,0x860,0x86c]
for off in regs:
    print(f'BAR2+0x{off:03x} = 0x{r(off):08x}')
m.close()
os.close(fd)

print("=== BAR0 ===")
fd = os.open('/sys/bus/pci/devices/0000:25:00.0/resource0', os.O_RDONLY)
m = mmap.mmap(fd, 0x100, mmap.MAP_SHARED, mmap.PROT_READ)
for off in [0x00,0x08,0x0c,0x0e,0x20,0x24,0x48,0x4c,0x58,0x5c]:
    sz = 2 if off in [0x0c, 0x0e] else 4
    v = struct.unpack('<H' if sz==2 else '<I', m[off:off+sz])[0]
    print(f'BAR0+0x{off:02x} = 0x{v:0{sz*2}x}')
m.close()
os.close(fd)
