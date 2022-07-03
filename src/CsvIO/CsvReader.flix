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


namespace CsvIO/CsvReader {
    
    use FlixSandbox/System.FilePath.{FilePath};
    
    use Text.Charset.{Charset};

    use CsvIO.CsvFormat;
    use CsvIO.RowEvaluator;
    use CsvIO.CsvFormat.{CsvFormat};

    ///
    /// Represents a CSV row.
    ///
    type alias CsvRow = ##flixspt.csvio.InputRow


    /// To use Flix's stdlib Iterator we need to retain a handle
    /// so we can close it.

    pub enum CsvReadHandle[a]((##flixspt.csvio.ReadIterator, Iterator[Result[a, String], Static]))

    pub def close(handle: CsvReadHandle[a]): Result[Unit, String] & Impure = 
        import flixspt.csvio.ReadIterator.close(): Unit & Impure;
        let CsvReadHandle((x1, _)) = handle;
        try {
            close(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("close")
        }

    pub def getIterator(handle: CsvReadHandle[a]): Iterator[Result[a, String], Static] = 
        let CsvReadHandle((_, i1)) = handle;
        i1



    ///
    /// Returns a new Csv Handle (iterator x a "close" handle).
    ///
    pub def newCsvReadHandle(format: CsvFormat,
                            cs: Text.Charset,
                            eval: RowEvaluator[a], 
                            path: FlixSandbox/System.FilePath): Result[CsvReadHandle[a], String] & Impure =
        import static flixspt.csvio.ReadIterator.createIterForFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, ##java.nio.charset.Charset): ##flixspt.csvio.ReadIterator & Impure;
        import flixspt.csvio.ReadIterator.hasNext(): Bool & Impure;
        import flixspt.csvio.ReadIterator.next(): ##flixspt.csvio.InputRow & Impure;
        try {
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let Charset(cs1) = cs;
            let primIter = createIterForFile(path1, fmt1, cs1);
            let iterDone = () -> if (hasNext(primIter)) false else true;
            let iterNext = () -> {
                try {
                    let row = next(primIter);
                    CsvIO/RowEvaluator.runRowEvaluator(eval, row)
                } catch {
                    case _: ##java.lang.Exception => Err("csvReadIter[next]")
                }
            };
            let iter1 = Iterator(iterDone, iterNext);
            let hdl = CsvReadHandle((primIter, iter1));
            Ok(hdl)
        } catch {
            case _: ##java.lang.Exception => Err("newCsvReadHandle")            
        }


    ///
    /// Returns a new Csv Handle (iterator x close handle).
    ///
    pub def newCsvReadHandleWithBOM(format: CsvFormat,
                                    eval: RowEvaluator[a], 
                                    path: FlixSandbox/System.FilePath): Result[CsvReadHandle[a], String] & Impure =        
        import static flixspt.csvio.ReadIterator.createIterForBOMFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat): ##flixspt.csvio.ReadIterator & Impure;
        import flixspt.csvio.ReadIterator.hasNext(): Bool & Impure;
        import flixspt.csvio.ReadIterator.next(): ##flixspt.csvio.InputRow & Impure;
        try {
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let primIter = createIterForBOMFile(path1, fmt1);
            let iterDone = () -> if (hasNext(primIter)) false else true;
            let iterNext = () -> {
                try {
                    let row = next(primIter);
                    CsvIO/RowEvaluator.runRowEvaluator(eval, row)
                } catch {
                    case _: ##java.lang.Exception => Err("csvReadIterBOM[next]")
                }
            };
            let iter1 = Iterator(iterDone, iterNext);
            let hdl = CsvReadHandle((primIter, iter1));
            Ok(hdl)
        } catch {
            case _: ##java.lang.Exception => Err("newCsvReadHandleWithBOM")            
        }


    pub def readCsv(format: CsvFormat,
                    charset: Text.Charset,
                    eval: RowEvaluator[a], 
                    path: FlixSandbox/System.FilePath): Result[List[a], String] & Impure =
        use Result.flatMap;
        let* hdl    = newCsvReadHandle(format, charset, eval, path);
        let iter    = getIterator(hdl);
        let* xs     = Iterator.toList(iter) |> Result.sequence;
        let* _      = close(hdl);
        Ok(xs)

}
