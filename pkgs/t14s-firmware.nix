{ stdenvNoCC
, lib
, rdfind
, which
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "linux-firmware";
  version = "20240726";

  src = fetchFromGitHub {
    owner = "jollheef";
    repo = "linux-firmware-x1e78100-lenovo-thinkpad-t14s";
    rev = "4ba0b781ffc27cb48736942822192b548a316838";
    hash = "sha256-ZeV6JRxU1gMwtWZH8sePCrZXFa27GxoKpLK4sg3Ljyo=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/firmware
    cp -r * $out/lib/firmware/
    runHook postInstall
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Firmware files for ThinkPad T14s Gen 6";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
