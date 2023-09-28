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

mod CsvIO.Internal.Apache.Commons.Csv {

    /// Class / Mutable

    pub enum CSVParser[_: Region](##org.apache.commons.csv.CSVParser)


}

mod CsvIO.Internal.Apache.Commons.Csv.CSVParser {

    use Basis.IO.Reader
    use Basis.IO.Reader.{Reader}

    use CsvIO.Internal.Apache.Commons.Csv.CSVParser
    use CsvIO.Internal.Apache.Commons.Csv.CSVParser.{CSVParser}
    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat
    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat}


    pub def new(_: Region[r], fmt: CSVFormat, reader: Reader[r]): CSVParser[r] \ r = 
        import new org.apache.commons.csv.CSVParser(##java.io.Reader, ##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVParser \ r as newCsvParser;
        let Reader(reader1) = reader;
        let CSVFormat(fmt1) = fmt;
        CSVParser(newCsvParser(reader1, fmt1))



    pub def close!(p: CSVParser[r]): Result[String, Unit] \ r = 
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVParser.close(): Unit \ r;
            let CSVParser(p1) = p;
            close(p1)
        })

    pub def iterator(rc: Region[r1], p: CSVParser[r]): Iterator[##org.apache.commons.csv.CSVRecord, r1, r1] \ {r, r1} =
        import org.apache.commons.csv.CSVParser.iterator(): ##java.util.Iterator \ {r, r1};
        let CSVParser(p1) = p;
        let rawIter = iterator(p1);
        Adaptor.fromIterator(rc, Proxy.Proxy: Proxy[##org.apache.commons.csv.CSVRecord], rawIter)
        

}
