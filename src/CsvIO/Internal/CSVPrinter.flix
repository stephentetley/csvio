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

    pub enum CSVPrinter[_: Region](##org.apache.commons.csv.CSVPrinter)

    instance Scoped[CSVPrinter] {
        pub def regionOf(_: CSVPrinter[r]): Region[r] = () as Region[r]
    }

}

namespace CsvIO/Internal/CSVPrinter {

    use Interop/Lang.ImpAppendable;

    use CsvIO/Internal.CSVPrinter;
    use CsvIO/Internal.CSVPrinter.{CSVPrinter};
    
    use CsvIO/Internal.CSVFormat;
    


    pub def getHH(p: CSVPrinter[r]): ##org.apache.commons.csv.CSVPrinter = 
        let CSVPrinter(p1) = p;
        p1


    pub def newCSVPrinter[r1: Region, r2: Region, t: Region -> Type](ws: t[r2], 
                                                        fmt: CSVFormat[r1]): Result[CSVPrinter[r2], String] \ {Read(r1), Write(r2)} with ImpAppendable[t]= 
        try {
            import new org.apache.commons.csv.CSVPrinter(##java.lang.Appendable, ##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVPrinter & r2 as newCSVPrinter;
            let ws1 = Interop/Lang/ImpAppendable.toAppendable(ws) |> Interop/Lang/Appendable.getHH;
            let fmt1 = CsvIO/Internal/CSVFormat.getHH(fmt);        
            CSVPrinter(newCSVPrinter(ws1, fmt1)) as \ {Read(r1), Write(r2)} |> Ok 
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r2;
                Err(getMessage(ex))
        }




    pub def close!(p: CSVPrinter[r]): Result[Unit, String] \ Write(r) = 
        try {
            import org.apache.commons.csv.CSVPrinter.close(): Unit & r;
            let CSVPrinter(p1) = p;
            close(p1) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }


    pub def printRecord!(l: List[String], p: CSVPrinter[r]): Result[Unit, String] \ Write(r) = 
        try {
            import static flixspt.csvio.PrinterVarargs.printRecordOfStrings(##org.apache.commons.csv.CSVPrinter, ##java.util.ArrayList): Unit & r;
            let CSVPrinter(p1) = p;
            let r1 = Scoped.regionOf(p);
            let arrl = Interop/Util/ArrayList.fromFoldable(r1, l);
            printRecordOfStrings(p1, Interop/Util/ArrayList.getHH(arrl));
            Ok()
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }


}
