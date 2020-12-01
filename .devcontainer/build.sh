# Install code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Create dirs
mkdir -p .config/code-server
mkdir -p .local/share/code-server/extensions
mkdir -p .local/share/code-server/User

# Create init.sh
cat > init.sh <<EOF
#!/bin/sh
rm -f ~/.vscode-remote/data/Machine/settings.json
ln -s ~/.vscode-remote/User/settings.json ~/.vscode-remote/data/Machine/settings.json
git submodule update --init --recursive
./build.sh Debug -nobuild
EOF
chmod +x init.sh

# Create config.yaml
cat > .config/code-server/config.yaml <<EOF
bind-addr: 0.0.0.0:8080
auth: password
password: mun789
cert: false
EOF

# Create default settings.json
cat > .local/share/code-server/User/settings.json <<EOF
{
    "terminal.integrated.shell.linux": "/bin/bash",
    "workbench.colorTheme": "Default Dark+",
    "workbench.tree.indent": 24,
    "extensions.ignoreRecommendations": true,
    "explorer.confirmDelete": false,
    "C_Cpp.errorSquiggles": "Disabled",
    "C_Cpp.intelliSenseEngine": "Disabled",
    "clangd.path": "/usr/bin/clangd-11",
    "clangd.arguments": [
        "--background-index",
        "--compile-commands-dir=build",
        "-j=32"
    ],
    "clangd.onConfigChanged": "restart",
    "editor.minimap.enabled": false,
    "editor.tokenColorCustomizations": {
        "textMateRules": [
            {
                "scope": "googletest.failed",
                "settings": {
                    "foreground": "#f00"
                }
            },
            {
                "scope": "googletest.passed",
                "settings": {
                    "foreground": "#0f0"
                }
            },
            {
                "scope": "googletest.run",
                "settings": {
                    "foreground": "#0f0"
                }
            }
        ]
    }
}
EOF

# Replicate settings for codespaces
ln -s ~/.local/share/code-server .vscode-remote

# Install extensions
TEMP=$(mktemp -d)
cd ${TEMP}
URL=http://makestuff.de/ext/vscode-clangd.zip.gz
#URL=https://marketplace.visualstudio.com/_apis/public/gallery/publishers/llvm-vs-code-extensions/vsextensions/vscode-clangd/0.1.8/vspackage
wget -O pkg.zip.gz ${URL}
gunzip pkg.zip.gz 
unzip pkg.zip
mv extension ~/.local/share/code-server/extensions/llvm-vs-code-extensions.vscode-clangd-0.1.8
rm -rf *

URL=http://makestuff.de/ext/cpptools.zip.gz
#URL=https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/1.1.2/vspackage
wget -O pkg.zip.gz ${URL}
gunzip pkg.zip.gz
unzip pkg.zip
mv extension ~/.local/share/code-server/extensions/ms-vscode.cpptools-1.1.2
rm -rf *

URL=http://makestuff.de/ext/gtest-adapter.zip.gz
#URL=https://marketplace.visualstudio.com/_apis/public/gallery/publishers/DavidSchuldenfrei/vsextensions/gtest-adapter/1.8.3/vspackage
wget -O pkg.zip.gz ${URL}
gunzip pkg.zip.gz
unzip pkg.zip
mv extension ~/.local/share/code-server/extensions/davidschuldenfrei.gtest-adapter-1.8.3
cd ~/.local/share/code-server/extensions/davidschuldenfrei.gtest-adapter-1.8.3
patch -p1 <<EOF
diff -r -U1 extension/out/GTestWrapper.js ext-patch/out/GTestWrapper.js
--- extension/out/GTestWrapper.js	2019-04-03 10:27:04.000000000 +0000
+++ ext-patch/out/GTestWrapper.js	2020-11-26 22:04:01.327171807 +0000
@@ -120,2 +120,3 @@
                 vscode_1.commands.executeCommand('workbench.view.debug');
+                debugConfig.args.pop();
             }
diff -r -U1 extension/package.json ext-patch/package.json
--- extension/package.json	2019-04-03 10:25:38.000000000 +0000
+++ ext-patch/package.json	2020-11-26 22:04:01.331171875 +0000
@@ -202,3 +202,7 @@
                 "gtest-adapter.debugConfig": {
-                    "type": ["string", "string[]"],
+                    "type": ["string", "array"],
+                    "default": [],
+                    "items": {
+                    	"type": "string"
+                    },
                     "description": "Debug configuration for debugging unittests."
EOF
rm -rf ${TEMP}
