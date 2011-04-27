start_vi_normal_mode(){
  global vi_normal_mode
  vi_normal_mode["repeat_count"] := 0
}

end_vi_normal_mode(){

}


KMD_ViperDoRepeat(tosend)
{

  global vi_normal_mode
    c := vi_normal_mode["repeat_count"]
    if (c == 0)
      c := 1

    ;; guard:
    ;; should use confirmation instead
    if (c > 200)
      c := 200
    
    Loop %c%
    {
        S := S . tosend
    }
    KMD_Send(S)
    vi_normal_mode["repeat_count"] := 0
}

; Beide wichtige Konstanten 
WM_HSCROLL := 0x114 
WM_VSCROLL := 0x115 

; Vertikal scrollen 
SB_BOTTOM := 7 
SB_ENDSCROLL := 8 
SB_LINEDOWN := 1 
SB_LINEUP := 0 
SB_PAGEDOWN := 3 
SB_PAGEUP := 2 
SB_THUMBPOSITION := 4 
SB_THUMBTRACK := 5 
SB_TOP := 6

KMD_Scroll(a, b, amount){
  ; a = WM_HSCROLL or WM_VSCROLL
  ; b = one of SB_ above
  ControlGetFocus, FocusedControl, A 
  Loop %amount%{
    SendMessage, %a%, %b%, 0, %FocusedControl%, A  ; 0x114 is WM_HSCROLL ; 1 vs. 0 causes SB_LINEDOWN vs. UP    }
  }
}

vi_normal_mode_handle_keys(key){
  ; MsgBox, %key%
  global

  ;; gg gT gt

  if (vi_normal_mode["last_chars"] == "g"){
    if (key == "g"){
      KMD_ViperDoRepeat("^{Home}")
    } else if (key == "t"){
      KMD_ViperDoRepeat("^{Tab}")
    } else if (key == "+t"){
      KMD_ViperDoRepeat("^+{Tab}")
    }
    vi_normal_mode["last_chars"] :=  ""
    return
  }

  if (key == "g"){
      vi_normal_mode["last_chars"] := vi_normal_mode["last_chars"] . key
    return
  }
  if (key == "^d" || key="^u"){
      ;; I'm not sure  whether PgUp/PgDn should be used
      ;; PgUp/Don moves cursor
      if (key == "^d") {
        KMD_Scroll(WM_VSCROLL, SB_PAGEDOWN, 1)
      }else if (key == "^u") {
        KMD_Scroll(WM_VSCROLL, SB_PAGEUP, 1) ; scroll up
      }
      return
  }

  if (key == "z"){
    local c
    c := vi_normal_mode["repeat_count"] ** 2
    if c > 100
      c := 100
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Up}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Down}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Down}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Up}")
    return
  }

  if (key == "0" && vi_normal_mode["repeat_count"] == 0)
  {
    KMD_Send("{Home}")
    return
  } else if (key == 0 || key == 1 || key == 2 || key == 3 || key == 4 || key == 5 || key == 6 || key == 7 || key == 8 || key == 9)
  {
    vi_normal_mode["repeat_count"] := vi_normal_mode["repeat_count"] * 10 + key
    return
  } else if (vi_normal_mode["simple_commands"].HasKey(key)) {
    KMD_ViperDoRepeat(vi_normal_mode["simple_commands"][key])
    return
  } else if (vi_normal_mode["goto_insert_mode"].HasKey(key)) {
    KMD_ViperDoRepeat(vi_normal_mode["goto_insert_mode"][key])
    KMD_SetMode("vi_insert_mode")
    return
  }

  ; drop repeat count
  vi_normal_mode["repeat_count"] := 0
  vi_normal_mode["last_chars"] := ""
  KMD_Send(key)
}

vi_normal_mode := {}
vi_normal_mode["start"] := "start_vi_normal_mode"
vi_normal_mode["end"] := "end_vi_normal_mode"
vi_normal_mode["shortcut"] := "v"
vi_normal_mode["repeat_count"] := 0
vi_normal_mode["handle_keys"] := "vi_normal_mode_handle_keys"

vi_normal_mode["simple_commands"] := {}
vi_normal_mode["simple_commands"]["h"] := "{Left}"
vi_normal_mode["simple_commands"]["j"] := "{Down}"
vi_normal_mode["simple_commands"]["k"] := "{Up}"
vi_normal_mode["simple_commands"]["l"] := "{Right}"

vi_normal_mode["simple_commands"]["w"] := "^{Right}"
vi_normal_mode["simple_commands"]["e"] := "^{Right}{Left}"
vi_normal_mode["simple_commands"]["b"] := "^{Left}"

vi_normal_mode["simple_commands"]["x"] := "{Del}"
vi_normal_mode["simple_commands"]["+x"] := "{BS}"

vi_normal_mode["simple_commands"]["$"]  := "{END}"
; vi_normal_mode["simple_commands"]["^u"] := "{PgUp}"
; vi_normal_mode["simple_commands"]["^d"] := "{PgDn}"
vi_normal_mode["simple_commands"]["+g"] := "^{End}"
vi_normal_mode["simple_commands"]["u"]  := "^z"

vi_normal_mode["goto_insert_mode"] := {}
vi_normal_mode["goto_insert_mode"]["o"] := "{End}{Enter}"
vi_normal_mode["goto_insert_mode"]["+o"] := "{Up}{End}{Enter}"
vi_normal_mode["goto_insert_mode"]["i"] := ""
vi_normal_mode["goto_insert_mode"]["+i"] := "{Home}"
vi_normal_mode["goto_insert_mode"]["a"] := "{Right}"
vi_normal_mode["goto_insert_mode"]["+a"] := "{End}"

; vi_normal_mode["app_depending_commands"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"]["/"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"]["?"] := {}

KMD_ViperRepeatCount := 0
