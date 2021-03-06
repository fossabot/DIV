;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%  Copyright (C) 1988-1995 by WATCOM International Corp. All	%
;%  rights reserved. No part of this software may be reproduced %
;%  in any form or by any means - graphic, electronic or	%
;%  mechanical, including photocopying, recording, taping	%
;%  or information storage and retrieval systems - except	%
;%  with the written permission of WATCOM International Corp.	%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; startup code for WATCOM C/C++16 under MS-DOS
;
;	This must be assembled using one of the following commands:
;		wasm cstrt086 -bt=DOS -ms -0r_ -d__TINY__
;		wasm cstrt086 -bt=DOS -ms -0r_
;		wasm cstrt086 -bt=DOS -mm -0r_
;		wasm cstrt086 -bt=DOS -mc -0r_
;		wasm cstrt086 -bt=DOS -ml -0r_
;		wasm cstrt086 -bt=DOS -mh -0r_
;
include mdef.inc
.286p
	name	cstart

	assume	nothing

ifdef	EXPRESS
	extrn	SaveDataSeg_		: far
endif

if _MODEL and _BIG_CODE
	extrn	__CMain			: far
;	extrn	__InitRtns		: far
;	extrn	__FiniRtns		: far
;	extrn	__fatal_runtime_error_	: far
else
	extrn	__CMain			: near
;	extrn	__InitRtns		: near
;	extrn	__FiniRtns		: near
;	extrn	__fatal_runtime_error_	: near
endif
	extrn	_edata			: byte	; end of DATA (start of BSS)
	extrn	_end			: byte	; end of BSS (start of STACK)

	extrn	"C",__curbrk		: word
	extrn	"C",__psp		: word
	extrn	"C",__osmajor		: byte
	extrn	"C",__osminor		: byte
	extrn	__osmode		: byte
	extrn	__HShift		: byte
	extrn	"C",__STACKLOW		: word
	extrn	"C",__STACKTOP		: word
	extrn	"C",__cbyte		: word
	extrn	"C",__child		: word
	extrn	__no87			: word
	extrn	__FPE_handler		: word
	extrn  ___FPE_handler		: word
	extrn	"C",__LpCmdLine		: word
	extrn	"C",__LpPgmName		: word
	extrn	__get_ovl_stack		: word
	extrn	__restore_ovl_stack	: word
	extrn	__close_ovl_file	: word

ifndef EXPRESS
	extrn	__DOSseg__		: byte
endif

ifdef __TINY__
	extrn	__stacksize		: word
 DGROUP group _TEXT,CONST,STRINGS,_DATA,DATA,XIB,XI,XIE,YIB,YI,YIE,_BSS
else
ifdef EXPRESS
 DGROUP group _NULL,_AFTERNULL,CONST,STRINGS,_DATA,DATA,BCSD,XIB,XI,XIE,_BSS,TCONS,SSTRING,DATA_,BSS_,STACK
else
 DGROUP group _NULL,_AFTERNULL,CONST,STRINGS,_DATA,DATA,BCSD,XIB,XI,XIE,YIB,YI,YIE,_BSS,STACK
endif
endif

ife _MODEL and _BIG_CODE

ifndef __TINY__
; this guarantees that no function pointer will equal NULL
; (WLINK will keep segment 'BEGTEXT' in front)
; This segment must be at least 4 bytes in size to avoid confusing the
; signal function.
; need a symbol defined here to prevent the dead code elimination from
; eliminating the segment.
; (the int 3h is useful for quickly revealing jumps to NULL code pointers)

BEGTEXT  segment word public 'CODE'
	assume	cs:BEGTEXT
forever	label	near
	int	3h
	jmp	short forever
___begtext label byte
	nop
	nop
	nop
	nop
	public ___begtext
	assume	cs:nothing
BEGTEXT  ends

endif
endif

_TEXT	segment word public 'CODE'

ifndef __TINY__
FAR_DATA segment byte public 'FAR_DATA'
FAR_DATA ends
endif

	assume	ds:DGROUP

ifndef __TINY__
	INIT_VAL	equ 0101h
	NUM_VAL 	equ 16

_NULL	segment para public 'BEGDATA'
__nullarea label word
	dw	NUM_VAL dup(INIT_VAL)
	public	__nullarea
_NULL	ends

_AFTERNULL segment word public 'BEGDATA'
	dw	0			; nullchar for string at address 0
_AFTERNULL ends

endif

CONST	segment word public 'DATA'
CONST	ends

STRINGS segment word public 'DATA'
STRINGS ends

