set -eu -o pipefail

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)

curl --fail --location --show-error --silient \
    'https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg' \
    | sudo dd of='/usr/share/keyrings/brave-browser-archive-keyring.gpg'
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

curl --fail --location --show-error --silent \
    'https://cli.github.com/packages/githubcli-archive-keyring.gpg' \
    | sudo dd of='/usr/share/keyrings/githubcli-archive-keyring.gpg'
sudo chmod go+r '/usr/share/keyrings/githubcli-archive-keyring.gpg'
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null


sudo apt-get update
sudo apt-get install --yes \
    brave-browser \
    build-essential \
    g++ \
    gh \
    git-lfs \
    jq \
    libbz2-dev \
    libffi-dev \
    libncursesw5-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev libxmlsec1-dev \
    python3-dev \
    python3-venv \
    ripgrep \
    tk-dev \
    vagrant \
    vim \
    virtualbox-qt \
    xclip \
    xz-utils \
    zlib1g-dev

# TODO: Import SSH private keys.

# TODO: Import GPG private keys.

cat >>"${HOME}/.bashrc" <<'EOF'
alias xccopy='xclip -selection clipboard -in'
alias xcpaste='xclip -selection clipboard -out'

export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
EOF
source "${HOME}/.bashrc"

mkdir --parents "${HOME}/.local/installations"
mkdir --parents "${XDG_DATA_HOME}/bash-completion/completions"

git config --global init.defaultBranch master
git config --global user.email "emcd@users.noreply.github.com"
git config --global user.name "Eric McDonald"

git clone --recurse-submodules --shallow-submodules https://github.com/emcd/vim-files.git "${HOME}/.vim"

# TODO: Discover latest stable Asdf branch.
git clone https://github.com/asdf-vm/asdf.git "${HOME}/.local/installations/asdf" --branch v0.11.3
# TODO: Use XDG paths.
#       https://github.com/asdf-vm/asdf/issues/687#issuecomment-1005195311
mkdir --parents "${XDG_CONFIG_HOME}/asdf"
cp .config/asdf/asdfrc "${XDG_CONFIG_HOME}/asdf"
cat >>"${HOME}/.bashrc" <<'EOF'
export ASDF_DATA_DIR="${XDG_DATA_HOME}/asdf"
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/asdfrc"
source "${HOME}/.local/installations/asdf/asdf.sh"
source "${HOME}/.local/installations/asdf/completions/asdf.bash"
EOF
source "${HOME}/.bashrc"

asdf plugin add packer
# TODO: Discover latest stable Packer release via Github API.
asdf install packer 1.8.6
