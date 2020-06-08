#!/bin/bash
# export ipod music
#
# Go to your ipod disk. for example F:\IPOD\iPod_control\Music\ and paste into your local drive (probably wsl does not have permissions to write or read into ipod drive). Notice that ipod_control folder is hide.
# exp ./script.sh /mnt/c/Users/caca/Desktop/folder you pasted from ipod
#
# Exiftool is needed
# apt install exiftool
#
IFS=$'\n'
dd=$(date +%F)
dwork=$1
ework="${dwork}exports_${dd}"
cont="1"
##
if [ -v $dwork ]; then
        echo "Error"
        echo "usage: script.sh [fullpath music directory]"
        #echo $dwork
        exit 1
fi
mkdir ${ework}
function artist_a {
        cd $dwork
        for dire in $(ls -ld F*|awk '{print $9}'); do
                exiftool *|grep -e "^Artist  "|awk -F":" '{print $2}'|sed -e '/^ *$/d' -e 's/\//_/g' -e 's/!/_/g' |sort|uniq >> ${ework}/tmp_artist.txt
        done
                cat ${ework}/tmp_artist.txt|sort|uniq|sed -e '/\.\.\./d'|sort|uniq >> ${ework}/artist_list.txt
                rm ${ework}/tmp_artist.txt
}
function band_a {
        cd $ework
        for artist in $(cat artist_list.txt); do
                mkdir $artist
        done
}
function song_a {
        cd $dwork
        for dir in $(ls -ld F*|awk '{print $9}'); do
                cd ${dir}
                for filem in $(ls -l |awk '{print $9}'); do
                        #echo $filem
                        ext=$(echo $filem|awk -F"." '{print $2}')
                        artists=$(exiftool $filem|grep -e "^Artist  "|awk -F":" '{print $2}'|sed -e 's/\//_/g' -e 's/!/_/g' -e 's/\/s//g')
                        names=$(exiftool $filem|grep -e "^Title"|awk -F":" '{print $2}'|sed -e 's/\//_/g' -e 's/!/_/g' -e 's/\/s//g')
                        #albums=$(exiftool $filem|grep -e "^Album"|awk -F":" '{print $2}')

                        if [ -v $names ]; then
                                names="uknown_song_${cont}"
                                cp $filem ${ework}/${names}.${ext}
                                let cont=$cont+1
                        else
                                #echo "Moviendo $names"
                                cp $filem ${ework}/${artists}/${names}.${ext} 2>/dev/null
                        fi

                done
                cd ..
        done
}

echo "Sacando Lista de Artistas."
artist_a
echo "Creando Directorios de Gruppos"
band_a
echo "Moviendo las Canciones"
song_a
