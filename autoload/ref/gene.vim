" vim: set et fdm=marker ft=vim sts=2 sw=2 ts=2 : 


scriptencoding utf-8


let s:save_cpo = &cpo
set cpo&vim


let s:source = {'name' : 'gene'}


function! s:read_genetxt()
  let s:ref_gene_dict_path = get(g:, 'ref_gene_dict_path',
  \                              globpath(&rtp, 'dict/gene.txt') == '' ? '' :
  \                              split(globpath(&rtp, 'dict/gene.txt'), "\n")[0])
  if filereadable(expand(s:ref_gene_dict_path))
    let s:genetxt = readfile(expand(s:ref_gene_dict_path))[2:]
  endif
endfunction


function! s:source.available()
  return filereadable(expand(s:ref_gene_dict_path))
endfunction


function! s:source.get_body(query)
  let q = (a:query == '' ? input('ref-gene : ') : a:query)
  if q != ''
    let i = index(s:genetxt, q, 0, 1)
    if i > -1
      let d = {'query' : q, 'body' : q . ' : ' . get(s:genetxt, i + 1)}
    else
      let d = {'query' : q, 'body' : q . ' : (NO DATA)'}
    endif
  else
    let d = {'query' : q, 'body' : q . ' : (NOT INPUT)'}
  endif
  return d
endfunction


function! s:source.complete(query)
  if a:query == '' | return [] | endif
  let m = filter(copy(s:genetxt), '!match(v:val, "' . a:query . '")')
  if m != []
    let i = index(m, a:query)
    let m = [m[i]] + (i > 0 ? m[ : i - 1] : []) + m[i + 1 : ]
  endif
  return m
endfunction


function! ref#gene#define()
  call s:read_genetxt()
  return copy(s:source)
endfunction


" for unite.vim "{{{
let s:action = {}


function! s:action.func(candidate)
  echo a:candidate.action__ref_source.get_body(a:candidate.word).body
endfunction


call unite#custom#action('ref', 'preview', s:action)
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

