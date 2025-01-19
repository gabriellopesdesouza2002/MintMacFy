#!/bin/bash

echo "----------------------------------------------"
echo "--------- CREATING BACKUP --------------------"
echo "----------------------------------------------"

# Define o diretório de backup no mesmo local onde o script está sendo executado
BACKUP_DIR="$(pwd)/mintmacify_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup das configurações do Cinnamon (dconf)
dconf dump / > "$BACKUP_DIR/cinnamon_settings_backup.dconf"

# Backup dos temas, ícones e cursores instalados
mkdir -p "$BACKUP_DIR/themes"
cp -r /usr/share/themes/* "$BACKUP_DIR/themes/" 2>/dev/null || true
mkdir -p "$BACKUP_DIR/icons"
cp -r /usr/share/icons/* "$BACKUP_DIR/icons/" 2>/dev/null || true
mkdir -p "$BACKUP_DIR/cursors"
cp -r /usr/share/icons/* "$BACKUP_DIR/cursors/" 2>/dev/null || true

# Backup dos arquivos de configuração do GTK
mkdir -p "$BACKUP_DIR/gtk"
cp -r ~/.config/gtk-* "$BACKUP_DIR/gtk/" 2>/dev/null || true

# Backup das configurações do Plank
mkdir -p "$BACKUP_DIR/plank"
cp -r ~/.config/plank "$BACKUP_DIR/plank/" 2>/dev/null || true
cp -r ~/.local/share/plank "$BACKUP_DIR/plank/" 2>/dev/null || true

# Backup das configurações do Ulauncher
mkdir -p "$BACKUP_DIR/ulauncher"
cp -r ~/.config/ulauncher "$BACKUP_DIR/ulauncher/" 2>/dev/null || true

echo "Backup criado com sucesso em: $BACKUP_DIR"

echo "Installing Git"
sudo apt install git -y

echo "Installing ulauncher"
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update -y
sudo apt install ulauncher -y

echo "Installing WhiteSur-gtk-theme"
cd ~
mkdir -p temp_mintmacify
cd temp_mintmacify
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
./install.sh --darker

echo "Installing WhiteSur Icon Theme"
cd ~/temp_mintmacify
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh -b

echo "Installing McMojave cursors"
cd ~/temp_mintmacify
git clone https://github.com/vinceliuice/McMojave-cursors.git
cd McMojave-cursors
./install.sh
./build.sh

echo "Applying all themes"

echo "----------------------------------------------"
echo "--------- CHANGE CURSOR ----------------------"
echo "----------------------------------------------"

mkdir -p ~/.icons/default
cat <<EOL >~/.icons/default/index.theme
[Icon Theme]
Inherits=McMojave-cursors
EOL
xsetroot -cursor_name left_ptr
echo "Cursor updated."

echo "----------------------------------------------"
echo "--------- CHANGE GTK THEME -------------------"
echo "----------------------------------------------"

mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

echo '[Settings]' >~/.config/gtk-3.0/settings.ini
echo 'gtk-theme-name="WhiteSur-Dark"' >>~/.config/gtk-3.0/settings.ini
echo 'gtk-icon-theme-name="WhiteSur-dark"' >>~/.config/gtk-3.0/settings.ini

echo '[Settings]' >~/.config/gtk-4.0/settings.ini
echo 'gtk-theme-name="WhiteSur-Dark"' >>~/.config/gtk-4.0/settings.ini
echo 'gtk-icon-theme-name="WhiteSur-dark"' >>~/.config/gtk-4.0/settings.ini

dconf write /org/cinnamon/desktop/interface/gtk-theme "'WhiteSur-Dark'"
dconf write /org/cinnamon/desktop/interface/icon-theme "'WhiteSur-dark'"
dconf write /org/cinnamon/desktop/interface/cursor-theme "'McMojave-cursors'"
gsettings set org.cinnamon.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.cinnamon.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.cinnamon.desktop.interface cursor-theme "McMojave-cursors"

echo "GTK theme and icon theme set to WhiteSur-Dark and WhiteSur-dark."

echo "----------------------------------------------"
echo "--------- CLEAN ICON CACHE -------------------"
echo "----------------------------------------------"

rm -rf ~/.cache/icon-cache.kcache
rm -rf ~/.cache/thumbnails/*
echo "Cache cleared. Please restart the session manually to apply all changes."

echo "----------------------------------------------"
echo "--------- INSTALLING PLANK -------------------"
echo "----------------------------------------------"

# Instala o Plank
sudo apt update
sudo apt install plank -y

echo "Plank instalado com sucesso."

echo "----------------------------------------------"
echo "--------- COPYING PLANK THEMES ---------------"
echo "----------------------------------------------"

# Copia os temas do Plank para o diretório local de temas
mkdir -p ~/.local/share/plank/themes
cp -r ~/temp_mintmacify/WhiteSur-gtk-theme/src/other/plank/theme-* ~/.local/share/plank/themes

echo "Temas do Plank copiados para ~/.local/share/plank/themes."

echo "----------------------------------------------"
echo "--------- ADDING PLANK TO STARTUP ------------"
echo "----------------------------------------------"

# Adiciona o Plank aos aplicativos de inicialização
mkdir -p ~/.config/autostart
cat <<EOL >~/.config/autostart/plank.desktop
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Start Plank at login
EOL

echo "Plank adicionado aos aplicativos de inicialização."

echo "----------------------------------------------"
echo "--------- CONFIGURING PLANK ------------------"
echo "----------------------------------------------"

# Configura o Plank para ficar grudado na base da tela
dconf write /net/launchpad/plank/docks/dock1/position "'bottom'"
dconf write /net/launchpad/plank/docks/dock1/alignment "'center'"
dconf write /net/launchpad/plank/docks/dock1/offset 0
dconf write /net/launchpad/plank/docks/dock1/hide-mode "'none'"

# Adiciona o ícone de configurações ao Plank
dconf write /net/launchpad/plank/docks/dock1/dock-items "['plank.dockitem:/usr/share/applications/plank.desktop', 'plank.dockitem:/usr/share/applications/plank-settings.desktop']"

# Cria o arquivo .desktop para as configurações do Plank
mkdir -p ~/.local/share/applications
cat <<EOL >~/.local/share/applications/plank-settings.desktop
[Desktop Entry]
Name=Plank Settings
Comment=Configure Plank Dock
Exec=plank --preferences
Icon=plank
Terminal=false
Type=Application
Categories=Utility;Settings;
EOL

echo "Plank configurado para ficar na base da tela."
echo "Ícone de configurações adicionado automaticamente."

echo "----------------------------------------------"
echo "Instalação e configuração do Plank concluídas."
echo "Executando o Plank"
nohup plank >/dev/null 2>&1 &

echo "----------------------------------------------"
echo "--------- SETTING WORK BAR -------------------"
echo "----------------------------------------------"

# Move a barra de tarefas para o topo
dconf write /org/cinnamon/panels-enabled "['1:0:top']"

# Limpa a lista de applets habilitados
dconf write /org/cinnamon/enabled-applets "@as []"

# Adiciona os applets na ordem correta
dconf write /org/cinnamon/enabled-applets "[
  'panel1:left:0:menu@cinnamon.org:1',
  'panel1:right:0:notifications@cinnamon.org:3',
  'panel1:right:1:network@cinnamon.org:4',
  'panel1:right:2:sound@cinnamon.org:5',
  'panel1:right:3:calendar@cinnamon.org:6',
  'panel1:right:4:cornerbar@cinnamon.org:7'
]"

echo "Barra de tarefas configurada com sucesso."

echo "----------------------------------------------"
echo "--------- CONFIGURING CALENDAR APPLET --------"
echo "----------------------------------------------"

# Configura o calendário para exibir a hora e os segundos (formato de 24 horas)
dconf write /org/cinnamon/desktop/interface/clock-show-date false
dconf write /org/cinnamon/desktop/interface/clock-show-seconds true
dconf write /org/cinnamon/desktop/interface/clock-format "'24h'"

echo "Calendário configurado para exibir a hora e os segundos."

echo "----------------------------------------------"
echo "--------- RESTARTING CINNAMON ----------------"
echo "----------------------------------------------"

# Reinicia o Cinnamon para aplicar as mudanças
cinnamon --replace >/dev/null 2>&1 &


echo "----------------------------------------------"
echo "--------- MOVING WINDOW BUTTONS TO LEFT ------"
echo "----------------------------------------------"

# Configura os botões da janela para ficarem à esquerda
dconf write /org/cinnamon/desktop/wm/preferences/button-layout "'close,minimize,maximize:menu'"

echo "Botões da janela movidos para o lado esquerdo."