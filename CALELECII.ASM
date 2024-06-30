; -------------------------------------------
; Calculos Electricos NEC
; By: Alfonso Davila - 2003
;     h1p0t@proton.me
;     www.h1pot.com
; -------------------------------------------

; #########################################################################
      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\masm32.inc
      include \masm32\fpulib\Fpu.inc
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\masm32.lib
      includelib \masm32\fpulib\fpu.lib

; #########################################################################

        ;=============
        ; Local macros
        ;=============
  
        szText MACRO Name, Text:VARARG
          LOCAL lbl
            jmp lbl
              Name db Text,0
            lbl:
          ENDM

;        FUNC MACRO parameters:VARARG
;            invoke parameters
;            EXITM <eax>
;        ENDM
    ; ---------------------
    ; literal string MACRO
    ; ---------------------
      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM

    ; --------------------------------
    ; string address in INVOKE format
    ; --------------------------------
      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM
      
        ;=================
        ; Local prototypes
        ;=================
        WndProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
        EditProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Edit0Proc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
        CheckO     PROTO :BYTE
        Calculos   PROTO :DWORD
        SelCond    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        SelCondCap PROTO :DWORD,:DWORD,:DWORD,:DWORD,:BYTE
        SelBreaker PROTO :DWORD,:DWORD
        KVA        PROTO :DWORD,:DWORD,:DWORD,:BYTE
        KW         PROTO :DWORD,:DWORD,:DWORD
        HP         PROTO :DWORD,:DWORD,:DWORD
        BTU        PROTO :DWORD,:DWORD,:DWORD
        AMP        PROTO :DWORD,:DWORD,:DWORD
        ConstK     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:BYTE
        CAIDA      PROTO :DWORD,:DWORD,:DWORD,:BYTE
        FLtoASWT   PROTO :DWORD,:DWORD
        GWTAtoFL   PROTO :DWORD,:DWORD


    .data
        hWnd          dd 0
        hKva          dd 0
        hKw           dd 0
        hHp           dd 0
        hBtu          dd 0
        hEfic         dd 0
        hCaida        dd 0
        hFp           dd 0
        hLong         dd 0
        hAmp          dd 0
        hBreaker      dd 0
        hTension      dd 0
        hCond         dd 0
        hTw           dd 0
        hThw          dd 0
        hTtu          dd 0
        hPvc          dd 0
        hAl           dd 0
        hAcero        dd 0
        hCorrMax      dd 0
        hR            dd 0
        hXl           dd 0
        hZ            dd 0
        hK            dd 0
        hMsg          dd 0
        hInstance     dd 0
;       hIconImage    dd 0
        hIcon         dd 0
        lpfnEdit0Proc dd 0
        Last          dd 0

        lXlPvcAl      dt 0.18,0.16,0.17,0.17,0.16,0.15,0.14,0.14,0.13,0.13,0.13,0.13,0.12,0.12
        lXlAcero      dt 0.22,0.21,0.21,0.21,0.20,0.19,0.18,0.18,0.17,0.17,0.16,0.16,0.16,0.15 
        lXl           dt 0,0,0,0,0,0.4390,0.4213,0.4125,0.3950,0,0,0,0,0 
        lRCuPvc       dt 6.56,3.94,2.56,1.61,1.02,0.62,0.39,0.33,0.20,0.17,0.12,0.09,0.06,0.05
        lRCuAl        dt 6.56,3.94,2.56,1.61,1.02,0.66,0.43,0.33,0.22,0.19,0.14,0.10,0.08,0.06
        lRCuAcero     dt 6.56,3.94,2.56,1.61,1.02,0.66,0.39,0.33,0.21,0.18,0.13,0.10,0.07,0.06
        lRCu          dt 0,0,0,1.6629,1.1117,0.7767,0.5548,0.4765,0.3659,0,0,0,0,0
        lRAlPvc       dt 10.50,6.56,4.26,2.66,1.67,1.05,0.66,0.52,0.33,0.28,0.20,0.14,0.10,0.08          
        lRAlAl        dt 10.50,6.56,4.26,2.66,1.67,1.05,0.69,0.52,0.36,0.30,0.22,0.16,0.11,0.09
        lRAlAcero     dt 10.50,6.56,4.26,2.66,1.67,1.05,0.66,0.52,0.33,0.28,0.21,0.15,0.10,0.08
        lRAl          dt 0,0,0,2.4550,1.6066,1.0750,0.7420,0.6266,0.4596,0,0,0,0,0

        CondCu        dt  0,0,0,120.0,170.0,230.0,310.0,360.0,480.0,540.0,670.0,840.0,1090.0,0
        CondCuTw      dt  25.0,30.0,40.0,55.0,70.0,95.0,125.0,145.0,195.0,215.0,260.0,320.0,400.0,455.0
        CondCuThw     dt  25.0,35.0,50.0,65.0,85.0,115.0,150.0,175.0,230.0,255.0,310.0,380.0,475.0,545.0
        CondCuTtu     dt  30.0,40.0,55.0,75.0,95.0,130.0,170.0,195.0,260.0,290.0,350.0,430.0,535.0,615.0
        CondArv       dt  0,0,0,100.0,140.0,180.0,240.0,280.0,380.0,0,0,0,0,0  
        CondAlTw      dt  20.0,25.0,30.0,40.0,55.0,75.0,100.0,115.0,150.0,170.0,210.0,260.0,320.0,375.0
        CondAlThw     dt  20.0,30.0,40.0,50.0,65.0,90.0,120.0,135.0,180.0,205.0,250.0,310.0,385.0,445.0
        CondAlTtu     dt  25.0,35.0,45.0,60.0,75.0,100.0,135.0,150.0,205.0,230.0,280.0,350.0,435.0,500.0

        Breaker       dt  20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,110.0,120.0,130.0,140.0,150.0

        ItemCond0 db "12",0
        ItemCond1 db "10",0
        ItemCond2 db "8",0
        ItemCond3 db "6",0
        ItemCond4 db "4",0
        ItemCond5 db "2",0
        ItemCond6 db "1/0",0
        ItemCond7 db "2/0",0
        ItemCond8 db "4/0",0
        ItemCond9 db "250",0
        ItemCond10 db "350",0
        ItemCond11 db "500",0
        ItemCond12 db "750",0
        ItemCond13 db "1000",0

        r2         dt 1.732050
        CFp        db "85",0
        CTe        db "13800",0
        CLong      db "1",0
        CEfic      db "100",0
        NoCond     dd 13
        CHp        dt 0.746
        CBtu       dt 3412.0
        dlgname    db "CALCULUS",0
        fMtStrinG  db "%lu",0      ; this is for wsprintf

