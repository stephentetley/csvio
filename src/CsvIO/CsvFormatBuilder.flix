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


namespace CsvIO {


    pub enum CsvFormatBuilderHandle[_: Region](##org.apache.commons.csv.CSVFormat$Builder)

    ///
    /// State and Codensity(Error) monad
    /// 
    /// `ka` is the continuation answer type
    ///
    /// TODO - do we need the internal impurity?
    ///
    pub enum CsvFormatBuilder[r: Region, ka: Type, a: Type](
        CsvFormatBuilderHandle[r] -> (a -> Result[ka, String] & r) -> Result[ka, String] & r)


    instance Functor[CsvFormatBuilder[r, ka]] {
        pub def map(f: a -> b & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef = 
            CsvIO/CsvFormatBuilder.map(f, ma)
    }


    instance Applicative[CsvFormatBuilder[r, ka]] {
        pub def point(x: a): CsvFormatBuilder[r, ka, a] =  CsvIO/CsvFormatBuilder.point(x)
        pub def ap(mf: CsvFormatBuilder[r, ka, a -> b & ef], ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
            CsvIO/CsvFormatBuilder.ap(mf, ma)
    }

    instance Monad[CsvFormatBuilder[r, ka]] {
        pub def flatMap(f: a -> CsvFormatBuilder[r, ka, b] & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
            CsvIO/CsvFormatBuilder.flatMap(f, ma)
    }


}

namespace CsvIO/CsvFormatBuilder {

    use CsvIO.CsvFormatBuilderHandle;
    use CsvIO.CsvFormatBuilderHandle.{CsvFormatBuilderHandle};
    use CsvIO.CsvFormatBuilder;
    use CsvIO.CsvFormatBuilder.{CsvFormatBuilder};
    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO/CsvFormat.QuoteMode;


    ///
    /// Helper function for the implementation of `map` and `ap` etc.
    ///
    def apply1(ma: CsvFormatBuilder[r, ka, a], 
                st: CsvFormatBuilderHandle[r], 
                k: a -> Result[ka, String] & r): Result[ka, String] & r=
        let CsvFormatBuilder(ma1) = ma;
        ma1(st, k)


    pub def toCsvFormat(_: Region[r], ma: CsvFormatBuilder[r, a, a]): Result[CsvFormat, String] \ Write(r) = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(): ##org.apache.commons.csv.CSVFormat$Builder & r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat & r as build1;
        try {
            let jbuilder = create1();
            match runBuilder(ma, CsvFormatBuilderHandle(jbuilder)) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.lang.Exception => Err(FlixSandbox/Marshal.unmarshalExceptionMessage(ex)) as \ r
        }


    pub def toCsvFormatWithCsvFormat(_: Region[r], fmt: CsvFormat, ma: CsvFormatBuilder[r, a, a]): Result[CsvFormat, String] \ Write(r) = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVFormat$Builder & r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat & r as build1;
        try {
            let fmt1 = CsvIO/CsvFormat.getCsvFormat(fmt);
            let jbuilder = create1(fmt1);
            match runBuilder(ma, CsvFormatBuilderHandle(jbuilder)) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.lang.Exception => Err(FlixSandbox/Marshal.unmarshalExceptionMessage(ex)) as \ r
        }


    ///
    /// Returns the result (new state and answer) of applying `ma` to the initial state `st`.
    ///
    def runBuilder(ma: CsvFormatBuilder[r, a, a], 
                    st: CsvFormatBuilderHandle[r]): Result[a, String] & r =
        let cont = a -> Ok(a) as & r;
        apply1(ma, st, cont)


    pub def point(x: a): CsvFormatBuilder[r, ka, a] =
        CsvFormatBuilder((_, k) -> k(x))

    pub def map(f: a -> b & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder((s, k) ->
            apply1(ma, s, a -> k(f(a) as & r))
        ) as & ef

        
    pub def ap(mf: CsvFormatBuilder[r, ka, a -> b & ef], ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder((s, k) ->
            apply1(mf, s, f ->
                apply1(ma, s, a ->
                    k(f(a) as & r)))
        ) as & ef


    pub def flatMap(f: a -> CsvFormatBuilder[r, ka, b] & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder((s, k) ->
            apply1(ma, s, a ->
                apply1(f(a) as & r, s, b ->
                    k(b)))
        ) as & ef

    pub def throwError(msg: String): CsvFormatBuilder[r, ka, a] = 
        CsvFormatBuilder((_, _) -> Err(msg) as & r)


    def liftJavaBuilderPrim(f: ##org.apache.commons.csv.CSVFormat$Builder -> ##org.apache.commons.csv.CSVFormat$Builder & ef): CsvFormatBuilder[r, ka, Unit] & ef = 
        CsvFormatBuilder((s, k) ->
            try {
                let CsvFormatBuilderHandle(s1) = s;
                let _ = f(s1) as & Pure;
                k()
            } catch {
                case ex: ##java.lang.Exception => 
                    import java.lang.Throwable.getMessage(): String & Pure; 
                    Err(getMessage(ex))
            }            
        ) as & ef

    /// API...

    pub def setAllowDuplicateHeaderNames(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowDuplicateHeaderNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setAllowDuplicateHeaderNames, allow))

    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setAllowMissingColumnNames, allow))


    pub def setAutoFlush(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAutoFlush(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setAutoFlush, allow))

    pub def setCommentMarker(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setCommentMarker(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setCommentMarker, c))

    pub def setDelimiter(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setDelimiter, c))

    pub def setDelimiterString(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setDelimiter, s))

    pub def setEscape(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setEscape(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setEscape, c))

    pub def setHeaderAuto(): CsvFormatBuilder[r, ka, Unit] \ Write(r) =
        liftJavaBuilderPrim(x -> 
            region r1 {
                import org.apache.commons.csv.CSVFormat$Builder.setHeader(Array[String, r1]): ##org.apache.commons.csv.CSVFormat$Builder & r1;
                FlixSandbox/Marshal.runVaragsOfString(Nil, setHeader(x), r1)
            } as \ Write(r)
        )

    pub def setHeaders(l: List[String]): CsvFormatBuilder[r, ka, Unit] \ Write(r) =         
        liftJavaBuilderPrim(x -> 
            region r1 {
                import org.apache.commons.csv.CSVFormat$Builder.setHeader(Array[String, r1]): ##org.apache.commons.csv.CSVFormat$Builder & r1;
                FlixSandbox/Marshal.runVaragsOfString(l, setHeader(x), r1)
            } as \ Write(r)
        )


    pub def setHeaderComments(l: List[String]): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        liftJavaBuilderPrim(x -> 
            region r1 {        
                import org.apache.commons.csv.CSVFormat$Builder.setHeaderComments(Array[String, r1]): ##org.apache.commons.csv.CSVFormat$Builder & r1;
                FlixSandbox/Marshal.runVaragsOfString(l, setHeaderComments(x), r1)
            } as \ Write(r)
        )

    
    pub def setIgnoreEmptyLines(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setIgnoreEmptyLines, b))

    pub def setIgnoreHeaderCase(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreHeaderCase(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setIgnoreHeaderCase, b))

    pub def setIgnoreSurroundingSpaces(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreSurroundingSpaces(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setIgnoreSurroundingSpaces, b))   

    pub def setNullString(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setNullString(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setNullString, s))  

    pub def setQuote(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuote(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setQuote, c))

    /// setQuoteMode        
    pub def setQuoteMode(m: QuoteMode): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuoteMode(##org.apache.commons.csv.QuoteMode): ##org.apache.commons.csv.CSVFormat$Builder & r;
        let m1 = CsvIO/CsvFormat.marshalQuoteMode(m);
        liftJavaBuilderPrim(flip(setQuoteMode, m1))


    pub def setRecordSeparator(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setRecordSeparator, c))

    pub def setRecordSeparatorString(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setRecordSeparator, s))

    pub def setSkipHeaderRecord(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setSkipHeaderRecord, b))  

    pub def setTrailingDelimiter(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrailingDelimiter(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setTrailingDelimiter, b))  

    pub def setTrim(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrim(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftJavaBuilderPrim(flip(setTrim, b))  

}
