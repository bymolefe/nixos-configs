{ pkgs, ... }:
{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    para = " /mnt/data/side_a";
    soul = " /mnt/data/side_b";
    dev= " $area/playground";
    project = "$para/project";
    area = "$para/area";
    resource = "$para/resource";
    archive = "$para/archive";
  };
}
