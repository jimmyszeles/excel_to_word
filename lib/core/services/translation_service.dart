import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

class TranslationService {
  static Future<String> translateAndSave({
    required String excelPath,
    required String wordTemplatePath,
    required String newFileName,
    required List<Map<String, String>> mappings,
  }) async {
    // 1. Excel-bestand inlezen
    final excelFile = File(excelPath);
    final bytes = excelFile.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // 2. Word-sjabloon (DOCX) inlezen als ZIP-archief
    final archive = ZipDecoder().decodeBuffer(InputFileStream(wordTemplatePath));
    final newArchive = Archive(); // Nieuw archief om de gewijzigde bestanden op te slaan

    // 3. Itereren over bestanden in het ZIP-archief
    for (final file in archive) {
      // We zijn alleen geïnteresseerd in 'word/document.xml'
      if (file.name == 'word/document.xml') {
        // Gebruik utf8.decode om de XML-inhoud correct in te lezen
        final xmlContent = utf8.decode(file.content as List<int>);

        final doc = XmlDocument.parse(xmlContent);

        // 4. Plaatsaanduidingen vervangen in de XML
        // Definieer de WordprocessingML namespace URI
        const String wNamespace = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main';

        // We zoeken naar <w:body> eerst om zeker te zijn dat we de hoofdinhoud pakken.
        final body = doc.findAllElements('body', namespace: wNamespace).firstOrNull;

        if (body == null) {
          print('Fout: <w:body> element niet gevonden in document.xml. Controleer de XML-structuur of de namespace.');
          return ''; // Of gooi een uitzondering
        }

        // We gaan nu een meer geavanceerde aanpak gebruiken om placeholders te vervangen
        // die mogelijk over meerdere <w:t> elementen zijn verspreid,
        // maar de opmaak binnen de runs behouden.

        // Eerst verzamelen we alle runs die mogelijk placeholders bevatten
        final runs = <XmlElement>[];
        for (final paragraph in body.findAllElements('p', namespace: wNamespace)) {
          runs.addAll(paragraph.findAllElements('r', namespace: wNamespace));
        }

        // Iterate over each mapping
        for (final map in mappings) {
          final key = '${map['key']}'; // De placeholder sleutel, bijv. [DATUM]
          final cellRef = map['cell']!; // De Excel celreferentie, bijv. A2

          // Haal de waarde op uit de Excel-cel
          final sheet = excel.tables[excel.tables.keys.first]!;
          String value = sheet.cell(CellIndex.indexByString(cellRef)).value?.toString() ?? '';

          // Controleer of de waarde een datum in ISO 8601 formaat is en formatteer deze
          try {
            final dateTime = DateTime.parse(value);
            // Als het parsen lukt, formatteren we het naar 'dd/MM/yyyy'
            value = DateFormat('dd/MM/yyyy').format(dateTime);
          } catch (e) {
            // Als het parsen mislukt, is het geen datum of niet in het verwachte formaat.
            // We gebruiken dan de originele 'value' string.
            // print('Waarde "$value" is geen geldig ISO 8601 datumformaat, of er is een andere fout opgetreden bij het parsen: $e');
          }

          // Loop door alle runs om de placeholder te vinden en te vervangen
          for (final run in runs) {
            final textNodesInRun = run.findAllElements('t', namespace: wNamespace).toList();

            // Combineer de tekst van alle <w:t> elementen in de huidige run
            String combinedText = textNodesInRun.map((node) => node.text).join();

            // Controleer of de gecombineerde tekst de placeholder bevat
            if (combinedText.contains(key)) {
              // Voer de vervanging uit op de gecombineerde tekst
              final replacedText = combinedText.replaceAll(key, value);

              // Nu moeten we de vervangen tekst terugplaatsen in de <w:t> elementen.
              // De meest veilige manier is om alle oude <w:t> elementen te verwijderen
              // en één nieuw <w:t> element toe te voegen met de vervangen tekst.
              // Dit kan echter opmaak verliezen die aan individuele <w:t> elementen was gekoppeld.
              // Een betere aanpak is om de tekst van het eerste <w:t> element aan te passen
              // en de rest te verwijderen. Dit behoudt de opmaak van de eerste <w:t> node.

              if (textNodesInRun.isNotEmpty) {
                // Pas de tekst van het eerste <w:t> element aan
                textNodesInRun.first.innerText = replacedText;

                // Verwijder de overige <w:t> elementen in deze run
                for (int i = 1; i < textNodesInRun.length; i++) {
                  textNodesInRun[i].remove();
                }
              }
            }
          }
        }

        // 5. De gewijzigde XML terug toevoegen aan het nieuwe archief
        // Zorg ervoor dat pretty: false en indent: '' worden gebruikt om de originele compacte XML-structuur te behouden
        final fixedXml = doc.toXmlString(pretty: false, indent: '');

        // Converteer de XML-string expliciet naar UTF-8 bytes
        final fixedXmlBytes = utf8.encode(fixedXml);
        newArchive.addFile(ArchiveFile(file.name, fixedXmlBytes.length, fixedXmlBytes));
      } else {
        // Andere bestanden (zoals _rels, theme, settings, etc.) ongewijzigd kopiëren
        newArchive.addFile(file);
      }
    }

    // 6. Het nieuwe DOCX-bestand opslaan
    final outputPath = p.join(p.dirname(wordTemplatePath), '$newFileName.docx');
    final outStream = OutputFileStream(outputPath);
    ZipEncoder().encode(newArchive, output: outStream);
    await outStream.close(); // Wacht tot de stream is gesloten

    return outputPath;
  }
}
