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

mod Internal.Apache.Commons.Csv {

    /// Class / Mutable 

    pub enum CSVFormatBuilder[_: Region](##org.apache.commons.csv.CSVFormat$Builder)

}

mod Internal.Apache.Commons.Csv.CSVFormatBuilder {

    use Internal.Apache.Commons.Csv.CSVFormatBuilder
    use Internal.Apache.Commons.Csv.CSVFormatBuilder.{CSVFormatBuilder}
    use Internal.Apache.Commons.Csv.CSVFormat
    use Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat}
    

    pub def create(_: Region[r]): CSVFormatBuilder[r] \ r = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        CSVFormatBuilder(create())

    pub def createWithCSVFormat(_: Region[r], fmt: CSVFormat): CSVFormatBuilder[r] \ r = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormat(fmt1) = fmt;
        CSVFormatBuilder(create(fmt1))

    pub def build(b: CSVFormatBuilder[r]): CSVFormat \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat \ {r};
        let CSVFormatBuilder(b1) = b;
        CSVFormat(build(b1))


    pub def setAllowDuplicateHeaderNames!(allow: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowDuplicateHeaderNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setAllowDuplicateHeaderNames(b1, allow) |> CSVFormatBuilder


    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames!(allow: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setAllowMissingColumnNames(b1, allow) |> CSVFormatBuilder


    pub def setAutoFlush!(allow: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setAutoFlush(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setAutoFlush(b1, allow) |> CSVFormatBuilder

    pub def setCommentMarker!(ch: Char, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setCommentMarker(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setCommentMarker(b1, ch) |> CSVFormatBuilder

    pub def setDelimiter!(ch: Char, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setDelimiter(b1, ch) |> CSVFormatBuilder

    pub def setDelimiterString!(s: String, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setDelimiter(b1, s) |> CSVFormatBuilder

    pub def setEscape!(ch: Char, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setEscape(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setEscape(b1, ch) |> CSVFormatBuilder

    pub def setHeadersAuto!(b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = region rc {
        import org.apache.commons.csv.CSVFormat$Builder.setHeader(Array[String, rc]): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        let arr: Array[String, rc] = Array#{} @ rc;
        setHeader(b1, arr) |> CSVFormatBuilder
    }

    pub def setHeaders!(l: List[String], b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = region rc {
        import org.apache.commons.csv.CSVFormat$Builder.setHeader(Array[String, rc]): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        let arr = List.toArray(rc, l);
        setHeader(b1, arr) |> CSVFormatBuilder
    }

    pub def setHeaderComments!(l: List[String], b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = region rc {        
        import org.apache.commons.csv.CSVFormat$Builder.setHeaderComments(Array[String, rc]): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        let arr = List.toArray(rc, l);
        setHeaderComments(b1, arr) |> CSVFormatBuilder
    }

    pub def setIgnoreEmptyLines!(ignore: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setIgnoreEmptyLines(b1, ignore) |> CSVFormatBuilder

    pub def setIgnoreHeaderCase!(ignore: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreHeaderCase(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setIgnoreHeaderCase(b1, ignore) |> CSVFormatBuilder

    pub def setIgnoreSurroundingSpaces!(ignore: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreSurroundingSpaces(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setIgnoreSurroundingSpaces(b1, ignore) |> CSVFormatBuilder

    pub def setNullString!(s: String, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setNullString(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setNullString(b1, s) |> CSVFormatBuilder

    pub def setQuote!(ch: Char, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuote(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setQuote(b1, ch) |> CSVFormatBuilder

    /// setQuoteMode        
    pub def setQuoteMode!(m: ##org.apache.commons.csv.QuoteMode, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuoteMode(##org.apache.commons.csv.QuoteMode): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setQuoteMode(b1, m) |> CSVFormatBuilder


    pub def setRecordSeparator!(ch: Char, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setRecordSeparator(b1, ch) |> CSVFormatBuilder

    pub def setRecordSeparatorString!(s: String, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setRecordSeparator(b1, s) |> CSVFormatBuilder

    pub def setSkipHeaderRecord!(skip: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setSkipHeaderRecord(b1, skip) |> CSVFormatBuilder

    pub def setTrailingDelimiter!(trail: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrailingDelimiter(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setTrailingDelimiter(b1, trail) |> CSVFormatBuilder

    pub def setTrim!(trim: Bool, b: CSVFormatBuilder[r]): CSVFormatBuilder[r] \ r = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrim(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let CSVFormatBuilder(b1) = b;
        setTrim(b1, trim) |> CSVFormatBuilder



}