XIB	segment word public 'DATA'
XIB	ends
XI	segment word public 'DATA'
XI	ends
XIE	segment word public 'DATA'
XIE	ends

YIB	segment word public 'DATA'
YIB	ends
YI	segment word public 'DATA'
YI	ends
YIE	segment word public 'DATA'
YIE	ends

_DATA	segment word public 'DATA'

if _MODEL and _BIG_CODE
;	Variables filled in by Microsoft Overlay Manager
;	These are here for people who want to link with Microsoft Linker
;	and use CodeView for debugging overlayed programs.
__ovlflag  db 0 		; non-zero => program is overlayed
__intno    db 0 		; interrupt number used by MS Overlay Manager
__ovlvec   dd 0 		; saved contents of interrupt vector used
	public	__ovlflag
	public	__intno
	public	__ovlvec
endif

_DATA	ends

DATA	segment word public 'DATA'
DATA	ends

BCSD	segment word public 'DATA'
BCSD	ends

ifdef	EXPRESS

_BSS	      segment word public 'BSS'
_BSS	      ends

TCONS	segment word public 'ATAD'
__bss_end	label	word
__RTEndOfData	dw 0
	public	__RTEndOfData
TCONS	ends

SSTRING segment word public 'ATAD'
SSTRING ends

DATA_	segment word public 'ATAD'
DATA_	ends

BSS_	      segment word public 'SSB'
BSS_	      ends

else

_BSS	      segment word public 'BSS'
_BSS	      ends

endif


ifndef __TINY__
STACK_SIZE	equ	100h

STACK	segment para stack 'STACK'
	db	(STACK_SIZE) dup(?)
STACK	ends
endif

	assume	nothing
	public	_cstart_
	public	_Not_Enough_Memory_

	assume	cs:_TEXT

ifdef __TINY__
	org	0100h
endif

 _cstart_ proc near
	jmp	around

;
; copyright message
;
        db      "DIV Games Studio "
        db      "(c) 1999 Hammer Technologies."
;
; miscellaneous code-segment messages
;
ifndef __TINY__

NullAssign	db	'NULL assignment detected',0dh,0ah,0

endif

NoMemory	db	'Not enough memory',0dh,0ah,0

ConsoleName	db	'con',00h

ife _MODEL and _BIG_CODE
ifndef __TINY__
		dw	___begtext	; make sure dead code elimination
endif					; doesn't kill BEGTEXT segment
endif

around: sti				; enable interrupts
ifdef __TINY__
	mov	cx,cs
else
	mov	cx,DGROUP		; get proper stack segment
endif

	assume	es:DGROUP

	mov	es,cx			; point to data segment
	mov	bx,offset DGROUP:_end	; get bottom of stack
	add	bx,0Fh			; ...
	and	bl,0F0h			; ...
	mov	es:__STACKLOW,bx	; ...
	mov	es:__psp,ds		; save segment address of PSP

ifdef __TINY__
	mov	ax,es:__stacksize	; get size of stack required
	cmp	ax,0800h		; make sure stack size is at least
	jae	ss_ok			; 2048 bytes
	mov	ax,0800h		; - set stack size to 2048 bytes
ss_ok:	add	bx,ax			; calc top address for stack
else
	add	bx,sp			; calculate top address for stack
endif
	add	bx,0Fh			; round up to paragraph boundary
	and	bl,0F0h			; ...
	mov	ss,cx			; set stack segment
	mov	sp,bx			; set sp relative to DGROUP
	mov	es:__STACKTOP,bx	; set stack top

	mov	dx,bx			; make sure enough memory for stack
	shr	dx,1			; calc # of paragraphs needed
	shr	dx,1			; ... for data segment
	shr	dx,1			; ...
	shr	dx,1			; ...
;
;  check to see if running in protect-mode (Ergo 286 DPMI DOS-extender)
;
	cmp	byte ptr es:__osmode,0	; if not protect-mode
	jne	mem_setup		; then it is real-mode
	mov	cx,ds:2h		; get highest segment address
	mov	ax,es			; point to data segment
	sub	cx,ax			; calc # of paragraphs available
	cmp	dx,cx			; compare with what we need
	jb	enuf_mem		; if not enough memory
_Not_Enough_Memory_:
;	mov	bx,1			; - set exit code
;	mov	ax,offset NoMemory	;
;	mov	dx,cs			;
;	call	__fatal_runtime_error_	; - display msg and exit
enuf_mem:				; endif

	mov	ax,es			; point to data segment
