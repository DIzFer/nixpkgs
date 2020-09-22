{ stdenv, fetchFromGitHub, rustPlatform, pkgconfig, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "matrix-ircd";
  version = "dev";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = pname;
    rev = "HEAD";
    sha256 = "0gqmg1hmmkjrmvbvcbgg8b44fznfcilwa6hc14083nfc0df2vv0s";
  };

  cargoSha256 = "1aj31znlggadarc37silxmmsq3abr8jlw2nrgarrwfr9xl10mk68";

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ openssl ];

  meta = with stdenv.lib; {
    description = "An IRCd implementation backed by Matrix";
    homepage = "https://github.com/BurntSushi/ripgrep";
    license = licenses.unlicense;
    maintainers = [ maintainers.tailhook ];
    platforms = platforms.all;
  };
}

