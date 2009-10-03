if exists("b:did_ftplugin")
	finish
endif
setlocal omnifunc=CompleteEmails
imap <buffer> <expr> <Tab> "\<C-R>=MailAppExpandTab()\<CR>"
noremap <buffer> <leader>send :call MailAppSendMail()<CR>
call MailAppInit()
let b:did_ftplugin = 1
