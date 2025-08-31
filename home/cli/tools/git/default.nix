{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    git.enable = lib.mkEnableOption "Enable git module";
  };
  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;
      userName = config.home.username;
      userEmail = "mateusalvespereira7@gmail.com";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        init = {
          defaultBranch = "main";
        };
        branch = {
          autoSetupRemote = true;
        };
        fetch = {
          prune = true;
        };
        pull = {
          ff = false;
          commit = false;
          rebase = true;
          prune = true;
        };
        maintenance.repo = "${config.home.homeDirectory}/opensource/nixpkgs";
        safe = {
          directory = "${config.home.homeDirectory}/opensource/nixdots";
        };
      };
    };
    home.packages = with pkgs; [
      gh
    ];
  };
}
