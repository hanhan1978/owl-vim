
let s:save_cpo = &cpo
set cpo&vim

" Write plugin code here

function! owl_vim#list()
    let files = webapi#http#get("http://127.0.0.1:3000/api/show/hanhan1978") 
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
    let files = webapi#http#get("http://127.0.0.1:3000/api/items/show/" . item_id) 
    let lists = webapi#json#decode(files['content'])
    "echo lists

    let fname = 'my-own-buffer-show'
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
    let postdata ={ "title" : title, "body" : join(body), "tags" : tags , "published" : '2' }
    let fuga = webapi#http#post("http://127.0.0.1:3000/api/items/create", postdata)
    "echo fuga
endfunction

command! -bar OwlList call owl_vim#list()
command! -bar OwlNew call owl_vim#new()
command! -bar OwlSave call owl_vim#save()



unlet s:save_cpo


