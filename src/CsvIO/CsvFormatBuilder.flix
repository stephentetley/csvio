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
        Graded.MutStateError[ka, ##org.apache.commons.csv.CSVFormat$Builder, ef, a]
    )

    instance GradedFunctor[CsvFormatBuilder[r, ka]] {
        pub def map(f: a -> b \ ef1, ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1, b] = 
            CsvIO/CsvFormatBuilder.map(f, ma)
    }


    instance GradedApplicative[CsvFormatBuilder[r, ka]] {
        pub def point(x: a): CsvFormatBuilder[r, ka, Pure, a] = 
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

    use CsvIO.CsvFormatBuilder;
    use CsvIO.CsvFormatBuilder.{CsvFormatBuilder};
    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO/CsvFormat.QuoteMode;

    pub def getCsvFormatBuilder(x: CsvFormatBuilder[r, ka, ef, a]): Graded.MutStateError[ka, ##org.apache.commons.csv.CSVFormat$Builder, ef, a] = 
        let CsvFormatBuilder(x1) = x;
        x1

    ///
    /// Returns the result of applying `ma` to the mutable state `s`.
    ///
    pub def runBuilder(_: Region[r], 
                        ma: CsvFormatBuilder[r, a, ef, a], 
                        s: ##org.apache.commons.csv.CSVFormat$Builder): Result[String, a] \ {r, ef} = 
        Graded/MutStateError.runMutStateError(getCsvFormatBuilder(ma), s)


    pub def toCsvFormat(r: Region[r], 
                        ma: CsvFormatBuilder[r, a, ef, a]): Result[String, CsvFormat] \ {ef, Write(r)} = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(): ##org.apache.commons.csv.CSVFormat$Builder \ r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat \ r as build1;
        try {
            let jbuilder = create1();
            match runBuilder(r, ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }


    pub def toCsvFormatWithCsvFormat(r: Region[r], 
                                    fmt: CsvFormat, 
                                    ma: CsvFormatBuilder[r, a, ef, a]): Result[String, CsvFormat] \ {ef, Write(r)} = 
        import static org.apache.commons.csv.CSVFormat$Builder.create(##org.apache.commons.csv.CSVFormat): ##org.apache.commons.csv.CSVFormat$Builder \ r as create1;
        import org.apache.commons.csv.CSVFormat$Builder.build(): ##org.apache.commons.csv.CSVFormat \ r as build1;
        try {
            let fmt1 = CsvIO/CsvFormat.getCsvFormat(fmt);
            let jbuilder = create1(fmt1);
            match runBuilder(r, ma, jbuilder) {
                case Err(msg) => Err(msg)
                case Ok(_)    => Ok(CsvFormat(build1(jbuilder)))
            }
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String \ r;
                Err(getMessage(ex))
        }




    pub def point(x: a): CsvFormatBuilder[r, ka, Pure, a] = CsvFormatBuilder(Graded/MutStateError.point(x))

    pub def map(f: a -> b \ ef1, ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1, b] =
        CsvFormatBuilder(Graded/MutStateError.map(f, getCsvFormatBuilder(ma)))

        
    pub def ap(mf: CsvFormatBuilder[r, ka, ef1, a -> b \ ef2], 
                ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
        CsvFormatBuilder(Graded/MutStateError.ap(getCsvFormatBuilder(mf), getCsvFormatBuilder(ma)))


    pub def flatMap(f: a -> CsvFormatBuilder[r, ka, ef1, b] \ ef2, 
                    ma: CsvFormatBuilder[r, ka, ef, a]): CsvFormatBuilder[r, ka, ef and ef1 and ef2, b] =
        CsvFormatBuilder(Graded/MutStateError.flatMap(f >> getCsvFormatBuilder, getCsvFormatBuilder(ma)))

    pub def throwError(msg: String): CsvFormatBuilder[r, ka, ef, a] = 
        CsvFormatBuilder(Graded/MutStateError.throwError(msg))
    
    def liftSetter!(f: ##org.apache.commons.csv.CSVFormat$Builder -> ##org.apache.commons.csv.CSVFormat$Builder \ {r, ef}): CsvFormatBuilder[r, ka, r and ef, Unit] =
        CsvFormatBuilder(Graded/MutStateError.liftSetter!(f)) |> GradedFunctor.ignore


    /// API...

    pub def setAllowDuplicateHeaderNames!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowDuplicateHeaderNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setAllowDuplicateHeaderNames, allow))

    // setAllowMissingColumnNames
    pub def setAllowMissingColumnNames!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setAllowMissingColumnNames, allow))


    pub def setAutoFlush!(allow: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setAutoFlush(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setAutoFlush, allow))

    pub def setCommentMarker!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setCommentMarker(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setCommentMarker, c))

    pub def setDelimiter!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setDelimiter, c))

    pub def setDelimiterString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setDelimiter(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setDelimiter, s))

    pub def setEscape!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setEscape(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setEscape, c))

    pub def setHeaderAuto!(): CsvFormatBuilder[r, ka, r, Unit] =
        liftSetter!(x -> 
            import static flixspt.csvio.FormatBuilderVarargs.setHeaderEmpty(##org.apache.commons.csv.CSVFormat$Builder): ##org.apache.commons.csv.CSVFormat$Builder \ r;
            setHeaderEmpty(x)
        )

    pub def setHeaders!(l: List[String]): CsvFormatBuilder[r, ka, r, Unit] =
        liftSetter!(x -> 
            region rc {
                import static flixspt.csvio.FormatBuilderVarargs.setHeader(##org.apache.commons.csv.CSVFormat$Builder, ##java.util.ArrayList): ##org.apache.commons.csv.CSVFormat$Builder \ r;
                let arrl = Interop/Util/ArrayList.fromFoldable(rc, l);
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

    
    pub def setIgnoreEmptyLines!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreEmptyLines, b))

    pub def setIgnoreHeaderCase!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreHeaderCase(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreHeaderCase, b))

    pub def setIgnoreSurroundingSpaces!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setIgnoreSurroundingSpaces(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setIgnoreSurroundingSpaces, b))   

    pub def setNullString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setNullString(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setNullString, s))  

    pub def setQuote!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuote(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setQuote, c))

    /// setQuoteMode        
    pub def setQuoteMode!(m: QuoteMode): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setQuoteMode(##org.apache.commons.csv.QuoteMode): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        let m1 = CsvIO/CsvFormat.marshalQuoteMode(m);
        liftSetter!(flip(setQuoteMode, m1))


    pub def setRecordSeparator!(c: Char): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(Char): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setRecordSeparator, c))

    pub def setRecordSeparatorString!(s: String): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setRecordSeparator(String): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setRecordSeparator, s))

    pub def setSkipHeaderRecord!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setSkipHeaderRecord, b))  

    pub def setTrailingDelimiter!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrailingDelimiter(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setTrailingDelimiter, b))  

    pub def setTrim!(b: Bool): CsvFormatBuilder[r, ka, r, Unit] = 
        import org.apache.commons.csv.CSVFormat$Builder.setTrim(Bool): ##org.apache.commons.csv.CSVFormat$Builder \ r;
        liftSetter!(flip(setTrim, b))  

}
