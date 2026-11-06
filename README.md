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
autres périphériques audio. La capture et le micro AE-9 sont activés par défaut depuis `micdefault1` ;
les paramètres `ae9_capture=0` ou `ae9_mic=0` bloquent la capture principale.

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

- `hpauto4` : controle partage `Headphone+LO` pour le chemin casque et
  ligne, avec notification du muet Master. Son, muet et synchronisation
  ACM/Mint dans les deux sens confirmes par l'utilisateur.

  La synchronisation materielle exige que `api.alsa.soft-mixer` ne soit
  pas force a `true`. La valeur standard est `false` ; l'ancienne regle
  locale de depannage doit etre corrigee si elle est encore presente.
  Le pilote ne modifie pas les fichiers de configuration de la session.

- `hpauto5` : pas HDA réels et décibels ALSA alignés, plafond à 0 dB,
  affichage ACM calculé sur le gain effectif. L'utilisateur confirme
  l'accord au maximum avec Mint et les points intermédiaires ; −90 dB
  correspond à environ 3,2 %, le muet restant distinct.

Référence historique de `hpauto5` : Linux Mint 22.3, XanMod
`7.2.14-x64v3-xanmod1`, avec `iommu=pt`,
`ae9_capture=0`, `ae9_mic=0` et `ae9_acm_poll=1`. Cela ne qualifie pas
les autres noyaux, la capture, la reprise de veille ou les autres cartes.
Un délai ACM/Mint subsiste et reste en cours de mesure ; aucune modification
des échanges d'entretien destinée à le réduire n'est incluse.

- `hpauto5-displayui1` : envoi UART dédié à l'affichage et rafraîchissement
  demandé par les changements de volume/muet dans Mint (échéance de 20 ms,
  espacement de 50 ms entre envois). Les échanges d'entretien restent
  prioritaires sur une workqueue unique ; un entretien en cours peut
  encore retarder l'écran. L'utilisateur a confirmé que l'affichage suit
  mieux le curseur, avec des retards résiduels observés jusqu'à 696 ms.
  Cette version n'est pas une validation du micro ou de la capture.

- `pci1` (cœur HDA) : les quatre lectures de vidage ajoutées par la base
  DarkNikGr sont réservées au contrôleur PCI `1102:0010`, sous-système
  `1102:0071`. Aucun champ partagé n'est ajouté. Le cœur HDA reste commun
  aux autres cartes ; leur campagne matérielle de non-régression reste à
  faire. Le cœur `4976E15962035D24EDB04AA` a été utilisé sur la machine de
  référence sans `iommu=pt`, avec un domaine `DMA-FQ`.

- `knobtx1` : émetteur borné propre aux requêtes de molette C2, utilisant
  le statut DWORD à `BAR2+0xC7C`. Un échec arrête ce chemin, sans réémettre
  une trame partielle. Sur l'essai instrumenté, durée moyenne de la requête
  au repos : environ 42,5 → 1,54 ms ; 61 réponses C2 vérifiées. Le son est
  confirmé par l'utilisateur. Ce temps de fonction n'est pas une mesure du
  délai entre le mouvement physique et l'affichage. Les délais programmés
  restent inchangés ; la cadence réelle peut avancer avec le worker raccourci.

- `buttontx1` : émetteur borné distinct pour les requêtes boutons B1,
  avec arrêt avant réception après échec TX. Sur l'essai : 66 réponses B1
  conformes, requêtes d'environ 53 → 1,4–1,5 ms et 500 → 0 attentes TX.
  Au repos, sous les mêmes sondes, le worker passe de 2,13 à 1,88 % d'un
  cœur et de 4 598 à 3 952 réveils/s par rapport à `knobtx1` : un relevé
  comparatif, sans preuve d'économie électrique ni de latence physique.
  Les appuis physiques et la stabilité prolongée ne sont pas qualifiés par
  la seule observation de réponses B1 au repos.

