#!/bin/bash

set -e  # Stop si erreur

INSTALL_DIR="/workspace"
TMP_DIR="$INSTALL_DIR/tmp"

# Créer le dossier temporaire
mkdir -p "$TMP_DIR"
export TMPDIR="$TMP_DIR"

echo "📦 Nettoyage avant installation..."
rm -rf "$INSTALL_DIR/ComfyUI" "$INSTALL_DIR/venv" "$INSTALL_DIR"/*.whl "$INSTALL_DIR"/*.tar.gz "$INSTALL_DIR"/__pycache__

echo "🚀 Clonage de ComfyUI..."
cd "$INSTALL_DIR"
git clone https://github.com/comfyanonymous/ComfyUI
cd ComfyUI/custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager

echo "🐍 Création de l'environnement virtuel..."
cd "$INSTALL_DIR/ComfyUI"
python -m venv venv
source venv/bin/activate

echo "📦 Installation de Torch (GPU)..."
TMPDIR="$TMP_DIR" python -m pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

echo "📦 Installation des dépendances principales..."
TMPDIR="$TMP_DIR" python -m pip install -r requirements.txt

echo "📦 Installation des dépendances ComfyUI-Manager..."
TMPDIR="$TMP_DIR" python -m pip install -r custom_nodes/comfyui-manager/requirements.txt

echo "🛠 Création du script run_gpu.sh..."
cat << EOF > "$INSTALL_DIR/run_gpu.sh"
#!/bin/bash
cd ComfyUI
source venv/bin/activate
python main.py --preview-method auto --listen
EOF
chmod +x "$INSTALL_DIR/run_gpu.sh"

echo "🛠 Création du script run_cpu.sh..."
cat << EOF > "$INSTALL_DIR/run_cpu.sh"
#!/bin/bash
cd ComfyUI
source venv/bin/activate
python main.py --preview-method auto --cpu --listen
EOF
chmod +x "$INSTALL_DIR/run_cpu.sh"

echo "🧹 Nettoyage du cache pip..."
pip cache purge

echo "✅ Installation terminée !"
