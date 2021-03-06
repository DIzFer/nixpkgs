{ config, lib, pkgs, ... }:

with lib;

let
  cfgFile = pkgs.writeText "reader.conf" config.services.pcscd.readerConfig;

  pluginEnv = pkgs.buildEnv {
    name = "pcscd-plugins";
    paths = map (p: "${p}/pcsc/drivers") config.services.pcscd.plugins;
  };

in
{

  ###### interface

  options.services.pcscd = {
    enable = mkEnableOption "PCSC-Lite daemon";

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.ccid ];
      defaultText = "[ pkgs.ccid ]";
      example = literalExample "[ pkgs.pcsc-cyberjack ]";
      description = "Plugin packages to be used for PCSC-Lite.";
    };

    readerConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        FRIENDLYNAME      "Some serial reader"
        DEVICENAME        /dev/ttyS0
        LIBPATH           /path/to/serial_reader.so
        CHANNELID         1
      '';
      description = ''
        Configuration for devices that aren't hotpluggable.

        See <citerefentry><refentrytitle>reader.conf</refentrytitle>
        <manvolnum>5</manvolnum></citerefentry> for valid options.
      '';
    };
  };

  ###### implementation

  config = mkIf config.services.pcscd.enable {

    environment.etc."reader.conf".source = cfgFile;

    systemd.packages = [ (getBin pkgs.pcsclite) ];

    systemd.sockets.pcscd.wantedBy = [ "sockets.target" ];

    systemd.services.pcscd = {
      environment.PCSCLITE_HP_DROPDIR = pluginEnv;
      restartTriggers = [ "/etc/reader.conf" ];
    };
  };
}
