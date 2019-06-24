#!/bin/bash
clear

echo 'Wyświetlenie pomocy -h -?'

help () {
	clear
	cat <<HELP

 PHOTOdrawer 0.2.1
 -----------------

 Skrypt do porządkowania zdjęć, głownie z telefonów
 Domyślny folder w którym należy umieścić pliki to "PHOTOdrawerIN"
 Domyślny folder który zostanie utworzony i do którego zostaną pliki przeniesione "PHOTOdrawerOUT"
 Do działania potrzeby jest program exiftool do pobierania informacji EXIF oraz jq do parsowania danych JSON

 Format porządkowania plików:
 2010
   2010-01-01
   2010-02-03
   ...
 2011
   ...

 Format porządkowania plików, włączona opcja GPS:
 2010 Polska
   2010-01-01 Poznań
   2010-02-03 Wrocław
   ...
 2011 Wielka Brytania
   ...

 Opcje:
 -h, -? pomoc, która właśnie została wyświetlona
 -d pliki źródłowe zostaną usunięte
 -g sprawdzanie danych GPS i dadanie do nazwy folderu
 -i [nazwa floderu] własny folder źródłowy
 -o [nazwa floderu] własny folder docelowy
  -l zapis log'u do pliku

HELP
exit;
}

# Ustawienia domyślne
TOOLS=(exiftool jq)
DEFAULTINDIR='./PHOTOdrawerIN'
DEFAULTOUTDIR='./PHOTOdrawerOUT'
DATE=`date '+%Y-%m-%d %H:%M:%S'`
GEOCODEinfo='Zapis danych GPS	- OFF'
LOGinfo='Zapis logu do pliku	- OFF'
DELinfo='Usuwanie źródła		- OFF'

# Obsługa błędów
set -o errexit
set -o pipefail

# Aktywacja debagowania
#set -o xtrace
#set -o verbose

# Sprawdź, czy zainstalowane są potrzebne programy
echo
for cmd in exiftool jq curl; do
  printf '%-10s' "$cmd"
  if hash "$cmd" 2>/dev/null;
  then
    echo "- Program zainstalowany"
  else
    echo "- Program wymagany należy zainstalować (sudo apt-get update && sudo apt-get install $cmd)"
    exit;
  fi
done
echo

# Włączenie obsługi nazw plików ze spacjami:
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# Jeżeli nie podano własnych folderów usawione są domyślne
BASEINDIR=${DEFAULTINDIR}
BASEOUTDIR=${DEFAULTOUTDIR}

# Pobranie parametrów
while getopts "i:o:dghl" opt ; do
  case $opt in
   i)
      BASEINDIR=${OPTARG}
      ;;
   o)
      BASEOUTDIR=${OPTARG}
      ;;
   d)
      DEL=true
			DELinfo='Usuwanie źródła		- ON'
      ;;
   g)
		  GEOCODE=true
			GEOCODEinfo="Zapis danych GPS	- ON"
			case "$(curl -s --max-time 2 -I http://nominatim.openstreetmap.org | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
				[23]) echo -e "Połączenie z openstreetmap.org - OK\n";;
				5) echo "Serwer proxy nie przepuści nas";;
				*) echo -e "Brak połączenia z internetem\n"
					exit
					;;
			esac
      ;;
   l)
			LOG=true
			LOGinfo='Zapis logu do pliku	- ON'
			echo -e 'PHOTOdrawer LOG - '${DATE}' \n--------------------------------------' >> PHOTOdrawer.log
			;;
   h|?)
		help
		;;
  esac
done
shift $((OPTIND -1))
echo "Konfiguracja:"
echo "Folder źródłowy		- $BASEINDIR"
echo "Folder docelowy		- $BASEOUTDIR"
echo $GEOCODEinfo
echo $LOGinfo
echo $DELinfo