- `micdefault1` : initialise le micro DSP et expose la capture principale
  par défaut (`ae9_mic=1`, `ae9_capture=1`). Désactiver explicitement l'un
  des deux paramètres continue de bloquer la capture principale. Les corps
  des fonctions et les optimisations ACM restent identiques à `buttontx1`.

La combinaison `pci1` + `knobtx1` + `buttontx1` + `micdefault1` a été essayée
sur Linux Mint 22.3 / XanMod `7.2.14-x64v3-xanmod1`, sans `iommu=pt`, avec
`ae9_capture=1`, `ae9_mic=1` et `ae9_acm_poll=1`. L'utilisateur confirme un
vocal Discord fonctionnel au casque-micro ACM. Les 180 relevés montrent des
compteurs ERR à 0 pour le micro et les flux Discord, et un compteur lecture
à 1 dès le premier relevé actif, ensuite stable ; sa cause est indéterminée.
Aucun nouveau message noyau n'est apparu pendant ce relevé. Les gels signalés
ailleurs ne sont pas expliqués par cet essai ; plusieurs heures, plusieurs
démarrages, les autres cartes, noyaux et sorties restent à qualifier.
Les règles locales de session utilisées pour cet essai ne sont pas installées
par ce dépôt.

## Corrections de l’audit

Cette série conserve le diagnostic opt-in `clockdiag3` dans un prérequis
séparé, car il était activé pendant les essais matériels de référence.
Sa valeur par défaut reste zéro. Les scripts de mesure et les outils
personnels ne sont pas distribués.

- `clockdiag3` : Conserver séparément le diagnostic opt-in employé par les variantes réellement essayées. Désactivé par défaut, il ne corrige ni ne reprogramme les fréquences audio.

- `dead` : Supprimer le diagnostic différé jamais planifié et son état privé. Le dump actif de démarrage reste présent.

- `acmfix1` : Vérifier enveloppe, opcode, taille, direction et terminaison des réponses ACM avant toute action ALSA. Préserver les octets F7 présents dans les données.

- `filterfix1` : Exposer les sept filtres ES9038Q2M valides et préserver la consigne lors des changements de sortie et de muet.

- `pmfix1` : Terminer la détection avant de prendre le maintien PM, afin de ne pas attribuer la référence AE-9 au codec secondaire DBPro.

- `dspfix2` : Propager les erreurs DMA, loader et overlay. Arrêter proprement une initialisation échouée et limiter l’exception PM EACCES au probe avant enregistrement et activation runtime-PM.

- `shutdownfix1` : Utiliser les DAC, GPIO et flux propres à l’AE-9 pour mettre la carte et l’ACM au repos, sans reprendre les commandes d’arrêt AE-5.

- `cleanup1` : Corriger les commentaires de configuration et les noms trompeurs sans modifier les transactions matérielles.

- `refactor1` : Regrouper les couples registre/valeur, les trames communes et les fonctions ACM. Conserver ordre, répétitions, valeurs et temporisations.

- `headerfix1` : Regrouper les inclusions et séparer constantes, compatibilité workqueue et paramètres. Corriger les commentaires capture et sourdine sans changer les fonctions.

Les contrôles de cette adaptation comprennent compilation et simulations sur
XanMod 7.2.14. Les sources finales sont identiques aux variantes de l’audit essayées sur
la machine de référence, avec diagnostic activé. Ces observations ne
constituent pas une qualification universelle. Les appuis limites, autres cartes, autres noyaux
et la veille/reprise ne sont pas universellement qualifiés. Le correctif
UART de maintenance encore en étude n’est pas inclus.

## Maintenance ACM, molette et présence micro

- `mainttx2` : Attendre le statut Creative sur 32 bits pour les transmissions de maintenance ; arrêter les échanges après une erreur ou une trame partielle.
- `overlayfix1` : Retirer le transfert direct B redondant de l’overlay DSP, en conservant A+C, les contrôles d’erreur et le nettoyage.