.const

CE_KVA       equ 100
CE_KW        equ 101
CE_HP        equ 102
CE_BTU       equ 103
CE_AMP       equ 104
CE_EFIC      equ 105
CE_CAIDA     equ 106
CE_LONG      equ 107
CE_FP        equ 108
CE_TPVC      equ 200
CE_TAL       equ 201
CE_TACERO    equ 202
CE_TNINGUNA  equ 203
CE_MONO      equ 204
CE_TRIF      equ 205
CE_CU        equ 210
CE_AL        equ 211
CE_TW        equ 212
CE_THW       equ 213
CE_TTU       equ 214
CE_DESNUDO   equ 215
CE_TENSION   equ 300
CE_COND      equ 301
CE_K         equ 404
CE_BREAKER   equ 405
CE_MSG       equ 406

; #########################################################################

    .code

start:

      invoke GetModuleHandle, NULL
      mov hInstance, eax
      
      ; -------------------------------------------
      ; Llamada al cuadro de dialogo almacenado en el archivo de recursos
      ; -------------------------------------------
      invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR WndProc,0
      invoke ExitProcess,eax

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

      .if uMsg == WM_INITDIALOG
      ; --------------------------------
      ; setup de items requeridos al inicio
      ; --------------------------------
        mov eax, hWin
        mov hWnd, eax
