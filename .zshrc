# Aliases

## Shortcuts
alias ll='ls -al'
alias editgit='nano ~/.gitconfig'
alias editbash='nano ~/.zshrc'
alias resource='source ~/.zshrc && echo "Done!"'
alias vi=vim

## Git alias
git config --global alias.slog "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

## Git commands
alias log='git log'
alias slog='git slog'
alias wut='git log master...${branch} --oneline'
alias diff='git diff'
alias branch='git branch'
alias st='git status'
alias fetch='git fetch'
alias push='git push origin head'
alias pull='git pull'
alias fp='fetch && pull'
alias gmm='git merge master'
alias recent='git for-each-ref --sort=-committerdate refs/heads/'
alias branch_new="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)'"