#!/bin/bash

echo "----------------------------------------------"
echo "--------- RESTORING BACKUP -------------------"
echo "----------------------------------------------"

# Verifica se o diretório de backup existe no diretório atual
BACKUP_DIR="$(pwd)/mintmacify_backup_*"
if [ -z "$(ls -d $BACKUP_DIR 2>/dev/null)" ]; then
  echo "Nenhum backup encontrado. Nada para restaurar."
  exit 1
fi

# Seleciona o backup mais recente
LATEST_BACKUP=$(ls -d $BACKUP_DIR | tail -n 1)

echo "Restaurando backup de: $LATEST_BACKUP"

# Restaura as configurações do Cinnamon (dconf)
dconf load / < "$LATEST_BACKUP/cinnamon_settings_backup.dconf"

# Restaura temas, ícones e cursores
sudo cp -r "$LATEST_BACKUP/themes/"* /usr/share/themes/ 2>/dev/null || true
sudo cp -r "$LATEST_BACKUP/icons/"* /usr/share/icons/ 2>/dev/null || true
sudo cp -r "$LATEST_BACKUP/cursors/"* /usr/share/icons/ 2>/dev/null || true

# Restaura arquivos de configuração do GTK
cp -r "$LATEST_BACKUP/gtk/"* ~/.config/ 2>/dev/null || true

# Restaura configurações do Plank
cp -r "$LATEST_BACKUP/plank/plank" ~/.config/ 2>/dev/null || true
cp -r "$LATEST_BACKUP/plank/plank" ~/.local/share/ 2>/dev/null || true

# Restaura configurações do Ulauncher
cp -r "$LATEST_BACKUP/ulauncher/ulauncher" ~/.config/ 2>/dev/null || true

echo "Backup restaurado com sucesso."


echo "----------------------------------------------"
echo "--------- REMOVING INSTALLED PACKAGES --------"
echo "----------------------------------------------"

# Remove os pacotes instalados
sudo apt remove --purge ulauncher plank -y
sudo apt autoremove -y

echo "Pacotes removidos com sucesso."

echo "----------------------------------------------"
echo "--------- CLEANING UP ------------------------"
echo "----------------------------------------------"

# Remove os temas, ícones e cursores instalados pelo script
sudo rm -rf /usr/share/themes/WhiteSur*
sudo rm -rf /usr/share/icons/WhiteSur*
sudo rm -rf /usr/share/icons/McMojave-cursors

# Remove diretórios temporários
rm -rf ~/temp_mintmacify

echo "Limpeza concluída."

echo "----------------------------------------------"
echo "--------- RESTARTING CINNAMON ----------------"
echo "----------------------------------------------"

# Reinicia o Cinnamon para aplicar as mudanças
cinnamon --replace >/dev/null 2>&1 &

echo "Desinstalação concluída. Reinicie a sessão para aplicar todas as alterações."
