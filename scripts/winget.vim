function CreateWingetYaml()
  let vers=expand("$APPVEYOR_REPO_TAG_NAME")[1:]
  let gvim="gvim_" .. vers .. "_x64.exe"
  let sha256=systemlist("sha256sum " .. gvim)
  let sha256hash=toupper(split(sha256[0])[0])

  %s/<version>/\=vers/g
  %s/<sha256hash>/\=sha256hash/

  exe ":saveas! gvim_" .. vers ..".yml"
endfunction


call CreateWingetYaml()
quit
