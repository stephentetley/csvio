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

    pub enum InputStreamReader[_: Region](##java.io.InputStreamReader)

    instance Scoped[InputStreamReader] {
        pub def regionOf(_: InputStreamReader[r]): Region[r] = () as Region[r]
    }


}

namespace Interop/IO/InputStreamReader {

    use Interop/IO.InputStreamReader;
    use Interop/IO.InputStreamReader.{InputStreamReader};

    pub def getInputStreamReader(rd: InputStreamReader[r]): ##java.io.InputStreamReader = 
        let InputStreamReader(rd1) = rd;
        rd1

    pub def newInputStreamReader(_: Region[r], ins: ##java.io.InputStream, cs: ##java.nio.charset.Charset): InputStreamReader[r] \ Write(r) = 
        import new java.io.InputStreamReader(##java.io.InputStream, ##java.nio.charset.Charset): ##java.io.InputStreamReader & r as newInputStreamReader;
        InputStreamReader(newInputStreamReader(ins, cs))



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
