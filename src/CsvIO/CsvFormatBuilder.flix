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


    pub enum CsvFormatBuilder[r: Region, ka: Type, ef: Bool, a: Type](
        Graded.Builder[r, ka, Interop/Apache/Commons/Csv/CSVFormat.Builder, ef, a]
    )

    instance GradedFunctor[CsvFormatBuilder[r, ka]] {
        pub def map(f: a -> b \ ef1, ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1, b] = 
            CsvIO/CsvFormatBuilder.map(f, ma)
    }


    instance GradedApplicative[CsvFormatBuilder[r, ka]] {
        pub def point(x: a): CsvFormatBuilder[r, ka, ef, a] = 
            CsvIO/CsvFormatBuilder.point(x)

        pub def ap(mf: CsvFormatBuilder[r, ka, ef1, a -> b \ ef2], 
                    ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
            CsvIO/CsvFormatBuilder.ap(mf, ma)
    }

    instance GradedMonad[CsvFormatBuilder[r, ka]] {
        pub def flatMap(f: a -> CsvFormatBuilder[r, ka, ef1, b] \ ef2, 
                        ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
            CsvIO/CsvFormatBuilder.flatMap(f, ma)
    }


}

namespace CsvIO/CsvFormatBuilder {

    use CsvIO.CsvFormatBuilder
    use CsvIO.CsvFormatBuilder.{CsvFormatBuilder}
    use CsvIO.CsvFormat
    use CsvIO.CsvFormat.{CsvFormat}
    use CsvIO/CsvFormat.QuoteMode

    pub def getCsvFormatBuilder(x: CsvFormatBuilder[r, ka, ef, a]): Graded.Builder[r, ka, Interop/Apache/Commons/Csv/CSVFormat.Builder, ef, a] = 
        let CsvFormatBuilder(x1) = x;
        x1

    ///
    /// Returns the result of applying `ma` to the mutable state `s`.
    ///
    pub def runBuilder(ma: CsvFormatBuilder[r, a, ef, a], 
                        s: Interop/Apache/Commons/Csv/CSVFormat.Builder[r]): Result[String, a] \ ef = 
        Graded/Builder.runBuilder(getCsvFormatBuilder(ma), s)


    pub def toCsvFormat(rc: Region[r], 
                        ma: CsvFormatBuilder[r, a, ef, a]): Result[String, CsvFormat] \ {ef, Write(r)} = 
        try {
            let jbuilder = Interop/Apache/Commons/Csv/CSVFormat/Builder.create(rc);
            match runBuilder(ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvIO/CsvFormat.fromCSVFormat(Interop/Apache/Commons/Csv/CSVFormat/Builder.build(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }


    pub def toCsvFormatWithCsvFormat(rc: Region[r], 
                                    fmt: CsvFormat, 
                                    ma: CsvFormatBuilder[r, a, ef, a]): Result[String, CsvFormat] \ {ef, Write(r)} = 
        try {
            let fmt1 = CsvIO/CsvFormat.toCSVFormat(fmt);
            let jbuilder = Interop/Apache/Commons/Csv/CSVFormat/Builder.createWithCSVFormat(rc, fmt1);
            match runBuilder(ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvIO/CsvFormat.fromCSVFormat(Interop/Apache/Commons/Csv/CSVFormat/Builder.build(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }




    pub def point(x: a): CsvFormatBuilder[r, ka, ef, a] = 
        CsvFormatBuilder(Graded/Builder.point(x))

    pub def map(f: a -> b \ ef1, ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1, b] =
        CsvFormatBuilder(Graded/Builder.map(f, getCsvFormatBuilder(ma)))

        
    pub def ap(mf: CsvFormatBuilder[r, ka, ef1, a -> b \ ef2], 
                ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
        CsvFormatBuilder(Graded/Builder.ap(getCsvFormatBuilder(mf), getCsvFormatBuilder(ma)))


    pub def flatMap(f: a -> CsvFormatBuilder[r, ka, ef1, b] \ ef2, 
                    ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
        CsvFormatBuilder(Graded/Builder.flatMap(f >> getCsvFormatBuilder, getCsvFormatBuilder(ma)))

    pub def throwError(msg: String): CsvFormatBuilder[r, ka, ef, a] = 
        CsvFormatBuilder(Graded/Builder.throwError(msg))
    
    def liftSetter!(f: Interop/Apache/Commons/Csv/CSVFormat.Builder[r] -> Interop/Apache/Commons/Csv/CSVFormat.Builder[r] \ {r, ef}): CsvFormatBuilder[r, ka, r and ef, Unit] =
        CsvFormatBuilder(Graded/Builder.liftSetter!(f)) |> GradedFunctor.ignore


    /// API...

    pub def setAllowDuplicateHeaderNames!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setAllowDuplicateHeaderNames!(allow))

    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setAllowMissingColumnNames!(allow))


    pub def setAutoFlush!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setAutoFlush!(allow))

    pub def setCommentMarker!(ch: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setCommentMarker!(ch))

    pub def setDelimiter!(ch: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setDelimiter!(ch))

    pub def setDelimiterString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setDelimiterString!(s))

    pub def setEscape!(ch: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setEscape!(ch))

    pub def setHeaderAuto!(): CsvFormatBuilder[r, ka, r, Unit] =
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setHeadersAuto!)


    pub def setHeaders!(l: List[String]): CsvFormatBuilder[r, ka, r, Unit] =
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setHeaders!(l))  
        

    pub def setHeaderComments!(l: List[String]): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setHeaderComments!(l))

    pub def setIgnoreEmptyLines!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setIgnoreEmptyLines!(b))

    pub def setIgnoreHeaderCase!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setIgnoreHeaderCase!(b))

    pub def setIgnoreSurroundingSpaces!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setIgnoreSurroundingSpaces!(b))

    pub def setNullString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setNullString!(s))

    pub def setQuote!(ch: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setQuote!(ch))

    /// setQuoteMode        
    pub def setQuoteMode!(m: QuoteMode): CsvFormatBuilder[r, ka, r, Unit] = 
        let m1 = CsvIO/CsvFormat.marshalQuoteMode(m);
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setQuoteMode!(m1))


    pub def setRecordSeparator!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setRecordSeparator!(c))

    pub def setRecordSeparatorString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setRecordSeparatorString!(s))

    pub def setSkipHeaderRecord!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setSkipHeaderRecord!(b))

    pub def setTrailingDelimiter!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setTrailingDelimiter!(b))

    pub def setTrim!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        liftSetter!(Interop/Apache/Commons/Csv/CSVFormat/Builder.setTrim!(b))  

}
