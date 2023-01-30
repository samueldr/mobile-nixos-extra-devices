{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "rg351p-js2xbox";
  version = "2021-02-25";

  src = fetchFromGitHub {
    owner = "christianhaitian";
    repo = "RG351P_virtual-gamepad";
    rev = "5010b9b3734ea5741e359236a2b1a19f0d240bde"; # master
    sha256 = "sha256-p/NTgx9W+Wr1uW3sOZ3K7fLScB+9lE0dxMUC6jz+qxE=";
  };

  postPatch = ''
    # UGH
    make clean
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CPPC=${stdenv.cc.targetPrefix}c++"
    "LINK=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -t $out/bin/ rg351p-js2xbox

    runHook postInstall
  '';
}
