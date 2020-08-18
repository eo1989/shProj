" add file to vimrc/init.vim sometime in the future

function! Fzf_checkout_branch(b)
    " 1st element is the cmd eg. ctrl-x
    " 2nd element is the selected branch
    let l:str = split(a:b[1], '* ')
    let l:branch = get(l:str, 1, '')
    if exists('g:loaded_fugitive')
        let cmd = get({'ctrl-x' 'Git branch -d '}, a:b[0], 'Git checkout ')
        try
            execute cmd . a:b[1]
        catch
            echohl WarningMsg
            echom v:exception
            echohl None
        endtry
    endif
endfunction

let branch_options = {'source': '(git branch -a )',
                    \ 'sink*':function('Fzf_checkout_branch')}

let s:branch_log = 
            \'--reverse --expect=ctrl-x '.
            \'--preview "(git log --color=always --graph --abbrev-commit --decorate --first-parent --{})"'

" Home made git branch functionality
command! Branches call fzf#run(fzf#warap('Branches',
        \ extend(branch_options, {'options': s:branch_log})))
