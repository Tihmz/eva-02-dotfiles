#!/bin/bash

print_help () {
    echo "This script install all the dotfiles to there right place"
    echo "Use './setup --all' to install all dotfiles (zsh,tmux,kitty,vim,conky,lsd,neofetch)"
    echo "use './setup zsh' to only install zsh, './setup.sh tmux vim' to only install vim and tmux..."
}

url_zsh="https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh"
url_vim="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"  

if [ -x "$(command -v apt)" ]; then
    echo "[SETUP] apt detected"
    tool="apt install"
elif [ -x "$(command -v pacman)" ]; then
    echo "[SETUP] pacman detected"
    tool="pacman -S"
fi

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- zsh

zsh_install () { 
    if ! [ -x "$(command -v zsh)" ]; then
        echo "[SETUP] installing zsh"
        sudo $tool zsh
    fi

    sh -c "$(curl -fsSL $url_zsh)"
    cp ./zsh/tihmz.zsh-theme $HOME/.oh-my-zsh/themes/

    if [ -f $HOME/.zshrc ]; then
        cp $HOME/.zshrc $HOME/.zshrc.old
    fi

    cp ./zsh/zshrc $HOME/.zshrc
}


# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- kitty

kitty_install () {
    if ! [ -x "$(command -v kitty)" ]; then
        echo "[SETUP] installing kitty"
        sudo $tool kitty
    fi


    if [ -d "$HOME/.config/kitty/" ]; then
        if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
            cp $HOME/.config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf.old
        fi
    else
        mkdir $HOME/.config/kitty
    fi
    
    cp kitty/kitty.conf $HOME/.config/kitty/
}

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- vim

vim_install () {
    if ! [ -x "$(command -v vim)"]; then
        echo "[SETUP] installing vim"
        sudo $tool vim
    fi

    if [ -f $HOME/.vimrc ]; then
        mv $HOME/.vimrc $HOME/.vimrc.old
    fi

    cp vim/vimrc $HOME/.vimrc
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $vim_url  

    if [ "$(vim --version | grep -i +python)" != "" ]; then
        sudo $tool python3-powerline
    else
        echo "[SETUP] vim version doesn't support python"
    fi
}

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- tmux

tmux_install () {
    if ! [ -x "$(command -v tmux)" ]; then
        echo "[SETUP] installing tmux"
        sudo $tool tmux
    fi

    if [ -f $HOME/.tmux.conf ]; then
        mv $HOME/.tmux.conf $HOME/.tmux.conf.old
    fi

    if [ -f $HOME/.tmux.conf.local ]; then
        mv $HOME/.tmux.conf.local $HOME/.tmux.conf.local.old
    
    cp tmux/tmux.conf $HOME/.tmux.conf
    cp tmux/tmux.conf.local $HOME/.tmux.conf.local
}


# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- tmux

polybar_install () {
    if ! [ -x "$(command -v polybar)" ] || ! [ -x "$(command -v rofi)" ]; then
        echo "[SETUP] installing polybar and rofi"
        sudo $tool polybar rofi
    fi

    if [ -d $HOME/.config/polybar ]; then
        mv $HOME/.config/polybar $HOME/.config/polybar.old
    fi

    cp polybar/* $HOME/.config/polybar/ -r
}

if [ "$1" == "--all" ];then
    echo "[SETUP] installing everything"
    zsh_install
    polybar_install
    kitty_install
    tmux_install
    vim_install
elif [ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$#" == "0" ]; then
    print_help
else
    for i in "$@"
    do
        if [ "$i" == "zsh" ];then
            zsh_install
        elif [ "$i" == "kitty" ];then
            kitty_install
        elif [ "$i" == "tmux" ];then
            tmux_install
        elif [ "$i" == "vim" ];then
            vim_install
        elif [ "$i" == "polybar" ];then
            polybar_install
        else
            echo "unknow option : $i"
        fi
    done
fi


