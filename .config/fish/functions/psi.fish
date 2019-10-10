function psi -w pacman
    set -l to_install (pacman -Ss | sed -e "/    /d" | sk | sed -e 's/ .*$//')
    if test -n "$to_install" ;
        sudo pacman -S $to_install
    end
end
