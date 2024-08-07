{ lib, stdenv, fetchFromGitHub, substituteAll
, SDL2, SDL2_mixer
, libjpeg, libpng
, pkg-config, qt5, cmake, zlib }:

stdenv.mkDerivation rec {
  pname = "gargoyle";
  version = "releases/2023.1";

  src = fetchFromGitHub {
    owner = "garglk";
    repo = "garglk";
    rev = version;
    sha256 = "sha256-XsN5FXWJb3DSOjipxr/HW9R7QS+7iEaITERTrbGEMwA=";
  };

  nativeBuildInputs = [ pkg-config qt5.wrapQtAppsHook cmake ];

  buildInputs = [ qt5.qtbase qt5.qttools
    SDL2 SDL2_mixer
	libjpeg libpng
	zlib ];

  enableParallelBuilding = true;

  configurePhase = ''
    #Temporary workaround for std::uint8_t not being defined
    sed -i "s/#include <cstdio>/#include <cstdio>\\n#include <cstdint>\\n/" garglk/garglk.h
	mkdir build
	cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_SHARED_LIBS=false
  '';

  buildPhase = ''
	cmake --build . -j$NIX_BUILD_CORES
  '';

  installPhase = ''
	make install
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    homepage = "http://ccxvii.net/gargoyle/";
    license = licenses.gpl2Plus;
    description = "Interactive fiction interpreter GUI";
    mainProgram = "gargoyle";
    platforms = platforms.unix;
    maintainers = with maintainers; [ orivej ];
  };
}
