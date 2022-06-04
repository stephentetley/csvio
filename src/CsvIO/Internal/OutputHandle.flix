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


namespace CsvIO/Internal {

    pub enum OutputHandle(##flixspt.csvio.CsvWriter)
}

namespace CsvIO/Internal/OutputHandle {

    use FlixSandbox/System.FilePath.{FilePath};
    use FlixSandbox/Text.Charset.{Charset};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle};

    ///
    /// Returns a new Output handle.
    ///
    pub def new(format: ##org.apache.commons.csv.CSVFormat, columnCount: Int32, cs: FlixSandbox/Text.Charset, path: FlixSandbox/System.FilePath): Result[OutputHandle, String] & Impure =
        import static flixspt.csvio.CsvWriter.createCsvWriter(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, Int32, ##java.nio.charset.Charset): ##flixspt.csvio.CsvWriter & Impure;
        use Result.flatMap;
        try {
            let FilePath(path1) = path;
            let Charset(cs1) = cs;
            let ans = OutputHandle(createCsvWriter(path1, format, columnCount, cs1));
            Ok(ans)
        } catch {
            case _: ##java.lang.Exception => Err("new")
        }

    ///
    /// Returns a new Output handle with a BOM UTF_8, UTF_16LS and UTF_16BE only.
    ///
    pub def newWithBOM(format: ##org.apache.commons.csv.CSVFormat, columnCount: Int32, cs: FlixSandbox/Text.Charset, path: FlixSandbox/System.FilePath): Result[OutputHandle, String] & Impure =
        import static flixspt.csvio.CsvWriter.createCsvWriterWithBOM(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, Int32, ##java.nio.charset.Charset): ##flixspt.csvio.CsvWriter & Impure;
        use Result.flatMap;
        try {
            let FilePath(path1) = path;
            let Charset(cs1) = cs;
            let ans = OutputHandle(createCsvWriterWithBOM(path1, format, columnCount, cs1));
            Ok(ans)
        } catch {
            case _: ##java.lang.Exception => Err("newWithBOM")
        }

    ///
    /// Close the CSV output stream.
    ///
    pub def close!(x: OutputHandle): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.close(): Unit & Impure;
        try {
            let OutputHandle(x1) = x;
            close(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("close!")
        }


    pub def clearCells!(x: OutputHandle): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.clearCells(): Unit & Impure;
        try {
            let OutputHandle(x1) = x;
            let _ = clearCells(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("clearCells!")
        }

    pub def setCellString!(x: OutputHandle, ix: Int32, value: String): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.setCellString(Int32, String): Unit & Impure;
        try {
            let OutputHandle(x1) = x;
            let _ = setCellString(x1, ix, value);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("setCellString!")
        }

    pub def writeRow!(x: OutputHandle): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.writeRow(): Unit & Impure;
        try {
            let OutputHandle(x1) = x;
            let _ = writeRow(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("setCellString!")
        }

}
