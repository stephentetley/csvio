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
    
    use System.FilePath.{FilePath};
    use Text.Charset.{Charset};

    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};

    ///
    /// Represents a CSV row.
    ///
    type alias CsvRow = ##flix.runtime.spt.csvio.InputRow


    ///
    /// Returns a new Csv Cursor.
    ///
    pub def newCsvCursor(path: System.FilePath,
                        format: CsvFormat,
                        cs: Text.Charset): Cursor[String, CsvRow] & Impure =
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
                , next = Cursor.guardThunk(_ -> ffiNext(iter), "next failed")
                , finalize = () -> ffiClose(iter)
            };
            Cursor.makeCursor(cursorIter)
        } catch {
            case _: ##java.io.FileNotFoundException => Cursor.failure("newCsvCursor - file not found")
            case _: ##java.io.IOException => Cursor.failure("newCsvCursor")
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
                , next = Cursor.guardThunk(_ -> ffiNext(iter), "next failed")
                , finalize = () -> ffiClose(iter)
            };
            Cursor.makeCursor(cursorIter)
        } catch {
            case _: ##java.io.FileNotFoundException => Cursor.failure("newCsvCursorWithBOM - file not found")
            case _: ##java.io.IOException => Cursor.failure("newCsvCursorWithBOM - io exception")
        }
}