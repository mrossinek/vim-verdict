vim-verdict
===========

`vim-verdict` is a simple formatting tool to help you maintain more VCS-friendly
  prose text.
It follows the ideas outlined in this [blog](http://dustycloud.org/blog/vcs-friendly-patchable-document-line-wrapping/).

Installation
------------

I would recommend using [minpac](https://github.com/k-takata/minpac) which makes extensive use of the package feature
which was added to Vim 8 and Neovim.
```
call minpac#add('https://gitlab.com/mrossinek/vim-verdict')
```
Other package managers work in a similar fashion.

Usage
-----

Since the functionality provided by `vim-verdict` can be seen as rather
  restrictive to some use-cases, it is not enabled by default for any filetype.
Therefore, in order to use it, you must enable it explicitly where appropriate.
You can do so by running
```
:call verdict#Init()
```
You may also deactivate again with the corresponding `Deinit` function.
```
:call verdict#Deinit()
```
This function will initialize some configurable variables (see Configuration
  further down) and set the following options local to your buffer:
```
formatexpr=verdict#Format()
indentexpr=verdict#Indent(v:lnum)
```
This will enable automatic indentation while typing in insert mode.
Furthermore, you will be able to use `gq{motion}` to format the text moved over
  by `motion`.

**Note:** I recommend using the plugin [localvimrc](https://github.com/embear/vim-localvimrc) which allows you to use local
  `.lvimrc` files to specify additional settings on a project-basis.
This will allow you to automatize the initialization of `vim-verdict` where you
  need it on a regular basis.
You could for example add a single `.lvimrc` file to the root of your website,
  notes directory or tex project.

Configuration
-------------

`vim-verdict` makes use of the following variables:

* `g:verdict_loaded`: if existing, verdict is not loaded again [Default: `1` (after initial loading)]
* `g:verdict_sentence_delims`: symbols delimiting a sentence [Default: `.!?`]
* `g:verdict_sentence_suffixes`: symbols which may follow a delimiter [Default: `)]}"''`]