;
; This will be done by the call to _nheapgrow() in cmain.c
;if _MODEL and (_BIG_DATA or _HUGE_DATA)
;	 cmp	 cx,1000h		 ; if more than 64K available
;	 jbe	 lessthan64k		 ; then
;	 mov	 cx,1000h		 ; - keep 64K for data segment
;lessthan64k:				 ; endif
;	 mov	 dx,cx			 ; get # of paragraphs to keep
;endif
	mov	bx,dx			; get # of paragraphs in data segment
	shl	bx,1			; calc # of bytes
	shl	bx,1			; ...
	shl	bx,1			; ...
	shl	bx,1			; ...
	jne	not64k			; if 64K
	mov	bx,0fffeh		; - set _curbrk to 0xfffe
not64k: 				; endif
	mov	es:__curbrk,bx		; set top of memory owned by process
	mov	bx,dx			; get # of paragraphs in data segment
	add	bx,ax			; plus start of data segment
	mov	ax,es:__psp		; get segment addr of PSP
	mov	es,ax			; place in ES
;
;	free up memory beyond the end of the stack in small data models
;		and beyond the 64K data segment in large data models
;
	sub	bx,ax			; calc # of para's we want to keep
	mov	ah,4ah			; "SETBLOCK" func
	int	21h			; free up the memory
mem_setup:
;
;	copy command line into bottom of stack
;
	mov	di,ds			; point es to PSP
	mov	es,di			; ...
	mov	di,81H			; DOS command buffer __psp:80
	mov	cl,-1[di]		; get length of command
	mov	ch,0
	cld				; set direction forward
	mov	al,' '
	rep	scasb
	lea	si,-1[di]

ifdef __TINY__
	mov	dx,cs
else
	mov	dx,DGROUP
endif
	mov	es,dx			; es:di is destination
	mov	di,es:__STACKLOW
	mov	es:__LpCmdLine+0,di	; stash lpCmdLine pointer
	mov	es:__LpCmdLine+2,es	; ...
	je	noparm
	inc	cx
	rep	movsb
noparm: sub	al,al
	stosb				; store NULLCHAR
	mov	al,0			; assume no pgm name
	stosb				; . . .
	dec	di			; back up pointer 1
;
;	get DOS version number
;
	mov	ah,30h
	int	21h
	mov	es:__osmajor,al
	mov	es:__osminor,ah
	mov	cx,di			; remember address of pgm name
	cmp	al,3			; if DOS version 3 or higher
	jb	nopgmname		; then
;
;	copy the program name into bottom of stack
;
	mov	ds,ds:2ch		; get segment addr of environment area
	sub	si,si			; offset 0
	xor	bp,bp			; no87 not present!
L0:	mov	ax,[si] 		; get first part of environment var
	or	ax,2020H		; lower case
	cmp	ax,"on" 		; if first part is 'NO'
	jne	L1			; - then
	mov	ax,2[si]		; - get second part
	cmp	ax,"78" 		; - if second part is '87'
	jne	L1			; - then
	inc	bp			; - - set bp to indicate NO87
L1:	cmp	byte ptr [si],0 	; end of string ?
	lodsb
	jne	L1			; until end of string
	cmp	byte ptr [si],0 	; end of all strings ?
	jne	L0			; if not, then skip next string
	lodsb
	inc	si			; - point to program name
	inc	si			; - . . .
L2:	cmp	byte ptr [si],0 	; - end of pgm name ?
	movsb				; - copy a byte
	jne	L2			; - until end of pgm name
nopgmname:				; endif
	mov	si,cx			; save address of pgm name
	mov	es:__LpPgmName+0,si	; stash LpPgmName pointer
	mov	es:__LpPgmName+2,es	; ...

	mov	ax,es:__psp		; get segment addr of PSP
	mov	es,ax			; place in ES
	mov	bx,sp			; end of stack in data segment

	assume	ds:DGROUP
ifdef __TINY__
	mov	dx,cs
else
	mov	dx,DGROUP
endif
	mov	ds,dx
	mov	es,dx
	mov	__no87,bp		; set state of "NO87" environment var
	mov	__STACKLOW,di		; save low address of stack

ifdef	EXPRESS
	mov	cx,offset DGROUP:__bss_end ; end of _BSS segment (start of TCONS)
	mov	di,offset DGROUP:_BSS	; start of _BSS segment
else
	mov	cx,offset DGROUP:_end	; end of _BSS segment (start of STACK)
	mov	di,offset DGROUP:_edata ; start of _BSS segment
