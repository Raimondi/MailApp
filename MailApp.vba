" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
doc/mailapp.txt	[[[1
286
*MailApp.txt*     Send emails through Mail.app from Vim.


                          MAILAPP REFERENCE MANUAL *


==============================================================================
 0.- CONTENTS                                               *MailApp-contents*

    1. Introduction____________________________|MailApp|
    2. Usage___________________________________|MailAppUsage|
        2.1 E-mail example_____________________|MailAppEMailExample|
    3. Functionality___________________________|MailAppFunctionality|
        3.1 Syntax highlighting________________|MailAppHighlighting|
        3.2 Header name completion_____________|MailAppHeaderCompletion|
        3.3 E-mail address completion__________|MailAppEmailCompletion|
        3.4 Attachment path completion_________|MailAppAttachmentCompletion|
        3.5 Command line executable____________|MailAppCommandLine|
    4. Customization___________________________|MailAppOptions|
        3.1 Options summary____________________|MailAppOptionSummary|
        3.2 Options details____________________|MailAppOptionDetails|
    5. Public commands and mappings____________|MailAppPubCmdsAndMaps|
    6. TODO list_______________________________|MailAppTodo|
    7. Maintainer______________________________|MailAppMaintainer|
    8. Credits_________________________________|MailAppCredits|
    9. History_________________________________|MailAppHistory|

==============================================================================
 1.- INTRODUCTION                                                    *MailApp*

This is a plugin with a single purpose: to allow Mac OS X users to send
e-mails from Vim using the Mail.app application. In order to do so, it
requires the command line tool |mailapp| to be installed.

It provides syntax highlighting, auto-completion for header name, e-mail and
attachment path mapped to <Tab>.

Read |MailAppHighlighting|, |MailAppHeaderCompletion|,
|MailAppEmailCompletion| and |MailAppAttachmentCompletion| for detailed
information.

==============================================================================
 2.- USAGE                                                      *MailAppUsage*

To start a new e-mail, use the command |:MailAppNew|, which will open a
new buffer whwere you can start writing. To send the e-mail, use the command
|:MailAppSend| or the mapping |<leader>send|.

The e-mail is divided in two main parts, the headers and the body. The header
region starts in the first line of the e-mail and ends with the first empty
line, the body starts right after that.

The headers that can be used are the following:

 - from
 - to
 - cc
 - bcc
 - subject
 - attachment

Every header has the following format: at least one letter begins the line and
identifies the header, followed by a ":", optional spaces or tabs may follow
and will be ignored. The first character that is not a space or tab starts the
header's content.
e.g.: >
  fr: Israel Chauca F. <israelchauca@gmail.com>
  T:  some@example.com
  subj: Hello!
  aTTachment: trip/some picture.jpg
  a: trip/other picture.jpg
<
If you include the name with the e-mail, you must enclose the e-mail within
"<>". Multiple e-mails must be separated by a ";", or you can use multiple
headers of the same kind.
e.g.: >
  from: Israel Chauca F. <israelchauca@gmail.com>
  to: First Friend <friend1@example.com>; Second Friend <friend2@example.net>
  cc: Third Friend <friend3@example.org>; friend5@example.net
  cc: Fourth Friend <friend4@example.com>
<
Attachment paths have to be given one per header. They will be checked using
the following rules:

 1. If the path starts with "/" and a readable file doesn't exists on that
    path, the message is not sent and the user is notified.
 2. If the path starts with "~/", the leading "~/" is replace by the absolute
    path to the user's home folder ($HOME) and the new path is checked again
    as in rule 1.
 3. If the path doesn't start with "/" or "~/", the absolute path to the
    current working directory ($PWD) is prepended to the path and it's checked
    again as in rule 1.

------------------------------------------------------------------------------
   2.1 E-MAIL EXAMPLE                                    *MailAppEMailExample*

from: Israel Chauca F. <israelchauca@gmail.com>
to: First Friend <friend1@example.com>; Second Friend <friend2@example.net>
cc: Third Friend <friend3@example.org>; friend5@example.net
c: Fourth Friend <friend4@example.com>
Subject: Hello!
bcc: <anonymous@example.com>
attachment: trip/some picture.jpg
a: trip/other picture.jpg

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed tellus enim,
rhoncus sit amet sodales vel, bibendum sit amet nunc. Donec sodales
facilisis est, eget commodo elit euismod nec. Nunc vitae odio ac mi
fringilla faucibus. Mauris non tellus lectus, non porttitor augue. In hac
habitasse platea dictumst. Aliquam dolor velit, fermentum nec tempus vitae,
ultricies venenatis massa. Aliquam semper lacus vitae nulla euismod in
iaculis nibh euismod. Cum sociis natoque penatibus et magnis dis parturient
montes, nascetur ridiculus mus. Sed at consectetur libero.

Suspendisse potenti. Cras purus odio, tempor sed dignissim vitae, luctus
vitae felis. Aliquam mi sapien, interdum in fringilla ac, eleifend ut massa.
Aenean mauris ligula, sodales ut vulputate ut, blandit sit amet neque.
Maecenas gravida vestibulum ante eget mattis. Fusce porttitor dictum diam
eget viverra. Sed dictum laoreet eros, vel luctus dui vulputate euismod.
Curabitur condimentum ornare quam, non semper ipsum consequat non. Donec
sagittis tristique iaculis.

==============================================================================
 2. FUNCTIONALITY PROVIDED                              *MailAppFunctionality*

------------------------------------------------------------------------------
   2.1 SYNTAX HIGHLIGHTING                               *MailAppHighlighting*

MailApp provides syntax highlighting for the diferent parts of the email
headers: header name, valid email address, subject text and attachments paths.

------------------------------------------------------------------------------
   2.2 HEADER NAME COMPLETION                        *MailAppHeaderCompletion*

Headers follow the following format: at least one letter followed by a ":",
optional spaces or tabs and, after that, the header's content.

To make things easier, MailApp provides two auto-completion systems mapped to
<Tab>. In order to use the fisrt of them, type the first letter of a header
and then hit <Tab>, the header name will be completed if you are inside the
headers area. For the second system, you hit <Tab> in an empty line inside the
header area and it will be expanded using the following rules:

 1. If you are in the first line and |MailApp_from| doesn't exists, "from: "
    is inserted.
 2. If you are the first line and |MailApp_from| exists, "to: " is inserted.
 3. If the previous line is a "from" header, "to: " is inserted.
 4. If the previous line is a "to" header, "subject: " is inserted.
 5. If none of the previous rules apply, a <Tab> is inserted.

------------------------------------------------------------------------------
   2.3 E-MAIL ADDRESS COMPLETION                      *MailAppEmailCompletion*

When inside a header that takes e-mails as content, hitting <Tab> after typing
some characters, MacMail will search in the Address Book for matching names
and e-mails and display a menu list to choose one.

For the "from" header, Mail.app only accepts e-mail addresses that are set in
its e-mail accounts; if the e-mail provided doesn't match any of them or none
is provided, the default e-mail will be used. So, the completion of the "from"
header pulls every "from" e-mail from every account and displays a menu with
the options.

------------------------------------------------------------------------------
   2.4 ATTACHMENT PATH COMPLETION                *MailAppAttachmentCompletion*

When writing the path in an attachment header, hitting <Tab> will call file
auto-completion, see |compl-filename|.

------------------------------------------------------------------------------
   2.5 COMMAND LINE EXECUTABLE                            *MailAppCommandLine*
                                                                     *mailapp*

MailApp relies on a command line utility, "mailapp", which does all the dirty
work of comunicating with Mail.app and can be downloaded from the following
web site:

   http://cachivaches.chauca.net/mailapp/

Make sure to install it somewhere in your $PATH.

==============================================================================
 3. CUSTOMIZATION                                         *MailAppOptions*

------------------------------------------------------------------------------
   3.1 OPTIONS SUMMARY                                  *MailAppOptionSummary*

The behaviour of this script can be customized setting the following options
in your vimrc file. You can use local options to set the configuration for
specific file types, see |MailAppOptionDetails| for examples.

|'loaded_MailApp'|          Turns off the script.

|'MailApp_from'|            Sets the default name and e-mail to use in the
                            "from" header.

|'MailApp_send'|            Tells MailApp if the e-mail should be sent
                            or not.

|'MailApp_visible'|         Tells MailApp if the message should be visible or
                            not

------------------------------------------------------------------------------
   3.2 OPTIONS DETAILS                                  *MailAppOptionDetails*

Add the shown lines to your vimrc files in order to set the below options.

                                                            *'loaded_MailApp'*
This option prevents MailApp from loading.
e.g.: >
        let loaded_MailApp = 1
<
------------------------------------------------------------------------------
                                                              *'MailApp_from'*
Values: a string with the sender's name and e-mail.                          ~
Default: empty                                                               ~

MailApp will use the value of this option when no "from" header is provided.
e.g.: >
        let MailApp_from = "Israel Chauca F. <israelchauca@gmail.com>"
<
------------------------------------------------------------------------------
                                                              *'MailApp_send'*
Values: 1 or 0                                                               ~
Default: 1                                                                   ~

By default, MailApp will send the e-mail immediately, but if this option is
set to 0, the message will be left open or in the Draft folder.

e.g: >
        let MailApp_send = 0
<
------------------------------------------------------------------------------
                                                           *'MailApp_visible'*
Values: 1 or 0                                                               ~
Default: 0                                                                   ~

MailApp sends the message without opening any window in Mail.app, set this
option to 1 if you want to see the message window, you might want to use this
option along with |MailApp_send|.

e.g.: >
        let MailApp_visible = 1
<

==============================================================================
 4. PUBLIC COMMANDS AND MAPPINGS                       *MailAppPubCmdsAndMaps*

------------------------------------------------------------------------------
:MailAppNew                                                      *:MailAppNew*

This command opens a new buffer and sets its file type to "mailapp".

------------------------------------------------------------------------------
:MailAppSend                                                    *:MailAppSend*

Sends the message.

------------------------------------------------------------------------------
<Leader>send                                               *MailApp_imap_send*
                                                                *<leader>send*
Sends the message.

==============================================================================
 5. TODO LIST                                                    *MailAppTodo*

- Message navigation and retrieval.

==============================================================================
 6. MAINTAINER                                             *MailAppMaintainer*

Hi there! My name is Israel Chauca F. and I can be reached at:
    mailto:israelchauca@gmail.com

Feel free to send me any suggestions and/or comments about this plugin, I'll
be very pleased to read them.

==============================================================================
 7. HISTORY                                                   *MailAppHistory*

  Version      Date      Release notes                                       ~
|---------|------------|-----------------------------------------------------|
    1.0     2009-10-07   First release.
|---------|------------|-----------------------------------------------------|

vim:tw=78:ts=8:ft=help:norl:
plugin/MailApp.vim	[[[1
261
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

ftplugin/mailapp.vim	[[[1
8
if exists("b:did_ftplugin")
	finish
endif
setlocal omnifunc=CompleteEmails
imap <buffer> <expr> <Tab> "\<C-R>=MailAppExpandTab()\<CR>"
noremap <buffer> <leader>send :call MailAppSendMail()<CR>
call MailAppInit()
let b:did_ftplugin = 1
syntax/mailapp.vim	[[[1
62

" Vim syntax file
" Language:     MailApp
" Maintainer:   Israel Chauca F. <israelchauca@gmail.com>
"

if version < 600
	syn clear
elseif exists("b:current_syntax")
	finish
endif

syn case ignore
syntax sync fromstart

" Headers
syn match mailAppHeaders '\%^\(^\S\{-1,}:\(\s\|\t\)*.*\n\)*' contains=mailAppHeaderStart,mailAppAddresses,mailAppSubject,mailAppSubjectContent,mailAppAttachment

" Headers with addresses
syn match mailAppAddresses '\c^\(f\|t\|c\|b\)\a*:\s*.\+$' contains=mailAppHeaderStart,mailAppEmailLocal,mailAppEmailDomain,mailAppEmailAt,mailAppEmailDelimiter transparent

" email, local part
syn match mailAppEmailLocal '\(\([^<>()[\]\\.,;:[:blank:]@"]\+\(\.[^<>()[\]\\.,;:[:blank:]@"]\+\)*\)\|\(".\+"\)\)@\@=' contained

" email, domain part
syn match mailAppEmailDomain '@\@<=\(\[\(2\([0-4]\d\|5[0-5]\)\|1\=\d\{1,2}\)\(\.\(2\([0-4]\d\|5[0-5]\)\|1\=\d\{1,2}\)\)\{3} \]\)\|\(\([a-zA-Z\-0-9]\+\.\)\+[a-zA-Z]\{2,}\)' contained

" email, @
syn match mailAppEmailAt '@' contained

" Email delimiters
syn match mailAppEmailDelimiter '[<>]' contained

" Subject
syn match mailAppSubject '\c^s\a*:\s*.\+$' contains=mailAppSubjectContent,mailAppHeaderStart transparent

" Subject content
syn match mailAppSubjectContent '\s\+.\+$' contained

"Attachment
syn match mailAppAttachment '\c^a\a*:\s*.\+$' contains=mailAppAttachmentPath,mailAppHeaderStart transparent

" Attachment path
syn match mailAppAttachmentPath '\(^\a\+:\s*\)\@<=\s*.\+$' contained

" Header Start
syn match mailAppHeaderStart '\c^\(t\|f\|c\|b\|s\|a\)\a*:' contained

" Body
syn match mailAppBody '\(^\n\)\(^.*\n\)*\_$'

hi def link mailAppHeaderStart Statement
"hi def link mailAppHeaders Boolean
"hi def link mailAppBody String
hi def link mailAppSubjectContent Boolean
hi def link mailAppEmailAt String
hi def link mailAppEmailLocal Special
hi def link mailAppEmailDomain Special
hi def link mailAppAttachmentPath Float
hi def link mailAppEmailDelimiter Delimiter

let b:current_syntax = "mailapp"
