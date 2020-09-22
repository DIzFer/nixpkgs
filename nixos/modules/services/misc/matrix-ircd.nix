{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.matrix-ircd;
in {
  options.services.matrix-ircd = {
    enable = mkEnableOption "an IRC frontend to a Matrix homeserver";
    url = mkOption {
      type = types.str;
      default = "https://matrix.org";
      description = "The homeserver to which act as a frontend.";
    };
    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:";
      description = "Address to bind to, for IRC clients to connect.";
    };
    bindPort = mkOption {
      type = types.port;
      default = 5999;
      description = "Port via which IRC clients will connect to matrix-ircd.";
    };
    serviceDependencies = mkOption {
      type = with types; listOf str;
      default = optional config.services.matrix-synapse.enable "matrix-synapse.service";
      description = ''
        List of Systemd services to require and wait for when starting the service,
        such as the Matrix homeserver if it's running on the same host.
      '';
    };
  };

  config.systemd.services.matrix-ircd = mkIf cfg.enable {
    description = "An IRC frontend to a Matrix homeserver";

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
    after = [ "network-online.target" ] ++ cfg.serviceDependencies;

    serviceConfig = {
      Type = "simple";
      Restart = "always";

      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;

      DynamicUser = true;
      PrivateTmp = true;

      ExecStart = ''
          ${pkgs.matrix-ircd}/bin/matrix-ircd \
            --bind ${cfg.bindAddress}:${toString cfg.bindPort} \
            --url ${cfg.url} \
      '';
    };
  };
}