; invoke SendDlgItemMessage,hWin,ADDR dlgname,WS_OVERLAPPEDWINDOW,1,1
        szText dlgTitle,"C�lculos El�ctricos II - beta 06/10/03"
        invoke SendMessage,hWin,WM_SETTEXT,0,ADDR dlgTitle
        invoke LoadIcon,hInstance,700
        mov hIcon, eax
        invoke SendMessage,hWin,WM_SETICON,1,hIcon
      ; ----------------------------------------
      ; Valores por defecto de las listas
      ; ----------------------------------------
	 invoke SendDlgItemMessage, hWin, CE_COND, WM_SETREDRAW, FALSE, 0
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond0
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond1
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond2
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond3
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond4
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond5
 	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond6
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond7
 	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond8
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond9
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond10
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond11
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond12
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_ADDSTRING, 0, ADDR ItemCond13
	 invoke SendDlgItemMessage, hWin, CE_COND, WM_SETREDRAW, TRUE, 0
      ; ----------------------------------------
      ; Valores por defecto de los controles
      ; ----------------------------------------
  	 invoke CheckRadioButton, hWin, CE_TPVC, CE_TACERO, CE_TPVC ; activar opcion PVC
  	 invoke CheckRadioButton, hWin, CE_MONO, CE_TRIF, CE_TRIF ; activar opcion trifas
  	 invoke CheckRadioButton, hWin, CE_CU, CE_AL, CE_CU ; activar opcion Cu
       invoke CheckRadioButton, hWin, CE_TW, CE_DESNUDO, CE_TW ; activar opcion Desnudo
	 invoke SendDlgItemMessage, hWin, CE_COND, CB_SETCURSEL, 0, 0 ; activar Conductor
       ; --------------------
      ; handles para las entradas de datos
      ; --------------------
        invoke GetDlgItem,hWin,CE_KVA
        mov hKva, eax
        mov Last, eax
        invoke GetDlgItem,hWin,CE_KW
        mov hKw, eax
        invoke GetDlgItem,hWin,CE_HP
        mov hHp, eax
        invoke GetDlgItem,hWin,CE_BTU
        mov hBtu, eax
        invoke GetDlgItem,hWin,CE_AMP
        mov hAmp, eax
        invoke GetDlgItem,hWin,CE_EFIC
        mov hEfic, eax
        invoke SetWindowText,hEfic,ADDR CEfic ; coloca el valor predefinido
        invoke GetDlgItem,hWin,CE_CAIDA
        mov hCaida, eax
        invoke GetDlgItem,hWin,CE_LONG
        mov hLong, eax
        invoke SetWindowText,hLong,ADDR CLong ; coloca el valor predefinido
        invoke GetDlgItem,hWin,CE_FP
        mov hFp, eax
        invoke SetWindowText,hFp,ADDR CFp ; coloca el valor predefinido
        invoke GetDlgItem,hWin,CE_TENSION
        mov hTension, eax
        invoke SetWindowText,hTension,ADDR CTe ; coloca el valor predefinido
        invoke GetDlgItem,hWin,CE_COND
        mov hCond, eax

      ; ----------------------------------------
      ; Filtrado para la entrada de datos
      ; ----------------------------------------
        invoke SetWindowLong,hKva,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hKw,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hHp,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hBtu,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hAmp,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hEfic,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hCaida,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hLong,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hFp,GWL_WNDPROC,Edit0Proc
        invoke SetWindowLong,hTension,GWL_WNDPROC,Edit0Proc
        mov lpfnEdit0Proc, eax

      ; ----------------------------------------
      ; Items para la Salida de Resultados
      ; ----------------------------------------
        invoke GetDlgItem,hWin,400
        mov hR, eax
        invoke GetDlgItem,hWin,401
        mov hXl, eax
        invoke GetDlgItem,hWin,402
        mov hZ, eax
        invoke GetDlgItem,hWin,403
        mov hCorrMax, eax
        invoke GetDlgItem,hWin,CE_BREAKER
        mov hBreaker, eax
        invoke GetDlgItem,hWin,CE_MSG
        mov hMsg, eax
        invoke GetDlgItem,hWin,CE_K
        mov hK, eax

      ; -----------------------------------------
      ; procesamiento de los mensajes 
      ; -----------------------------------------
      .elseif uMsg == WM_COMMAND
    		mov eax,wParam
		mov edx,eax
		shr edx,16
	.if (wParam>=CE_TPVC && wParam<=CE_DESNUDO)
            invoke Calculos,NULL
      .elseif dx==CBN_SELCHANGE
            invoke Calculos,hCond
      .endif

      .if wParam == 1000  ; Limpiar
	     invoke SetWindowText,hKva,NULL
	     invoke SetWindowText,hKw,NULL
	     invoke SetWindowText,hHp,NULL
            invoke SetWindowText,hBtu,NULL
	     invoke SetWindowText,hAmp,NULL
            invoke SetWindowText,hEfic,ADDR CEfic   ; coloca el valor predefinido
            invoke SetWindowText,hCaida,NULL
            invoke SetWindowText,hLong,ADDR CLong   ; coloca el valor predefinido
            invoke SetWindowText,hBreaker,NULL
            invoke SetWindowText,hFp,ADDR CFp       ; coloca el valor predefinido
            invoke SetWindowText,hTension,ADDR CTe  ; coloca el valor predefinido
            invoke SetFocus,hKva
      .endif

      .if wParam == 1002  ; Acerca de...
              szText dlgTit,"C�lculos El�ctricos"
              szText dlgTex,"Ing. Alfonso A. D�vila V. - 2003",0ah, 0dh, "   h1p0t@proton.me", 0ah, 0dh, 0ah, 0dh,"NEC",0ah, 0dh, 0ah, 0dh,"   Assembler, Puro & Simple"
		invoke MessageBox,hWin,ADDR dlgTex,ADDR dlgTit,MB_OK
;          invoke AboutBox,hWin,hInstance,hIcon,SADD("Calculos El�ctricos II"),SADD("Ing. Alfonso A. D�vila V."),SADD("h1p0t@proton.me",13,10,"Copyright � 2003",13,10,"Assembler, Puro y Simple",13,10,"Version Beta")

        .endif
      .elseif uMsg == WM_MOUSEMOVE
            invoke SendMessage,hMsg,WM_SETTEXT,0,NULL

      .elseif uMsg == WM_CLOSE  ; para el boton X de cerrado
        invoke EndDialog,hWin,0
    .endif

    xor eax, eax    ; this must be here in NT4
    ret

WndProc endp

; #########################################################################

Edit0Proc proc hCtl   :DWORD,
               uMsg   :DWORD,
               wParam :DWORD,
               lParam :DWORD
    mov edx, hCtl
    .if edx == hFp
        invoke EditProc,hCtl,uMsg,wParam,lParam,4 
    .else
        invoke EditProc,hCtl,uMsg,wParam,lParam,9 
    .endif
ret
Edit0Proc endp

EditProc proc hCtl :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD,
              wLen   :DWORD

    LOCAL testBuffer[16]:BYTE
  ; -----------------------------
  ; Process control messages here
  ; -----------------------------
