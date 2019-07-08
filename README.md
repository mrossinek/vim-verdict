vim-verdict
===========

vim-verdict is a simple formatting tool to help you maintain more VCS-friendly
  prose text.
It follows the ideas outlined in this [blog](http://dustycloud.org/blog/vcs-friendly-patchable-document-line-wrapping/).

Usage
-----

You can set the `formatexpr` option to call the `Verdict()` function and then
  use the `gq{motion}` command to format your text.

Installation
------------

I would recommend using [minpac](https://github.com/k-takata/minpac) which makes extensive use of the package feature
which was added to Vim 8 and Neovim.
```
call minpac#add('gitlab.com/mrossinek/vim-verdict')
```
Other package managers work in a similar fashion.

