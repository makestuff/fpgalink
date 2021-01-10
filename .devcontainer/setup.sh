#!/bin/sh

# See what mode we're in
if [ $# -ne 1 ] || [ "$1" != "GC" ] && [ "$1" != "CS" ]; then
  echo "Synopsis: build.sh <GC|CS>"
  exit 1
fi
MODE=$1

# Get environment
set > env.txt

# Decide what to do based on the mode
INSTALL_LOC=.local/share/code-server
if [ ${MODE} = "GC" ]; then
  # Running in GitHub Codespaces
  cat > init.sh <<EOF
#!/bin/sh
git submodule update --init --recursive
./build.sh Debug -nobuild
EOF
  chmod +x init.sh
elif [ ${MODE} = "CS" ]; then
  # Need to install code-server
  curl -fsSL https://code-server.dev/install.sh | sh
  mkdir -p .config/code-server
  cat > .config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: mun789
cert: false
EOF
fi

# Create dirs
mkdir -p ${INSTALL_LOC}/extensions

# Install extensions
TEMP=$(mktemp -d)
cd ${TEMP}
BASE_URL=http://makestuff.de/ext
EXTENSIONS="
  hbenl.vscode-test-explorer-2.19.4
  llvm-vs-code-extensions.vscode-clangd-0.1.8
  matepek.vscode-catch2-test-adapter-3.6.19
  ms-vscode.cpptools-1.1.3
"
for i in ${EXTENSIONS}; do
  echo "Installing ${i}..."
  wget -q ${BASE_URL}/${i}.vsix
  unzip -q ${i}.vsix
  mv extension ${INSTALL_LOC}/extensions/${i}
  rm -rf *
done
cd -
rm -rf ${TEMP}