.if uMsg == WM_MOUSEMOVE
    mov eax,hCtl
    .if eax==hKva
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("kVA = kW / Fp")
    .elseif eax==hKw
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("kW = kVA * Fp")
    .elseif eax==hHp    
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("HP = Kw * %Ef / 0.746")
    .elseif eax==hBtu
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("BTU = KwH * 3412")
    .elseif eax==hAmp
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("I = kVA / sqr(3) * KV")
    .elseif eax==hEfic
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("%Ef = HP / kW * 0.746")
    .elseif eax==hCaida
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("V% = kVA * L * K")
    .elseif eax==hLong
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("Longitud en Metros (Mt)")
    .elseif eax==hFp
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("Factor de Potencia entre 0 - 100")
    .elseif eax==hTension
        invoke SendMessage,hMsg,WM_SETTEXT,0,SADD("Tension en Voltios (V)")
    .endif
    ret
 .elseif uMsg == WM_CHAR
      .if wParam == 8      ; allow backspace
        jmp @F            ; jump FORWORD to next @@:
      .endif
    invoke GetWindowText,hCtl,ADDR testBuffer,16
    invoke lnstr,ADDR testBuffer
      .if eax >= wLen         ; restringido a wLen digitos
        xor eax, eax
        ret
      .endif
        .if wParam == "."           ; only allow one decimal point
            invoke SendMessage,hCtl,WM_GETTEXT,sizeof testBuffer,ADDR testBuffer
            mov ecx, sizeof testBuffer  ; byte count in ecx
            lea esi, testBuffer         ; address in esi
          @xxx:
            lodsb                   ; load byte into al
            cmp al, "."             ; if decimal point already in Buffer
            jne @xx1
            xor eax, eax
            ret

            @xx1:
            dec ecx
            cmp ecx, 0
            jne @xxx
        jmp @F            ; jump FORWORD to next
     .endif
    ; ------------------
    ; allow numbers only
    ; ------------------
      .if wParam > 57
          xor eax, eax
          ret
      .elseif wParam < 48
          xor eax, eax
          ret
      .endif
    .endif
    @@:
      invoke CallWindowProc,lpfnEdit0Proc,hCtl,uMsg,wParam,lParam
      mov ecx,hCtl
	.if (uMsg==WM_CHAR && (ecx==hKva || ecx==hKw || ecx==hHp || ecx==hBtu || ecx==hAmp || ecx==hEfic || ecx==hCaida || ecx==hLong || ecx==hFp || ecx==hTension)) || (uMsg==WM_KEYUP && wParam==46)
          invoke Calculos,hCtl
      .endif
    ret
EditProc endp

