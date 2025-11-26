profile-dir := "/nix/var/nix/profiles/per-user/$USER"
find-gen:= "home-manager-generation"

d computer:
    #!/usr/bin/env bash
    if [[ "{{computer}}" == "$(hostname)" ]] ; then
        deploy .#{{computer}} -s --interactive-sudo true
    else
        deploy .#{{computer}} -s --ssh-user root
    fi

switch:
    nh home switch ./

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
