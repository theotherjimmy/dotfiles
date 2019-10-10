function skn -d "skim files to open with nvim"
  set -l files (sk -m | tr "\n" " ")
  if test -n "$files" 
    commandline "nvim "$files
    commandline -f execute
  end
end
