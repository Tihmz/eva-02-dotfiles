#!/bin/bash

print_help () {
    echo "This script install all the dotfiles to there right place"
    echo "Use './setup --all' to install all dotfiles (zsh,tmux,kitty,vim,polybar)"
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
    echo "[SETUP] setting zsh as default shell, will take effect after reloging"
    chsh -s /bin/zsh
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

    if ! [ -d $HOME/.local/share/fonts ]; then
        mkdir $HOME/.local/share/fonts
    fi
    cp data/MesloLGS\ NF $HOME/.local/share/fonts/

}

# -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- vim

vim_install () {
    if ! [ -x "$(command -v vim)" ]; then
        echo "[SETUP] installing vim"
        sudo $tool vim
    fi

    if [ -f $HOME/.vimrc ]; then
        mv $HOME/.vimrc $HOME/.vimrc.old
    fi

    cp vim/vimrc $HOME/.vimrc
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs $url_vim 

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
    fi

    if [ -d $HOME/.tmux/ ]; then
        mv $HOME/.tmux $HOME/.tmux.old
    fi

    cp tmux/tmux.conf $HOME/.tmux.conf
    cp tmux/tmux.conf.local $HOME/.tmux.conf.local
    mkdir $HOME/.tmux && mkdir $HOME/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    if ! [ -d $HOME/.local/share/fonts ]; then
        mkdir $HOME/.local/share/fonts
    fi
    cp data/MesloLGS\ NF $HOME/.local/share/fonts/
    


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
    
    if ! [ -d $HOME/.config/polybar ]; then
        mkdir $HOME/.config/polybar
    fi

    cp polybar/* $HOME/.config/polybar/ -r

    # stolen here :
    # https://github.com/adi1090x/polybar-themes/blob/master/setup.sh

    FDIR="$HOME/.local/share/fonts"

	echo "[SETUP] installing fonts..."
	if [[ -d "$FDIR" ]]; then
		cp -rf data/fonts/* "$FDIR"
	else
		mkdir -p "$FDIR"
		cp -rf data/fonts/* "$FDIR"
	fi
    
    echo "[SETUP] installing spotify modules dependencies"

    if ! [ -x "$(command -v playerctl)" ];then
        echo "[SETUP] installing playerctl"
        sudo $tool playerctl
    fi

    if ! [ -x "$(command -v zscroll)" ];then
        echo "[SETUP] installing zscroll"
        git clone https://github.com/noctuid/zscroll
        cd zscroll
        sudo python3 setup.py install
    fi

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
