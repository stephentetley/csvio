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



    pub enum CsvRecordEvaluator[r: Region, ka: Type, ef: Bool, a: Type](
        Graded.MutStateError[ka, Interop/Apache/Commons/Csv.CSVRecord[r], ef, a])

    instance GradedFunctor[CsvRecordEvaluator[r, ka]] {
        pub def map(f: a -> b \ ef1, x: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1, b] =
            CsvIO/CsvRecordEvaluator.map(f, x)
    }

    instance GradedApplicative[CsvRecordEvaluator[r, ka]] {
        pub def point(x: a): CsvRecordEvaluator[r, ka, Pure, a] = 
            CsvIO/CsvRecordEvaluator.point(x)

        pub def ap(mf: CsvRecordEvaluator[r, ka, ef1, a -> b \ ef2], 
                    ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, b] =
            CsvIO/CsvRecordEvaluator.ap(mf, ma)
    }

    instance GradedMonad[CsvRecordEvaluator[r, ka]] {
        pub def flatMap(k: a -> CsvRecordEvaluator[r, ka, ef1, b] \ ef2, 
                        x: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, b] =
            CsvIO/CsvRecordEvaluator.flatMap(k, x)
    }    
    
    instance GradedZero[CsvRecordEvaluator[r, ka]] {
        pub def empty(): CsvRecordEvaluator[r, ka, ef, a] = CsvIO/CsvRecordEvaluator.empty()
    }
    
    instance GradedOr[CsvRecordEvaluator[r, ka]] {
        pub def orelse(a: CsvRecordEvaluator[r, ka, ef1, a], 
                        b: CsvRecordEvaluator[r, ka, ef2, a]): CsvRecordEvaluator[r, ka, ef1 and ef2, a] =
            CsvIO/CsvRecordEvaluator.orelse(a, b)
    }

    instance GradedError[CsvRecordEvaluator[r, ka]] {
        pub def throwError(msg: String): CsvRecordEvaluator[r, ka, ef, a] = 
            CsvIO/CsvRecordEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef1, 
                            ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1, a] =
            CsvIO/CsvRecordEvaluator.mapError(f, ma)

        pub def catchError(ma: CsvRecordEvaluator[r, ka, ef, a], 
                            f: String -> CsvRecordEvaluator[r, ka, ef1, a] \ ef2): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, a] =
            CsvIO/CsvRecordEvaluator.catchError(ma, f)
    }

}

/// Note - the underlying library - Apache Commons Csv - supports both named 
/// and indexed getters, so there isn't a compelling reason to have CsvRecordEvaluator 
/// and NamedCsvRecordEvaluator modules.

namespace CsvIO/CsvRecordEvaluator {

    use GradedMonad.{>>=};
    
    use Time/Format.DateTimeFormatter;

    use Interop/Apache/Commons/Csv.CSVRecord;

    use CsvIO.CsvFormat;
    use CsvIO.CsvRecordEvaluator;
    use CsvIO.CsvRecordEvaluator.{CsvRecordEvaluator};



    pub def getCsvRecordEvaluator(x: CsvRecordEvaluator[r, ka, ef, a]): Graded.MutStateError[ka, CSVRecord[r], ef, a] = 
        let CsvRecordEvaluator(x1) = x;
        x1
        
    pub def runCsvRecordEvaluator(r: Region[r], 
                                    ma: CsvRecordEvaluator[r, a, ef, a], 
                                    st: CSVRecord[r]): Result[String, a] \ { r, ef } =
        Graded/MutStateError.runMutStateError(getCsvRecordEvaluator(ma), st)


    pub def point(x: a): CsvRecordEvaluator[r, ka, Pure, a] = CsvRecordEvaluator(Graded/MutStateError.point(x))

    pub def map(f: a -> b \ ef1, ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1, b] =
        CsvRecordEvaluator(Graded/MutStateError.map(f, getCsvRecordEvaluator(ma)))

