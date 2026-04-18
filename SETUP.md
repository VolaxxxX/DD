# AETHER DRIFT — SETUP (Débutant)

Guide pas-à-pas pour lancer le projet. Suis les étapes dans l'ordre, tu n'as rien à coder.

---

## 1. Installer Godot 4.3

1. Va sur https://godotengine.org/download
2. Télécharge **Godot Engine 4.3 (Standard)** pour ton OS (Windows / macOS / Linux).
3. Dézippe → lance `Godot_v4.3-stable_xxx` (pas besoin d'installer, c'est portable).

---

## 2. Ouvrir le projet

1. Clone ce repo ou télécharge le ZIP de la branche `claude/mobile-game-mvp-9riFM`.
2. Lance Godot → clique **Import**.
3. Sélectionne le fichier `project.godot` à la racine du projet.
4. Clique **Import & Edit**.

---

## 3. Lancer le jeu (PC test)

1. Dans Godot, appuie sur **F5** (ou l'icône ▶ en haut à droite).
2. Si Godot demande la scène principale, choisis `main.tscn`.
3. Le jeu démarre. Tu devrais voir :
   - un terrain coloré (biome généré)
   - des silhouettes (créatures) qui se baladent
   - un personnage blanc (toi)

### Commandes clavier :
- **ZQSD** ou **WASD** : se déplacer
- **Espace** : interagir avec la créature la plus proche (combat ou dialogue selon son archétype)
- **Page Down** : passer à la zone suivante

Regarde la console Godot en bas : tu verras les logs `[ZONE]`, `[ECO]`, `[APEX]`, `[RUN]`.

---

## 4. Export Android (plus tard)

Quand tu es prêt à tester sur mobile :

1. Dans Godot : **Editor → Manage Export Templates** → Download.
2. Installe **Android Studio** (pour le SDK) : https://developer.android.com/studio
3. **Editor → Editor Settings → Export → Android** : renseigne les chemins du SDK.
4. **Project → Export** → Add → **Android** → Export Project.
5. Active **Use Gradle Build** dans les options Android.

---

## 5. Structure des fichiers

```
project.godot           ← config Godot
main.tscn / main.gd     ← scène principale
core/                   ← seed, rng, event bus, orchestrator, memory
world/                  ← génération zones
entity/                 ← archétypes + IA + écosystème
apex/                   ← dragons (modificateurs d'écosystème)
fate/                   ← RNG caché + résolution d'événements
net/                    ← multijoueur (ENet)
coop/                   ← votes coop
render/                 ← vues 2.5D
ui/                     ← HUD
player/                 ← personnage jouable
```

---

## 6. Prochaines étapes

Une fois que le jeu tourne chez toi :
1. Dis-moi "**ça marche**" et on passe aux **assets** (vrais sprites de créatures).
2. Ou bien "**ça plante**" + copie l'erreur de la console, je corrige.
3. Ensuite on branche le **multijoueur LAN** pour tester à 2.

---

## Dépannage rapide

| Problème | Solution |
|---|---|
| "Parser Error" dans un .gd | Vérifie que la version Godot est bien 4.3 (pas 4.2 ni 3.x) |
| Écran noir au lancement | Console Godot → cherche `ERROR` rouge et colle-le moi |
| Rien ne bouge | Les inputs ZQSD sont mappés ; clique sur la fenêtre avant de presser les touches |
| Pas de créatures visibles | Zoom caméra : elles sont petites, regarde de près |
