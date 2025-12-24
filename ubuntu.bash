set -eu -o pipefail

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)

curl --fail --location --show-error --silent \
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

sudo add-apt-repository ppa:neovim-ppa/unstable

sudo apt-get update
sudo apt-get install --yes \
    brave-browser \
    bubblewrap \
    build-essential \
    fd-find \
    fzf \
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
    neovim \
    npm \
    python3-dev python3-pip python3-venv \
    ripgrep \
    rustup \
    socat \
    tk-dev \
    vim \
    xclip \
    xz-utils \
    zlib1g-dev

# TODO: Use signed version of Uv installer, if available.
curl -LsSf https://astral.sh/uv/install.sh | sh

uv tool install 'maestral[gui]'
# TODO: Maestral sync instructions.

cat >>"${HOME}/.bashrc" <<'EOF'
alias vi=nvim
alias xccopy='xclip -selection clipboard -in'
alias xcpaste='xclip -selection clipboard -out'

export EDITOR=nvim VISUAL=nvim
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
EOF
source "${HOME}/.bashrc"

mkdir --parents "${HOME}/.local/installations"
mkdir --parents "${XDG_DATA_HOME}/bash-completion/completions"

# TODO: Import SSH private keys.
# TODO: Import GPG private keys.

git config --global init.defaultBranch master
git config --global user.email "emcd@users.noreply.github.com"
git config --global user.name "Eric McDonald"
git config --global gpg.format ssh
git config --global user.signingkey "${HOME}/.ssh/id_ed25519_github.pub"
git config --global gpg.ssh.allowedSignersFile "${HOME}/.ssh/allowed_signers"
git config --global commit.gpgSign true
git config --global tag.gpgSign true
echo "$(git config --global --get user.email) namespaces=\"git\" $(cat ~/.ssh/id_ed25519_github.pub)" >>"${HOME}/.ssh/allowed_signers"

git clone https://github.com/emcd/nvim-config.git "${XDG_CONFIG_HOME}/nvim"
#git clone --recurse-submodules --shallow-submodules https://github.com/emcd/vim-files.git "${HOME}/.vim"

npm config set prefix "${HOME}/.local/share/npm-packages"

gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 0x7413A06D
curl https://mise.jdx.dev/install.sh.sig | gpg --decrypt | MISE_INSTALL_PATH="${HOME}/.local/bin/mise" sh

# TODO: Configure 'rustup' path.
cat >>"${HOME}/.bashrc" <<'EOF'
eval "$(~/.local/bin/mise activate bash)"

export GOPATH="${HOME}/.local/share/go"
export PATH="${PATH}:${HOME}/.local/bin:${HOME}/.local/share/npm-packages/bin:${HOME}/.local/share/go/bin"

export CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME}/claude"
export CODEX_HOME="${XDG_CONFIG_HOME}/codex"
EOF
source "${HOME}/.bashrc"

mise install python@3.10 python@3.11 python@3.12 python@3.13
mise install rust@latest
mise install go@latest
mise install node@22 node@24
mise install packer@latest

mise use --global python@3.10 rust@latest go@latest node@24 packer@latest

rustup component add rust-analyzer

go install github.com/isaacphi/mcp-language-server@latest

npm install -g @anthropic-ai/claude-code
# claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

# curl --fail --location --show-error --silent \
#     'https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2025.05.20_amd64.deb' \
#     --output /tmp/dropbox.deb
# sudo apt install --yes /tmp/dropbox.deb
# rm /tmp/dropbox.deb

# TODO: Download and install fonts.
#       https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip
#
#       sudo cp "$font_file" /usr/share/fonts/truetype/
#       sudo fc-cache -f -v
