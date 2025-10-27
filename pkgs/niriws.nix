{ writeShellApplication, runtimeEnv }:
writeShellApplication {
  inherit runtimeEnv;
  name = "niriws";
  text = builtins.readFile ./niriws.bash;
}
