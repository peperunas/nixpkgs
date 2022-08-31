{ lib, stdenv, fetchurl, pkg-config, libmnl }:

stdenv.mkDerivation rec {
  version = "1.2.3";
  pname = "libnftnl";

  src = fetchurl {
    url = "https://netfilter.org/projects/${pname}/files/${pname}-${version}.tar.bz2";
    hash = "sha256-6Rbqm3n5UYVguaGHJRp8BCRCqey85/Nr55CIiGBdAlU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libmnl ];

  # Avoid
  #
  # # object.c:399:19: error: no member named '__builtin___snprintf_chk' in 'struct obj_ops'
  # #                 ret = obj->ops->snprintf(buf + offset, remain, flags, obj);
  preConfigure = lib.optionalString stdenv.cc.isClang ''
    for f in $(find include src -type f | grep -E '\.(c|h)$'); do
      substituteInPlace "$f" \
        --replace snprintf op_snprintf
    done
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A userspace library providing a low-level netlink API to the in-kernel nf_tables subsystem";
    homepage = "https://netfilter.org/projects/libnftnl/";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ajs124 ];
  };
}
