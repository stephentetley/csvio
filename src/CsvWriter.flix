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
    

    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO.RowSetter;
    use CsvIO/Internal.OutputHandle;

    ///
    /// outputIndexedCsv.
    /// TODO add optional headings 
    ///
    pub def outputColumnIndexedCsv!(format: CsvFormat,
                        cs: Text.Charset,
                        path: System.FilePath,
                        columnCount: Int32,
                        rowWriter: a -> RowSetter[b],
                        rows: Cursor[String, a]): Result[Unit, String] & Impure =
        use Result.flatMap;
        let CsvFormat(format1) = format;
        let* handle = CsvIO/Internal/OutputHandle.new(format1, columnCount, cs, path);
        let* _ = Cursor.foreachResult!(row -> writeRow(row, rowWriter, handle), rows);
        let* _ = CsvIO/Internal/OutputHandle.close!(handle);
        Ok()

    def writeRow(row: a, rowWriter: a -> RowSetter[b], handle: OutputHandle): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* _ = CsvIO/Internal/OutputHandle.clearCells!(handle);
        let* _ = CsvIO/RowSetter.runRowSetter!(rowWriter(row), handle);
        let* _ = CsvIO/Internal/OutputHandle.writeRow!(handle);
        Ok()

    pub def outputColumnIndexedCsvWithBOM!(format: CsvFormat,
                        cs: Text.Charset,
                        path: System.FilePath,
                        columnCount: Int32,
                        rowWriter: a -> RowSetter[b],
                        rows: Cursor[String, a]): Result[Unit, String] & Impure =
        use Result.flatMap;
        let CsvFormat(format1) = format;
        let* handle = CsvIO/Internal/OutputHandle.newWithBOM(format1, columnCount, cs, path);
        let* _ = Cursor.foreachResult!(row -> writeRow(row, rowWriter, handle), rows);
        let* _ = CsvIO/Internal/OutputHandle.close!(handle);
        Ok()

    /// TODO to N=15
    pub def row2(a: t1, b: t2): RowSetter[Unit] with ToString[t1], ToString[t2] = 
        use CsvIO/RowSetter.{flatMap, putItem!, return};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        return()
}
