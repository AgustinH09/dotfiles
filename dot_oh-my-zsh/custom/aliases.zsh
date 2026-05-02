alias c="wl-copy"
alias v="wl-paste"
alias p="wl-paste"
alias n='nvim'
alias z='cd'
alias cat="bat"
alias ls="eza --color=always --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias fuck="fk"
alias mux="tmuxinator"

# SSH Aliases
# ThinkCERCA
alias hatchbox_dev="ssh -i ~/.ssh/tc_hatchbox.pem deploy@3.90.209.226"
alias hatchbox_stage="ssh -i ~/.ssh/tc_hatchbox.pem deploy@3.225.220.76"
alias hatchbox_prod="ssh -i ~/.ssh/tc_hatchbox.pem deploy@44.220.223.215"
alias hatchbox_review_apps_01="ssh -i ~/.ssh/tc_hatchbox.pem deploy@3.230.92.132"
alias hatchbox_review_apps_02="ssh -i ~/.ssh/tc_hatchbox.pem deploy@54.156.50.36"
alias hatchbox_review_apps_03="ssh -i ~/.ssh/tc_hatchbox.pem deploy@52.22.252.135"
alias ec2_canvas_01="ssh -i ~/.ssh/tc_prod.pem ubuntu@18.215.212.225"
alias ec2_canvas_02="ssh -i ~/.ssh/tc_prod.pem ubuntu@44.199.165.236"
alias hatchbox_editorial_stage="ssh -i ~/.ssh/tc_hatchbox.pem deploy@3.95.139.177"
alias hatchbox_editorial_prod="ssh -i ~/.ssh/tc_hatchbox.pem deploy@52.72.189.159"

# Kitty kittens
alias icat="kitten icat"
alias clipboard="kitten clipboard"

# --- Agent Mode Aliases ---
if [[ "$AGENT_MODE" == "true" ]]; then
  alias ll='eza -lh --color=always --git --icons=always'
  alias la='eza -lAh --color=always --git --icons=always'
  alias grep='grep --color=auto'
  alias diff='diff --color=auto'
  alias curl='curl -s'
  alias wget='wget -q'
  alias make='make -s'
fi
