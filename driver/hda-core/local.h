/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Local helper macros and functions for HD-audio core drivers
 */

#ifndef __HDAC_LOCAL_H
#define __HDAC_LOCAL_H

#include <linux/pci.h>
#include <sound/hdaudio.h>

/* Scope the existing readbacks to the AE-9 PCI controller. */
static inline bool hdac_bus_needs_posted_flush(const struct hdac_bus *bus)
{
	const struct pci_dev *pci;

	if (!bus->dev || !dev_is_pci(bus->dev))
		return false;

	pci = to_pci_dev(bus->dev);
	return pci->vendor == PCI_VENDOR_ID_CREATIVE &&
	       pci->device == 0x0010 &&
	       pci->subsystem_vendor == PCI_VENDOR_ID_CREATIVE &&
	       pci->subsystem_device == 0x0071;
}

extern const struct attribute_group *hdac_dev_attr_groups[];
int hda_widget_sysfs_init(struct hdac_device *codec);
int hda_widget_sysfs_reinit(struct hdac_device *codec, hda_nid_t start_nid,
			    int num_nodes);
void hda_widget_sysfs_exit(struct hdac_device *codec);

int snd_hdac_bus_add_device(struct hdac_bus *bus, struct hdac_device *codec);
void snd_hdac_bus_remove_device(struct hdac_bus *bus,
				struct hdac_device *codec);
void snd_hdac_bus_queue_event(struct hdac_bus *bus, u32 res, u32 res_ex);
int snd_hdac_bus_exec_verb(struct hdac_bus *bus, unsigned int addr,
			   unsigned int cmd, unsigned int *res);

int snd_hdac_exec_verb(struct hdac_device *codec, unsigned int cmd,
		       unsigned int flags, unsigned int *res);

#endif /* __HDAC_LOCAL_H */