; ########################################################################
Calculos proc oPc:DWORD
    LOCAL inBuffer[16]   :BYTE     
    LOCAL I              :TBYTE
    LOCAL Kva            :TBYTE
    LOCAL Kw             :TBYTE
    LOCAL Hp             :TBYTE
    LOCAL Btu            :TBYTE
    LOCAL Amp            :TBYTE
    LOCAL Efic           :TBYTE
    LOCAL Caida          :TBYTE
    LOCAL Fp             :TBYTE
    LOCAL kV             :TBYTE            
    LOCAL kVC            :TBYTE          
    LOCAL K              :TBYTE
    LOCAL Long           :TBYTE
    LOCAL Tension        :TBYTE
    LOCAL BotonTrif      :DWORD     
     
    invoke GWTAtoFL,hFp,ADDR Fp
    .if eax==0
        ret
    .endif
    invoke FpuDiv,ADDR Fp,100,ADDR Fp,SRC1_REAL or SRC2_DIMM or DEST_MEM
    invoke GWTAtoFL,hTension,ADDR Tension
    .if eax==0
        ret
    .endif
    invoke FpuDiv,ADDR Tension,1000,ADDR kV,SRC1_REAL or SRC2_DIMM or DEST_MEM
    invoke IsDlgButtonChecked, hWnd,CE_TRIF
    mov BotonTrif, eax
    .if BotonTrif == 1
        invoke FpuMul, ADDR kV, ADDR r2, ADDR kVC, SRC1_REAL or SRC2_REAL or DEST_MEM
    .else
        invoke FpuMul, ADDR kV, 1, ADDR kVC, SRC1_REAL or SRC2_DIMM or DEST_MEM
    .endif
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_GETCURSEL, 0, 0 ; toma el calibre del conductor
    invoke ConstK,ADDR K,ADDR kV,ADDR Fp,eax,0    ; Calcula la Constante K OJO ----<------
    mov ecx, Last
    mov edx, oPc
    .if edx==hKva || ((edx==hFp || edx==hTension || edx==hLong || edx==NULL || edx==hCond) && ecx==hKva)
        push edx
       .if edx==hKva
            mov Last,edx
        .endif    
        invoke GWTAtoFL,hKva,ADDR Kva
        .if eax==0
            ret
        .endif
        invoke KW,ADDR Kva,ADDR Fp,ADDR Kw
        invoke BTU,ADDR Kw,ADDR CBtu, ADDR Btu
        invoke GWTAtoFL,hEfic,ADDR Efic
        .if eax!=0
            invoke FpuDiv,ADDR Efic,100,ADDR Efic,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke HP,ADDR Kw,ADDR Efic,ADDR Hp
        .endif
        invoke AMP,ADDR Kva,ADDR kVC,ADDR I
        pop edx
        .if edx!=hCond
            invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
        .else
            invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
        .endif
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax!=0
            invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke CAIDA,ADDR Kva,ADDR Long,ADDR K,0    ; Calcula la Caida de Tension
        .endif
        ret
    .elseif edx==hKw || ((edx==hFp || edx==hTension || edx==hLong || edx==NULL || edx==hCond) && ecx==hKw)
        push edx
        .if edx==hKw
            mov Last,edx
        .endif    
        invoke GWTAtoFL,hKw,ADDR Kw
        .if eax==0
            ret
        .endif
        invoke KVA,ADDR Kw,ADDR Fp,ADDR Kva,0
        invoke GWTAtoFL,hEfic,ADDR Efic
        .if eax!=0
            invoke FpuDiv,ADDR Efic,100,ADDR Efic,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke HP,ADDR Kw,ADDR Efic,ADDR Hp
        .endif
        invoke BTU,ADDR Kw,ADDR CBtu, ADDR Btu
        invoke AMP,ADDR Kva,ADDR kVC,ADDR I
        pop edx
        .if edx!=hCond
            invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
        .else
            invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
        .endif
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax!=0
            invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke CAIDA,ADDR Kva,ADDR Long,ADDR K,0    ; Calcula la Caida de Tension
        .endif
        ret
    .elseif edx==hHp || edx==hEfic || ((edx==hFp || edx==hTension || edx==hLong || edx==NULL || edx==hCond) && ecx==hHp)
        push edx
        .if edx==hHp
            mov Last,edx
        .endif    
        invoke GWTAtoFL,hHp,ADDR Hp
        .if eax==0
            ret
        .endif
        invoke FpuMul, ADDR Hp, ADDR CHp, ADDR inBuffer, SRC1_REAL or SRC2_REAL or DEST_MEM
        invoke GWTAtoFL,hEfic,ADDR Efic
        .if eax!=0
            invoke FpuDiv,ADDR Efic,100,ADDR Efic,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke FpuDiv, ADDR inBuffer, ADDR Efic, ADDR Kw, SRC1_REAL or SRC2_REAL or DEST_MEM
            invoke FLtoASWT,hKw,ADDR Kw
        invoke KVA,ADDR Kw,ADDR Fp,ADDR Kva,0
        invoke BTU,ADDR Kw,ADDR CBtu, ADDR Btu
        invoke AMP,ADDR Kva,ADDR kVC,ADDR I
        pop edx
        .if edx!=hCond
            invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
        .else
            invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
        .endif
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax!=0
            invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke CAIDA,ADDR Kva,ADDR Long,ADDR K,0    ; Calcula la Caida de Tension
        .endif
        .endif
        ret
    .elseif edx==hBtu || ((edx==hFp || edx==hTension || edx==hLong || edx==NULL || edx==hCond) && ecx==hBtu)
        push edx
        .if edx==hBtu
            mov Last,edx
        .endif    
        invoke GWTAtoFL,hBtu,ADDR Btu
        .if eax==0
            ret
        .endif
        invoke FpuDiv, ADDR Btu, ADDR CBtu, ADDR Kw, SRC1_REAL or SRC2_REAL or DEST_MEM ; KwH = Btu / 3412
        invoke FLtoASWT,hKw,ADDR Kw
        invoke KVA,ADDR Kw,ADDR Fp,ADDR Kva,0
        invoke GWTAtoFL,hEfic,ADDR Efic
        .if eax==0
            ret
        .endif
        invoke FpuDiv,ADDR Efic,100,ADDR Efic,SRC1_REAL or SRC2_DIMM or DEST_MEM
        invoke HP,ADDR Kw,ADDR Efic,ADDR Hp
        invoke AMP,ADDR Kva,ADDR kVC,ADDR I
        pop edx
        .if edx!=hCond
            invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
        .else
            invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
        .endif
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax!=0
            invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke CAIDA,ADDR Kva,ADDR Long,ADDR K,0    ; Calcula la Caida de Tension
        .endif
        ret
    .elseif edx==hAmp || ((edx==hFp || edx==hTension || edx==hLong || edx==NULL || edx==hCond) && ecx==hAmp)
        push edx
        .if edx==hAmp
            mov Last,edx
        .endif    
        invoke GWTAtoFL,hAmp,ADDR I
        .if eax==0
            ret
        .endif
        pop edx
        .if edx!=hCond
            invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
        .else
            invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
        .endif
        invoke KVA,ADDR I,ADDR kVC,ADDR Kva,1
        invoke KW,ADDR Kva,ADDR Fp,ADDR Kw
        invoke GWTAtoFL,hEfic,ADDR Efic
        .if eax==0
            ret
        .endif
        invoke FpuDiv,ADDR Efic,100,ADDR Efic,SRC1_REAL or SRC2_DIMM or DEST_MEM
        invoke HP,ADDR Kw,ADDR Efic,ADDR Hp
        invoke BTU,ADDR Kw,ADDR CBtu, ADDR Btu
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax!=0
            invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
            invoke CAIDA,ADDR Kva,ADDR Long,ADDR K,0    ; Calcula la Caida de Tension
        .endif
        ret
    .elseif edx==hCaida     ; V% = KVA . L . K -> 
        invoke GWTAtoFL,hCaida,ADDR Caida
        .if eax==0
            ret
        .endif
        invoke GWTAtoFL,hKva,ADDR Kva
        .if eax==0
            ret
        .endif
        invoke GWTAtoFL,hLong,ADDR Long
        .if eax==0
            ret
        .endif
        invoke FpuDiv,ADDR Long,1000,ADDR Long,SRC1_REAL or SRC2_DIMM or DEST_MEM
        invoke SelCond,ADDR Caida,ADDR Kva,ADDR kV,ADDR Fp,ADDR Long   ; se hace la selecci�n del conductor
        ret
    .endif
    invoke GWTAtoFL,hAmp,ADDR I
    .if eax==0
        ret
    .endif
    invoke SelCondCap,ADDR I,ADDR K,ADDR kV,ADDR Fp,0
    ret
