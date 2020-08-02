{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.jellyfin;
in
{
  options = {
    services.jellyfin = {
      enable = mkEnableOption "Jellyfin Media Server";

      user = mkOption {
        type = types.str;
        default = "jellyfin";
        description = "User account under which Jellyfin runs.";
      };

      group = mkOption {
        type = types.str;
        default = "jellyfin";
        description = "Group under which jellyfin runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jellyfin = {
      description = "Jellyfin Media Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = rec {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "jellyfin";
        CacheDirectory = "jellyfin";
        db_version = pkgs.lib.versions.majorMinor pkgs.jellyfin.version;
        ExecPreStart = ''
          #!/bin/bash
          mkdir -p /var/lib/${StateDirectory}/database/${db_version}
          if [ "${db_version}" = "10.6.1" ]; then
            cp -r /var/lib/${StateDirectory}/data /var/lib/${StateDirectory}/database/${db_version}/
            exit 0
          else
            versions=$(find /var/lib/${StateDirectory}/database/ -maxdepth 1 -mindepth 1 | sort -r)
            for version in versions;
            do
              if [ -d "$version" ]; then
                if find "$version" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then;
                  cp -r "$version" /var/lib/${StateDirectory}/database/${db_version}
                  break
                fi
              fi
            done
        '';
        ExecStart = "${pkgs.jellyfin}/bin/jellyfin --datadir '/var/lib/${StateDirectory}/database/${db_version}' --cachedir '/var/cache/${CacheDirectory}'";
        Restart = "on-failure";
      };
    };

    users.users = mkIf (cfg.user == "jellyfin") {
      jellyfin = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "jellyfin") {
      jellyfin = {};
    };

  };

  meta.maintainers = with lib.maintainers; [ minijackson ];
}
