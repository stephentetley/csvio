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

namespace Interop/Apache/Commons/Csv/CSVFormat {

    /// Class / Mutable 

    pub enum Builder[_: Region](##org.apache.commons.csv.CSVFormat$Builder)

}

namespace Interop/Apache/Commons/Csv/CSVFormat/Builder {

    use Interop/Apache/Commons/Csv/CSVFormat.Builder
    use Interop/Apache/Commons/Csv/CSVFormat.Builder.{Builder}
    use Interop/Apache/Commons/Csv.CSVFormat
    use Interop/Apache/Commons/Csv.CSVFormat.{CSVFormat}
    

    pub def getHH(b: Builder[r]): ##org.apache.commons.csv.CSVFormat$Builder = 
        let Builder(b1) = b;
        b1

    pub def create(_: Region[r]): Builder[r] \ Write(r) = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        create() |> Builder

    pub def createWithCSVFormat(_: Region[r], fmt: CSVFormat): Builder[r] \ { Write(r) }= 
        import static org.apache.commons.csv.CSVFormat$Builder.create(##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let fmt1 = Interop/Apache/Commons/Csv/CSVFormat.getHH(fmt);
        create(fmt1) |> Builder

    pub def build(b: Builder[r]): CSVFormat \ { Read(r) } = 
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat \ {r};
        let Builder(b1) = b;
        build(b1) |> Interop/Apache/Commons/Csv/CSVFormat.wrapHH


    pub def setAllowDuplicateHeaderNames!(allow: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowDuplicateHeaderNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setAllowDuplicateHeaderNames(b1, allow) |> Builder


    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames!(allow: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setAllowMissingColumnNames(b1, allow) |> Builder


    pub def setAutoFlush!(allow: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAutoFlush(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setAutoFlush(b1, allow) |> Builder

    pub def setCommentMarker!(ch: Char, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setCommentMarker(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setCommentMarker(b1, ch) |> Builder

    pub def setDelimiter!(ch: Char, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setDelimiter(b1, ch) |> Builder

    pub def setDelimiterString!(s: String, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setDelimiter(b1, s) |> Builder

    pub def setEscape!(ch: Char, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setEscape(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setEscape(b1, ch) |> Builder

    pub def setHeaderAuto!(b: Builder[r]): Builder[r] \ Write(r) =
        import static flixspt.csvio.FormatBuilderVarargs.setHeaderEmpty(##org.apache.commons.csv.CSVFormat$Builder): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let Builder(b1) = b;
        setHeaderEmpty(b1) |> Builder
/*

    pub def setHeaders!(l: List[String], b: Builder[r]): Builder[r] \ Write(r) =
        liftSetter!(x -> 
            region rc {
                import static flixspt.csvio.FormatBuilderVarargs.setHeader(##org.apache.commons.csv.CSVFormat$Builder, ##java.util.ArrayList): ##org.apache.commons.csv.CSVFormat$Builder \ r;
                let arrl = Interop/Util/ArrayList.fromFoldable(rc, l) |> Interop/Util/ArrayList.getHH;
                setHeader(x, Interop/Util/ArrayList.getHH(arrl))
            })



    // pub def setHeaderComments!(l: List[String]): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
    //     liftSetter!(x -> 
    //         unsafe_cast (region r1 {        
    //             import static flixspt.csvio.FormatBuilderVarargs.setHeaderComments(##org.apache.commons.csv.CSVFormat$Builder, ##java.util.ArrayList): ##org.apache.commons.csv.CSVFormat$Builder \ r1;
    //             let arrl = Interop/Util/ArrayList.fromFoldable(r1, l);
    //             setHeaderComments(x, Interop/Util/ArrayList.getHH(arrl))
    //         }) as \ Write(r)
    //     )

    
    pub def setIgnoreEmptyLines!(b: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreEmptyLines, b))

    pub def setIgnoreHeaderCase!(b: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreHeaderCase(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreHeaderCase, b))

    pub def setIgnoreSurroundingSpaces!(b: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreSurroundingSpaces(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreSurroundingSpaces, b))   

    pub def setNullString!(s: String, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setNullString(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setNullString, s))  

    pub def setQuote!(c: Char, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuote(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setQuote, c))

    /// setQuoteMode        
    pub def setQuoteMode!(m: QuoteMode, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuoteMode(##org.apache.commons.csv.QuoteMode): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let m1 = CsvIO/CsvFormat.marshalQuoteMode(m);
        liftSetter!(flip(setQuoteMode, m1))


    pub def setRecordSeparator!(c: Char, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setRecordSeparator, c))

    pub def setRecordSeparatorString!(s: String, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setRecordSeparator, s))

    pub def setSkipHeaderRecord!(b: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setSkipHeaderRecord, b))  

    pub def setTrailingDelimiter!(b: Bool, b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrailingDelimiter(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setTrailingDelimiter, b))  

    pub def setTrim!(b: Bool, b: Builder[r], b: Builder[r]): Builder[r] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrim(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setTrim, b))  

*/

}
