if status --is-login; and status --is-interactive
    set_color yellow; echo -n "...Landing on"; set_color normal
    echo -E "     ___                       ___                       ___     
                 /  /\                     /__/\          ___        /  /\    
                /  /::\                    \  \:\        /  /\      /  /::\   
               /  /:/\:\  ___     ___       \  \:\      /  /:/     /  /:/\:\  
              /  /:/~/:/ /__/\   /  /\  ___  \  \:\    /  /:/     /  /:/  \:\ 
             /__/:/ /:/  \  \:\ /  /:/ /__/\  \__\:\  /  /::\    /__/:/ \__\:\\
             \  \:\/:/    \  \:\  /:/  \  \:\ /  /:/ /__/:/\:\   \  \:\ /  /:/
              \  \::/      \  \:\/:/    \  \:\  /:/  \__\/  \:\   \  \:\  /:/ 
               \  \:\       \  \::/      \  \:\/:/        \  \:\   \  \:\/:/  
                \  \:\       \__\/        \  \::/          \__\/    \  \::/   
                 \__\/                     \__\/                     \__\/
    "
end

# homebrew at the very beginning
eval "$(/opt/homebrew/bin/brew shellenv fish)"

if status --is-login

    set -gx LANG en_US.UTF-8
    set -gx LC_CTYPE en_US.UTF-8
    set -gx LC_ALL en_US.UTF-8

    # rust
    fish_add_path $HOME/.cargo/bin

    # nvim mason
    fish_add_path -a $HOME/.local/share/nvim/mason/bin/

    # warp terminal
    if test "$TERM_PROGRAM" != WarpTerminal
        # WHAT YOU WANT TO DISABLE FOR WARP - BELOW

        # Unsupported Custom Prompt Code
        starship init fish | source

        # WHAT YOU WANT TO DISABLE FOR WARP - ABOVE
    end

end

# Added by `rbenv init` on Thu Aug 22 10:15:29 CST 2024
status --is-interactive; and rbenv init - --no-rehash fish | source

if status --is-interactive
    # Commands to run in interactive sessions can go here
    set -gx EDITOR hx

    # use lsd instead of ls
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'

    # pyenv
    # pyenv init - | source
    # pyenv virtualenv-init - | source

    # z cd
    zoxide init fish | source

    # fzf completion
    fzf --fish | source

    # wezterm completion
    wezterm shell-completion --shell fish | source

    # Added by OrbStack: command-line tools and integration
    # source ~/.orbstack/shell/init.fish 2>/dev/null || :
    source ~/.orbstack/shell/init.fish

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/pluto/miniconda3/bin/conda
    eval /Users/pluto/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/pluto/miniconda3/etc/fish/conf.d/conda.fish"
        source "/Users/pluto/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/pluto/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

end

