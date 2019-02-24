export PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\\[\e[1;33m\]\$\[\e[m\] "
alias tmux="tmux -2"
shopt -s checkwinsize

$HOME/quotes.sh
export HISTFILESIZE=2000000


source ~/.profile
export PATH="/home/matt/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
