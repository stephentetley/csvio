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


    /// Class / Immutable

    pub enum CSVRecord(##org.apache.commons.csv.CSVRecord)


}

mod Interop.Apache.Commons.Csv.CSVRecord {

    use Interop.Apache.Commons.Csv.CSVRecord
    use Interop.Apache.Commons.Csv.CSVRecord.{CSVRecord}

    
    pub def getHH(x: CSVRecord): ##org.apache.commons.csv.CSVRecord = 
        let CSVRecord(x1) = x;
        x1
    
    pub def wrapHH(x: ##org.apache.commons.csv.CSVRecord): CSVRecord = 
        CSVRecord(x)

    pub def getStringAt(ix: Int32, x: CSVRecord): Result[String, String] =
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVRecord.get(Int32): String \ {} as get1;
            let CSVRecord(x1) = x;
            get1(x1, ix)
        })

    pub def getStringNamed(label: String, x: CSVRecord): Result[String, String] =
        Result.tryCatch(_ -> {
            import org.apache.commons.csv.CSVRecord.get(String): String \ {} as get1;
            let CSVRecord(x1) = x;
            get1(x1, label)
        })

    pub def hasComment(x: CSVRecord): Bool =
        import org.apache.commons.csv.CSVRecord.hasComment(): Bool \ {};
        let CSVRecord(x1) = x;
        hasComment(x1)

    pub def getCharacterPosition(x: CSVRecord): Int64 =
        import org.apache.commons.csv.CSVRecord.getCharacterPosition(): Int64 \ {};
        let CSVRecord(x1) = x;
        getCharacterPosition(x1)

    pub def getComment(x: CSVRecord): Option[String] =
        import org.apache.commons.csv.CSVRecord.getComment(): String \ {};
        let CSVRecord(x1) = x;
        getComment(x1) |> Object.toOption

    pub def getRecordNumber(x: CSVRecord): Int64 =
        import org.apache.commons.csv.CSVRecord.getRecordNumber(): Int64 \ {};
        let CSVRecord(x1) = x;
        getRecordNumber(x1)


    pub def isConsistent(x: CSVRecord): Bool =
        import org.apache.commons.csv.CSVRecord.isConsistent(): Bool \ {};
        let CSVRecord(x1) = x;
        isConsistent(x1)

    pub def isMapped(label: String, x: CSVRecord): Bool =
        import org.apache.commons.csv.CSVRecord.isMapped(String): Bool \ {};
        let CSVRecord(x1) = x;
        isMapped(x1, label)

    pub def isSetAt(ix: Int32, x: CSVRecord): Bool =
        import org.apache.commons.csv.CSVRecord.isSet(Int32): Bool \ {};
        let CSVRecord(x1) = x;
        isSet(x1, ix)

    pub def isSetNamed(label: String, x: CSVRecord): Bool  =
        import org.apache.commons.csv.CSVRecord.isSet(String): Bool \ {};
        let CSVRecord(x1) = x;
        isSet(x1, label)

    pub def size(x: CSVRecord): Int32 =
        import org.apache.commons.csv.CSVRecord.size(): Int32 \ {};
        let CSVRecord(x1) = x;
        size(x1)

}
