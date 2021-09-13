{ stdenv, fetchurl, lib, rpmextract, zlib, glib, nss, nspr, gtk3, util-linux
, cairo, pango, freetype, gdk-pixbuf , expat, dbus, alsa-lib, libxcb, xorg
, atk, at-spi2-atk, cups
}:

let
  libs = lib.makeLibraryPath (with xorg; [
    nss zlib glib gtk3 nspr expat dbus alsa-lib atk at-spi2-atk
    libX11 libXi libXext libXrandr libXfixes libXcomposite libxcb libXau libXdamage libXtst
    libXcursor libXdmcp libXext libXfixes libXrender libxcb libxkbfile xcbutil
    xcbutilwm util-linux cairo pango freetype gdk-pixbuf libX11 cups
  ]);
in
stdenv.mkDerivation rec {
  name = "vtune-profiler";
  src = fetchurl {
    url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/17113/parallel_studio_xe_2020_update4_cluster_edition.tgz";
    sha256 = "sha256-825J2pe2ziTS1GTXPX/0nXHP8g4WmMIOYHkZgZYCqfU=";
  };

  nativeBuildInputs = [ rpmextract ];

  installPhase = ''
    rpmextract ./rpm/intel-vtune-profiler-*.rpm
    mkdir $out
    mv opt $out/
    for bin in $out/opt/intel/*/bin64/*; do
      if [[ -f $bin ]] && [[ -x $bin ]]; then
        patchelf --set-rpath "$(patchelf --print-rpath $bin):${libs}" --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$bin" || true
      fi
    done
    ln -s $out/opt/intel/*/bin64 $out/bin
  '';

  meta = with lib; {
    platforms = platforms.unix;
    license = licenses.unfree;
  };
}
