wall
!rm MailApp.zip
!cp doc/mailapp.txt ~/.vim/doc/mailapp.txt
!cp plugin/MailApp.vim ~/.vim/plugin/MailApp.vim
!cp ftplugin/mailapp.vim ~/.vim/ftplugin/mailapp.vim
!cp syntax/mailapp.vim ~/.vim/syntax/mailapp.vim
"!xcodebuild
!cp build/Release/mailapp MailApp.bundle/mailapp
!install_name_tool -change /Users/israel/Library/Frameworks/Appscript.framework/Versions/A/Appscript @executable_path/Appscript.framework/Appscript MailApp.bundle/mailapp
!zip MailApp.zip -y -r MailApp.bundle/ doc/*.txt plugin/*.vim syntax/*.vim ftplugin/*.vim
