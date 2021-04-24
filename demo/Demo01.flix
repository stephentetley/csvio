
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    test01();
    test02();
    test03();
    0

def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{withFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let cursor  = CsvIO/CsvReader.newCsvCursor(withFirstRecordAsHeader(CsvIO/CsvFormat.defaultFormat()), Text/Charset.utf_8(), eval, path);
    let* _      = Cursor.foreach!(println, cursor);
    Ok()


def test02(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{withFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let outpath    = System/FilePath.new("E://coding/flix/csvio/data/compass-out.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
    let cursor  = CsvIO/CsvReader.newCsvCursor(withFirstRecordAsHeader(CsvIO/CsvFormat.defaultFormat()), Text/Charset.utf_8(), eval, path);
    let* _      = CsvIO/CsvWriter.outputColumnIndexedCsv!(CsvIO/CsvFormat.defaultFormat(), Text/Charset.utf_8(), outpath, 2, writer, cursor);
    Ok()    


def test03(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{withFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let outpath    = System/FilePath.new("E://coding/flix/csvio/data/compass-out-utf8-bom.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let writer  = xy -> {let (x, y) = xy; CsvIO/CsvWriter.row2(y, x)};  /// Flip 
    let cursor  = CsvIO/CsvReader.newCsvCursor(withFirstRecordAsHeader(CsvIO/CsvFormat.defaultFormat()), Text/Charset.utf_8(), eval, path);
    let* _      = CsvIO/CsvWriter.outputColumnIndexedCsvWithBOM!(CsvIO/CsvFormat.defaultFormat(), Text/Charset.utf_8(), outpath, 2, writer, cursor);
    Ok() 
    