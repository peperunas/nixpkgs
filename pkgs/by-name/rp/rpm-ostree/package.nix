{
  lib,
  stdenv,
  fetchurl,
  ostree,
  rpm,
  which,
  autoconf,
  automake,
  libtool,
  pkg-config,
  cargo,
  rustc,
  gobject-introspection,
  gtk-doc,
  libxml2,
  libxslt,
  docbook_xsl,
  docbook_xml_dtd_42,
  docbook_xml_dtd_43,
  gperf,
  cmake,
  libcap,
  glib,
  systemd,
  json-glib,
  libarchive,
  libsolv,
  librepo,
  polkit,
  bubblewrap,
  pcre2,
  check,
  python3,
  json_c,
  zchunk,
  libmodulemd,
  util-linux,
  sqlite,
  cppunit,
}:

stdenv.mkDerivation rec {
  pname = "rpm-ostree";
  version = "2024.8";

  outputs = [
    "out"
    "dev"
    "man"
    "devdoc"
  ];

  src = fetchurl {
    url = "https://github.com/coreos/rpm-ostree/releases/download/v${version}/rpm-ostree-${version}.tar.xz";
    hash = "sha256-6aCGP3SJ0DegmhiQkiqBr733C5vuDGTjLMaxNtai3G0=";
  };

  nativeBuildInputs = [
    python3
    pkg-config
    which
    autoconf
    automake
    libtool
    cmake
    gperf
    cargo
    rustc
    gobject-introspection
    gtk-doc
    libxml2
    libxslt
    docbook_xsl
    docbook_xml_dtd_42
    docbook_xml_dtd_43
  ];

  buildInputs = [
    libcap
    ostree
    rpm
    glib
    systemd
    polkit
    bubblewrap
    json-glib
    libarchive
    libsolv
    librepo
    pcre2
    check

    # libdnf # vendored unstable branch
    # required by vendored libdnf
    json_c
    zchunk
    libmodulemd
    util-linux # for smartcols.pc
    sqlite
    cppunit
  ];

  configureFlags = [
    "--enable-gtk-doc"
    "--with-bubblewrap=${bubblewrap}/bin/bwrap"
  ];

  dontUseCmakeConfigure = true;

  prePatch = ''
    # According to #cmake on freenode, libdnf should bundle the FindLibSolv.cmake module
    cp ${libsolv}/share/cmake/Modules/FindLibSolv.cmake libdnf/cmake/modules/

    # Let's not hardcode the rpm-gpg path...
    substituteInPlace libdnf/libdnf/dnf-keyring.cpp \
      --replace '"/etc/pki/rpm-gpg"' 'getenv("LIBDNF_RPM_GPG_PATH_OVERRIDE") ? getenv("LIBDNF_RPM_GPG_PATH_OVERRIDE") : "/etc/pki/rpm-gpg"'
  '';

  preConfigure = ''
    env NOCONFIGURE=1 ./autogen.sh
  '';

  meta = with lib; {
    description = "Hybrid image/package system. It uses OSTree as an image format, and uses RPM as a component model";
    homepage = "https://coreos.github.io/rpm-ostree/";
    license = licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "rpm-ostree";
  };
}
