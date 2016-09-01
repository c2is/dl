#!/bin/sh
#/etc/config/incron.d/root
#/share/WebGra/FTP_EXTERNAL/dl/files IN_ALL_EVENTS /share/c2isutils/c2is-download-area-handler.sh $% $#
debug=true
event_name=$1
file=$2
timel=$(date +"%Y-%m-%d %T")
excluded=".DS_Store ._.DS_Store"
dl_root="/share/WebGra/FTP_EXTERNAL/dl"
dl_samba_files="/mnt/WebGra/FTP_EXTERNAL/dl/files"
dl_files="/share/WebGra/FTP_EXTERNAL/dl/files"
dl_url="https://dl.c2is.fr/"
chgrp 33 $dl_root/mapping.txt
chmod 750  $dl_root/mapping.txt

[[ $excluded =~ $file ]] && exit
[[  $file == "."* ]] && exit
[[ -f "$dl_files/._$file" ]] && exit

[[ "$debug" = true  ]] && echo $timel"- $$ -"$event_name":"$file >> /tmp/incrondebug.log

function mail_notify() {
    echo -e "subject:$1\nfrom:Monitor DL <SRVFILES-QNAP@srvfiles-qnap>\nto:a.cianfarani@c2is.fr\n\n$2\n" | sendmail a.cianfarani@c2is.fr
    # echo -e "$2" | mail -s "$1" -a "From: Monitoring DL <root@srvdev.c2is>" a.cianfarani@c2is.fr
}

function mail_notify_user() {
    file=$1
    url=$2
    addr=$3
    subj="Vous avez ajouté un fichier à télécharger"
    alert_msg="Le fichier \"$file\" sera disponible pendant 30 jours à cette url $url\nUne authentification sera requise, en voici les identifiants : \n- login : c2is\n- mot de passe : c2is"
    echo -e "subject:$subj\nfrom:Monitor DL <SRVFILES-QNAP@srvfiles-qnap>\nto:$addr\n\n$alert_msg\n" | sendmail a.cianfarani@c2is.fr
}

function get_user() {
    file=$1
    file=${file// /\\ }
    usr=$(ssh root@srvdocs stat -c '%U' $file)
    echo $usr
}

function key_generate() {
    M="abcdefghijklmnopqrstuvwxyz"
    while [ "${n:=1}" -le "4" ]
    do  pass="$pass${M:$(($RANDOM%${#M})):1}"
      let n+=1
    done
    echo "$pass"
}

if [ "$event_name" == "IN_MOVED_TO,IN_ISDIR" ] || [ "$event_name" == "IN_MOVED_TO" ] ; then
    key=`key_generate`

    while [ $(grep "$key " $dl_root/mapping.txt) ]
    do
        key=`key_generate`
    done

    echo "$key $file" >> $dl_root/mapping.txt

    chgrp 33 $dl_files/$file

    usr=`get_user "$dl_samba_files/$file"`
    if [ $usr != "UNKNOWN" ] ; then
        mail_notify_user "$file" "$dl_url$key" "$usr@c2is.fr"
    fi

    subj="Fichier DL ajouté"
    alert_msg="Un fichier a été ajouté sur srvdev:/mnt/ftp_external/dl/files : $file\nUser : $usr"
    mail_notify "$subj" "$alert_msg"

fi

if [ "$event_name" == "IN_CREATE" ] || [ "$event_name" == "IN_CLOSE_WRITE" ] || [ "$event_name" == "IN_CREATE,IN_ISDIR" ] ; then
    file_unix=${file// /\\ }
    [[ -f "$dl_files/.$file.lock" ]] && exit

    touch "$dl_files/.$file.lock"

    size=0
    #check_command=$(du -s "$dl_files/$file" | cut -f1)
    [[ "$debug" = true  ]] && echo $timel"- $$ - $event_name - SIZE BEGIN : $(du -s "$dl_files/$file" | cut -f1) "$event_name":"$file >> /tmp/incrondebug.log
    sleep 50
    while [ $(du -s "$dl_files/$file" | cut -f1) -gt $size ]
    do
        size=$(du -s "$dl_files/$file" | cut -f1)
        sleep 50
        [[ "$debug" = true  ]] && echo $timel"- $$ - $event_name - SIZE CHECK : $size "$event_name":"$file >> /tmp/incrondebug.log
    done

    [[ "$debug" = true  ]] && echo $(date +"%Y-%m-%d %T")"- $$ - $event_name - SIZE END : $size - Ok to continue -"$event_name":"$file >> /tmp/incrondebug.log
    sleep 5
    rm "$dl_files/.$file.lock"

    key=`key_generate`

    while [ $(grep "$key " $dl_root/mapping.txt) ]
    do
        key=`key_generate`
    done

    echo "$key $file" >> $dl_root/mapping.txt

    chgrp 33 "$dl_files/$file"

    usr=`get_user "$dl_samba_files/$file"`
    if [ $usr != "UNKNOWN" ] ; then
        mail_notify_user "$file" "$dl_url$key" "$usr@c2is.fr"
    fi

    subj="Fichier DL ajouté"
    alert_msg="Un fichier a été ajouté sur srvdev:/mnt/ftp_external/dl/files : $file\nUser : $usr"
    mail_notify "$subj" "$alert_msg"
fi

if [ "$event_name" == "IN_DELETE" ] || [ "$event_name" == "IN_DELETE,IN_ISDIR" ] || [ "$event_name" == "IN_MOVED_FROM,IN_ISDIR" ] || [ "$event_name" == "IN_MOVED_FROM" ]; then
    today=$(date +"%m-%d-%Y")
    sed -i -r 's|^(.*) '$file$'|#removed on '$today':\1 '$file'|g' $dl_root/mapping.txt
    subj="Fichier DL supprimé"
    alert_msg="Un fichier a été supprimé sur srvdev:/mnt/ftp_external/dl/files : $file"
    mail_notify "$subj" "$alert_msg"
fi