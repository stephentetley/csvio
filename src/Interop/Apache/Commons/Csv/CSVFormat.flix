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

mod Interop.Apache.Commons.Csv {

    /// Class / Immutable (if avoid using the deprecated methods)

    pub enum CSVFormat(##org.apache.commons.csv.CSVFormat)

}

mod Interop.Apache.Commons.Csv.CSVFormat {

    use Interop.IO.SubReader
    use Interop.Apache.Commons.Csv.CSVFormat
    use Interop.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    use Interop.Apache.Commons.Csv.CSVParser
    use Interop.Apache.Commons.Csv.CSVParser.{CSVParser}


    pub def getHH(p: CSVFormat): ##org.apache.commons.csv.CSVFormat = 
        let CSVFormat(p1) = p;
        p1

    pub def wrapHH(fmt: ##org.apache.commons.csv.CSVFormat): CSVFormat = 
        CSVFormat(fmt)

    pub def parse[t: Region -> Type, r: Region, r1: Region]
                (_: Region[r1], rd: t[r], fmt: CSVFormat): Result[String, CSVParser[r1]] \ {r, r1} with SubReader[t] = 
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVFormat.parse(##java.io.Reader): ##org.apache.commons.csv.CSVParser \ {r, r1};
            let CSVFormat(fmt1) = fmt;
            let rd1 = Interop.IO.Reader.getHH(Interop.IO.SubReader.toReader(rd));
            CSVParser(parse(fmt1, rd1))
        })

}
