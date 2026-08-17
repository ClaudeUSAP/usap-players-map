#!/bin/bash
# Install launchd watcher pour auto-deploy USAP Players artifact
# Run UNE fois pour activer le watcher

set -e

PLIST_NAME="com.usap.players-deploy.plist"
LABEL="com.usap.players-deploy"
SOURCE_PLIST="/Users/nicolas/Documents/Claude/Artifacts/usap-players-ncaa/$PLIST_NAME"
TARGET_PLIST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "→ Copie le plist vers ~/Library/LaunchAgents/..."
mkdir -p "$HOME/Library/LaunchAgents"
cp "$SOURCE_PLIST" "$TARGET_PLIST"

# Si déjà chargé, unload d'abord (clean reload)
if launchctl list | grep -q "$LABEL"; then
  echo "→ Déjà chargé, unload pour reload..."
  launchctl unload "$TARGET_PLIST" 2>/dev/null || true
fi

echo "→ Load le watcher..."
launchctl load "$TARGET_PLIST"

if launchctl list | grep -q "$LABEL"; then
  echo ""
  echo "✅ Watcher actif"
  echo ""
  echo "À chaque update du fichier:"
  echo "  /Users/nicolas/Documents/Claude/Artifacts/usap-players-ncaa/index.html"
  echo ""
  echo "→ deploy.sh sera lancé automatiquement (commit + push GitHub)"
  echo "→ Site live updaté à https://claudeusap.github.io/usap-players-map/ ~30s après"
  echo ""
  echo "Logs en cas de souci:"
  echo "  tail -f ~/Documents/Claude/Artifacts/usap-players-ncaa/deploy.log"
  echo ""
  echo "Pour désactiver:"
  echo "  launchctl unload $TARGET_PLIST"
else
  echo "❌ Échec du load. Vérifie le plist:"
  echo "  plutil -lint $TARGET_PLIST"
fi
