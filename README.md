# Sound Blaster AE-9 — pilote Linux

Sources du pilote CA0132 et du cœur HDA provenant de
[DarkNikGr/sb-ae9](https://github.com/DarkNikGr/sb-ae9), révision
`f33f44c7c49d127aff3d9e9133a8ab51732b9966`, puis améliorations locales.
Les licences et mentions des auteurs d'origine sont conservées.
Le dossier `docs/` existant conserve les archives du projet.

Ce dépôt contient les sources, en-têtes, Makefiles et `dkms.conf` nécessaires
aux deux modules. Les outils graphiques, scripts de diagnostic, binaires et
firmwares propriétaires ne sont pas inclus.

## Compilation sans installation

Prérequis : en-têtes du noyau démarré, `make` et compilateur correspondant.
Depuis la racine du dépôt :

```bash
make -C driver/hda-core KDIR="/lib/modules/$(uname -r)/build"
make -C driver/ca0132 KDIR="/lib/modules/$(uname -r)/build"
```

Pour un noyau compilé avec LLVM 21, ajouter `LLVM=-21` aux deux commandes.
Les fichiers produits sont `driver/hda-core/snd-hda-core.ko` et
`driver/ca0132/snd-hda-codec-ca0132.ko`. Ces commandes ne les installent pas.
Une compilation réussie ne valide ni le son ni l'ABI des en-têtes privés HDA.

## Firmware et essais

Le pilote utilise le firmware CA0132 (`ctefx-desktop.bin`, avec repli sur
`ctefx.bin`) et l'overlay AE-9 `ae9-dsp-output-overlay.bin`. Consulter les
[instructions d'origine](https://github.com/DarkNikGr/sb-ae9#readme) pour leur
provenance et leur extraction. Aucun firmware propriétaire n'est redistribué.

L'installation et le chargement des modules demandent une procédure adaptée
au noyau, avec un module de secours. Le module HDA commun affecte aussi les
autres périphériques audio. La capture AE-9 reste désactivée par défaut.

## Versions

- Base DarkNikGr : sources du pilote inchangées. Sur le noyau XanMod 7.2.14
  étudié ici, l'adaptation ABI du commit suivant est nécessaire avant essai.

- `abi1` : disposition de `hda_multi_out` alignee sur celle du noyau
  `7.2.14-x64v3-xanmod1` pour eviter un ecrasement des broches de sortie
  par le helper SPDIF natif. Lecture casque confirmee par l'utilisateur
  dans cette configuration ; autres noyaux non qualifies.

- `hpauto2` : detection de la fiche casque ACM et bascule automatique vers
  `Headphone` a l'insertion, `Speakers` au retrait. Reponses ACM `83`
  validees et changements observes sur le materiel de reference.
