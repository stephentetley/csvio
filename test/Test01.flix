
namespace Test01 {

    use Applicative.{*>};
/*
    @test
    def test01(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaders, setSkipHeaderRecord};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let* fmt    = region r1 {
            toCsvFormatWithCsvFormat(r1, 
                                        CsvIO/CsvFormat.makeCsvFormat(DEFAULT), 
                                        setHeaders("Cardinal direction" :: "Abbreviation" :: Nil) *> setSkipHeaderRecord(true))
        };
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(fmt, Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let _       = Iterator.foreach(println, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok()
*/

    @test
    def test02(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setHeaders, setSkipHeaderRecord};
        region r1 {
            let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
            let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out.csv");
            let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
            let toCells = xy -> {let (x, y) = xy; y :: x :: Nil};  /// Flip 
            let* fmt1   = toCsvFormatWithCsvFormat(r1, CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto());
            let* src    = CsvIO/CsvReader.readCsv(fmt1, Text/Charset.utf_8(), eval, path);
            let* fmt2   = toCsvFormatWithCsvFormat(r1, CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaders("Short" :: "Long" :: Nil));
            let* _      = CsvIO/CsvWriter.outputCsv(fmt2, Text/Charset.utf_8(), outpath, toCells, src);
            Ok()
        }
/*

    @test
    def test03(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setHeaders, setSkipHeaderRecord};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out-utf8-bom.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let toCells = xy -> {let (x, y) = xy; y :: x :: Nil};  /// Flip 
        let* fmt1    = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto() *> setSkipHeaderRecord(true), r1)
        };        
        let* src    = CsvIO/CsvReader.readCsv(fmt1, Text/Charset.utf_8(), eval, path);
        let* fmt2   = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaders("Short" :: "Long" :: Nil), r1)
        };        
        let* _      = CsvIO/CsvWriter.outputCsvWithBOM(fmt2, Text/Charset.utf_8(), outpath, toCells, src);
        Ok() 
*/        
}
