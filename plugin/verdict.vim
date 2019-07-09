func! verdict#Format()
    " only reformat on explicit gq command
    if mode() !=# 'n'
        " fall back to Vims internal reformatting
        return 1
    endif
    let lines = getline(v:lnum, v:lnum + v:count - 1)

    " concatenate all lines into a single string
    let text = lines[0]
    let index = 1
    while index < len(lines)
        let text = join([text, lines[index]], ' ')
        let index = index + 1
    endwhile

    " now split the text into individual sentences
    let sentences = split(text, '\v([.!?])([\)\]\}\"''])*\zs\s+')

    " iterative over all sentences
    let index = 0
    while index < len(sentences)
        let sentence = sentences[index]
        " if the length exceeds the specified maximum
        if len(sentence) ># 80
            let wrapped = ['']
            " split it word by word
            for word in split(sentence)
                if len(wrapped[-1]) + len(word) + 1 >= 80
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

    " store current cursor position
    let cursor_prev = getpos('.')

    " compute difference in number of lines
    " if this difference is negative, we need to add some additional lines in
    " order to prevent overwriting non-formatted text parts
    " if it is positive, we can remove left-over lines after inserting our
    " newly formatted text
    let diff = v:count - len(sentences)

    " insert additional lines in order not to overwrite other text parts
    while diff < 0
        call append(line('.'), '')
        let diff = diff + 1
    endwhile

    " insert new lines into buffer
    call setline('.', sentences)

    " all superfluous lines need to be removed
    while diff > 0
        call cursor(cursor_prev[0] + len(sentences) + diff, 1)
        delete
        let diff = diff - 1
    endwhile

    " do not run internal formatter!
    return 0
endfunc

func! verdict#Indent( line_num )
    if a:line_num == 0
        return 0
    endif
    let prevline = getline(a:line_num - 1)
    if prevline =~# '^\s*$'
        return 0
    elseif prevline =~# '\v([.!?])([\)\]\}\"''])*$'
        return 0
    else
        return 2
    endif
endfunc

func! verdict#Init()
    let b:prev_formatexpr=&formatexpr
    let b:prev_indentexpr=&indentexpr
    setlocal formatexpr=verdict#Format()
    setlocal indentexpr=verdict#Indent(v:lnum)
endfunc

func! verdict#Deinit()
    setlocal formatexpr=&b:prev_formatexpr
    setlocal indentexpr=&b:prev_indentexpr
endfunc
