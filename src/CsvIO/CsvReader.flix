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


mod CsvIO.CsvReader {
    
    use Basis.IO.Path
    

    use Interop.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    use CsvIO.CsvFormat
    use CsvIO.CsvRecordEvaluator
    use CsvIO.CsvFormat.{CsvFormat}
    use CsvIO.CsvReader.CsvReadHandle
    use CsvIO.CsvReader.CsvReadHandle.{CsvReadHandle}


    /// To use Flix's stdlib Iterator we need to retain a handle
    /// so we can close it.
    /// 
    pub enum CsvReadHandle[r: Region, ef: Eff, a: Type]((Interop.Apache.Commons.Csv.CSVParser[r], Iterator[Result[String, a], ef, r]))

    pub def getIterator(handle: CsvReadHandle[r, ef, a]): Iterator[Result[String, a], ef, r] = 
        let CsvReadHandle((_, i1)) = handle;
        i1

    pub def close!(handle: CsvReadHandle[r, ef, a]): Result[String, Unit] \ r = 
        let CsvReadHandle((x1, _)) = handle;
        Interop.Apache.Commons.Csv.CSVParser.close!(x1)




    ///
    /// Returns a new Csv Handle (iterator and a "close" handle).
    ///
    pub def newCsvReadHandle(rc: Region[r], 
                            format: CsvFormat,
                            cs: Charset,
                            eval: CsvRecordEvaluator[a, ef, a], 
                            path: Path): Result[IOError, CsvReadHandle[r, ef + r, a]] \ {IO, r} =
        let CsvFormat(fmt1) = format;
        forM (ins       <- Basis.IO.FileInputStream.new(path) |> Result.map(Basis.IO.FileInputStream.asInputStream);
                reader  <- Ok(Basis.IO.InputStreamReader.newWithCharset(cs, ins)) |> Result.map(Basis.IO.InputStreamReader.asReader);
                parser  <- Interop.Apache.Commons.Csv.CSVFormat.parse(rc, CSVFormat(fmt1), reader) |> CsvIO.Util.errIOError;
                iter1   <- Ok(Interop.Apache.Commons.Csv.CSVParser.iterator(rc, parser));
                iter2   <- Ok(Iterator.map(row -> CsvIO.CsvRecordEvaluator.runCsvRecordEvaluator(eval, Interop.Apache.Commons.Csv.CSVRecord.wrapHH(row)), iter1)))
        yield CsvReadHandle((parser, iter2))


    pub def readCsv(r: Region[r], 
                    format: CsvFormat,
                    charset: Charset,
                    eval: CsvRecordEvaluator[a, ef, a], 
                    path: Path): Result[IOError, List[a]]  \ {IO, r} =
        forM (hdl   <- newCsvReadHandle(r, format, charset, eval, path);
                iter  <- Ok(getIterator(hdl));
                xs    <- Iterator.toList(iter) |> Result.sequence |> CsvIO.Util.errIOError;
                _     <- close!(hdl) |> CsvIO.Util.errIOError)
        yield xs


    ///
    /// Returns a new Csv Handle (iterator x a "close" handle).
    ///
    pub def newCsvReadHandleWithBOM(rc: Region[r], 
                            format: CsvFormat,
                            eval: CsvRecordEvaluator[a, ef, a], 
                            path: Path): Result[IOError, CsvReadHandle[r, ef + r, a]] \ {ef, IO, r} =
        let CsvFormat(fmt1) = format;
        forM (ins       <- Basis.IO.FileInputStream.new(path) |> Result.map(Basis.IO.FileInputStream.asInputStream);
                bomIns  <- Ok(Apache.Commons.IO.Input.BOMInputStream.new(rc, ins));
                csname  <- Apache.Commons.IO.Input.BOMInputStream.getBOMCharsetName(bomIns) |> CsvIO.Util.errIOError;
                csname1 <- Ok(Option.getWithDefault("UTF-16", csname));
                cs1     <- Charset.forName(csname1) |> CsvIO.Util.errIOError;
                reader  <- Ok(Basis.IO.InputStreamReader.newWithCharset(cs1, ins)) |> Result.map(Basis.IO.InputStreamReader.asReader);
                parser  <- Interop.Apache.Commons.Csv.CSVFormat.parse(rc, CSVFormat(fmt1), reader) |> CsvIO.Util.errIOError;
                iter1   <- Ok(Interop.Apache.Commons.Csv.CSVParser.iterator(rc, parser));
                iter2   <- Ok(Iterator.map(row -> CsvIO.CsvRecordEvaluator.runCsvRecordEvaluator(eval, Interop.Apache.Commons.Csv.CSVRecord.wrapHH(row)), iter1)))
        yield CsvReadHandle((parser, iter2))



}
