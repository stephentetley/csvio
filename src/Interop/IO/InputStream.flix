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

namespace Interop/IO {

    pub enum InputStream[_: Region](##java.io.InputStream)

    instance Scoped[InputStream] {
        pub def regionOf(_: InputStream[r]): Region[r] = () as Region[r]
    }


}

namespace Interop/IO/InputStream {

    use Interop/IO.InputStream;
    use Interop/IO.InputStream.{InputStream};

    pub def getInputStream(ins: InputStream[r]): ##java.io.InputStream = 
        let InputStream(ins1) = ins;
        ins1

    /// pub def newCSVParser(_: Region[r], reader: ##java.io.Reader, fmt: ##org.apache.commons.csv.CSVFormat): CSVParser[r] \ Write(r) = 
    ///     import new org.apache.commons.csv.CSVParser(##java.io.Reader, ##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVParser & r as newCsvParser;
    ///     CSVParser(newCsvParser(reader, fmt))



    /// pub def close(p: CSVParser[r]): Unit \ Write(r) = 
    ///     import org.apache.commons.csv.CSVParser.close(): Unit & r;
    ///     let CSVParser(p1) = p;
    ///     close(p1)

    /// pub def iterator(p: CSVParser[r]): Iterator[##org.apache.commons.csv.CSVRecord, r] \ Read(r) = 
    ///     import org.apache.commons.csv.CSVParser.iterator(): ##java.util.Iterator & r;
    ///     let CSVParser(p1) = p;
    ///     let r1 = Scoped.regionOf(p);
    ///     let rawIter = Interop/Collections/RawIterator.new(r1, iterator(p1));
    ///     Interop/Collections/RawIterator.iteratorWith(obj -> obj as ##org.apache.commons.csv.CSVRecord, rawIter)


}
