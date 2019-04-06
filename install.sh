git clone https://github.com/tpope/vim-pathogen.git
cd autoload
ln -s ../vim-pathogen/autoload/pathogen.vim .

mkdir bundle
cd bundle
git clone https://github.com/kien/rainbow_parentheses.vim.git
git clone git@github.com:tpope/vim-surround.git
git clone git@github.com:altercation/vim-colors-solarized.git
