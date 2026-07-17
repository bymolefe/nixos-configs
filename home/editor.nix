{ ... }:
{
  xdg.desktopEntries.nvim-ghostty = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "ghostty -e nvim %F";
    terminal = false;
    categories = [ "Utility" "TextEditor" "Development" ];
    mimeType = [ "text/plain" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain"              = "nvim-ghostty.desktop";
      "text/x-lua"             = "nvim-ghostty.desktop";
      "text/x-python"          = "nvim-ghostty.desktop";
      "text/x-shellscript"     = "nvim-ghostty.desktop";
      "text/x-script.python"   = "nvim-ghostty.desktop";
      "application/json"       = "nvim-ghostty.desktop";
      "application/javascript" = "nvim-ghostty.desktop";
      "text/javascript"        = "nvim-ghostty.desktop";
      "text/css"               = "nvim-ghostty.desktop";
      "text/html"              = "nvim-ghostty.desktop";
      "text/markdown"          = "nvim-ghostty.desktop";
      "text/x-nix"             = "nvim-ghostty.desktop";
    };
  };
}
