# AETHER DRIFT — SETUP (Débutant)

## 1. Installer Godot 4.3+

https://godotengine.org/download — version **Standard** (pas .NET)

## 2. Ouvrir le projet

1. Lance Godot → **Import** → sélectionne `project.godot` → **Import & Edit**
2. Si Godot propose la migration 4.3 → 4.6, accepte.

## 3. Jouer

Appuie **F5**. Choisis `main.tscn` si demandé.

### Comment on joue

- Tu vois une **créature 3D** au centre (humanoïde / bête / mort-vivant / construct / élémentaire / chose / fée / draconide — chacune est visuellement distincte).
- Le décor change selon le biome (forêt / cité / ruines / corrompu / anomalie).
- En bas, **3 phrases** apparaissent : ce sont tes choix.
- Tu **cliques une phrase** (ou touches sur mobile) → narration du résultat → la créature réagit (tombe, fuit, mute…).
- 4 rencontres par zone, 2 à 4 zones par run.
- **Permadeath** : quand ta vie tombe à 0, la run se termine.

### Tons des choix (couleurs des boutons)

- 🟥 **Rouge** = Agressif (attaque)
- 🔵 **Bleu** = Diplomatique (parler — marche seulement si créature intelligente)
- 🟡 **Jaune** = Prudent (fuir / se cacher)
- 🟣 **Violet** = Curieux (observer — biomes mystérieux uniquement)

Chaque choix est **un jet caché** : la force (FORCE), la difficulté de la créature, la corruption de la zone et le hasard décident. Tu ne vois **jamais** les chiffres — seulement les conséquences.

## 4. Export Android (plus tard)

Godot : **Editor → Manage Export Templates** → Download → puis **Project → Export → Android**.

## 5. Structure du code

```
core/           seed, RNG, event bus, orchestrator, mémoire persistante
world/          génération de zones (biome, chaos, corruption)
entity/         archétypes (8 familles × 6 raretés), FSM, écosystème
apex/           système dragons (modificateurs d'écosystème)
fate/           RNG caché (d20) + résolveur d'événements
game/           phrase pool, Encounter, SceneDirector
render/         Creature3D (formes 3D par famille), Decor3D, Backdrop3D, Animator
ui/             game_ui (narration + boutons de choix)
net/ coop/      multijoueur ENet + votes coop (MVP)
player/         stats joueur
```

## 6. Dépannage

| Problème | Solution |
|---|---|
| Erreurs "Parse Error" | Vérifie Godot 4.3+, puis **Project → Reload Current Project** |
| Écran noir | Console en bas → colle-moi les lignes rouges |
| Boutons ne réagissent pas | Clique sur la fenêtre avant |
| Créature absente | Attends 2s (intro de zone s'affiche d'abord) |
