#!/bin/sh
# Forensic
# Recherche d'indicateurs d'ajout de nouveaux fichiers par comparaison d'inodes
# principalement sur /bin/ et /sbin/
# xophidia @2018

utilisation () {
    echo "Utilisation: $0 -p <chemin> -v (0|1) "
    echo "-p path"
    echo "-v verbose"
    exit 1
}

if [ $# -lt 1 ] ; then
  utilisation
fi

VERBOSE=0
inode_start=0


while getopts ":p:v:" option
do
	case $option in
		p) FILE=${OPTARG};;
		v) VERBOSE=${OPTARG};;
		\?) echo "Invalide option: -$OPTARG"
			exit 1
			;;
		esac
done


#Creation d'un fichier temporaire

tmp='/tmp/inode.txt'
ls -i $FILE |sort -n > $tmp

#Parcours des différents fichiers

cat $tmp | while read line
do

	if [ $inode_start -eq 0 ]; then
		inode_start=$(echo $line | awk '{print $1}')
	else
		t=$(echo $line | awk '{print $1}')
		diff=$(( $t - $inode_start))
		if [ $diff -gt 1 ]; then
			echo "\e[31m Décallage détecté de $diff \e[0m"
			echo "\e[32m $line \e[0m"
			inode_start=$t
		else
			if [ $VERBOSE -eq 1 ]; then echo $line; fi
			inode_start=$t
		fi
	fi

done
