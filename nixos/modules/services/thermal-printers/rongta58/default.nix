{ stdenv, autoPatchelfHook, cups }:

stdenv.mkDerivation {
  pname = "rongta58";
  version = "1.0";

  src = ./.;

  # autoPatchelfHook automatically patches pre-compiled binaries
  nativeBuildInputs = [ autoPatchelfHook ];

  # Dependencies the binary likely needs to link against (like libcups)
  buildInputs = [ cups ];

  installPhase = ''
    # 1. Install the PPD file
    mkdir -p $out/share/cups/model/
    cp Printer58.ppd $out/share/cups/model/

    # 2. Install the filter binary
    mkdir -p $out/lib/cups/filter/
    cp rastertort58_80 $out/lib/cups/filter/
    chmod +x $out/lib/cups/filter/rastertort58_80
  '';
}
