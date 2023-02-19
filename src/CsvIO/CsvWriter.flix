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


namespace CsvIO/CsvWriter {
    
    use Basis/NIO/File.Path;
    use Basis/NIO/Charset.Charset;

    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use Interop/Apache/Commons/Csv.CSVFormat.{CSVFormat};


    ///
    /// outputIndexedCsv.
    /// TODO switch to iterator rather than list
    ///
    pub def outputCsv(format: CsvFormat,
                        cs: Charset,
                        path: Path,
                        makeRow: a -> List[String] \ ef,
                        rows: List[a]): Result[String, Unit] \ {IO, ef} =
        use Result.flatMap;
        region r1 {
            let CsvFormat(format1) = format;
            let* file1      = Basis/NIO/File/Path.toFile(r1, path);
            let* fos        = Interop/IO/FileOutputStream.newWithFile(file1);
            let writer      = Interop/IO/OutputStreamWriter.newOutputStreamWriter(fos |> Interop/IO/SubOutputStream.toOutputStream, cs);
            let* printer    = Interop/Apache/Commons/Csv/CSVPrinter.newCSVPrinter(writer, CSVFormat(format1));
            let* _          = Result.traverseX(row -> {let cells = makeRow(row); Interop/Apache/Commons/Csv/CSVPrinter.printRecord!(cells, printer)}, rows);
            let* _          = Interop/Apache/Commons/Csv/CSVPrinter.close!(printer);
            Ok()
        }


    /// pub def outputCsvWithBOM(format: CsvFormat,
    ///                     cs: Charset,
    ///                     path: FilePath,
    ///                     makeRow: a -> List[String] \ ef,
    ///                     rows: List[a]): Result[String, Unit] \ IO =
    ///     use Result.flatMap;
    ///     let CsvFormat(format1) = format;
    ///     region r1 {
    ///         let* handle = Interop/Apache/Commons/Csv/OutputHandle.makeOutputHandleWithBOM(r1, format1, cs, path);
    ///         let* _      = Result.traverseX(row -> {let cells = makeRow(row); Interop/Apache/Commons/Csv/OutputHandle.writeRow!(cells, handle)}, rows);
    ///         let* _      = Interop/Apache/Commons/Csv/OutputHandle.close!(handle);
    ///         Ok()
    ///     }





}
