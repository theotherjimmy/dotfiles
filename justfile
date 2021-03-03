profile-dir := "/nix/var/nix/profiles/per-user/$USER"
find-gen:= "home-manager-generation"

switch:
    nix run -L

rollback num="0":
    {{profile-dir}}/home-manager-{{num}}-link/activate

check:
    nix flake check

man:
    man home-configuration.nix

alias ls := list-generations
alias generations := list-generations
alias gen := list-generations
list-generations:
    exa -1 --color always {{profile-dir}} | rg --color never {{find-gen}}
