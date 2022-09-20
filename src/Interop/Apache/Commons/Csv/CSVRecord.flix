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

    pub enum CSVRecord[_: Region](##org.apache.commons.csv.CSVRecord)

    instance Scoped[CSVRecord] {
        pub def regionOf(_: CSVRecord[r]): Region[r] = () as Region[r]
    }

}

namespace Interop/Apache/Commons/Csv/CSVRecord {

    use Interop/Apache/Commons/Csv.CSVRecord;
    use Interop/Apache/Commons/Csv.CSVRecord.{CSVRecord};

    
    pub def getHH(x: CSVRecord[r]): ##org.apache.commons.csv.CSVRecord = 
        let CSVRecord(x1) = x;
        x1
    
    pub def wrapHH(_: Region[r], x: ##org.apache.commons.csv.CSVRecord): CSVRecord[r] = 
        CSVRecord(x)

    pub def getStringAt(ix: Int32, x: CSVRecord[r]): Result[String, String] \ Read(r) =
        try {
            import org.apache.commons.csv.CSVRecord.get(Int32): String \ r as get1;
            let CSVRecord(x1) = x;
            get1(x1, ix) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }

    pub def getStringNamed(label: String, x: CSVRecord[r]): Result[String, String] \ Read(r) =
        try {
            import org.apache.commons.csv.CSVRecord.get(String): String \ r as get1;
            let CSVRecord(x1) = x;
            get1(x1, label) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }

    pub def hasComment(x: CSVRecord[r]): Bool \ Read(r) =
        import org.apache.commons.csv.CSVRecord.hasComment(): Bool \ r;
        let CSVRecord(x1) = x;
        hasComment(x1)

    pub def getComment(x: CSVRecord[r]): Option[String] \ Read(r) =
        import org.apache.commons.csv.CSVRecord.getComment(): String \ r;
        let CSVRecord(x1) = x;
        getComment(x1) |> Object.toOption

    pub def isConsistent(x: CSVRecord[r]): Bool \ Read(r) =
        import org.apache.commons.csv.CSVRecord.isConsistent(): Bool \ r;
        let CSVRecord(x1) = x;
        isConsistent(x1)

    pub def isMapped(label: String, x: CSVRecord[r]): Bool \ Read(r) =
        import org.apache.commons.csv.CSVRecord.isMapped(String): Bool \ r;
        let CSVRecord(x1) = x;
        isMapped(x1, label)

    pub def isSetAt(ix: Int32, x: CSVRecord[r]): Bool \ Read(r) =
        import org.apache.commons.csv.CSVRecord.isSet(Int32): Bool \ r;
        let CSVRecord(x1) = x;
        isSet(x1, ix)

    pub def isSetNamed(label: String, x: CSVRecord[r]): Bool \ Read(r) =
        import org.apache.commons.csv.CSVRecord.isSet(String): Bool \ r;
        let CSVRecord(x1) = x;
        isSet(x1, label)

}
