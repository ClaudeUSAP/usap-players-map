#!/bin/bash
# Setup initial — à run UNE seule fois
# Pré-requis : GitHub repo "usap-players-map" créé manuellement sur github.com (public)
#   → Aller sur https://github.com/new
#   → Repository name: usap-players-map
#   → Public
#   → ☐ NE PAS cocher "Add a README" (on en a déjà un local)
#   → Create repository

set -e

REPO_DIR="/Users/nicolas/Documents/Claude/Artifacts/usap-players-ncaa"
GITHUB_USER="ClaudeUSAP"
REPO_NAME="usap-players-map"

cd "$REPO_DIR"

# Init git si pas déjà fait
if [ ! -d ".git" ]; then
  echo "→ Init git..."
  git init -b main
fi

# Add remote si pas déjà
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "→ Add remote..."
  git remote add origin "git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
fi

# Génère .gitignore (silencieux si existe)
cat > .gitignore <<'GIEOF'
.DS_Store
*.swp
*.tmp
node_modules/
.env
GIEOF

# Génère README si manquant
if [ ! -f README.md ]; then
  cat > README.md <<'READEOF'
# USAP Players in NCAA

Visualisation interactive des joueurs européens placés par [US Athletic Performance](https://usathleticperformance.com) dans les programmes universitaires américains (NCAA D1/D2, NAIA, NJCAA).

🌐 **Live** : https://claudeusap.github.io/usap-players-map/

## Features
- Carte interactive des USA avec pin par fac
- Filtre par genre, classe (Freshman/Sophomore/...), division NCAA
- Filtre par club français + académie / centre de performance
- Modal joueur avec photo, scoring trend, ranking français history
- Snapshots historiques (saisons 2023/24, 2024/25, courante)
- Bilingue FR / EN

## Mises à jour
- Hebdo (lundi) : Scoreboard rankings via tâche `usap-college-golf-tracker`
- Mensuel (1er) : FFGOLF + Scoreboard global via tâche `usap-rankings-monthly-update`
- Manuel : ajout/retrait joueurs, clubs, IG handles

## Source de données
- FFGOLF (rankings amateurs FR)
- Scoreboard.clippd.com (stats NCAA)
- European Golf Rankings (joueurs internationaux)
- Données internes USAP (placements, transferts)

## Confidentialité
Données présentées avec consentement des joueurs/représentants légaux.
Pour signaler une erreur ou demander un retrait : nicolas@usathleticperformance.com

© 2026 US Athletic Performance SA · Suisse
READEOF
fi

# Premier commit + push
echo "→ Add files..."
git add index.html README.md .gitignore
if git diff --cached --quiet; then
  echo "→ Rien à commit"
else
  git commit -m "Initial deploy — USAP Players in NCAA visualization"
fi

echo "→ Push to ${GITHUB_USER}/${REPO_NAME}..."
git push -u origin main

echo ""
echo "✅ Setup OK"
echo ""
echo "Prochaine étape (manuelle, 30s) :"
echo "  1. Va sur https://github.com/${GITHUB_USER}/${REPO_NAME}/settings/pages"
echo "  2. Source: 'Deploy from a branch'"
echo "  3. Branch: 'main' / folder '/ (root)'"
echo "  4. Save"
echo "  5. Attends ~1 min, le site sera live à :"
echo "     https://${GITHUB_USER,,}.github.io/${REPO_NAME}/"
echo ""
echo "Pour les updates suivantes, run : bash deploy.sh"
