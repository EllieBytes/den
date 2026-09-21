{
  nix = {
    settings = {
      use-sandbox = true;
      show-trace = true;
    };

    gc = {
      enable = true;
      persistent = true;
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
