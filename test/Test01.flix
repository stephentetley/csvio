
namespace Test01 {

    use Applicative.{*>};

    @test
    def test01(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setSkipHeaderRecord};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let* fmt    = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto() *> setSkipHeaderRecord(true), r1)
        };
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(fmt, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let _       = Iterator.foreach(println, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok()


    @test
    def test02(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setHeaders, setSkipHeaderRecord};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
        let* fmt1    = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto() *> setSkipHeaderRecord(true), r1)
        };        
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(fmt1, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let* fmt2   = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaders("Short" :: "Long" :: Nil) *> setSkipHeaderRecord(true), r1)
        };
        let* _      = CsvIO/CsvWriter.outputColumnIndexedCsv!(fmt2, FlixSandbox/Text/Charset.utf_8(), outpath, 2, writer, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok()      


    @test
    def test03(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO/CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto, setHeaders, setSkipHeaderRecord};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out-utf8-bom.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
        let* fmt1    = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto() *> setSkipHeaderRecord(true), r1)
        };        
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(fmt1, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let* fmt2   = region r1 {
            toCsvFormatWithCsvFormat(CsvIO/CsvFormat.makeCsvFormat(DEFAULT), setHeaders("Short" :: "Long" :: Nil) *> setSkipHeaderRecord(true), r1)
        };        
        let* _      = CsvIO/CsvWriter.outputColumnIndexedCsvWithBOM!(fmt2, FlixSandbox/Text/Charset.utf_8(), outpath, 2, writer, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok() 
        

}
