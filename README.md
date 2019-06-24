# PHOTOdrawer
Skrypt do porządkowania zdjęć, głownie z telefonów<br>
 Domyślny folder w którym należy umieścić pliki to "PHOTOdrawerIN"<br>
 Domyślny folder który zostanie utworzony i do którego zostaną pliki przeniesione "PHOTOdrawerOUT"<br>
 Do działania potrzeby jest program exiftool do pobierania informacji EXIF oraz jq do parsowania danych JSON<br>
<br>
 Format porządkowania plików:<br>
 <ul>
 <li>2010</li>
  <ul>
   <li>2010-01-01</li>
   <li>2010-02-03</li>
   <li>...</li>
  </ul>
 <li>2011</li>
 <ul>
   <li>...</li>
  </ul>
</ul>
 Format porządkowania plików, włączona opcja GPS:<br>
  <ul>
 <li>2010 Polska</li>
  <ul>
   <li>2010-01-01 Poznań</li>
   <li>2010-02-03 Wrocław</li>
   <li>...</li>
  </ul>
 <li>2011 Wielka Brytania</li>
 <ul>
   <li>...</li>
  </ul>
</ul>
 Opcje:<br>
 -h, -? pomoc, która właśnie została wyświetlona<br>
 -d pliki źródłowe zostaną usunięte<br>
 -g sprawdzanie danych GPS i dadanie do nazwy folderu<br>
 -i [nazwa floderu] własny folder źródłowy<br>
 -o [nazwa floderu] własny folder docelowy<br>
  -l zapis log'u do pliku<br>
