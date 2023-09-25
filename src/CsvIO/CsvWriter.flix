/*
 * Copyright 2021 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


mod CsvIO.CsvWriter {
    
    use Basis.IO.Path

    use Interop.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    use CsvIO.CsvFormat
    use CsvIO.CsvFormat.{CsvFormat}


    ///
    /// outputIndexedCsv.
    /// TODO switch to iterator rather than list
    ///
    pub def outputCsv(format: CsvFormat,
                        cs: Charset,
                        path: Path,
                        makeRow: a -> List[String] \ ef,
                        rows: List[a]): Result[IOError, Unit] \ {IO, ef} =
        use Result.flatMap;
        region rc {
            let CsvFormat(format1) = format;
            forM (fos       <- Basis.IO.FileOutputStream.new(path) |> CsvIO.Util.errIOError;
                    outs    <- Ok(Basis.IO.FileOutputStream.asOutputStream(fos));
                    writer  <- Ok(Basis.IO.OutputStreamWriter.newWithCharset(cs, outs));
                    printer <- Interop.Apache.Commons.Csv.CSVPrinter.newCSVPrinter(rc, writer, CSVFormat(format1)) |> CsvIO.Util.errIOError;
                    _       <- Result.traverseX(row -> {let cells = makeRow(row); Interop.Apache.Commons.Csv.CSVPrinter.printRecord!(cells, printer) |> CsvIO.Util.errIOError}, rows);
                    _       <- Interop.Apache.Commons.Csv.CSVPrinter.close!(printer)  |> CsvIO.Util.errIOError)
            yield ()
        }


    /// pub def outputCsvWithBOM(format: CsvFormat,
    ///                     cs: Charset,
    ///                     path: FilePath,
    ///                     makeRow: a -> List[String] \ ef,
    ///                     rows: List[a]): Result[String, Unit] \ IO =
    ///     use Result.flatMap;
    ///     let CsvFormat(format1) = format;
    ///     region r1 {
    ///         let* handle = Interop.Apache.Commons.Csv.OutputHandle.makeOutputHandleWithBOM(r1, format1, cs, path);
    ///         let* _      = Result.traverseX(row -> {let cells = makeRow(row); Interop.Apache.Commons.Csv.OutputHandle.writeRow!(cells, handle)}, rows);
    ///         let* _      = Interop.Apache.Commons.Csv.OutputHandle.close!(handle);
    ///         Ok()
    ///     }





}
