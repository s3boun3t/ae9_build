# CA0113 Handshake Fix — Implementation Plan

> **For Claude:** Use `executing-plans` skill to implement this plan task-by-task.

**Goal:** Obtenir le son sur le casque MMX300 v2 en résolvant le CA0113 handshake qui échoue au boot normal.

**Architecture:** Le handshake CA0113 bloque l'init 5 secondes (100 polls × 50ms) puis échoue au boot normal. Avec blacklist+modprobe ça marche instantanément. La solution : (1) supprimer le poll bloquant de l'init, (2) ajouter un `delayed_work` pour réessayer 15s après le boot, (3) flag `ca0113_ready` pour éviter la double exécution.

**Tech Stack:** Linux kernel C, `schedule_delayed_work`, `struct delayed_work`, `ca0132.c` uniquement.

---

## État actuel du code

Fichier : `~/ae9_build/build/ca0132.c`

### Ce qui existe déjà
- `spec->unsol_hp_work` : `struct delayed_work` déjà dans `ca0132_spec` (ligne ~1153)
- Handshake + re-send commands : lignes 9920-9983, inline dans `ae9_setup_defaults()`
- Poll bloquant : 100 × 50ms = **5 secondes bloquées au boot** en pure perte
- `ca0113_ready` : **n'existe pas encore**

### Problème exact
Le CA0113 ne répond pas au boot normal même après ACM init (T+14s).
Il répond seulement avec blacklist+modprobe (T+20s). Delta = ~6s supplémentaires.
Le poll de 5s est donc trop court ET bloque le boot pour rien.

---

## Task 1 : Ajouter `ca0113_ready` dans `ca0132_spec`

**Fichier :** `~/ae9_build/build/ca0132.c`
**Section :** struct ca0132_spec (autour de la ligne 1150)

**Step 1 : Trouver l'emplacement**
```bash
grep -n "unsol_hp_work\|is_d2_acm_only\|delayed_work" ~/ae9_build/build/ca0132.c | head -10
```

**Step 2 : Ajouter le champ et le delayed_work AE-9**

Trouver le bloc contenant `struct delayed_work unsol_hp_work;` et ajouter juste après :
```c
	struct delayed_work ae9_ca0113_work; /* AE-9: deferred CA0113 handshake */
	bool ca0113_ready;                  /* AE-9: true once CA0113 handshake succeeded */
```

**Step 3 : Vérifier**
```bash
grep -n "ca0113_ready\|ae9_ca0113_work" ~/ae9_build/build/ca0132.c
```
Expected : 2 lignes correspondantes dans la struct.

---

## Task 2 : Extraire le handshake dans une fonction dédiée

**But :** Le code inline dans `ae9_setup_defaults()` (lignes 9920-9983) doit devenir une fonction réutilisable appelable depuis le delayed_work ET depuis l'init.

**Step 1 : Trouver la section exacte à extraire**
```bash
grep -n "CA0113 handshake\|writel.*0x00800003\|0xffff.*mem.*0x208\|ca0113.*commands" ~/ae9_build/build/ca0132.c | head -20
```

**Step 2 : Créer la fonction `ae9_ca0113_handshake()`**

Insérer **avant** `ae9_setup_defaults()` (trouver sa ligne exacte avec `grep -n "^static void ae9_setup_defaults" ca0132.c`) :

```c
/*
 * AE-9: Attempt the CA0113 command interface handshake.
 *
 * The CA0113 only responds after the full init sequence (DSP + ACM).
 * Returns true if the handshake succeeded (0x208 != 0xffffffff).
 *
 * Called from ae9_setup_defaults() as a best-effort attempt, and
 * retried from ae9_ca0113_deferred_work() 15s later if it failed.
 */
static bool ae9_ca0113_handshake(struct hda_codec *codec)
{
	struct ca0132_spec *spec = codec->spec;
	void __iomem *mem = spec->mem_base;
	unsigned int val;
	int i;

	if (spec->ca0113_ready)
		return true;

	writel(0x00800003, mem + 0x20c);
	readl(mem + 0x20c);
	msleep(16);
	writel(0x00800003, mem + 0x20c);
	readl(mem + 0x20c);
	writel(0xffff, mem + 0x208);
	readl(mem + 0x208);

	for (i = 0; i < 20; i++) {
		msleep(50);
		val = readl(mem + 0x208);
		if (val != 0xffffffff)
			break;
	}
	codec_info(codec,
		   "AE-9: CA0113 handshake: 0x208=0x%08x (poll %d)\n",
		   val, i);

	if (val == 0xffffffff)
		return false;

	/* Protocol state machine */
	writel(0x00800002, mem + 0x20c);
	readl(mem + 0x20c);
	writel(0x00800003, mem + 0x20c);
	readl(mem + 0x20c);
	writel(0x48, mem + 0x804);
	readl(mem + 0x804);
	writel(0x00800005, mem + 0x20c);
	readl(mem + 0x20c);
	msleep(19);
	writel(0x00800004, mem + 0x20c);
	readl(mem + 0x20c);
	writel(0x00800005, mem + 0x20c);
	readl(mem + 0x20c);
	writel(0x49, mem + 0x804);
	readl(mem + 0x804);
	writel(0x00800005, mem + 0x20c);
	readl(mem + 0x20c);

	/* Re-send CA0113 commands that were lost during init */
	ca0113_mmio_command_set_type2(codec, 0x48, 0x07, 0x81);
	ca0113_mmio_command_set(codec, 0x49, 0x0a, 0x07);
	ca0113_mmio_gpio_set(codec, 2, false);
	ca0113_mmio_command_set(codec, 0x48, 0x1d, 0x40);
	ca0113_mmio_command_set(codec, 0x48, 0x0d, 0x00);
	ca0113_mmio_command_set(codec, 0x48, 0x17, 0x00);
	ca0113_mmio_command_set(codec, 0x48, 0x19, 0x00);
	ca0113_mmio_command_set(codec, 0x48, 0x11, 0xff);
	ca0113_mmio_command_set(codec, 0x48, 0x12, 0xff);
	ca0113_mmio_command_set(codec, 0x48, 0x13, 0xff);
	ca0113_mmio_command_set(codec, 0x48, 0x14, 0x7f);
	ca0113_mmio_command_set(codec, 0x48, 0x1d, 0x80);

	spec->ca0113_ready = true;
	codec_info(codec, "AE-9: CA0113 alive, commands sent\n");
	return true;
}
```

