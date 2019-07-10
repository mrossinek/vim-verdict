" do not load multiple times
if exists('g:verdict_loaded')
    finish
endif

" formatting function
" Usage: :setlocal formatexpr=verdict#Format()
"        now you can use gq{motion} to format the text moved over by motion
func! verdict#Format()
    " only reformat on explicit gq command
    if mode() !=# 'n'
        " fall back to Vims internal reformatting
        return 1
    endif
    let lines = getline(v:lnum, v:lnum + v:count - 1)

    let formatted = []
    let paragraph = ''
    " iterate over all lines
    let index = 0
    while index < len(lines)
        " concatenate paragraph into a single string
        while lines[index] !~# '^\s*$'
            if paragraph =~# '^\s*$'
                " if string is actually empty simply add line
                " (this prevents an additional space at the beginning)
                let paragraph = paragraph . lines[index]
            else
                " else use join
                let paragraph = join([paragraph, lines[index]], ' ')
            endif
            let index = index + 1
        endwhile
        " remove multiple whitespace occurences
        let paragraph = substitute(paragraph, '\v\s\zs\s+', '', 'g')
        " format paragraph
        let block = s:FormatParagraph(paragraph)
        " append to output
        for bline in block
            call add(formatted, bline)
        endfor
        " also append current line since it might be an empty line which needs
        " to be preserved
        call add(formatted, lines[index])

        let paragraph = ''
        let index = index + 1
    endwhile

    " store insertion position
    let line_num = v:lnum

    " compute difference in number of lines
    " if this difference is negative, we need to add some additional lines in
    " order to prevent overwriting non-formatted text parts
    " if it is positive, we can remove left-over lines after inserting our
    " newly formatted text
    let diff = v:count - len(formatted)

    " insert additional lines in order not to overwrite other text parts
    while diff < 0
        call append(line_num, '')
        let diff = diff + 1
    endwhile

    " insert formatted lines into buffer
    call setline(line_num, formatted)

    " all superfluous lines need to be removed
    while diff > 0
        call cursor(line_num + len(formatted) - 1 + diff, 1)
        delete
        let diff = diff - 1
    endwhile

    " do not run internal formatter!
    return 0
endfunc

" internal paragraph formatting function
" this function is used internally since verdict#Format() works through the
" text paragraph-wise
func! s:FormatParagraph( text )
    " determine local textwidth
    " Note: this is done here to obey user overwritten textwidth settings
    "       during the session
    if &l:textwidth ==# 0
        let max_width = g:verdict_default_textwidth
    else
        let max_width = &l:textwidth
    endif

    " split the text into individual sentences
    let sentences = split(a:text, '\v([' . escape(g:verdict_sentence_delims, g:verdict_sentence_delims) . '])([' . escape(g:verdict_sentence_suffixes, g:verdict_sentence_suffixes) . '])*\zs\s+')

    " iterate over all sentences
    let index = 0
    while index < len(sentences)
        let sentence = sentences[index]
        " if the length exceeds the specified maximum
        if len(sentence) ># max_width
            let wrapped = ['']
            " split it word by word
            for word in split(sentence)
                if len(wrapped[-1]) + len(word) + 1 >= max_width
                    " if split: add indentation for sentence continuation
                    call add(wrapped, '  ')
                endif
                if wrapped[-1] =~# '^\s*$'
                    " if string is actually empty simply add word
                    " (this prevents an additional space at the beginning)
                    let wrapped[-1] = wrapped[-1] . word
                else
                    " else use join
                    let wrapped[-1] = join([wrapped[-1], word], ' ')
                endif
            endfor
            " remove previous sentence from list
            call remove(sentences, index)
            " and add all lines into the sentence list
            for line in wrapped
                call insert(sentences, line, index)
                let index = index + 1
            endfor
        else
            let index = index + 1
        endif
    endwhile

    return sentences
endfunc

" indenting function
" Usage: :setlocal indentexpr=verdict#Indent(v:lnum)
"        now automatic indentation will work while typing in insert mode
func! verdict#Indent( line_num )
    " the first line of the file should not be indented
    if a:line_num == 0
        return 0
    endif
    " get previous line
    let prevline = getline(a:line_num - 1)
    if prevline =~# '^\s*$'
        " if empty: do not indent since new paragraph means new sentence
        return 0
    elseif prevline =~# '\v([' . escape(g:verdict_sentence_delims, g:verdict_sentence_delims) . '])([' . escape(g:verdict_sentence_suffixes, g:verdict_sentence_suffixes) . '])*$'
        " if matches end of sentence: no indent
        return 0
    else
        " otherwise insert normal indent
        return 2
    endif
endfunc

" initialization function
" Usage: :call verdict#Init()
"        used to initialize verdict
func! verdict#Init()
    if !exists('g:verdict_sentence_delims')
        let g:verdict_sentence_delims = '.!?'
    endif
    if !exists('g:verdict_sentence_suffixes')
        let g:verdict_sentence_suffixes = ')]}"'''
    endif
    if !exists('g:verdict_default_textwidth')
        let g:verdict_default_textwidth = 80
    endif
    if &l:textwidth ==# 0
        let &l:textwidth=g:verdict_default_textwidth
    endif

    if &l:formatexpr !=# 'verdict#Format()'
        let b:prev_formatexpr = &l:formatexpr
        setlocal formatexpr=verdict#Format()
    endif
    if &l:indentexpr !=# 'verdict#Indent(v:lnum)'
        let b:prev_indentexpr = &l:indentexpr
        setlocal indentexpr=verdict#Indent(v:lnum)
    endif
endfunc

" de-initialization function
" Usage: :call verdict#Deinit()
"        used to de-initialize verdict
func! verdict#Deinit()
    if exists('b:prev_formatexpr')
        let &l:formatexpr=b:prev_formatexpr
    endif
    if exists('b:prev_indentexpr')
        let &l:indentexpr=b:prev_indentexpr
    endif
endfunc

let g:verdict_loaded = 1
