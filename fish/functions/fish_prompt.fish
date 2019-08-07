function fish_prompt
  if test $status -eq 0
    set second_color green
  else
    set second_color red
  end
  echo -n (set_color cyan)(prompt_pwd)'❯'(set_color $second_color)'❯ '(set_color normal)
end
