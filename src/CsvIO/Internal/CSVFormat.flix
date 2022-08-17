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

namespace CsvIO/Internal {

    pub enum CSVFormat[_: Region](##org.apache.commons.csv.CSVFormat)

    instance Scoped[CSVFormat] {
        pub def regionOf(_: CSVFormat[r]): Region[r] = () as Region[r]
    }

}

namespace CsvIO/Internal/CSVFormat {

    use CsvIO/Internal.CSVFormat;
    use CsvIO/Internal.CSVFormat.{CSVFormat};
    use CsvIO/Internal.CSVParser;
    use CsvIO/Internal.CSVParser.{CSVParser};

    use Interop/IO.SubReader;

    pub def getHH(p: CSVFormat[r]): ##org.apache.commons.csv.CSVFormat = 
        let CSVFormat(p1) = p;
        p1

    pub def parse[r: Region, t: Region -> Type](rd: t[r], fmt: CSVFormat[r]): Result[CSVParser[r], String] \ Write(r) with SubReader[t]= 
        try {
            import org.apache.commons.csv.CSVFormat.parse(##java.io.Reader): ##org.apache.commons.csv.CSVParser & r;
            let CSVFormat(fmt1) = fmt;
            let rd1 = Interop/IO/Reader.getHH(Interop/IO/SubReader.toReader(rd));
            CSVParser(parse(fmt1, rd1)) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }

}
