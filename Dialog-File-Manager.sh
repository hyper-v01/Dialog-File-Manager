#!/bin/zsh
export pa="/"
function install_dialog
{
    if uname -a|grep -i "arch"; then
        if (( $(id -u) == 0 )); then
            pacman -S dialog
        else
            sudo pacman -S dialog
        fi
    else
        if uname -a|grep -i -E "centos|fedora"; then
            if (( $(id -u) == 0 )); then
                dnf install dialog
            else
                sudo dnf install dialog
            fi
        else
            if uname -a|grep -i -E "debian|ubuntu|deepin|kali|neon"; then
                if (( $(id -u) == 0 )); then
                    apt install dialog
                else
                    sudo apt install dialog
                fi
            fi
        fi
    fi
}
if command -v dialog > /dev/null; then
    :
else
    echo "Dialog is not installed,Install now?[Y|n]"
    read yesno
    case $yesno in
        "y"|"Y")
            install_dialog;;
        "n"|"N")
            exit;;
        "")
            install_dialog;;
        *)
            exit;;
    esac
fi
while true
do
    for i in $(ls $pa)
    do
        echo $i >> path.log
    done
    export lines=$(cat path.log|wc -l)
    for ((i=1; i<=$lines; i++))
    do
        echo $i >> text.log
        cat path.log|tail -n $i|head -n 1 >> text.log
    done
    if [ $pa = "/" ]; then
        :
    else
        sed -i '1 i\0 ..' text.log
    fi
    dialog --menu "Dialog File Manager - Path=$pa" 40 200 180 $(cat text.log) 2> sel.log
    if (( $? == 1 )); then
        break
    else
    export sel=$(cat sel.log)
    export dr=$(cat path.log|tail -n $sel|head -n 1)
    if (( $sel == 0 )); then
        for ((i=$[$(echo ${#pa})-1]; i>=1; i--))
        do
            if echo $pa[$i]|grep "/"; then
                export ma2=$(echo ${#pa})
                export ma=$[$i+1]
                break
            fi
        done
        export pa_on=$(echo $pa[$ma,$ma2])
        export pa=$(echo ${pa/$pa_on/""})
        unset pa_on
        rm *log
        unset sel
        unset dr
        else
            if test -d $pa$dr; then
                if test -z "$(ls $pa$dr)"; then
                    dialog --msgbox "This Directory $pa$dr has no any file" 40 200
                    rm *log
                    unset sel
                    unset dr
                else
                    export pa="$pa$dr/"
                    rm *log
                    unset sel
                    unset dr
                fi
            else
                dialog --msgbox "Now you can not open any file" 40 200
                rm *log
                unset sel
                unset dr
            fi
        fi
    fi
done
rm *log