Calculos endp

; ########################################################################

GWTAtoFL proc hVar:DWORD,Var:DWORD
         LOCAL inBuffer[16]:BYTE
         invoke GetWindowText,hVar,ADDR inBuffer,10
         invoke FpuAtoFL,ADDR inBuffer,Var,DEST_MEM
         invoke CheckO,inBuffer
         ret
GWTAtoFL endp

FLtoASWT proc hVar:DWORD,Var:DWORD
         LOCAL inBuffer[20]:BYTE
         invoke FpuFLtoA, Var, 3, ADDR inBuffer, SRC1_REAL or SRC2_DIMM or DEST_MEM
         invoke ltrim,ADDR inBuffer,ADDR inBuffer
         invoke SetWindowText,hVar,ADDR inBuffer
         ret
FLtoASWT endp

HP proc Var:DWORD,Var1:DWORD,Var2:DWORD       ; Hp = Kw * %Ef / 0.746
        invoke FpuMul, Var, Var1, 0, SRC1_REAL or SRC2_REAL or DEST_FPU
        invoke FpuDiv, 0, ADDR CHp, Var2, SRC1_FPU or SRC2_REAL or DEST_MEM
        invoke FLtoASWT,hHp,Var2
        ret
HP endp

AMP proc Var:DWORD,Var1:DWORD,Var2:DWORD       ; I = KVA / sqr(3) * KV
        invoke FpuDiv,Var,Var1,Var2, SRC1_REAL or SRC2_REAL or DEST_MEM
        invoke FLtoASWT,hAmp,Var2
        ret
AMP endp

BTU proc Var:DWORD,Var1:DWORD,Var2:DWORD       ; BTU = KwH * 3412
        invoke FpuMul,Var,Var1,Var2, SRC1_REAL or SRC2_REAL or DEST_MEM 
        invoke FLtoASWT,hBtu,Var2
        ret
BTU endp

KVA proc Var:DWORD,Var1:DWORD,Var2:DWORD,V:BYTE       ; KVA = Kw / Fp
    .if V==0
        invoke FpuDiv,Var,Var1,Var2, SRC1_REAL or SRC2_REAL or DEST_MEM 
    .else
        invoke FpuMul,Var,Var1,Var2, SRC1_REAL or SRC2_REAL or DEST_MEM 
    .endif
        invoke FLtoASWT,hKva,Var2
        ret
KVA endp

KW proc Var:DWORD,Var1:DWORD,Var2:DWORD       ; KW = KVA * Fp
        invoke FpuMul,Var,Var1,Var2,SRC1_REAL or SRC2_REAL or DEST_MEM
        invoke FLtoASWT,hKw,Var2
        ret
KW endp        

CAIDA proc Kva:DWORD,Long:DWORD,K:DWORD,O:BYTE     ; V% = KVA . L . K   o   V% = I . L . K
        LOCAL inBuffer:TBYTE
        invoke FpuMul,Kva,Long,0,SRC1_REAL or SRC2_REAL or DEST_FPU 
        invoke FpuMul,0,K,ADDR inBuffer,SRC1_FPU or SRC2_REAL or DEST_MEM 
        .if O==0
            invoke FLtoASWT,hCaida,ADDR inBuffer
        .else
            lea ecx,inBuffer
        .endif
        ret
CAIDA endp    

