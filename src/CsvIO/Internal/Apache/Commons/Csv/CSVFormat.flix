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

    /// Class / Immutable (if avoid using the deprecated methods)

    pub enum CSVFormat(##org.apache.commons.csv.CSVFormat)

}

mod CsvIO.Internal.Apache.Commons.Csv.CSVFormat {

    use Basis.IO.Reader
    use Basis.IO.Reader.{Reader}

    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat
    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    use CsvIO.Internal.Apache.Commons.Csv.CSVParser
    use CsvIO.Internal.Apache.Commons.Csv.CSVParser.{CSVParser}


    pub def parse(_: Region[r1], fmt: CSVFormat, rd: Reader[r]): Result[String, CSVParser[r1]] \ {r, r1} = 
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVFormat.parse(##java.io.Reader): ##org.apache.commons.csv.CSVParser \ {r, r1};
            let CSVFormat(fmt1) = fmt;
            let Reader(rd1) = rd;
            CSVParser(parse(fmt1, rd1))
        })

}
