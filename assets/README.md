# Tiara — assets externes

Le moteur charge automatiquement les modèles GLB depuis ce dossier.
**S'il en trouve un, il l'utilise. Sinon, le rendu procédural prend le relais.**

## Convention de nommage

Place les fichiers dans `assets/models/` avec ces noms exacts.
Une *fallback* par famille suffit pour habiller toutes les créatures procédurales.

### Par créature (priorité 1)
```
<id>.glb
```
Exemple : `dire_wolf.glb`, `lich_scholar.glb`, `thorn_duchess.glb`.
Les IDs sont dans `entity/creature_registry.gd`.

### Fallback par famille (priorité 2)
```
family_humanoid.glb
family_beast.glb
family_undead.glb
family_construct.glb
family_elemental.glb
family_aberration.glb
family_fey.glb
family_draconic.glb
```

### Dragons (11 IDs)
```
dragon_<id>.glb        (cinderborn, stormfather, rotcrown, mire_king,
                        hollowfrost, lawbringer, moonvowed, tidekeeper,
                        silvertongue, veilstep, unlit_wyrm)
dragon.glb             (fallback générique)
```

### World bosses (6 IDs)
```
boss_<id>.glb          (prismatic_ascendant, nameless_sovereign,
                        sea_beneath_stone, gallows_parliament,
                        silent_orchestra, that_which_dreams_us)
```

## Inclus par défaut (CC0)

Téléchargés depuis [glTF-Sample-Assets](https://github.com/KhronosGroup/glTF-Sample-Assets) :

- `family_beast.glb`     — Fox (animé, parfait pour loups/cerfs/lions)
- `family_humanoid.glb`  — CesiumMan (animé, marche)
- `family_construct.glb` — BrainStem (animé)
- `family_undead.glb`    — RiggedFigure (animé)

Ce sont des tests pour valider le pipeline. Remplace-les par mieux.

## Packs gratuits recommandés

Tous CC0 ou libre d'usage commercial sans attribution requise :

| Source | Style | Lien |
|---|---|---|
| **Quaternius** | Low-poly fantasy stylisé | https://quaternius.com |
| **Kenney – Mini Dungeon** | Voxel mignon | https://kenney.nl/assets/mini-dungeon |
| **Kenney – Fantasy Town Kit** | Bâtiments | https://kenney.nl/assets/fantasy-town-kit |
| **Kenney – Nature Kit** | Arbres / rochers | https://kenney.nl/assets/nature-kit |
| **Synty (gratuit) – POLYGON Knights Sample** | AAA stylisé | https://syntystore.com |
| **Sketchfab** (filtre CC0) | Tout | https://sketchfab.com/3d-models?features=downloadable&licenses=322a749bcfa841b29dff1e8a1bb74b0b |

### Méthode rapide
1. Téléchargez un pack Quaternius (par ex. *Fantasy Skeletons*)
2. Ouvrez Blender → ouvrez le .blend → exportez chaque créature en `.glb`
3. Renommez selon la convention ci-dessus
4. Déposez dans `assets/models/`
5. Relancez le jeu — le visuel est mis à jour automatiquement

## Animations

Si le GLB contient un `AnimationPlayer` avec au moins une animation,
elle est jouée en boucle automatiquement (idle / walk / fly).
