{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          dotnet-sdk_10 csharp-ls
          nodejs typescript typescript-language-server
        ];
        env.DOTNET_ROOT = "${pkgs.dotnet-sdk_10}";
      };
    };
}
