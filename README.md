# CFTC COT Automation

[English](#english) · [Türkçe](#türkçe)

## English

Refresh the latest CFTC Disaggregated Commitments of Traders **Futures and Options Combined** report in Excel with Power Query. The query tracks 28 markets across grains, livestock, energy, metals, and softs. It calculates net positions and weekly changes for Producer/Merchant, Swap Dealers, Managed Money, and Other Reportables, alongside open interest.

### Set up Excel

1. Open a blank workbook in desktop Excel with Power Query, a Blank Query option, and the Advanced Editor. Availability depends on the Excel version and platform.
2. In the **Data** tab, create a **Blank Query** and open **Advanced Editor**.
3. Open [COT_DATA.pq](COT_DATA.pq) as text. Copy its entire contents into the Advanced Editor, replacing the default text. Name the query `COT_DATA`.
4. When prompted for access to `www.cftc.gov`, select **Anonymous**. Choose **Close & Load**, then save your workbook locally.
5. Use **Data → Refresh All** after each CFTC release. Check the **Report Date** column to confirm that a fresh report has loaded.

The [CFTC source file](https://www.cftc.gov/dea/newcot/c_disagg.txt) provides the current snapshot. Sugar in this query refers to the CFTC contract code `080732` (Sugar No. 11). The previous-date label is a seven-day estimate, so verify it against the release history around holidays or reporting disruptions. The weekly position changes use the CFTC's published change fields.

The last two values on each `ProductMap` row are optional historical Managed Money net long and short records. They default to `null`, which leaves the output record columns blank. If you maintain verified historical extrema for the same contract and report type, enter them in your local copy. The query does not build a persistent historical archive. Keep your workbook and local customizations outside the repository.

## Türkçe

Bu Power Query sorgusu CFTC’nin **Disaggregated Futures and Options Combined** raporunu Excel’e getirir. Tahıl, hayvancılık, enerji, metal ve softs gruplarında 28 piyasa için net pozisyonları, haftalık değişimleri ve açık pozisyonu gösterir. Şeker satırı `080732` kodlu Sugar No. 11 kontratını izler.

1. Power Query ve Advanced Editor bulunan masaüstü Excel’de boş bir kitap açın.
2. **Veri** sekmesinden **Boş Sorgu** oluşturup **Gelişmiş Düzenleyici**’yi açın.
3. [COT_DATA.pq](COT_DATA.pq) içeriğinin tamamını düzenleyiciye yapıştırın. Sorguya `COT_DATA` adını verin.
4. Bağlantı sorulursa **Anonim** erişimi seçin. Sorguyu çalışma sayfasına yükleyip Excel dosyanızı kendi bilgisayarınıza kaydedin.
5. Yeni rapor sonrasında **Veri → Tümünü Yenile** seçeneğini kullanın. **Report Date** alanından rapor tarihini kontrol edin.

**Previous Report Date**, rapor tarihinden yedi gün çıkarılarak hesaplanır. Tatil veya gecikme varsa CFTC yayın geçmişiyle karşılaştırın. Haftalık pozisyon değişimleri CFTC’nin yayımladığı değişim sütunlarından gelir. Tarihsel rekor sütunları varsayılan olarak boştur. Elinizde aynı kontrat ve rapor türü için doğrulanmış rekor değerler varsa bunları yerel sorgunuzdaki `ProductMap` satırının son iki alanına girebilirsiniz.

⚠️ Disclaimer

This project is for educational and engineering research purposes only. It does not constitute financial advice. The developer is not responsible for any financial losses incurred from using this bot or its signals. Trade at your own risk.

⚖️ Yasal Uyarı (Disclaimer)

Bu yazılım tamamen açık kaynaklı bir mühendislik ve veri bilimi araştırma projesi (Proof of Concept) olarak tasarlanmıştır. Çıktıların hiçbiri bir ticaret sistemi teklifi veya finansal yatırım tavsiyesi (YTD) niteliği taşımaz. Finansal piyasalar doğası gereği yüksek risk içerir, projenin kullanımı sonucu doğabilecek kâr veya zararlardan kodun geliştiricileri veya katkıda bulunanlar sorumlu tutulamaz. Yazılımı kullanmadan önce daima kendi risk analizinizi ve testlerinizi gerçekleştirmeniz önerilir.
