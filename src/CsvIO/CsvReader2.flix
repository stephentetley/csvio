/*
 * Copyright 2022 Stephen Tetley
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


namespace CsvIO/CsvReader2 {
    
    use Interop/System.FilePath;
    use Interop/System.FilePath.{FilePath};
    use Interop/Text.Charset;
    use Interop/Text.Charset.{Charset};

    use CsvIO.CsvFormat;
    use CsvIO.CsvRecordEvaluator;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO/Internal.CSVFormat.{CSVFormat};



    /// To use Flix's stdlib Iterator we need to retain a handle
    /// so we can close it.
    /// 
    pub enum CsvReadHandle[r: Region, a: Type]((CsvIO/Internal.CSVParser[r], Iterator[Result[a, String], r]))

    pub def getIterator(handle: CsvReadHandle[r, a]): Iterator[Result[a, String], r] = 
        let CsvReadHandle((_, i1)) = handle;
        i1

    pub def close(handle: CsvReadHandle[r, a]): Result[Unit, String] \ Write(r) = 
        let CsvReadHandle((x1, _)) = handle;
        CsvIO/Internal/CSVParser.close(x1)




    ///
    /// Returns a new Csv Handle (iterator x a "close" handle).
    ///
    pub def newCsvReadHandle(r: Region[r], 
                            format: CsvFormat,
                            cs: Charset,
                            eval: CsvRecordEvaluator[r, a, a], 
                            path: FilePath): Result[CsvReadHandle[r, a], String] \ { Read(r), IO } =
        use Result.{flatMap};
        try {
            import java.nio.file.Path.toFile(): ##java.io.File \ IO;
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let Charset(cs1) = cs;
            let file1   = toFile(path1);
            let* ins = Interop/IO/FileInputStream.newFileInputStream(r, file1);
            let reader = Interop/IO/InputStreamReader.newInputStreamReader(r, ins, cs1);
            let* parser = CsvIO/Internal/CSVFormat.parse(reader, CSVFormat(fmt1));
            let iter1 = CsvIO/Internal/CSVParser.iterator(parser);
            let iterDone = () -> Iterator.isEmpty(iter1);
            let iterNext = () -> {
                try {
                    match Iterator.next(iter1) { 
                        case None      => Err("Done")
                        case Some(row) => CsvIO/CsvRecordEvaluator.runCsvRecordEvaluator(r, eval, row)
                    }
                } catch {
                    case _: ##java.lang.Exception => Err("csvReadIterBOM[next]")
                }
            };
            let iter2 = Iterator(iterDone, iterNext);
            let hdl = CsvReadHandle((parser, iter2));
            Ok(hdl)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))           
        }


    pub def readCsv(r: Region[r], 
                    format: CsvFormat,
                    charset: Charset,
                    eval: CsvRecordEvaluator[r, a, a], 
                    path: FilePath): Result[List[a], String] & Impure =
        use Result.flatMap;
        let* hdl    = newCsvReadHandle(r, format, charset, eval, path);
        let iter    = getIterator(hdl);
        let* xs     = Iterator.toList(iter) |> Result.sequence;
        let* _      = close(hdl);
        Ok(xs)


    /// ///
    /// /// Returns a new Csv Handle (iterator x close handle).
    /// ///
    /// pub def newCsvReadHandleWithBOM(r: Region[r], 
    ///                                 format: CsvFormat,
    ///                                 eval: CsvRecordEvaluator[r, a, a], 
    ///                                 path: FilePath): Result[CsvReadHandle[r, a], String] \ { Read(r), Impure } =
    ///     import static flixspt.csvio.ReadIterator.createIterForBOMFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat): ##flixspt.csvio.ReadIterator & Impure;
    ///     import flixspt.csvio.ReadIterator.hasNext(): Bool & r;
    ///     import flixspt.csvio.ReadIterator.next(): ##org.apache.commons.csv.CSVRecord & r;
    ///     try {
    ///         let FilePath(path1) = path;
    ///         let CsvFormat(fmt1) = format;
    ///         let primIter = createIterForBOMFile(path1, fmt1);
    ///         let iterDone = () -> if (hasNext(primIter)) false else true;
    ///         let iterNext = () -> {
    ///             try {
    ///                 let row = next(primIter);
    ///                 CsvIO/CsvRecordEvaluator.runCsvRecordEvaluator(r, eval, row)
    ///             } catch {
    ///                 case _: ##java.lang.Exception => Err("csvReadIterBOM[next]")
    ///             }
    ///         };
    ///         let iter1 = Iterator(iterDone, iterNext);
    ///         let hdl = CsvReadHandle((primIter, iter1));
    ///         Ok(hdl)
    ///     } catch {
    ///         case _: ##java.lang.Exception => Err("newCsvReadHandleWithBOM")            
    ///     }



}
