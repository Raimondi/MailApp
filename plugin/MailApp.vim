if exists("loaded_MailApp") && !exists("MailApp_testing")
	"call MailAppInit()
	finish
endif
if !executable("mailapp")
	echoerr "MailApp: The command 'mailapp' could not be found, make sure it is somewhere in your $PATH!"
	finish
endif

let loaded_MailApp = 1

function! MailAppInit() " {{{
	let s:args = ""
	let s:from = ""
	let s:to   = ""
	let s:cc   = ""
	let s:bcc  = ""
	let s:subj = ""
	let s:att  = ""
	let s:attIsValid = 1
	let s:isBody = 0
	let s:body = ""
	let s:mailcommand = "mailapp"
	set omnifunc=CompleteEmails
	if exists("g:MailApp_visible")
		let s:visible = g:MailApp_visible
	else
		let s:visible = 0
	endif
	if exists("g:MailApp_send")
		let s:send = g:MailApp_send
	else
		let s:send = 1
	endif
endfunction " }}}

function! s:ParseText() " {{{
	for i in range(1, line('$'))
		let curLine = getline(i)
		if s:isBody
			let s:body = s:body . curLine . "\n"
		elseif curLine =~? '^f\S\{-}:\(\s\|\t\)*'
			if s:from == ""
				let s:from = substitute(curLine, '^f\S:\(\s\|\t\)*',"","")
			else
				let s:ignored = 1
				echomsg "MailApp: More than one 'from' line #" . line('.') . ": '" .  curLine . "'."
			endif
		elseif curLine =~? '^t\S*:\(\s\|\t\)*'
			if s:to == ""
				let s:to = substitute(curLine, '^t\S\{-}:\(\s\|\t\)*',"","")
			else
				let s:to = s:to . ';' . substitute(curLine, '^t\S\{-}:\(\s\|\t\)*',"","")
			endif
		elseif curLine =~? '^c\S*:\(\s\|\t\)*'
			if s:cc == ""
				let s:cc = substitute(curLine, '^c\S\{-}:\(\s\|\t\)*',"","")
			else
				let s:cc = s:cc . ';' . substitute(curLine, '^c\S\{-}:\(\s\|\t\)*',"","")
			endif
		elseif curLine =~? '^b\S*:\(\s\|\t\)*'
			if s:bcc == ""
				let s:bcc = substitute(curLine, '^b\S\{-}:\(\s\|\t\)*',"","")
			else
				let s:bcc = s:bcc . ';' . substitute(curLine, '^b\S\{-}:\(\s\|\t\)*',"","")
			endif
		elseif curLine =~? '^s\S*:\(\s\|\t\)*'
			if s:subj == ""
				let s:subj = substitute(curLine, '^s\S\{-}:\(\s\|\t\)*',"","")
			else
				let s:ignored = 1
				echomsg "MailApp: More than one 'subject' line #" . line('') . ": '" .  curLine . "'."
			endif
		elseif curLine =~? '^a\S*:\(\s\|\t\)*'
			call s:ValidateAttachment(substitute(curLine, '^a\S\{-}:\(\s\|\t\)*',"",""))
		elseif len(curLine) == 0
			let s:isBody = 1
		else
				let s:ignored = 1
				echomsg "MailApp: Line #" . line('.') . " doesn't seem to be a properly formated: '" . curLine . "'."
		endif
	endfor
	if s:from == "" && exists("g:mailApp_from")
		let s:from = g:mailApp_from
	endif

endfunction " }}}

function! s:ValidateAttachment(path) " {{{
	let s:att_temp = substitute(substitute(a:path, '^\~/',glob("~/"),""), '^\([^/]\)', getcwd() . '/\1', '')
	if !filereadable(s:att_temp) || isdirectory(s:att_temp) || s:att_temp == ""
		echomsg "MailApp: There seems to be a problem with the given path ('" . s:att_temp . "'), make sure it's valid."
		let s:attIsValid = 0
		return 0
	endif

	if s:att == ""
		let s:att = s:att_temp
	else
		let s:att = s:att . "\n" . s:att_temp
	endif
	return 1
endfunction " }}}

