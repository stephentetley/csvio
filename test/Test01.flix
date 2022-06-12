
namespace Test01 {


    @test
    def test01(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.{putFirstRecordAsHeader};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let _       = Iterator.foreach(println, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok()


    @test
    def test02(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.{putFirstRecordAsHeader};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let* _      = CsvIO/CsvWriter.outputColumnIndexedCsv!(CsvIO/CsvFormat.defaultFormat(Some(["Short", "Long"])), FlixSandbox/Text/Charset.utf_8(), outpath, 2, writer, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok()      


    @test
    def test03(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        use CsvIO/RowEvaluator.{getStringNamed};
        use CsvIO/CsvFormat.{putFirstRecordAsHeader};
        let path    = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass.csv");
        let outpath = FlixSandbox/System/FilePath.filePath("E://coding/flix/csvio/data/compass-out-utf8-bom.csv");
        let eval    = Applicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
        let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
        let* hdl    = CsvIO/CsvReader.newCsvReadHandle(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, FlixSandbox/Text/Charset.utf_8(), eval, path);
        let iter    = CsvIO/CsvReader.getIterator(hdl);
        let* _      = CsvIO/CsvWriter.outputColumnIndexedCsvWithBOM!(CsvIO/CsvFormat.defaultFormat(Some(["Short", "Long"])), FlixSandbox/Text/Charset.utf_8(), outpath, 2, writer, iter);
        let* _      = CsvIO/CsvReader.close(hdl);
        Ok() 
        

}
