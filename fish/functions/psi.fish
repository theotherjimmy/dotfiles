function psi -a search-term -w pacman
    set -l to_install (pacman -Ss $search-term | sed -e "/    /d" | sk | sed -e 's/ .*$//')
    echo $to_install
    if test -n "$to_install" ;
        sudo pacman -S $to_install
    end
end