endif
	sub	cx,di			; calc # of bytes in _BSS segment
	mov	al,0			; zero the _BSS segment
	rep	stosb			; . . .

	cmp	word ptr __get_ovl_stack,0 ; if program not overlayed
	jne	_is_ovl 		; then
	mov	ax,offset __null_ovl_rtn; - set vectors to null rtn
	mov	__get_ovl_stack,ax	; - ...
	mov	__get_ovl_stack+2,cs	; - ...
	mov	__restore_ovl_stack,ax	; - ...
	mov	__restore_ovl_stack+2,cs; - ...
	mov	__close_ovl_file,ax	; - ...
	mov	__close_ovl_file+2,cs	; - ...
_is_ovl:				; endif
	xor	bp,bp			; set up stack frame
if _MODEL and _BIG_CODE
	push	bp			; ... for new overlay manager
	mov	bp,sp			; ...
endif
	; DON'T MODIFY BP FROM THIS POINT ON!
ifdef	EXPRESS

	mov	cx,offset DGROUP:__bss_end; end of _BSS segment
	mov	di,offset DGROUP:BSS_	; start of _BSS segment
	sub	cx,di			; calc # of bytes in _BSS segment
	mov	al,0			; zero the _BSS segment
	rep	stosb			; . . .

	call	SaveDataSeg_		;*** special for load&go ***
endif
	mov	ax,offset __null_FPE_rtn; initialize floating-point exception
	mov	___FPE_handler,ax	; ... handler address
	mov	___FPE_handler+2,cs	; ...

	mov	ax,0FFh			; run all initalizers
;	call	__InitRtns		; call initializer routines
	call	__CMain
_cstart_ endp

;	don't touch AL in __exit_, it has the return code

__exit_  proc near
	public	"C",__exit_
ifdef __TINY__
	jmp	ok
else
	push	ax
	mov	dx,DGROUP
	mov	ds,dx
	cld				; check lower region for altered values
	lea	di,__nullarea		; set es:di for scan
	mov	es,dx
	mov	cx,NUM_VAL
	mov	ax,INIT_VAL
	repe	scasw
	pop	ax			; restore return code
	je	ok
;
; low memory has been altered
;
	mov	bx,ax			; get exit code
	mov	ax,offset NullAssign	; point to msg
	mov	dx,cs			; . . .
endif

	public	__do_exit_with_msg__

; input: DX:AX - far pointer to message to print
;	 BX    - exit code

__do_exit_with_msg__:
	mov	sp,offset DGROUP:_end+80h; set a good stack pointer
	push	bx			; save return code
	push	ax			; save address of msg
	push	dx			; . . .
ifndef __TINY__
	mov	dx,_TEXT
	mov	ds,dx
endif
	mov	dx,offset ConsoleName
	mov	ax,03d01h		; write-only access to screen
	int	021h
	mov	bx,ax			; get file handle
	pop	ds			; restore address of msg
	pop	dx			; . . .
	mov	si,dx			; get address of msg
	cld				; make sure direction forward
L3:	lodsb				; get char
	cmp	al,0			; end of string?
	jne	L3			; no
	mov	cx,si			; calc length of string
	sub	cx,dx			; . . .
	dec	cx			; . . .
	mov	ah,040h 		; write out the string
	int	021h			; . . .
	pop	ax			; restore return code
ok:
if _MODEL and _BIG_CODE
	mov	dx,DGROUP		; get access to DGROUP
	mov	ds,dx			; . . .
	cmp	byte ptr __ovlflag,0	; if MS Overlay Manager present
	je	no_ovl			; then
	push	ax			; - save return code
	mov	al,__intno		; - get interrupt number used
	mov	ah,25h			; - DOS func to set interrupt vector
	lds	dx,__ovlvec		; - get previous contents of vector
	int	21h			; - restore interrupt vector
	pop	ax			; - restore return code
no_ovl: 				; endif
endif
	push	ax			; save return code
	mov	ax,00h			; run all finalizers
	mov	dx,0ffh			; run all finalizers
;	call	__FiniRtns		; do finalization
	pop	ax			; restore return code
	mov	ah,04cH 		; DOS call to exit with return code
	int	021h			; back to DOS
__exit_  endp


;
;	set up addressability without segment relocations for emulator
;
public	__GETDS
__GETDS proc	near
	push	ax			; save ax
ifdef __TINY__
;	can't have segment fixups in the TINY memory model
	mov	ax,cs			; DS=CS
else
	mov	ax,DGROUP		; get DGROUP
endif
	mov	ds,ax			; load DS with appropriate value
	pop	ax			; restore ax
	ret				; return
__GETDS endp


__null_FPE_rtn proc far
	ret				; return
__null_FPE_rtn endp

__null_ovl_rtn proc far
	ret				; return
__null_ovl_rtn endp


_TEXT	ends

	end	_cstart_