    pub def ap(mf: CsvRecordEvaluator[r, ka, ef1, a -> b \ ef2], 
                ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, b] =
        CsvRecordEvaluator(Graded/MutStateError.ap(getCsvRecordEvaluator(mf), getCsvRecordEvaluator(ma)))


    pub def flatMap(f: a -> CsvRecordEvaluator[r, ka, ef1, b] \ ef2, 
                    ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, b] =
        CsvRecordEvaluator(Graded/MutStateError.flatMap(f >> getCsvRecordEvaluator, getCsvRecordEvaluator(ma)))



    pub def throwError(msg: String): CsvRecordEvaluator[r, ka, ef, a] = 
        CsvRecordEvaluator(Graded/MutStateError.throwError(msg))

    pub def mapError(f: String -> String \ ef1, ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1, a] = 
        CsvRecordEvaluator(Graded/MutStateError.mapError(f, getCsvRecordEvaluator(ma)))

    pub def catchError(ma: CsvRecordEvaluator[r, ka, ef, a], 
                        f: String -> CsvRecordEvaluator[r, ka, ef1, a] \ ef2): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, a] =
        CsvRecordEvaluator(Graded/MutStateError.catchError(getCsvRecordEvaluator(ma), f >> getCsvRecordEvaluator))

    pub def empty(): CsvRecordEvaluator[r, ka, ef, a] = 
        CsvRecordEvaluator(Graded/MutStateError.empty())
        
    pub def orelse(ma: CsvRecordEvaluator[r, ka, ef1, a], 
                    mb: CsvRecordEvaluator[r, ka, ef2, a]): CsvRecordEvaluator[r, ka, ef1 and ef2, a] =
        CsvRecordEvaluator(Graded/MutStateError.orelse(getCsvRecordEvaluator(ma), getCsvRecordEvaluator(mb)))

    def liftGetter(f: CSVRecord[r] -> a \ {r, ef}): CsvRecordEvaluator[r, ka, r and ef, a] =
        CsvRecordEvaluator(Graded/MutStateError.liftGetter(f))

    def liftGetterResult(f: CSVRecord[r] -> Result[err, a] \ {r, ef}): CsvRecordEvaluator[r, ka, r and ef, a] with ToString[err] =
        CsvRecordEvaluator(Graded/MutStateError.liftGetterResult(f))


    /// pub def optional(x: CsvRecordEvaluator[r, a]): CsvRecordEvaluator[r, Option[a]] =
    ///     CsvRecordEvaluator(r ->
    ///         match apply1(x, r) {
    ///             case Ok(a)  => Ok(Some(a))
    ///             case Err(_) => Ok(None)
    ///         }
    ///     )




    /// pub def choice(xs: List[CsvRecordEvaluator[r, a]]): CsvRecordEvaluator[r, a] =
    ///     CsvRecordEvaluator(r -> choiceHelper(r, xs))

    /// def choiceHelper(r: ##flixspt.csvio.InputRow, xs: List[CsvRecordEvaluator[r, a]]): Result[String, a] \ r =
    ///     match xs {
    ///         case Nil => Err("choice")
    ///         case x1 :: rs => match apply1(x1, r) {
    ///             case Ok(a) => Ok(a)
    ///             case Err(_) => choiceHelper(r, rs)
    ///         }
    ///     }

    // Cell readers

    pub def getStringAt(ix: Int32): CsvRecordEvaluator[r, ka, r, String] =        
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringAt(ix))


    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): CsvRecordEvaluator[r, ka, r, String] =
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringNamed(label))


    pub def hasComment(): CsvRecordEvaluator[r, ka, r, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.hasComment)


    pub def getComment(): CsvRecordEvaluator[r, ka, r, String] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.getComment >> Option.getWithDefault(""))

    pub def isConsistent(): CsvRecordEvaluator[r, ka, r, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isConsistent)

    pub def isMapped(label: String): CsvRecordEvaluator[r, ka, r, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isMapped(label))


    pub def isSetAt(ix: Int32): CsvRecordEvaluator[r, ka, r, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetAt(ix))

    pub def isSetNamed(label: String): CsvRecordEvaluator[r, ka, r, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetNamed(label))

    // TODO - toList, toMap...

    pub def parseAt(ix: Int32, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[r, ka, r and ef, a] =
        let* s = getStringAt(ix);
        GradedError.liftOption(msg, parse(s))

    pub def parseNamed(label: String, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[r, ka, r and ef, a] =
        let* s = getStringNamed(label);
        GradedError.liftOption(msg, parse(s))


    pub def getInt8At(ix: Int32): CsvRecordEvaluator[r, ka, r, Int8] =
        parseAt(ix, Int8.fromString, "getInt8At(${ix})")

    pub def getInt8Named(label: String): CsvRecordEvaluator[r, ka, r, Int8] =
        parseNamed(label, Int8.fromString, "getInt8Named('${label}'")

    pub def getInt16At(ix: Int32): CsvRecordEvaluator[r, ka, r, Int16] =
        parseAt(ix, Int16.fromString, "getInt16At('${ix}'")

    pub def getInt16Named(label: String): CsvRecordEvaluator[r, ka, r, Int16] =
        parseNamed(label, Int16.fromString, "getInt16Named('${label}'")

    pub def getInt32At(ix: Int32): CsvRecordEvaluator[r, ka, r, Int32] =
        parseAt(ix, Int32.fromString, "getInt32At('${ix}'")

    pub def getInt32Named(label: String): CsvRecordEvaluator[r, ka, r, Int32] =
        parseNamed(label, Int32.fromString, "getInt32Named('${label}'")

    pub def getInt64At(ix: Int32): CsvRecordEvaluator[r, ka, r, Int64] =
        parseAt(ix, Int64.fromString, "getInt64At('${ix}'")

    pub def getInt64Named(label: String): CsvRecordEvaluator[r, ka, r, Int64] =
        parseNamed(label, Int64.fromString, "getInt64Named('${label}'")


    pub def getFloat32At(ix: Int32): CsvRecordEvaluator[r, ka, r, Float32] =
        parseAt(ix, Float32.fromString, "getFloat32At('${ix}'")

    pub def getFloat32Named(label: String): CsvRecordEvaluator[r, ka, r, Float32] =
        parseNamed(label, Float32.fromString, "getFloat32Named('${label}'")

    pub def getFloat64At(ix: Int32): CsvRecordEvaluator[r, ka, r, Float64] =
        parseAt(ix, Float64.fromString, "getFloat64At('${ix}'")

    pub def getFloat64Named(label: String): CsvRecordEvaluator[r, ka, r, Float64] =
        parseNamed(label, Float64.fromString, "getFloat64Named('${label}'")


    pub def getBigIntAt(ix: Int32): CsvRecordEvaluator[r, ka, r, BigInt] =
        parseAt(ix, BigInt.fromString, "getBigIntAt('${ix}'")

    pub def getBigIntNamed(label: String): CsvRecordEvaluator[r, ka, r, BigInt] =
        parseNamed(label, BigInt.fromString, "getBigIntNamed('${label}'")


/*
    /// June 2022 - stubbed out due to regex changes...

    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[r, a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[r, a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[r, a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[r, a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)
*/


    pub def getLocalDateAt(ix: Int32, 
                            formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalDate] =
        parseAt(ix, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateAt('${ix}'") 

    pub def getLocalDateNamed(label: String, 
                                formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalDate] =
        parseNamed(label, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateNamed('${label}'")


    pub def getLocalDateTimeAt(ix: Int32, 
                                formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalDateTime] =
        parseAt(ix, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeAt('${ix}'") 

    pub def getLocalDateTimeNamed(label: String, 
                                    formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalDateTime] =
        parseNamed(label, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeNamed('${label}'")


    pub def getLocalTimeAt(ix: Int32, 
                            formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalTime] =
        parseAt(ix, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeAt('${ix}'") 

    pub def getLocalTimeNamed(label: String, 
                                formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, ka, r, Time.LocalTime] =
        parseNamed(label, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeNamed('${label}'")


}
