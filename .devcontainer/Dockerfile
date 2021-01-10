# [Choice] Debian / Ubuntu version: debian-10, debian-9, ubuntu-20.04, ubuntu-18.04
ARG VARIANT=buster
FROM mcr.microsoft.com/vscode/devcontainers/cpp:dev-${VARIANT}

# [Optional] Uncomment this section to install additional packages.
RUN echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-11 main"     >> /etc/apt/sources.list
RUN echo "deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-11 main" >> /etc/apt/sources.list
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get update
RUN apt-get -y install --no-install-recommends clangd-11 libusb-1.0-0-dev

# Run final steps as vscode user
COPY setup.sh /home/vscode/
RUN set > /home/vscode/env.txt
RUN su - vscode -c './setup.sh GC'
