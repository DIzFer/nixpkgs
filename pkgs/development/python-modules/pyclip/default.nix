{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "pyclip";
  version = "0.7.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "spyoungtech";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-0nOkNgT8XCwtXI9JZntkhoMspKQU602rTKBFajVKBoM=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace docs/README.md README.md
  '';

  meta = {
    broken = stdenv.hostPlatform.isDarwin;
    description = "Cross-platform clipboard utilities supporting both binary and text data";
    mainProgram = "pyclip";
    homepage = "https://github.com/spyoungtech/pyclip";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mcaju ];
  };
}
