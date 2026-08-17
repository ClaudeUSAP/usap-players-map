#!/bin/bash
# Deploy une nouvelle version vers GitHub Pages
# Run automatiquement par launchd (com.usap.players-deploy.plist) quand index.html change
# Manuel : bash deploy.sh "V23 — feature description"

set +e  # Ne crashe pas — log les erreurs

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMIT_MSG="${1:-Auto-deploy $(date +%Y-%m-%d-%H%M)}"
LOG="$REPO_DIR/deploy.log"

echo "" >> "$LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Deploy triggered: $COMMIT_MSG" >> "$LOG"

cd "$REPO_DIR" || { echo "❌ Cannot cd to $REPO_DIR" >> "$LOG"; exit 0; }

if [ ! -d ".git" ]; then
  echo "❌ Pas un git repo. Run setup-github-pages.sh d'abord" >> "$LOG"
  exit 0
fi

# Strip Cowork-only metadata + internal references avant publication
# (le fichier source est régénéré par Cowork avec ces tags ; on les enlève côté repo public)
# Repoint toutes les URLs SCOUT de l'ancien projet US vers l'EU (le source Cowork utilise encore l'US).
# Substitution globale = BSD/macOS-safe (l'ancien `c\` n'était pas compatible macOS et ne matchait pas l'US).
sed -i.tmp \
  -e '/<script type="application\/json" id="cowork-artifact-meta">/,/<\/script>/d' \
  -e 's|^// Helper photo URL: SCOUT storage|// Helper photo URL|' \
  -e 's|qusqisznwpdrvpwlnnpq|bfxhruvkzidvznsyyryp|g' \
  index.html
rm -f index.html.tmp

# Stage seulement les fichiers du repo (évite versions/ et autres).
# On ajoute chaque chemin individuellement : un chemin absent (ex: photos/ pas
# présent localement) ne doit PAS faire échouer tout le `git add` (sinon plus
# rien n'est stagé et le deploy croit qu'il n'y a "aucun changement").
for path in index.html player_rankings.html README.md CNAME photos; do
  [ -e "$path" ] && git add "$path" 2>>"$LOG"
done

if git diff --cached --quiet 2>>"$LOG"; then
  echo "→ Pas de changements à deployer" >> "$LOG"
  exit 0
fi

echo "→ Commit: $COMMIT_MSG" >> "$LOG"
git commit -m "$COMMIT_MSG" >>"$LOG" 2>&1

echo "→ Push to origin/main..." >> "$LOG"
if git push origin main >>"$LOG" 2>&1; then
  echo "✅ Deployed → https://claudeusap.github.io/usap-players-map/" >> "$LOG"
  echo "✅ Deployed → https://claudeusap.github.io/usap-players-map/"
else
  echo "❌ Push failed (voir log)" >> "$LOG"
  echo "❌ Push failed — vérifie SSH auth ou network. Log: $LOG"
  exit 0  # Ne crashe pas launchd
fi