**Note sur le poll :** Réduit de 100 à **20 iterations** (1 seconde max au lieu de 5s).
Au boot normal ça échoue de toute façon — inutile de bloquer 5s. Le delayed_work
retente avec un poll plus long.

---

## Task 3 : Ajouter le delayed_work handler

Insérer **juste après** `ae9_ca0113_handshake()` :

```c
/*
 * AE-9: Deferred CA0113 handshake worker.
 *
 * Scheduled 15s after ae9_setup_defaults() completes. This covers the
 * case where the CA0113 is not yet responsive at init time (normal boot)
 * but becomes responsive a few seconds later (observed ~20s post-boot
 * with blacklist+modprobe). Does nothing if the handshake already
 * succeeded at init time.
 */
static void ae9_ca0113_deferred_work(struct work_struct *work)
{
	struct ca0132_spec *spec = container_of(
		to_delayed_work(work), struct ca0132_spec, ae9_ca0113_work);
	struct hda_codec *codec = spec->codec;

	if (spec->ca0113_ready)
		return;

	codec_info(codec, "AE-9: deferred CA0113 handshake attempt\n");
	ae9_ca0113_handshake(codec);
}
```

**Important :** `spec->codec` doit exister — vérifier qu'il est bien stocké dans ca0132_spec.
```bash
grep -n "spec->codec\b" ~/ae9_build/build/ca0132.c | head -5
```
Si le champ n'existe pas, chercher comment le codec est accessible depuis spec (peut-être via `codec->spec` uniquement — dans ce cas utiliser un pattern différent, voir note ci-dessous).

**Note si spec->codec n'existe pas :**
Utiliser `container_of` différemment en stockant le codec dans la spec. Ajouter dans la struct :
```c
	struct hda_codec *codec;  /* back-pointer for delayed_work */
```
Et dans `ca0132_init()` après `codec->spec = spec;` :
```c
	spec->codec = codec;
```

---

## Task 4 : Remplacer le code inline dans `ae9_setup_defaults()`

**Step 1 :** Trouver exactement les lignes du bloc handshake inline (le bloc `{ void __iomem *mem = spec->mem_base; ... }` lignes ~9920-9983).

```bash
grep -n "CA0113 handshake\|void __iomem \*mem = spec->mem_base\|ca0113.*dead\|ca0113.*alive\|ca0113.*commands" ~/ae9_build/build/ca0132.c
```

**Step 2 :** Remplacer tout le bloc inline par :
```c
	/*
	 * AE-9: Attempt CA0113 handshake. Best-effort at init time;
	 * ae9_ca0113_deferred_work() will retry 15s later if this fails.
	 */
	ae9_ca0113_handshake(codec);
```

**Step 3 :** Juste avant `ae9_keepalive_start(spec);` en fin de `ae9_setup_defaults()`, ajouter :
```c
	/* Schedule deferred CA0113 retry in case the handshake failed above */
	if (!spec->ca0113_ready)
		schedule_delayed_work(&spec->ae9_ca0113_work,
				      msecs_to_jiffies(15000));
```

---

## Task 5 : Initialiser et annuler le delayed_work

### 5a : Init dans `ca0132_init()`

Trouver où `INIT_DELAYED_WORK(&spec->unsol_hp_work, ...)` est appelé et ajouter juste après (uniquement pour AE-9) :

```bash
grep -n "INIT_DELAYED_WORK\|unsol_hp_work" ~/ae9_build/build/ca0132.c
```

