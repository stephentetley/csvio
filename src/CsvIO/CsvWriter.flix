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
    /// TODO switch to iterator rather than list
    ///
    pub def outputCsv(format: CsvFormat,
                        cs: Text.Charset,
                        path: FlixSandbox/System.FilePath,
                        makeRow: a -> List[String] & ef,
                        rows: List[a]): Result[Unit, String] & Impure =
        use Result.flatMap;
        region r1 {
            let CsvFormat(format1) = format;
            let* handle = CsvIO/Internal/OutputHandle.makeOutputHandle(format1, cs, path, r1);
            let* _      = Result.traverseX(row -> {let cells = makeRow(row); CsvIO/Internal/OutputHandle.writeRow!(cells, handle)}, rows);
            let* _      = CsvIO/Internal/OutputHandle.close!(handle);
            Ok()
        }


    pub def outputCsvWithBOM(format: CsvFormat,
                        cs: Text.Charset,
                        path: FlixSandbox/System.FilePath,
                        makeRow: a -> List[String] & ef,
                        rows: List[a]): Result[Unit, String] & Impure =
        use Result.flatMap;
        let CsvFormat(format1) = format;
        region r1 {
            let* handle = CsvIO/Internal/OutputHandle.makeOutputHandleWithBOM(format1, cs, path, r1);
            let* _      = Result.traverseX(row -> {let cells = makeRow(row); CsvIO/Internal/OutputHandle.writeRow!(cells, handle)}, rows);
            let* _      = CsvIO/Internal/OutputHandle.close!(handle);
            Ok()
        }





}
