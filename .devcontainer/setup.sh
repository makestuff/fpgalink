#!/bin/sh

# See what mode we're in
if [ $# -ne 1 ] || [ "$1" != "GC" ] && [ "$1" != "CS" ]; then
  echo "Synopsis: build.sh <GC|CS>"
  exit 1
fi
MODE=$1

# Decide what to do based on the mode
if [ ${MODE} = "GC" ]; then
  # Running in github codespaces
  INSTALL_LOC=~/.vscode-remote
  SETTINGS=settings-new
  rm -rf ${INSTALL_LOC}
  cat > ~/init.sh <<EOF
#!/bin/sh
# The GitHub Codespaces init process overwrites any settings files, so the needs to be done later
LOC=~/.vscode-remote/data/Machine
rm -f \${LOC}/settings.json
ln -s \${LOC}/settings-new.json \${LOC}/settings.json
git submodule update --init --recursive
./build.sh Debug -nobuild
EOF
  chmod +x ~/init.sh
elif [ ${MODE} = "CS" ]; then
  # Need to install code-server
  INSTALL_LOC=~/.local/share/code-server
  SETTINGS=settings
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
mkdir -p ${INSTALL_LOC}/User

# Create default settings.json
cat > ${INSTALL_LOC}/data/Machine/${SETTINGS}.json <<EOF
{
    "terminal.integrated.shell.linux": "/bin/bash",
    "extensions.ignoreRecommendations": true,
    "workbench.colorTheme": "Default Dark+",
    "workbench.tree.indent": 24,
    "explorer.confirmDelete": false,
    "editor.minimap.enabled": false,
    "editor.tabSize": 2,

    "C_Cpp.errorSquiggles": "Disabled",
    "C_Cpp.intelliSenseEngine": "Disabled",
    "clangd.path": "/usr/bin/clangd-11",
    "clangd.onConfigChanged": "restart",
    "clangd.arguments": [
        "--query-driver=*",
        "--background-index",
        "--compile-commands-dir=build",
        "-j=32"
    ],
    "testMate.cpp.log.logSentry": "disable_3",
    "testMate.cpp.debug.configTemplate": {
        "type": "cppdbg",
        "program": "\${exec}",
        "args": "\${argsArray}",
        "cwd": "\${cwd}",
        "sourceFileMap":"\${sourceFileMapObj}",
        "setupCommands": [{"text": "-enable-pretty-printing"}]
    },
    "testMate.cpp.test.advancedExecutables": [{
        "pattern": "build/**/*-tests*",
        "runTask": {"before": ["build"]}
    }]
}
EOF

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
