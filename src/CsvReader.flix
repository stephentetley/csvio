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
    
    use X.Cursor;
    use System.FilePath.{FilePath};
    use Text.Charset.{Charset};

    use CsvIO.CsvFormat;
    use CsvIO.RowEvaluator;
    use CsvIO.CsvFormat.{CsvFormat};

    ///
    /// Represents a CSV row.
    ///
    type alias CsvRow = ##flix.runtime.spt.csvio.InputRow


    /// TODO 
    /// To change to Flix's builtin iterator we need to retain a handle
    /// so we can close it.

    pub opaque type CsvReadHandle[a] = (##flix.runtime.spt.csvio.ReadCursor, Iterator[Result[a, String]])

    pub def close(handle: CsvReadHandle[a]): Result[Unit, String] & Impure = 
        import flix.runtime.spt.csvio.ReadCursor.close();
        let CsvReadHandle((x1, _)) = handle;
        try {
            close(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("close")
        }

    pub def getIterator(handle: CsvReadHandle[a]): Iterator[Result[a, String]] = 
        let CsvReadHandle((_, i1)) = handle;
        i1



    ///
    /// Returns a new Csv Handle (iterator x close handle).
    ///
    pub def newCsvReadHandle(format: CsvFormat,
                            cs: Text.Charset,
                            eval: RowEvaluator[a], 
                            path: System.FilePath): Result[CsvReadHandle[a], String] & Impure =
        import flix.runtime.spt.csvio.ReadCursor:createCursorForFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, ##java.nio.charset.Charset);
        import flix.runtime.spt.csvio.ReadCursor.hasNext();
        import flix.runtime.spt.csvio.ReadCursor.next();        
        try {
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let Charset(cs1) = cs;
            let primIter = createCursorForFile(path1, fmt1, cs1);
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
    /// DEPRECATED
    /// Returns a new Csv Cursor.
    ///
    pub def newCsvCursor(format: CsvFormat,
                        cs: Text.Charset,
                        eval: RowEvaluator[a], 
                        path: System.FilePath): Cursor[String, a] & Impure =
        import flix.runtime.spt.csvio.ReadCursor:createCursorForFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, ##java.nio.charset.Charset);
        import flix.runtime.spt.csvio.ReadCursor.hasNext() as ffiHasNext;
        import flix.runtime.spt.csvio.ReadCursor.next() as ffiNext;
        import flix.runtime.spt.csvio.ReadCursor.close() as ffiClose;
        try {
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let Charset(cs1) = cs;
            let iter = createCursorForFile(path1, fmt1, cs1);
            let cursorIter =  {
                  hasNext = () -> ffiHasNext(iter)
                , next = X/Cursor.guardThunk(_ -> ffiNext(iter), "next failed")
                , finalize = () -> ffiClose(iter)
            };
            X/Cursor.makeCursor(cursorIter) |> X/Cursor.mapResult(CsvIO/RowEvaluator.runRowEvaluator(eval))
        } catch {
            case _: ##java.io.FileNotFoundException => X/Cursor.failure("newCsvCursor - file not found")
            case _: ##java.io.IOException => X/Cursor.failure("newCsvCursor")
        }


    ///
    /// Returns a new Csv Cursor from a file with a BOM.
    ///
    pub def newCsvCursorWithBOM(path: System.FilePath,
                                format: CsvFormat): Cursor[String, CsvRow] & Impure =
        import flix.runtime.spt.csvio.ReadCursor:createCursorForBOMFile(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat);
        import flix.runtime.spt.csvio.ReadCursor.hasNext() as ffiHasNext;
        import flix.runtime.spt.csvio.ReadCursor.next() as ffiNext;
        import flix.runtime.spt.csvio.ReadCursor.close() as ffiClose;
        try {
            let FilePath(path1) = path;
            let CsvFormat(fmt1) = format;
            let iter = createCursorForBOMFile(path1, fmt1);
            let cursorIter =  {
                  hasNext = () -> ffiHasNext(iter)
                , next = X/Cursor.guardThunk(_ -> ffiNext(iter), "next failed")
                , finalize = () -> ffiClose(iter)
            };
            X/Cursor.makeCursor(cursorIter)
        } catch {
            case _: ##java.io.FileNotFoundException => X/Cursor.failure("newCsvCursorWithBOM - file not found")
            case _: ##java.io.IOException => X/Cursor.failure("newCsvCursorWithBOM - io exception")
        }
}
