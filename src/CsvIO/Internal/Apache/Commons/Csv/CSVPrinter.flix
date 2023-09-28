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

    /// Class / Mutable (contains an underlying output stream c.f. `close!`)

    pub enum CSVPrinter[_: Region](##org.apache.commons.csv.CSVPrinter)

    
}

mod CsvIO.Internal.Apache.Commons.Csv.CSVPrinter {

    use Basis.IO.OutputStreamWriter
    use Basis.IO.OutputStreamWriter.{OutputStreamWriter}

    use CsvIO.Internal.Apache.Commons.Csv.CSVPrinter
    use CsvIO.Internal.Apache.Commons.Csv.CSVPrinter.{CSVPrinter}
    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat
    use CsvIO.Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    

    pub def new(_: Region[r1], ws: OutputStreamWriter[r], fmt: CSVFormat): Result[String, CSVPrinter[r1]] \ {r, r1} = 
        Result.tryCatch(_ -> {
            import new org.apache.commons.csv.CSVPrinter(##java.lang.Appendable, ##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVPrinter \ {r, r1} as newCSVPrinter;
            let OutputStreamWriter(ws1) = ws;
            let appendable1 = unchecked_cast(ws1 as ##java.lang.Appendable);
            let CSVFormat(fmt1) = fmt;
            CSVPrinter(newCSVPrinter(appendable1, fmt1))
        })




    pub def close!(p: CSVPrinter[r]): Result[String, Unit] \ r = 
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVPrinter.close(): Unit \ r;
            let CSVPrinter(p1) = p;
            close(p1)
        })


    pub def flush!(p: CSVPrinter[r]): Result[String, Unit] \ r = 
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVPrinter.flush(): Unit \ r;
            let CSVPrinter(p1) = p;
            flush(p1)
        })


    pub def printRecord!(l: List[String], p: CSVPrinter[r]): Result[String, Unit] \ r = 
        Result.tryCatch(_ -> {
            region rc {
                import org.apache.commons.csv.CSVPrinter.printRecord(Array[##java.lang.Object, rc]): Unit \ r;
                let CSVPrinter(p1) = p;
                let objList: List[##java.lang.Object] = List.map(s -> checked_cast(s), l);
                let arr = List.toArray(rc, objList);
                printRecord(p1, arr)
            }
        })


}
