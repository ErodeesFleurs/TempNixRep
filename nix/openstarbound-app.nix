{
  openstarbound-raw,
  writeShellApplication,
}:
writeShellApplication {
  name = "openstarbound-${openstarbound-raw.version}";
  runtimeInputs = [ openstarbound-raw ];
  text = ''
    steam_assets_dir="$HOME/.local/share/Steam/steamapps/common/Starbound/assets"
    storage_dir="$HOME/.local/share/OpenStarbound/storage"

    mkdir -p "$storage_dir"
    tmp_cfg="$(mktemp -t openstarbound.XXXXXXXX)"

    cat << EOF > "$tmp_cfg"
      {
      "assetDirectories" : [
        "$steam_assets_dir",
        "../mods/"
      ],

      "storageDirectory" : "$storage_dir",

      "assetsSettings" : {
        "pathIgnore" : [],
        "digestIgnore" : [
          ".*"
        ]
      },

      "defaultConfiguration" : {
        "allowAdminCommandsFromAnyone" : true,
        "anonymousConnectionsAreAdmin" : true
      }
    }
    EOF

    osb-client \
      -bootconfig "$tmp_cfg"
      "$@"

    rm "$tmp_cfg"
  '';
}
