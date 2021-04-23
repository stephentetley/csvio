
def main(_args: Array[String]): Int32 & Impure = 
    Console.printLine("Running...");
    test01();
    0

def test01(): Result[Unit, String] & Impure = 
    use Result.flatMap;
    use CsvIO/RowEvaluator.{tuple2, getStringNamed};
    use CsvIO/CsvFormat.{withFirstRecordAsHeader};
    let path    = System/FilePath.new("E://coding/flix/csvio/data/compass.csv");
    let eval    = tuple2(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation"));
    let cursor  = CsvIO/CsvReader.newCsvCursor(path, withFirstRecordAsHeader(CsvIO/CsvFormat.defaultFormat()), Text/Charset.utf_8());
    let* _      = Cursor.foreach!(CsvIO/RowEvaluator.runRowEvaluator(eval) >> println, cursor);
    Ok()