
let s:save_cpo = &cpo
set cpo&vim

" Write plugin code here

function! owl_vim#list()
    call owl_vim#readconf()
    let files = webapi#http#get(s:owl_vim_host. "/api/show/hanhan1978") 
    let lists = webapi#json#decode(files['content'])
    let length = len(lists['data']) 
    let fname = 'my-own-buffer'
    silent! execute 'new' fname
    setlocal buftype=nofile
    setlocal noswapfile 
    let i = 0
    for dat in lists['data']
        call append(i, dat['id'] . "  " . dat['created_at'] . "  " . dat['title'] . "  ")
        nmap <buffer> <cr> :call owl_vim#show() <cr>
        unlet dat
        let i += 1
    endfor
endfunction

function! owl_vim#show()
    let lines = split(getline(".") , "  ")
    let item_id = lines[0]
    call owl_vim#readconf()
    let files = webapi#http#get(s:owl_vim_host."/api/items/show/" . item_id) 
    let lists = webapi#json#decode(files['content'])
    "echo lists

    let fname = 'my-own-buffer-show'.item_id
    if bufnr(fname) > 0
        silent! execute 'new' fname
        bwipeout!
    endif
    silent! execute 'new' fname
    setlocal buftype=nofile
    setlocal noswapfile 
    call append(0, "============== META ==============")
    call append(1, "id : " . lists["id"])
    call append(2, "open_item_id : " . lists["open_item_id"])
    call append(3, "title : " . lists["title"])
    call append(4, "============== Contents ==============")
    call append(5, lists['body'])
endfunction

function! owl_vim#new()
    let fname = 'my-own-buffer-new'
    silent! execute 'new' fname
    setlocal buftype=nofile
    setlocal noswapfile 
    call append(0, "============== Title ==============")
    call append(1, "")
    call append(2, "============== Tags ===============")
    call append(3, "")
    call append(4, "============== Contents ===========")
    call append(5, "")
endfunction

function! owl_vim#save()
    let title = getline(2)
    let tags = getline(4)
    let body  = getbufline('my-own-buffer-new', 6, '$')
    "echo title
    "echo body
    let postdata ={ "title" : title, "body" : join(body, "\n"), "tags" : tags , "published" : '2' }
    call owl_vim#readconf()
    let fuga = webapi#http#post(s:owl_vim_host."/api/items/create", postdata)
    "echo fuga
endfunction

function! owl_vim#readconf()
    let fname = $HOME . "/.vimowlrc"
    if filereadable(fname) > 0
        let conf = readfile(fname)
        for line in conf
            let mm = split(line , "=")
            let key = substitute(mm[0], '^\s*\(.\{-}\)\s*$', '\1', '')
            let val = substitute(mm[1], '^\s*\(.\{-}\)\s*$', '\1', '')
            if key == 'host'
                let s:owl_vim_host = val
            endif
        endfor
    endif
endfunction

command! -bar OwlList call owl_vim#list()
command! -bar OwlNew call owl_vim#new()
command! -bar OwlSave call owl_vim#save()



unlet s:save_cpo


