{ writeShellApplication, runtimeEnv }:
writeShellApplication {
  inherit runtimeEnv;
  name = "hyprws";
  text = builtins.readFile ./hyprws.bash;
}
