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


namespace CsvIO/CsvReader {
    
    use Basis/NIO/File.Path
    use Basis/NIO/Charset.Charset

    use Interop/Apache/Commons/Csv.CSVFormat.{CSVFormat}
    use CsvIO.CsvFormat
    use CsvIO.CsvRecordEvaluator
    use CsvIO.CsvFormat.{CsvFormat}
    use CsvIO/CsvReader.CsvReadHandle
    use CsvIO/CsvReader.CsvReadHandle.{CsvReadHandle}


    /// To use Flix's stdlib Iterator we need to retain a handle
    /// so we can close it.
    /// 
    pub enum CsvReadHandle[r: Region, ef: Bool, a: Type]((Interop/Apache/Commons/Csv.CSVParser[r], Iterator[Result[String, a], ef, r]))

    pub def getIterator(handle: CsvReadHandle[r, ef, a]): Iterator[Result[String, a], ef, r] = 
        let CsvReadHandle((_, i1)) = handle;
        i1

    pub def close!(handle: CsvReadHandle[r, ef, a]): Result[String, Unit] \ Write(r) = 
        let CsvReadHandle((x1, _)) = handle;
        Interop/Apache/Commons/Csv/CSVParser.close!(x1)




    ///
    /// Returns a new Csv Handle (iterator and a "close" handle).
    ///
    pub def newCsvReadHandle(rc: Region[r], 
                            format: CsvFormat,
                            cs: Charset,
                            eval: CsvRecordEvaluator[a, ef, a], 
                            path: Path): Result[String, CsvReadHandle[r, r and ef, a]] \ { Read(r), Write(r), IO } =
        use Result.{flatMap};
        try {
            let CsvFormat(fmt1) = format;
            let* file1      = Basis/NIO/File/Path.toFile(rc, path);
            let* ins        = Interop/IO/FileInputStream.newWithFile(rc, file1) |> Result.map(Interop/IO/SubInputStream.toInputStream);
            let reader      = Interop/IO/InputStreamReader.newInputStreamReader(rc, ins, cs);
            let* parser     = Interop/Apache/Commons/Csv/CSVFormat.parse(rc, reader, CSVFormat(fmt1));
            let iter1       = Interop/Apache/Commons/Csv/CSVParser.iterator(rc, parser);
            let iter2       = Iterator.map(row -> CsvIO/CsvRecordEvaluator.runCsvRecordEvaluator(eval, Interop/Apache/Commons/Csv/CSVRecord.wrapHH(row)), iter1);
            let hdl         = CsvReadHandle((parser, iter2));
            Ok(hdl)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))           
        }


    pub def readCsv(r: Region[r], 
                    format: CsvFormat,
                    charset: Charset,
                    eval: CsvRecordEvaluator[a, ef, a], 
                    path: Path): Result[String, List[a]]  \ { ef, Read(r), Write(r), IO } =
        use Result.flatMap;
        let* hdl    = newCsvReadHandle(r, format, charset, eval, path);
        let iter    = getIterator(hdl);
        let* xs     = Iterator.toList(iter) |> Result.sequence;
        let* _      = close!(hdl);
        Ok(xs)


    ///
    /// Returns a new Csv Handle (iterator x a "close" handle).
    ///
    pub def newCsvReadHandleWithBOM(rc: Region[r], 
                            format: CsvFormat,
                            eval: CsvRecordEvaluator[a, ef, a], 
                            path: Path): Result[String, CsvReadHandle[r, r and ef, a]] \ { ef, Read(r), Write(r), IO } =
        use Result.{flatMap};
        try {
            let CsvFormat(fmt1) = format;
            let* file1      = Basis/NIO/File/Path.toFile(rc, path);
            let* ins        = Interop/IO/FileInputStream.newWithFile(rc, file1) |> Result.map(Interop/IO/SubInputStream.toInputStream);
            let bomIns      = Interop/Apache/Commons/IO/Input/BOMInputStream.new(rc, ins);
            let* csname     = Interop/Apache/Commons/IO/Input/BOMInputStream.getBOMCharsetName(bomIns);
            let csname1     = Option.getWithDefault("UTF-16", csname);
            let* cs1        = Basis/NIO/Charset/Charset.forName(csname1) |> Option.toOk("bad charset ${csname1}");
            let reader      = Interop/IO/InputStreamReader.newInputStreamReader(rc, ins, cs1);
            let* parser     = Interop/Apache/Commons/Csv/CSVFormat.parse(rc, reader, CSVFormat(fmt1));
            let iter1       = Interop/Apache/Commons/Csv/CSVParser.iterator(rc, parser);
            let iter2       = Iterator.map(row -> CsvIO/CsvRecordEvaluator.runCsvRecordEvaluator(eval, Interop/Apache/Commons/Csv/CSVRecord.wrapHH(row)), iter1);
            let hdl         = CsvReadHandle((parser, iter2));
            Ok(hdl)
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))           
        }



}
