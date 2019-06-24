# PHOTOdrawer
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