# Fonkcja główna skryptu
PHOTOdrawer () {
if [ -z "$(ls $BASEINDIR 2>/dev/null)" ];
then
	echo -e "Brak plików w folerze źródłowym $BASEINDIR\n"
	exit
fi

counter=0
for FILE in $(find ${BASEINDIR} -not -wholename "*._*" -iname "*.JPG" -or -iname "*.JPEG" -or -iname "*.CRW" -or -iname "*.THM" -or -iname "*.RW2" -or -iname '*.ARW' -or -iname "*AVI" -or -iname "*MOV" -or -iname "*MP4"  -or -iname "*MTS" -or -iname "*PNG")
do
	INPUT=${FILE}
	DATE=$(exiftool -q -dateformat "%Y:%m:%d" -json -DateTimeOriginal "${INPUT}" | jq --raw-output '.[].DateTimeOriginal')

	if [ ! -z "$GEOCODE" ] && [ "$GEOCODE" == "true" ]
	then
		GPS=$(exiftool -q -q -c -ee -p '&lat=$gpslatitude&lon=$gpslongitude' "${INPUT}" -n)
		CITY=null
		COUNTRY=null

		if [ ! -z "$GPS" ]
		then
			URL="https://nominatim.openstreetmap.org/reverse?format=geocodejson${GPS}&accept-language=pl"
			#CITY=$(curl -s $URL | jq --raw-output '.features[].properties.geocoding.city')
			json_data=$(curl -s $URL)

			CITY=$(echo $json_data | jq --raw-output '.features[].properties.geocoding.city')
			COUNTRY=$(echo $json_data | jq --raw-output '.features[].properties.geocoding.country')

			if [ "$CITY" == null ]
			then
			CITY=$(echo $json_data | jq --raw-output '.features[].properties.geocoding.admin.level8')

				if [ "$CITY" == null ]
				then
				CITY=$(echo $json_data | jq --raw-output '.features[].properties.geocoding.admin.level7')
				fi
			fi
		fi
	fi

	if [ "$DATE" == null ]  # Jeśli pobranie danych daty (DateTimeOriginal) z exif nie powiodła się
	then
		DATE=$(exiftool -q -dateformat "%Y:%m:%d" -json -MediaCreateDate "${INPUT}" | jq --raw-output '.[].MediaCreateDate')
	fi
	if [ -z "$DATE" ] || [ "$DATE" == null ] # Jeśli pobranie danych daty (MediaCreateDate) z exif nie powiodła się
	then
		DATE=$(stat -f "%Sm" -t %F "${INPUT}" | awk '{print $1}'| sed 's/-/:/g')
	fi

	if [ ! -z "$DATE" ]; # Podwójne sprawdzenie
	then

		YEAR=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\1/")
		MONTH=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\2/")
		DAY=$(echo $DATE | sed -E "s/([0-9]*):([0-9]*):([0-9]*)/\\3/")


		if [ "$YEAR" -gt 0 ] & [ "$MONTH" -gt 0 ] & [ "$DAY" -gt 0 ]
		then
			if [ ! -z "$CITY" ] && [ "$CITY" != null ] && [ ! -z "$COUNTRY" ] && [ "$COUNTRY" != null ]
			then
				OUTPUT_DIRECTORY=${BASEOUTDIR}/${YEAR}\ ${COUNTRY}/${YEAR}-${MONTH}-${DAY}\ ${CITY}
			else
				OUTPUT_DIRECTORY=${BASEOUTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}
			fi
			mkdir -p ${OUTPUT_DIRECTORY}
			OUTPUT=${OUTPUT_DIRECTORY}/$(basename ${INPUT})

			#kolopwanie pliku ze sprawdzeniem poprawności za pomocą synchronizacji
			if [ -e "$OUTPUT" ] && ! cmp -s "$INPUT" "$OUTPUT"
			then
				echo "UWAGA: '$OUTPUT' istnieje i różni się od '$INPUT'."
			else
				if [ ! -z "$LOG" ] && [ "$LOG" == "true" ]
					then
						echo -e "Plik $INPUT -> $OUTPUT" | tee -a PHOTOdrawer.log
					else
						echo -e "Plik $INPUT -> $OUTPUT"
				fi
				rsync -ah "$INPUT"  "$OUTPUT"
				if ! cmp -s "$INPUT" "$OUTPUT"
				then
					echo "UWAGA: kopiowanie nie powiodło się, oryginał '$INPUT' pozostanie w folderze źródłowym"
				else

				if [ ! -z "$DEL" ] && [ "$DEL" == "true" ]
					then
						echo -e "Dane źródłowe są przenoszone\n"
						rm -f "$INPUT"
					else
						echo -e "Dane źródłowe są kopiowane\n"
					fi
				fi
			fi
		else
		  echo "UWAGA: '$INPUT' nie zawiera daty."
		fi
	else
		echo "UWAGA: '$INPUT' nie zawiera daty."
	fi
	counter=$(( $counter + 1 ))
done

if [ ! -z "$LOG" ] && [ "$LOG" == "true" ]
	then
		echo -e "------------------------------------------------------------\nPHOTOdrawer zakończył działanie, przetworzonych plików: $counter\n${GEOCODEinfo}\n${DELinfo}\n------------------------------------------------------------\n" | tee -a PHOTOdrawer.log
	else
		echo -e "----------------------------------------------------------\nPHOTOdrawer zakończył działanie, przetworzonych plików: $counter\n"
fi
}
echo
read -r -p "Jesteś pewny? [y/N] " response
echo
case "$response" in
    [yY][eE][sS]|[yY])
        PHOTOdrawer
        ;;
    *)
        exit
        ;;
esac
# restore $IFS
IFS=$SAVEIFS