function! s:ValidateEmail() " {{{
	if s:to == ""
		echomsg "MailApp: You need to especify a 'To:' recipient!"
		return 0
	endif
	if s:subj == ""
		let s:subjConfirm = confirm("MailApp: Subject is missing, send message anyway?", "&No\n&Yes", 1)
		if s:subjConfirm == 0 || s:subjConfirm == 1
			return 0
		endif
	endif
	if s:body == ""
		let s:bodyConfirm = confirm("MailApp: The message text is empty, send message anyway?", "&No\n&Yes", 1)
		if s:bodyConfirm == 0 || s:bodyConfirm == 1
			return 0
		endif
	endif
	if exists("s:ignored")
		return 0
	endif
	return 1
endfunction " }}}

function! MailAppExpandTab() " {{{
	let lineNumber = line('.')
	if len(getline(".")) == 0
		if lineNumber == 1
			if !exists("g:mailApp_from")
				return "from: "
			else
				return "to: "
			endif
		elseif getline(lineNumber - 1) =~ '^f\a*:\(\s\|\t\)*'
			return "to: "
		elseif getline(lineNumber - 1) =~ '^t\a*:\(\s\|\t\)*'
			return "subject: "
		else
			return "\<Tab>"
		endif
	elseif strpart(getline('.'), 0, col('.')) =~ '^a\a*:\(\s\|\t\)*'
		return "\<C-X>\<C-F>"
	elseif getline('.') =~ '^\(f\|t\|c\|b\)\a*:\(\s\|\t\)*'
		return "\<C-X>\<C-O>"
	elseif (getline(lineNumber - 1) =~ '^\(f\|t\|s\|c\|b\|a\)\a*:\(\s\|\t\)*'
				\	|| lineNumber == 1)
				\	&& getline('.') !~ ':'
		if getline('.') =~ '^f.*'
			call setline('.', "from: ")
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		elseif getline('.') =~ '^t.*'
			call setline('.', "to: ")
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		elseif getline('.') =~ '^s.*'
			call setline('.', "subject: ")
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		elseif getline('.') =~ '^c.*'
			call setline('.', "cc: ")
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		elseif getline('.') =~ '^b.*'
			call setline('.', "bcc: "
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		elseif getline('.') =~ '^a.*'
			call setline('.', "attachment: ")
			call setpos('.', [0, line('.'), 999, 0])
			return ""
		else
			return "\<Tab>"
		endif
	else
		return "\<Tab>"
	endif

endfunction " }}}

function! s:GetArguments() " {{{
	if s:from != ""
		let from = "-from " . shellescape(s:from, 1) . " "
	else
		let from = ""
	endif
	if s:to != ""
		let to   = "-to " . shellescape(s:to, 1) . " "
	else
		let to = ""
	endif
	if s:cc != ""
		let cc   = "-cc " . shellescape(s:cc, 1) . " "
	else
		let cc = ""
	endif
	if s:bcc !=""
		let bcc  = "-bcc " . shellescape(s:bcc, 1) . " "
	else
		let bcc = ""
	endif
	if s:subj != ""
		let subj = "-subject " . shellescape(s:subj, 1) . " "
	else
		let subj = ""
	endif
	if s:att != ""
		let att  = "-attachment " . shellescape(s:att, 1) . " "
	else
		let att = ""
	endif
	if s:body != ""
		let body = "-body " . shellescape(s:body, 1) . " "
	else
		let body = ""
	endif
	return from . to . cc . bcc . subj . att . body .
				\	"-send " . s:send . " -visible " . s:visible
endfunction " }}}

function! CompleteEmails(findstart, base) " {{{
	if a:findstart
		if getline('.') =~? '^f\S*:'
			let results = col('.')
		else
			let results = match(getline('.'),substitute(getline('.'),'\(^\S\S\{-}:\(\s\|\t\)*\)\(.*$\)','\3',""))
		endif

	else
		if getline('.') =~? '^f\S*:'
			let results = split(system(s:mailcommand . " -listfrom 1"),"\n")
		else
			let results = split(system(s:mailcommand . " -list " . shellescape(a:base)),"\n")
		endif
	endif
	return results
endfunction " }}}

function! MailAppSendMail() " {{{
	call MailAppInit()
	call s:ParseText()
	if s:ValidateEmail() && s:attIsValid
		"echomsg "silent !" . s:mailcommand . " " . s:GetArguments()
		exec "silent !" . s:mailcommand . " " . s:GetArguments()
	else
		echomsg "MailApp: The message wasn't sent!"
	endif
endfunction " }}}

function! MailAppNewMail() " {{{
	new
	set ft=mailapp
endfunction " }}}

command! MailAppNew call MailAppNewMail()
command! MailAppSend call MailAppSendMail()
autocmd BufNewFile,BufRead *.mailapp setf mailapp