Ajouter dans `ca0132_init()` au même endroit :
```c
	if (ca0132_quirk(spec) == QUIRK_AE9)
		INIT_DELAYED_WORK(&spec->ae9_ca0113_work, ae9_ca0113_deferred_work);
```

### 5b : Annulation dans `ca0132_free()`

Trouver `cancel_delayed_work_sync(&spec->unsol_hp_work)` et ajouter juste après :
```c
	if (ca0132_quirk(spec) == QUIRK_AE9)
		cancel_delayed_work_sync(&spec->ae9_ca0113_work);
```

Vérifier qu'il n'y a qu'un seul endroit où c'est annulé :
```bash
grep -n "cancel_delayed_work\|ca0132_free\|ca0132_remove" ~/ae9_build/build/ca0132.c | head -10
```

---

## Task 6 : Build et test

**Step 1 : Build**
```bash
cd ~/ae9_build && make -C /lib/modules/$(uname -r)/build M=$(pwd)/build modules 2>&1 | tail -20
```
Expected : `Building modules, stage 2.` ... `snd-hda-codec-ca0132.ko`

**Step 2 : Install**
```bash
sudo rm -f /lib/modules/$(uname -r)/kernel/sound/hda/codecs/snd-hda-codec-ca0132.ko.zst
sudo cp ~/ae9_build/build/snd-hda-codec-ca0132.ko /lib/modules/$(uname -r)/kernel/sound/hda/codecs/
sudo depmod -a
```

**Step 3 : Poweroff (JAMAIS reboot)**
```bash
sudo poweroff
```

**Step 4 : Après boot normal, attendre 20s puis vérifier**
```bash
# Attendre 20s après le login pour que le delayed_work ait eu le temps de s'exécuter
dmesg | grep "CA0113\|ca0113\|AE-9.*handshake\|AE-9.*deferred"
```

Expected output (si ça marche) :
```
AE-9: CA0113 handshake: 0x208=0xffffffff (poll 19)   ← init attempt fails fast
AE-9: deferred CA0113 handshake attempt               ← 15s later
AE-9: CA0113 handshake: 0x208=0xffff4141 (poll N)    ← success!
AE-9: CA0113 alive, commands sent
```

**Step 5 : Tester l'audio**
```bash
# Masquer PipeWire d'abord
systemctl --user stop pipewire pipewire-pulse wireplumber

# Générer un son de test
speaker-test -D hw:0,0 -c 2 -t sine -l 1 2>&1 | tail -5
# OU
aplay -D hw:0,0 /tmp/test.wav
```

---

## Task 7 : Si ça ne marche toujours pas — diagnostic registres

**But :** Comparer l'état du matériel entre boot normal et blacklist+modprobe pour identifier la vraie différence.

**Step 1 :** Boot normal, attendre 25s (après le delayed_work), capturer :
```bash
sudo python3 ~/ae9_build/dump_regs.py > ~/ae9_build/docs/bar2_normal_boot.txt
dmesg > ~/ae9_build/docs/dmesg_normal_boot.txt
cat ~/ae9_build/docs/bar2_normal_boot.txt
```

**Step 2 :** Créer le blacklist, rebooter, charger manuellement :
```bash
echo "blacklist snd_hda_intel" | sudo tee /etc/modprobe.d/blacklist-hda.conf
sudo poweroff
# Après reboot :
sudo setpci -s 25:00.0 COMMAND=0x06
sudo modprobe snd_hda_intel power_save=0 power_save_controller=N
sleep 20
sudo python3 ~/ae9_build/dump_regs.py > ~/ae9_build/docs/bar2_blacklist_boot.txt
diff ~/ae9_build/docs/bar2_normal_boot.txt ~/ae9_build/docs/bar2_blacklist_boot.txt
```

**Step 3 :** Retirer le blacklist
```bash
sudo rm /etc/modprobe.d/blacklist-hda.conf
```

---

## Ordre d'exécution

```
Task 1  → ajouter ca0113_ready + ae9_ca0113_work dans la struct    [5 min]
Task 2  → créer ae9_ca0113_handshake()                             [15 min]
Task 3  → créer ae9_ca0113_deferred_work()                         [5 min]
Task 4  → remplacer le inline dans ae9_setup_defaults()            [5 min]
Task 5  → init + cancel du delayed_work                            [5 min]
Task 6  → build + install + poweroff + test                        [15 min]
Task 7  → seulement si Task 6 échoue                               [30 min]
```

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|-----------|
| `spec->codec` n'existe pas | Compilation fail | Voir note Task 3 |
| 15s pas assez long | Handshake encore 0xffffffff | Augmenter à 20s ou 25s |
| delayed_work s'exécute pendant suspend/resume | Race condition | `cancel_delayed_work_sync` au suspend |
| CA0113 vivant mais toujours pas de son | Pipeline broken | Vérifier LPIB SD4 + ES9038 DAC |
| Codec reset libère CA0113 | Handshake re-requis | Ne pas reset après handshake |