ConstK proc Var:DWORD,kV:DWORD,Fp:DWORD,ComboCond:DWORD,o:BYTE        ;   K= (R.FP + XL . SEN[ARCOS(FP)]) / (10 . Kv^2)
      LOCAL inBuffer[16]   :BYTE      ; pila es mas eficiente
      LOCAL inBuffer1[16]  :BYTE      
      LOCAL inBuffer2[16]  :BYTE      
      LOCAL Valor          :TBYTE
      LOCAL Valor1         :TBYTE
      LOCAL Valor2         :TBYTE
      LOCAL Z              :TBYTE
      LOCAL K              :TBYTE
      LOCAL BotonPvc       :DWORD     
      LOCAL BotonAl        :DWORD     
      LOCAL BotonAcero     :DWORD     
      LOCAL BotonNinguna   :DWORD    
      LOCAL BotonTw        :DWORD     
      LOCAL BotonCu        :DWORD     
      LOCAL BotonThw       :DWORD     
      LOCAL BotonTtu       :DWORD    
    ; -------------------------------------------------------------
    ; Estado de los Radio Butons
    ; -------------------------------------------------------------
    invoke IsDlgButtonChecked, hWnd,CE_TPVC
    mov BotonPvc, eax
    invoke IsDlgButtonChecked, hWnd,CE_TAL
    mov BotonAl, eax
    invoke IsDlgButtonChecked, hWnd,CE_TACERO
    mov BotonAcero, eax
    invoke IsDlgButtonChecked, hWnd,CE_TNINGUNA
    mov BotonNinguna, eax
    invoke IsDlgButtonChecked, hWnd,CE_CU
    mov BotonCu, eax
    invoke IsDlgButtonChecked, hWnd,CE_TW
    mov BotonTw, eax
    invoke IsDlgButtonChecked, hWnd,CE_THW
    mov BotonThw, eax
    invoke IsDlgButtonChecked, hWnd,CE_TTU
    mov BotonTtu, eax
     ; -------------------------------------------------------------
     ;   Z= R.FP + XL . SEN[ARCOS(FP)]
     ; -------------------------------------------------------------
    invoke FpuArccos, Fp, 0, SRC1_REAL or DEST_FPU
    invoke FpuSin, 0, 0, SRC1_FPU or DEST_FPU
    invoke MulDiv,ComboCond,10,1
    mov ecx,eax
    push ecx
    .if BotonAcero == 1
        lea ebx,lXlAcero[ecx]
    .elseif BotonNinguna == 1
        lea ebx,lXl[ecx]
    .else
        lea ebx,lXlPvcAl[ecx]
    .endif
    invoke FpuMul,0,ebx,ADDR Valor, SRC1_FPU or SRC2_REAL or DEST_MEM
    .if o==0
        invoke FLtoASWT,hXl,ebx
    .endif
    pop ecx
    .if BotonCu == 1
        .if BotonPvc == 1
            lea edx,lRCuPvc[ecx]
            .elseif BotonAl == 1
                lea edx,lRCuAl[ecx]
            .elseif BotonAcero == 1
                lea edx,lRCuAcero[ecx]
            .else    
                lea edx,lRCu[ecx]
        .endif
        .if BotonTw == 1
            lea ebx,CondCuTw[ecx]
        .elseif BotonThw == 1
            lea ebx,CondCuThw[ecx]
        .elseif BotonTtu == 1
            lea ebx,CondCuTtu[ecx]
        .else
            lea ebx,CondCu[ecx]
        .endif
    .else
        .if BotonPvc == 1
                lea edx,lRAlPvc[ecx]
            .elseif BotonAl == 1
                lea edx,lRAlAl[ecx]
            .elseif BotonAcero == 1
                lea edx,lRAlAcero[ecx]
            .else
                lea edx,lRAl[ecx]
        .endif
        .if BotonTw == 1
            lea ebx,CondAlTw[ecx]
        .elseif BotonThw == 1
            lea ebx,CondAlThw[ecx]
        .elseif BotonTtu == 1
            lea ebx,CondAlTtu[ecx]
        .else
            lea ebx,CondArv[ecx]
        .endif
    .endif
    invoke FpuMul,edx,Fp,0,SRC1_REAL or SRC2_REAL or DEST_FPU
    invoke FpuAdd,0,ADDR Valor,ADDR Z,SRC1_FPU or SRC2_REAL or DEST_MEM
    ; Mostramos valores de R, Z, Imax
    .if o==0
        invoke FLtoASWT,hR,edx
        invoke FLtoASWT,hZ,ADDR Z
        invoke FLtoASWT,hCorrMax,ebx
    .endif
      ; -------------------------------------------------------------
      ;   K= (R.FP + XL . SEN[ARCOS(FP)]) / (10 . Kv^2)
      ; -------------------------------------------------------------

    invoke FpuXexpY,kV,2,0,SRC1_REAL or SRC2_DIMM or DEST_FPU
    invoke FpuMul,0,10,0,SRC1_FPU or SRC2_DIMM or DEST_FPU
    invoke FpuDiv,ADDR Z,0,Var,SRC1_REAL or SRC2_FPU or DEST_MEM
    .if o==0
       invoke FpuFLtoA, Var, 6, ADDR inBuffer, SRC1_REAL or SRC2_DIMM
       invoke SendMessage, hK,WM_SETTEXT,0,ADDR inBuffer
    .endif
    ret
ConstK endp

CheckO proc Var   :BYTE
    lea esi, Var            ; direccion en esi
    lodsb                   ; Byte cargado en Al
    cmp al, 46              ; Si el valor del buffer es >
    jg @xx2
    xor eax, eax
    ret
    @xx2:
    mov eax,1   ; es valido
    ret
CheckO endp

