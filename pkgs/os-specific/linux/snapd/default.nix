{ stdenv
, fetchurl
, buildGoPackage
, pkgconfig
, libseccomp
, libcap
, libudev
, libapparmor
, xfsprogs
}:

assert stdenv.isLinux;

buildGoPackage rec {
  version = "2.32.6";
  name = "snapd-${version}";

  goPackagePath = "github.com/snapcore/snapd";

  src = fetchurl {
    url = "https://github.com/snapcore/snapd/releases/download/${version}/snapd_${version}.vendor.tar.xz";
    sha256 = "0xlazabnqqgll067rdla4nb6ahq4fy8ad3prdycw99bd9vccmjqx";
  };

  hardeningDisable = [ "fortify" ];

  buildInputs = [
    pkgconfig
    (libseccomp.overrideAttrs (oa: { dontDisableStatic = true; }))
    libcap
    libudev
    libapparmor
    xfsprogs
  ];

  postInstall = ''
    mkdir -p "$bin"/share/{polkit-1/actions,dbus-1/services,bash-completion/completions}/ \
      "$bin"/lib/snapd/
    cp "$out"/share/go/src/github.com/snapcore/snapd/data/polkit/io.snapcraft.snapd.policy \
    "$bin"/share/polkit-1/actions/io.snapcraft.snapd.policy
    cp "$out"/share/go/src/github.com/snapcore/snapd/data/dbus/* "$bin"/share/dbus-1/services/
    make -C "$bin"/share/dbus-1/services/
    rm "$bin"/share/dbus-1/services/{io.snapcraft.Launcher.service.in,Makefile}

    cp "$out"/share/go/src/github.com/snapcore/snapd/data/completion/snap "$bin"/share/bash-completion/completions/snap
    cp "$out"/share/go/src/github.com/snapcore/snapd/data/completion/complete.sh "$bin"/lib/snapd/complete.sh
    cp "$out"/share/go/src/github.com/snapcore/snapd/data/completion/etelpmoc.sh "$bin"/lib/snapd/etelpmoc.sh
  '';

  meta = with stdenv.lib; {
    homepage = https://snapcraft.io;
    description = "The snapd and snap tools enable systems to work with .snap files";
    license = licenses.gpl3;
    maintainers = with maintainers; [ dizfer ];
    platforms = platforms.linux;
  };
}
