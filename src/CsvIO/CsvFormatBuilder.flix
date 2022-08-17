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


    pub enum CsvFormatBuilder[r: Region, ka: Type, a: Type](MonadLib.Builder[r, ka, ##org.apache.commons.csv.CSVFormat$Builder, a])

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

    use CsvIO.CsvFormatBuilder;
    use CsvIO.CsvFormatBuilder.{CsvFormatBuilder};
    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO/CsvFormat.QuoteMode;

    pub def getCsvFormatBuilder(x: CsvFormatBuilder[r, ka, a]): MonadLib.Builder[r, ka, ##org.apache.commons.csv.CSVFormat$Builder, a] = 
        let CsvFormatBuilder(x1) = x;
        x1

    ///
    /// Returns the result of applying `ma` to the mutable state `s`.
    ///
    pub def runBuilder(r: Region[r], 
                        ma: CsvFormatBuilder[r, a, a], 
                        s: ##org.apache.commons.csv.CSVFormat$Builder): Result[a, String] & r = 
        MonadLib/Builder.runBuilder(r, getCsvFormatBuilder(ma), s)


    pub def toCsvFormat(r: Region[r], ma: CsvFormatBuilder[r, a, a]): Result[CsvFormat, String] \ Write(r) = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(): ##org.apache.commons.csv.CSVFormat$Builder & r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat & r as build1;
        try {
            let jbuilder = create1();
            match runBuilder(r, ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }


    pub def toCsvFormatWithCsvFormat(r: Region[r], fmt: CsvFormat, ma: CsvFormatBuilder[r, a, a]): Result[CsvFormat, String] \ Write(r) = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVFormat$Builder & r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat & r as build1;
        try {
            let fmt1 = CsvIO/CsvFormat.getCsvFormat(fmt);
            let jbuilder = create1(fmt1);
            match runBuilder(r, ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }




    pub def point(x: a): CsvFormatBuilder[r, ka, a] = CsvFormatBuilder(MonadLib/Builder.point(x))

    pub def map(f: a -> b & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder(MonadLib/Builder.map(f, getCsvFormatBuilder(ma)))

        
    pub def ap(mf: CsvFormatBuilder[r, ka, a -> b & ef], ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder(MonadLib/Builder.ap(getCsvFormatBuilder(mf), getCsvFormatBuilder(ma)))


    pub def flatMap(f: a -> CsvFormatBuilder[r, ka, b] & ef, ma: CsvFormatBuilder[r, ka, a]): CsvFormatBuilder[r, ka, b] & ef =
        CsvFormatBuilder(MonadLib/Builder.flatMap(f >> getCsvFormatBuilder, getCsvFormatBuilder(ma)))

    pub def throwError(msg: String): CsvFormatBuilder[r, ka, a] = 
        CsvFormatBuilder(MonadLib/Builder.throwError(msg))
    
    def liftSetter(f: ##org.apache.commons.csv.CSVFormat$Builder -> ##org.apache.commons.csv.CSVFormat$Builder & ef): CsvFormatBuilder[r, ka, Unit] & ef =
        CsvFormatBuilder(MonadLib/Builder.liftSetter(f))


    /// API...

    pub def setAllowDuplicateHeaderNames!(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowDuplicateHeaderNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setAllowDuplicateHeaderNames, allow))

    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames!(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setAllowMissingColumnNames, allow))


    pub def setAutoFlush!(allow: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setAutoFlush(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setAutoFlush, allow))

    pub def setCommentMarker!(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setCommentMarker(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setCommentMarker, c))

    pub def setDelimiter!(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setDelimiter, c))

    pub def setDelimiterString!(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setDelimiter, s))

    pub def setEscape!(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setEscape(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setEscape, c))

    pub def setHeaderAuto!(): CsvFormatBuilder[r, ka, Unit] \ Write(r) =
        liftSetter(x -> 
            import static flixspt.csvio.FormatBuilderVarargs.setHeaderEmpty(##org.apache.commons.csv.CSVFormat$Builder): ##org.apache.commons.csv.CSVFormat$Builder & r;
            setHeaderEmpty(x) as \ Write(r)
        )

    pub def setHeaders!(l: List[String]): CsvFormatBuilder[r, ka, Unit] \ Write(r) =
        liftSetter(x -> 
            region r1 {
                import static flixspt.csvio.FormatBuilderVarargs.setHeader(##org.apache.commons.csv.CSVFormat$Builder, ##java.util.ArrayList): ##org.apache.commons.csv.CSVFormat$Builder & r1;
                let arrl = Interop/Util/ArrayList.fromList(r1, l);
                setHeader(x, Interop/Util/ArrayList.getHH(arrl))
            } as \ Write(r)
        )


    pub def setHeaderComments!(l: List[String]): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        liftSetter(x -> 
            region r1 {        
                import static flixspt.csvio.FormatBuilderVarargs.setHeaderComments(##org.apache.commons.csv.CSVFormat$Builder, ##java.util.ArrayList): ##org.apache.commons.csv.CSVFormat$Builder & r1;
                let arrl = Interop/Util/ArrayList.fromList(r1, l);
                setHeaderComments(x, Interop/Util/ArrayList.getHH(arrl))
            } as \ Write(r)
        )

    
    pub def setIgnoreEmptyLines!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setIgnoreEmptyLines, b))

    pub def setIgnoreHeaderCase!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreHeaderCase(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setIgnoreHeaderCase, b))

    pub def setIgnoreSurroundingSpaces!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreSurroundingSpaces(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setIgnoreSurroundingSpaces, b))   

    pub def setNullString!(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setNullString(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setNullString, s))  

    pub def setQuote!(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuote(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setQuote, c))

    /// setQuoteMode        
    pub def setQuoteMode!(m: QuoteMode): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuoteMode(##org.apache.commons.csv.QuoteMode): ##org.apache.commons.csv.CSVFormat$Builder & r;
        let m1 = CsvIO/CsvFormat.marshalQuoteMode(m);
        liftSetter(flip(setQuoteMode, m1))


    pub def setRecordSeparator!(c: Char): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(Char): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setRecordSeparator, c))

    pub def setRecordSeparatorString!(s: String): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(String): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setRecordSeparator, s))

    pub def setSkipHeaderRecord!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setSkipHeaderRecord, b))  

    pub def setTrailingDelimiter!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrailingDelimiter(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setTrailingDelimiter, b))  

    pub def setTrim!(b: Bool): CsvFormatBuilder[r, ka, Unit] \ Write(r) = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrim(Bool): ##org.apache.commons.csv.CSVFormat$Builder & r;
        liftSetter(flip(setTrim, b))  

}
