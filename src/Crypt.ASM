format PE GUI 4.0
entry start

include 'win32a.inc'


section '.data' data readable writeable

buff	rb 500h


section '.code' code readable executable

  start:
	invoke	GetModuleHandle,0
	invoke	DialogBoxParam,eax,37,HWND_DESKTOP,DialogProc,0
	invoke	ExitProcess,0


proc DialogProc hwnddlg,msg,wparam,lparam
	push	ebx esi edi
	cmp	[msg],WM_INITDIALOG
	je	.wminitdialog
	cmp	[msg],WM_COMMAND
	je	.wmcommand
	cmp	[msg],WM_CLOSE
	je	.wmclose
	xor	eax,eax
	jmp	.finish
  .wminitdialog:
	jmp	.wmencode
  .wmcommand:
	cmp	[wparam],BN_CLICKED shl 16 + IDCANCEL
	je	.wmclose
	cmp	[wparam],EN_CHANGE shl 16 + ID_TXT
	je	.wmencode
	jmp	.processed

  .wmencode:
	invoke	GetDlgItemText,[hwnddlg],ID_TXT,buff,255
	invoke	lstrlen,buff

	stdcall ROT13,buff,eax

	invoke	SetDlgItemText,[hwnddlg],ID_ROT13,buff
	jmp	.processed

  .wmclose:
	invoke	EndDialog,[hwnddlg],0
  .processed:
	mov	eax,1
  .finish:
	pop	edi esi ebx
	ret
endp

proc	ROT13 lpData:DWORD, dSize:DWORD
	pusha

	mov	ecx,[dSize]
	or	ecx,ecx
	jz	.loc_ret

	mov	esi,[lpData]
	mov	edi,esi
.loc_crypt:
	lodsb
	inc	edi
	mov	ah,al
	and	ah,20h
	and	al,0FFh-20h
	cmp	al,'A'
	jb	.no_crypt
	cmp	al,'Z'
	ja	.no_crypt

	sub	al,13
	cmp	al,'A'
	jae	@f
	add	al,26
@@:
	or	al,ah
	dec	edi
	stosb
.no_crypt:
	loop	.loc_crypt
.loc_ret:
	popa
	ret
endp


section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL'

  include 'api\kernel32.inc'
  include 'api\user32.inc'


section '.rsrc' resource data readable

  directory RT_DIALOG,dialogs

  resource dialogs,\
	   37,LANG_ENGLISH+SUBLANG_DEFAULT,demonstration

  ID_TXT = 100
  ID_ROT13 = 101

  dialog demonstration,'Crypt by ROT13',0,0,190,55,WS_CAPTION+WS_SYSMENU+DS_CENTER+DS_SYSMODAL
    dialogitem 'BUTTON','',-1, 2, -1, 185, 36,WS_VISIBLE+BS_GROUPBOX
    dialogitem 'EDIT','Try to encrypt ;)', ID_TXT,5,7,177,13,WS_VISIBLE+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL
    dialogitem 'EDIT','', ID_ROT13,5,19,177,13,WS_VISIBLE+WS_BORDER+ES_AUTOHSCROLL+ES_READONLY
    dialogitem 'BUTTON','Exit',IDCANCEL,135,37,50,15,WS_VISIBLE+WS_TABSTOP+BS_PUSHBUTTON
  enddialog