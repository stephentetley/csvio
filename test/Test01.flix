
mod Test01 {

    use IOError.{Generic}
    use GradedApplicative.{*>}


    @test
    def test01(): Result[IOError, Unit] \ IO = 
        use Result.flatMap;
        use CsvIO.CsvRecordEvaluator.{getStringNamed};
        use CsvIO.CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO.CsvFormatBuilder.{setHeaders!, setSkipHeaderRecord!};
        region r1 {
            forM (path      <- Basis.IO.Path.new("E://coding/flix/csvio/data/compass.csv")  |> Result.mapErr(Generic);
                    eval    <- Ok(GradedApplicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation")));
                    fmt     <- CsvIO.CsvFormatBuilder.toCsvFormat(r1, setHeaders!("Cardinal direction" :: "Abbreviation" :: Nil) *> setSkipHeaderRecord!(true)) |> Result.mapErr(Generic);
                    hdl     <- CsvIO.CsvReader.newCsvReadHandle(r1, fmt, Charset.utf_8(), eval, path);
                    iter    <- Ok(CsvIO.CsvReader.getIterator(hdl));
                    _       <- Ok(Iterator.forEach(ans -> println("test01: ${ans}"), iter));
                    _       <- CsvIO.CsvReader.close!(hdl)  |> Result.mapErr(Generic))
            yield ()
        }
    
    @test
    def test02(): Result[IOError, Unit] \ IO = 
        use Result.flatMap;
        use CsvIO.CsvRecordEvaluator.{getStringNamed};
        use CsvIO.CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO.CsvFormatBuilder.{setHeaders!, setSkipHeaderRecord!};
        region r1 {
            forM (path      <- Basis.IO.Path.new("E://coding/flix/csvio/data/compass-utf8-bom.csv") |> Result.mapErr(Generic);
                    eval    <- Ok(GradedApplicative.product(getStringNamed("Short"), getStringNamed("Long")));
                    fmt     <- CsvIO.CsvFormatBuilder.toCsvFormat(r1, setHeaders!("Short" :: "Long" :: Nil) *> setSkipHeaderRecord!(true)) |> Result.mapErr(Generic);
                    hdl     <- CsvIO.CsvReader.newCsvReadHandleWithBOM(r1, fmt, eval, path);
                    iter    <- Ok(CsvIO.CsvReader.getIterator(hdl));
                    _       <- Ok(Iterator.forEach(ans -> println("test02: ${ans}"), iter));
                    _       <- CsvIO.CsvReader.close!(hdl) |> Result.mapErr(Generic))
            yield ()
        }

    @test
    def test03(): Result[IOError, Unit] \ IO = 
        use Result.flatMap;
        use CsvIO.CsvRecordEvaluator.{getStringNamed};
        use CsvIO.CsvFormat.PredefinedFormat.{DEFAULT};
        use CsvIO.CsvFormatBuilder.{toCsvFormatWithCsvFormat, setHeaderAuto!, setHeaders!};
        region r1 {
            let toCells = xy -> {let (x, y) = xy; y :: x :: Nil};  /// Flip 
            forM (path      <- Basis.IO.Path.new("E://coding/flix/csvio/data/compass.csv") |> Result.mapErr(Generic);
                    outpath <- Basis.IO.Path.new("E://coding/flix/csvio/data/compass-out.csv") |> Result.mapErr(Generic);
                    eval    <- Ok(GradedApplicative.product(getStringNamed("Cardinal direction"), getStringNamed("Abbreviation")));
                    fmt1    <- toCsvFormatWithCsvFormat(r1, CsvIO.CsvFormat.makeCsvFormat(DEFAULT), setHeaderAuto!()) |> Result.mapErr(Generic);
                    src     <- CsvIO.CsvReader.readCsv(r1, fmt1, Charset.utf_8(), eval, path);
                    fmt2    <- toCsvFormatWithCsvFormat(r1, CsvIO.CsvFormat.makeCsvFormat(DEFAULT), setHeaders!("Short" :: "Long" :: Nil)) |> Result.mapErr(Generic);
                    _       <- CsvIO.CsvWriter.outputCsv(fmt2, Charset.utf_8(), outpath, toCells, src))            
            yield ()
        }
       
}
