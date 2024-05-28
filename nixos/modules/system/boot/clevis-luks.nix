{ config, lib, pkgs, ... }:

with lib;

let
  clevisCfg = config.boot.initrd.clevis;
  luksCfg = config.boot.initrd.luks;
  systemdInitrd = config.boot.initrd.systemd;
in
{
  meta.maintainers = with maintainers; [ julienmalka camillemndn ];
  options = { };

  config = mkIf clevisCfg.enable {
    boot.initrd.luks.devices = mkIf (!systemdInitrd.enable) (mapAttrs'
      (name: _: nameValuePair name {
        preOpenCommands = ''
          mkdir -p /clevis-${name}
          mount -t ramfs none /clevis-${name}
          clevis decrypt < /etc/clevis/${name}.jwe > /clevis-${name}/decrypted
        '';
        keyFile = "/clevis-${name}/decrypted";
        fallbackToPassword = true;
        postOpenCommands = "umount /clevis-${name}";
      })
      (filterAttrs (device: _: (hasAttr device luksCfg.devices)) clevisCfg.devices)
    );

    boot.initrd.systemd.services = (mapAttrs'
      (name: _: nameValuePair "cryptsetup-clevis-${name}" {
        wantedBy = [ "systemd-cryptsetup@${utils.escapeSystemdPath name}.service" ];
        before = [
          "systemd-cryptsetup@${utils.escapeSystemdPath name}.service"
          "initrd-switch-root.target"
          "shutdown.target"
        ];
        wants = [ "systemd-udev-settle.service" ] ++ optional clevisCfg.useTang "network-online.target";
        after = [ "systemd-modules-load.service" "systemd-udev-settle.service" ] ++ optional clevisCfg.useTang "network-online.target";
        script = ''
          mkdir -p /clevis-${name}
          mount -t ramfs none /clevis-${name}
          umask 277
          clevis decrypt < /etc/clevis/${name}.jwe > /clevis-${name}/decrypted
        '';
        conflicts = [ "initrd-switch-root.target" "shutdown.target" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "${systemdInitrd.package.util-linux}/bin/umount /clevis-${name}";
        };
      })
      (filterAttrs (device: _: (hasAttr device luksCfg.devices)) clevisCfg.devices)
    );
  };
}
