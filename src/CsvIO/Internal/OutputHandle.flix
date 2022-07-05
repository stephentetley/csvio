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

    /// TODO Add a region...
    pub enum OutputHandle[_: Region](##flixspt.csvio.CsvWriter)

    instance Scoped[OutputHandle] {
        pub def regionOf(_: OutputHandle[r]): Region[r] = () as Region[r]
    }


}


namespace CsvIO/Internal/OutputHandle {

    use FlixSandbox/System.FilePath.{FilePath};
    
    use Text.Charset.{Charset};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle};

    ///
    /// Returns a new Output handle.
    ///
    pub def makeOutputHandle(_: Region[r], 
                            format: ##org.apache.commons.csv.CSVFormat,
                            cs: Text.Charset, 
                            path: FlixSandbox/System.FilePath): Result[OutputHandle[r], String] & Impure =
        import static flixspt.csvio.CsvWriter.createCsvWriter(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, ##java.nio.charset.Charset): ##flixspt.csvio.CsvWriter & Impure;
        use Result.flatMap;
        try {
            let FilePath(path1) = path;
            let Charset(cs1) = cs;
            let ans = OutputHandle(createCsvWriter(path1, format, cs1));
            Ok(ans)
        } catch {
            case _: ##java.lang.Exception => Err("new")
        }

    ///
    /// Returns a new Output handle with a BOM UTF_8, UTF_16LS and UTF_16BE only.
    ///
    pub def makeOutputHandleWithBOM(_: Region[r], 
                                    format: ##org.apache.commons.csv.CSVFormat, 
                                    cs: Text.Charset, 
                                    path: FlixSandbox/System.FilePath): Result[OutputHandle[r], String] & Impure =
        import static flixspt.csvio.CsvWriter.createCsvWriterWithBOM(##java.nio.file.Path, ##org.apache.commons.csv.CSVFormat, ##java.nio.charset.Charset): ##flixspt.csvio.CsvWriter & Impure;
        use Result.flatMap;
        try {
            let FilePath(path1) = path;
            let Charset(cs1) = cs;
            let ans: OutputHandle[r] = OutputHandle(createCsvWriterWithBOM(path1, format, cs1));
            Ok(ans)
        } catch {
            case _: ##java.lang.Exception => Err("newWithBOM")
        }

    ///
    /// Close the CSV output stream.
    ///
    /// Fully Impure - closes a file handle
    pub def close!(x: OutputHandle[r]): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.close(): Unit & Impure;
        try {
            let OutputHandle(x1) = x;
            close(x1);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("close!")
        }


    pub def writeRow!(xs: List[String], x: OutputHandle[r]): Result[Unit, String] & Impure =
        import flixspt.csvio.CsvWriter.writeRowOfObjects(##java.util.ArrayList): Unit & Impure;
        let step = l -> match l {
            case x1 :: rs => Some((x1 as ##java.lang.Object, rs))
            case Nil      => None
        };
        try {
            let OutputHandle(out1) = x;
            let arrlist = FlixSandbox/Marshal.unfoldArrayList(step, xs);
            let _ = writeRowOfObjects(out1, arrlist);
            Ok()
        } catch {
            case _: ##java.lang.Exception => Err("setCellString!")
        }

}
