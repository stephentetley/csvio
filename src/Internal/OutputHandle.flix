/*
 * Copyright 2020 Stephen Tetley
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


namespace CsvIO/Internal {

    pub opaque type OutputHandle = ##flix.runtime.spt.csvio.CsvWriter
}

namespace CsvIO/Internal/OutputHandle {

    use Text.Charset.{Charset};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle};

    ///
    /// Returns a new Output handle.
    ///
    pub def new(format: ##org.apache.commons.csv.CSVFormat, columnCount: Int32, cs: Text.Charset, path: System.FilePath): Option[OutputHandle] & Impure =
        import new flix.runtime.spt.csvio.CsvWriter(String, ##org.apache.commons.csv.CSVFormat, Int32, ##java.nio.charset.Charset) as newCsvOutput;
        use Result.flatMap;
        try {
            let Charset(cs1) = cs;
            let ans = OutputHandle(newCsvOutput(ToString.toString(path), format, columnCount, cs1));
            Some(ans)
        } catch {
            case _: ##java.lang.Exception => None
        }

    ///
    /// Close the CSV output stream.
    ///
    pub def close!(x: OutputHandle): Result[Unit, String] & Impure =
        import flix.runtime.spt.csvio.CsvWriter.close();
        try {
            let OutputHandle(x1) = x;
            close(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("close!")
        }


    pub def clearCells!(x: OutputHandle): Result[Unit, String] & Impure =
        import flix.runtime.spt.csvio.CsvWriter.clearCells();
        try {
            let OutputHandle(x1) = x;
            let _ = clearCells(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("clearCells!")
        }

    pub def setCellString!(x: OutputHandle, ix: Int32, value: String): Result[Unit, String] & Impure =
        import flix.runtime.spt.csvio.CsvWriter.setCellString(Int32, String);
        try {
            let OutputHandle(x1) = x;
            let _ = setCellString(x1, ix, value);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("setCellString!")
        }

    pub def writeRow!(x: OutputHandle): Result[Unit, String] & Impure =
        import flix.runtime.spt.csvio.CsvWriter.writeRow();
        try {
            let OutputHandle(x1) = x;
            let _ = writeRow(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("setCellString!")
        }

}
