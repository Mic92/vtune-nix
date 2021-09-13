{ stdenv, fetchurl, lib, rpmextract }:

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
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$bin" || true
      fi
    done
    ln -s $out/opt/intel/*/bin64 $out/bin
  '';

  meta = with lib; {
    platforms = platforms.unix;
    license = licenses.unfree;
  };
}
