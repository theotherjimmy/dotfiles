{ writeShellApplication }:
writeShellApplication {
  name = "edit";
  text = builtins.readFile ./edit.bash;
}
