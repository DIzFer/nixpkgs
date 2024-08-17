{
  mkKdeDerivation,
  qtwebengine,
  kaddressbook,
  kmail,
  korganizer,
  zanshin,
}:
mkKdeDerivation {
  pname = "kontact";

  extraBuildInputs = [
    qtwebengine
    kaddressbook
    kmail
    korganizer
    zanshin
  ];
  meta.mainProgram = "kontact";
}
