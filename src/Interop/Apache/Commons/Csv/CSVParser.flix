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

namespace Interop/Apache/Commons/Csv {

    /// Class / Mutable

    pub enum CSVParser[_: Region](##org.apache.commons.csv.CSVParser)


}

namespace Interop/Apache/Commons/Csv/CSVParser {

    use Interop/Apache/Commons/Csv.CSVParser;
    use Interop/Apache/Commons/Csv.CSVParser.{CSVParser};

    use Interop/IO.SubReader;


    pub def getHH(p: CSVParser[r]): ##org.apache.commons.csv.CSVParser = 
        let CSVParser(p1) = p;
        p1

    pub def newCSVParser[r: Region, t: Region -> Type](_: Region[r], 
                                                        reader: t[r], 
                                                        fmt: ##org.apache.commons.csv.CSVFormat): CSVParser[r] \ Write(r) with SubReader[t]= 
        import new org.apache.commons.csv.CSVParser(##java.io.Reader, ##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVParser \ r as newCsvParser;
        CSVParser(newCsvParser(Interop/IO/Reader.getHH(Interop/IO/SubReader.toReader(reader)), fmt))



    pub def close!(p: CSVParser[r]): Result[String, Unit] \ Write(r) = 
        try {
            import org.apache.commons.csv.CSVParser.close(): Unit \ r;
            let CSVParser(p1) = p;
            close(p1) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }

    pub def iterator(rc: Region[r1], p: CSVParser[r]): Iterator[##org.apache.commons.csv.CSVRecord, r1, r1] \ {Read(r), Write(r1) } =
        import org.apache.commons.csv.CSVParser.iterator(): ##java.util.Iterator \ r;
        let CSVParser(p1) = p;
        let rawIter = iterator(p1) |> Interop/Util/IteratorZ.wrapHH(rc);
        Interop/Util/IteratorZ.toFlixIterator(rc, obj -> unsafe_cast obj as ##org.apache.commons.csv.CSVRecord, rawIter)

}
