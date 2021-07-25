
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    test01();
    test02();
    test03();
    0

def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{putFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let* hdl    = CsvIO/CsvReader.newCsvReadHandle(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, Text/Charset.utf_8(), eval, path);
    let iter1   = CsvIO/CsvReader.getIterator(hdl);
    let _       = Iterator.foreach(println, iter1);
    let* _      = CsvIO/CsvReader.close(hdl);
    Ok()


/// TODO change to use iterator
def test02(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{putFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let outpath    = System/FilePath.new("E://coding/flix/csvio/data/compass-out.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
    let cursor  = CsvIO/CsvReader.newCsvCursor(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, Text/Charset.utf_8(), eval, path);
    let* _      = CsvIO/CsvWriter.outputColumnIndexedCsv!(CsvIO/CsvFormat.defaultFormat(Some(["Short", "Long"])), Text/Charset.utf_8(), outpath, 2, writer, cursor);
    Ok()      


/// TODO change to use iterator
def test03(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{putFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let outpath    = System/FilePath.new("E://coding/flix/csvio/data/compass-out-utf8-bom.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
    let cursor  = CsvIO/CsvReader.newCsvCursor(CsvIO/CsvFormat.defaultFormat(None) |> putFirstRecordAsHeader, Text/Charset.utf_8(), eval, path);
    let* _      = CsvIO/CsvWriter.outputColumnIndexedCsvWithBOM!(CsvIO/CsvFormat.defaultFormat(Some(["Short", "Long"])), Text/Charset.utf_8(), outpath, 2, writer, cursor);
    Ok() 
    