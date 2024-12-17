{
  steamSupport ? false,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  zlib,
  zstd,
  libpng,
  freetype,
  libvorbis,
  libopus,
  SDL2,
  glew,
  xorg,
  ...
}:
let
  fs = lib.fileset;
in

stdenv.mkDerivation rec {
  pname = "openstarbound-raw";
  version = "v3.1.3r1";
  src = fetchFromGitHub ({
    owner = "OpenStarbound";
    repo = "OpenStarbound";
    rev = "a52c213";
    fetchSubmodules = false;
    sha256 = "sha256-EyJ8TVvSLsbUnHriosLCovaV3TzbdCdeSkmHH2emwV4=";
  });

  sourceRoot = "source/source";

  cmakeFlags = [
    # TODO: Steam support has not been tested for this derivation
    # "-DCMAKE_TOOLCHAIN_FILE=${vcpkg}/share/vcpkg/scripts/buildsystems/vcpkg.cmake"
    # "-DCMAKE_MAKE_PROGRAM=${ninja}/bin/ninja"
    "-DSTAR_ENABLE_STEAM_INTEGRATION=${if steamSupport then "ON" else "OFF"}"
    "-DOpus_DIR=${./cmake}"
    "-DGLEW_INCLUDE_DIR=${glew.dev}/include"
  ];

  # NB: This code specifically passes libopus to the linker. At the time of writing (2024-09-09),
  # the reason for why we have to do this is unknown. All other libraries gets automatically passed by
  # existing in nativeBuildInputs, but not libopus. This hack makes the build logs very noisy and it's not
  # very elegant, so if any future readers know what the issue might be, please improve this.
  env.CXXFLAGS =
    let
      opusObjects = builtins.attrNames (builtins.readDir "${libopus}/lib");
    in
    "-Wl,-rpath ${lib.concatMapStringsSep " " (obj: "${libopus}/lib/${obj}") opusObjects}";
  nativeBuildInputs = [
    cmake
    ninja
    zlib
    zstd
    libpng
    freetype
    libvorbis
    libopus
    SDL2
    glew
    xorg.libSM
    xorg.libXi
  ];
  postPatch = ''
    substituteInPlace CMakeLists.txt \
        --replace-warn "GLEW::glew_s" "GLEW::GLEW"
    substituteInPlace CMakeLists.txt \
        --replace-warn "find_package(GLEW REQUIRED)" "find_package(GLEW CONFIG REQUIRED)"
    substituteInPlace CMakeLists.txt \
        --replace-warn "CMAKE_RUNTIME_OUTPUT_DIRECTORY" "NIX_STB_PLACEHOLDER"
  '';

  installPhase = ''
    cmake --install . --prefix $out
    runHook postInstall
  '';

  postInstall = ''
    mkdir -p "$out/bin"
    ln -s "$out/linux/client" "$out/bin/client"
  '';

  meta.mainProgram = "osb-client";
}
