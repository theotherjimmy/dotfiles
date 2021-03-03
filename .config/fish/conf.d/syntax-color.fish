set fish_color_normal normal
set fish_color_command brblue
set fish_color_args blue
set fish_color_quote bryellow
set fish_color_redirection brgreen
set fish_color_end white
set fish_color_error red --bold
set fish_color_comment green
set fish_color_match magenta
set fish_color_selection cyan
set fish_color_search_match brwhite
set fish_color_operator brcyan
set fish_color_escape yellow
set fish_color_autosuggestion brblack

# start blink
export LESS_TERMCAP_mb=(set_color magenta)
# start bold
export LESS_TERMCAP_md=(set_color blue)
# start standout (reverse)
export LESS_TERMCAP_so=(set_color yellow)
# start underline
export LESS_TERMCAP_us=(set_color -i red)

# stop bold
export LESS_TERMCAP_me=(set_color normal)
# stop standout (reverse)
export LESS_TERMCAP_se=(set_color normal)
# stop underline
export LESS_TERMCAP_ue=(set_color normal)
