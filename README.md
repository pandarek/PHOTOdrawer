# PHOTOdrawer
Skrypt do porządkowania zdjęć, głownie z telefonów
 Domyślny folder w którym należy umieścić pliki to "PHOTOdrawerIN"
 Domyślny folder który zostanie utworzony i do którego zostaną pliki przeniesione "PHOTOdrawerOUT"
 Do działania potrzeby jest program exiftool do pobierania informacji EXIF oraz jq do parsowania danych JSON
<br>
 Format porządkowania plików:<br>
 2010<br>
   2010-01-01<br>
   2010-02-03<br>
   ...<br>
 2011<br>
   ...<br>

 Format porządkowania plików, włączona opcja GPS:<br>
 2010 Polska<br>
   2010-01-01 Poznań<br>
   2010-02-03 Wrocław<br>
   ...<br>
 2011 Wielka Brytania<br>
   ...<br>

 Opcje:<br>
 -h, -? pomoc, która właśnie została wyświetlona<br>
 -d pliki źródłowe zostaną usunięte<br>
 -g sprawdzanie danych GPS i dadanie do nazwy folderu<br>
 -i [nazwa floderu] własny folder źródłowy<br>
 -o [nazwa floderu] własny folder docelowy<br>
  -l zapis log'u do pliku<br>