SelCond proc Caida:DWORD,Kva:DWORD,kV:DWORD,Fp:DWORD,Long:DWORD
    LOCAL K:TBYTE
    LOCAL I:TBYTE    
    LOCAL c1:DWORD
    mov c1,0
    invoke GWTAtoFL,hAmp,ADDR I
@xx1:
    invoke ConstK,ADDR K,kV,Fp,c1,1    ; Calcula la Constante K
    invoke CAIDA,Kva,Long,ADDR K,1      ; Calcula la Caida de Tension
    invoke FpuComp,ecx,Caida,SRC1_REAL or SRC2_REAL
    test	eax,CMP_EQU or CMP_LOWER
    jz @xx2
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_SETCURSEL, c1, 0 ; Selecciomar Conductor
    invoke ConstK,ADDR K,kV,Fp,c1,0    ; Calcula la Constante K
    invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
ret
@xx2:
    inc c1
    mov ecx,c1
    cmp ecx,NoCond
    jl @xx1   
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_SETCURSEL, c1, 0 ; Selecciomar Conductor
    invoke ConstK,ADDR K,kV,Fp,c1,0    ; Calcula la Constante K
    invoke SelCondCap,ADDR I,NULL,NULL,NULL,1
    ret
SelCond endp

SelCondCap proc Imax:DWORD,K:DWORD,kV:DWORD,Fp:DWORD,o:BYTE
    LOCAL c1:DWORD
    LOCAL BotonTw        :DWORD     
    LOCAL BotonCu        :DWORD     
    LOCAL BotonThw       :DWORD     
    LOCAL BotonTtu       :DWORD    
    invoke IsDlgButtonChecked, hWnd,CE_CU
    mov BotonCu, eax
    invoke IsDlgButtonChecked, hWnd,CE_TW
    mov BotonTw, eax
    invoke IsDlgButtonChecked, hWnd,CE_THW
    mov BotonThw, eax
    invoke IsDlgButtonChecked, hWnd,CE_TTU
    mov BotonTtu, eax
    mov c1,0
@xx1:
.if o==1
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_GETCURSEL, 0, 0 ; toma el calibre del conductor
    mov c1,eax
.endif
    invoke MulDiv,c1,10,1
    mov ecx,eax
    .if BotonCu == 1
        .if BotonTw == 1
            lea ebx,CondCuTw[ecx]
        .elseif BotonThw == 1
            lea ebx,CondCuThw[ecx]
        .elseif BotonTtu == 1
            lea ebx,CondCuTtu[ecx]
        .else
            lea ebx,CondCu[ecx]
        .endif
    .else
        .if BotonTw == 1
            lea ebx,CondCuTw[ecx]
        .elseif BotonThw == 1
            lea ebx,CondCuThw[ecx]
        .elseif BotonTtu == 1
            lea ebx,CondCuTtu[ecx]
        .else
            lea ebx,CondCu[ecx]
        .endif
    .endif
    invoke SelBreaker,ebx,Imax
.if o==0
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_SETCURSEL, c1, 0 ; Selecciomar Conductor
    invoke ConstK,K,kV,Fp,c1,0    ; Calcula la Constante K
    invoke FpuComp,ebx,Imax,SRC1_REAL or SRC2_REAL
    test	eax,CMP_EQU or CMP_GREATER
    jz @xx2
    invoke SelBreaker,ebx,Imax
    invoke SendDlgItemMessage, hWnd, CE_COND, CB_SETCURSEL, c1, 0 ; Selecciomar Conductor
    invoke ConstK,K,kV,Fp,c1,0    ; Calcula la Constante K
ret
@xx2:
    inc c1
    mov ecx,c1
    cmp ecx,NoCond
    jle @xx1   
.endif
ret
SelCondCap endp

SelBreaker proc Ic:DWORD,I:DWORD
    LOCAL Ip:TBYTE
    LOCAL c1:DWORD
    LOCAL inBuffer[16]   :BYTE      ; pila es mas eficiente
    LOCAL BotonDesn      :DWORD    
    invoke IsDlgButtonChecked, hWnd,CE_DESNUDO
    mov BotonDesn, eax
.if BotonDesn != 1
    invoke FpuAdd,I,Ic,0,SRC1_REAL or SRC2_REAL or DEST_FPU
    invoke FpuDiv,0,2,ADDR Ip,SRC1_FPU or SRC2_DIMM or DEST_MEM
    mov c1,0
    @xx1:
        invoke MulDiv,c1,10,1
        lea ebx,Breaker[eax]
        push ebx
        invoke FpuFLtoA,ebx, 0, ADDR inBuffer, SRC1_REAL or SRC2_DIMM or DEST_MEM
        invoke SetWindowText,hBreaker,ADDR inBuffer
        pop ebx
        invoke FpuComp,ebx,ADDR Ip,SRC1_REAL or SRC2_REAL
        test	eax,CMP_EQU or CMP_GREATER
        jz @xx2
    ret
    @xx2:
        inc c1
        mov ecx,c1
        cmp ecx,NoCond
        jle @xx1   
.else
    invoke SetWindowText,hBreaker,NULL
.endif  
ret
SelBreaker endp

end start
