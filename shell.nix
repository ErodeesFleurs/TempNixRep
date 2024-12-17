with import <nixpkgs> { };

(mkShell) {
  buildInputs = [
    gcc
    gnumake
    cmake
    vcpkg
    pkg-config
    autoconf
    automake
    libtool
    ninja

    xz
    util-linux
    libcap
    libxcrypt
    zlib
    zstd
    xorg.libSM
    xorg.libXi
    lz4
    mimalloc
    libpng
    freetype
    libvorbis
    libopus
    SDL2
  ];
}
