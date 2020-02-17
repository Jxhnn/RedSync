add_del(word,sfile,action){
if !regexmatch(action,"del|add") ;to prevent deleting by accident
return

  fileread,data,%sfile%
  word:=regexreplace(word,"\s+$")  ;remove unwanted blank characters at the end
  if (action="add")
            {
          loop,parse,data,`n,`r
              if (A_LoopField=word)
              status:=1
              
              if status
              newdata:=data
              else
              newdata:=data "`n" word
              }
         
  if (action="del")
          {
          loop,parse,data,`n,`r
              {
              if (A_LoopField=word)
                  Continue
              newdata .=A_LoopField "`n"
              }
           }  
  newdata:=regexreplace(newdata,"\s+$")   ;remove unwanted blank characters at the end

  FileDelete, %sfile%
      sleep 1000
  FileAppend, %newdata%,%sfile%
      sleep 1000
  }

AddAnimatedGIF(imagefullpath , x="", y="", w="", h="", guiname = "1")
{
  global AG1,AG2,AG3,AG4,AG5,AG6,AG7,AG8,AG9,AG10
  static AGcount:=0, pic
  AGcount++
  html := "<html><body style='background-color: F9F9F9' style='overflow:hidden' leftmargin='0' topmargin='0'><img src='" imagefullpath "' width=" w " height=" h " border=0 padding=0></body></html>"
  Gui, AnimGifxx:Add, Picture, vpic, %imagefullpath%
  GuiControlGet, pic, AnimGifxx:Pos
  Gui, AnimGifxx:Destroy
  Gui, %guiname%:Add, ActiveX, % (x = "" ? " " : " x" x ) . (y = "" ? " " : " y" y ) . (w = "" ? " w" picW : " w" w ) . (h = "" ? " h" picH : " h" h ) " vAG" AGcount, Shell.Explorer
  AG%AGcount%.navigate("about:blank")
  AG%AGcount%.document.write(html)
  return "AG" AGcount
}
