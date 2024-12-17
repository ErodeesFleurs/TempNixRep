{ openstarbound-raw
, assetsDirectory ? null
, storageDirectory ? "storage"
, extraAttrs ? { }
, writeTextFile
, writeShellApplication
, lib
, runCommandLocal
}:
let


  defaults = {

    assetDirectories = [
      assetsDirectory
    ];

    inherit storageDirectory;

    assetsSettings = {
      pathIgnore = [ ];
      digestIgnore = [ ".*" ];
    };

    defaultConfiguration = {
      allowAdminCommandsFromAnyone = true;
      anonymousCOnnectionsAreAdmin = true;
    };
  };

  mergedConfig = defaults // extraAttrs;

  osbconfig = writeTextFile {
    name = "osbinit.config";
    text = builtins.toJSON mergedConfig;
  };
in
writeShellApplication {
  name = "openstarbound";
  runtimeInputs = [ openstarbound-raw ];
  derivationArgs.passthru = { inherit openstarbound-raw osbconfig; };
  text = ''
    mkdir -p "${mergedConfig.storageDirectory}"
    osb-client \
      -bootconfig ${osbconfig}
      "$@"
  '';
}
