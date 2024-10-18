{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  qrtr,
  lzma,
}:

stdenv.mkDerivation {
  pname = "pd-mapper";
  version = "2024-06-19";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pd-mapper";
    rev = "e7c42e1522249593302a5b8920b9e7b42dc3f25e";
    sha256 = "sha256-gTUpltbY5439IEEvnxnt8WOFUgfpQUJWr5f+OB12W8A=";
  };

  nativeBuildInputs = [ pkg-config lzma ];

  buildInputs = [ qrtr ];

  installFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "pd mapper";
    homepage = "https://github.com/linux-msm/pd-mapper";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
