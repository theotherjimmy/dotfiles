function skn -d "skim files to open with nvim"
  set -l files (sk)
  if test -n "$files" 
    nvim $files
  end
end
