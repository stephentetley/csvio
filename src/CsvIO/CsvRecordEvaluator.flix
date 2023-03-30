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

    // `CSVRecord` is immutable so we can use `Graded.EnvError` rather than `Graded.Evaluator`

    pub enum CsvRecordEvaluator[ka: Type, ef: Bool, a: Type](
        Graded.EnvError[ka, Interop/Apache/Commons/Csv.CSVRecord, ef, a])

    instance GradedFunctor[CsvRecordEvaluator[ka]] {
        pub def map(f: a -> b \ ef1, x: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1, b] =
            CsvIO/CsvRecordEvaluator.map(f, x)
    }

    instance GradedApplicative[CsvRecordEvaluator[ka]] {
        pub def point(x: a): CsvRecordEvaluator[ka, ef, a] = 
            CsvIO/CsvRecordEvaluator.point(x)

        pub def ap(mf: CsvRecordEvaluator[ka, ef1, a -> b \ ef2], 
                    ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1 and ef2, b] =
            CsvIO/CsvRecordEvaluator.ap(mf, ma)
    }

    instance GradedMonad[CsvRecordEvaluator[ka]] {
        pub def flatMap(k: a -> CsvRecordEvaluator[ka, ef1, b] \ ef2, 
                        x: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1 and ef2, b] =
            CsvIO/CsvRecordEvaluator.flatMap(k, x)
    }    
    
    instance GradedZero[CsvRecordEvaluator[ka]] {
        pub def empty(): CsvRecordEvaluator[ka, ef, a] = CsvIO/CsvRecordEvaluator.empty()
    }
    
    instance GradedOr[CsvRecordEvaluator[ka]] {
        pub def orelse(a: CsvRecordEvaluator[ka, ef1, a], 
                        b: CsvRecordEvaluator[ka, ef2, a]): CsvRecordEvaluator[ka, ef1 and ef2, a] =
            CsvIO/CsvRecordEvaluator.orelse(a, b)
    }

    instance GradedError[CsvRecordEvaluator[ka]] {
        pub def throwError(msg: String): CsvRecordEvaluator[ka, ef, a] = 
            CsvIO/CsvRecordEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef1, 
                            ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1, a] =
            CsvIO/CsvRecordEvaluator.mapError(f, ma)

        pub def catchError(ma: CsvRecordEvaluator[ka, ef, a], 
                            f: String -> CsvRecordEvaluator[ka, ef1, a] \ ef2): CsvRecordEvaluator[ka, ef and ef1 and ef2, a] =
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



    pub def getCsvRecordEvaluator(x: CsvRecordEvaluator[ka, ef, a]): Graded.EnvError[ka, CSVRecord, ef, a] = 
        let CsvRecordEvaluator(x1) = x;
        x1
        
    pub def runCsvRecordEvaluator( ma: CsvRecordEvaluator[a, ef, a], 
                                    e: CSVRecord): Result[String, a] \ ef =
        Graded/EnvError.runEnvError(getCsvRecordEvaluator(ma), e)


    pub def point(x: a): CsvRecordEvaluator[ka, ef, a] = CsvRecordEvaluator(Graded/EnvError.point(x))

    pub def map(f: a -> b \ ef1, ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1, b] =
        CsvRecordEvaluator(Graded/EnvError.map(f, getCsvRecordEvaluator(ma)))

    pub def ap(mf: CsvRecordEvaluator[ka, ef1, a -> b \ ef2], 
                ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1 and ef2, b] =
        CsvRecordEvaluator(Graded/EnvError.ap(getCsvRecordEvaluator(mf), getCsvRecordEvaluator(ma)))


    pub def flatMap(f: a -> CsvRecordEvaluator[ka, ef1, b] \ ef2, 
                    ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1 and ef2, b] =
        CsvRecordEvaluator(Graded/EnvError.flatMap(f >> getCsvRecordEvaluator, getCsvRecordEvaluator(ma)))



    pub def throwError(msg: String): CsvRecordEvaluator[ka, ef, a] = 
        CsvRecordEvaluator(Graded/EnvError.throwError(msg))

    pub def mapError(f: String -> String \ ef1, ma: CsvRecordEvaluator[ka, ef, a]): CsvRecordEvaluator[ka, ef and ef1, a] = 
        CsvRecordEvaluator(Graded/EnvError.mapError(f, getCsvRecordEvaluator(ma)))

    pub def catchError(ma: CsvRecordEvaluator[ka, ef, a], 
                        f: String -> CsvRecordEvaluator[ka, ef1, a] \ ef2): CsvRecordEvaluator[ka, ef and ef1 and ef2, a] =
        CsvRecordEvaluator(Graded/EnvError.catchError(getCsvRecordEvaluator(ma), f >> getCsvRecordEvaluator))

    pub def empty(): CsvRecordEvaluator[ka, ef, a] = 
        CsvRecordEvaluator(Graded/EnvError.empty())
        
    pub def orelse(ma: CsvRecordEvaluator[ka, ef1, a], 
                    mb: CsvRecordEvaluator[ka, ef2, a]): CsvRecordEvaluator[ka, ef1 and ef2, a] =
        CsvRecordEvaluator(Graded/EnvError.orelse(getCsvRecordEvaluator(ma), getCsvRecordEvaluator(mb)))

    def liftGetter(f: CSVRecord -> a \ ef): CsvRecordEvaluator[ka, ef, a] =
        CsvRecordEvaluator(Graded/EnvError.liftGetter(f))

    def liftGetterResult(f: CSVRecord -> Result[err, a] \  ef): CsvRecordEvaluator[ka, ef, a] with ToString[err] =
        CsvRecordEvaluator(Graded/EnvError.liftGetterResult(f))


    /// pub def optional(x: CsvRecordEvaluator[a]): CsvRecordEvaluator[Option[a]] =
    ///     CsvRecordEvaluator(r ->
    ///         match apply1(x, r) {
    ///             case Ok(a)  => Ok(Some(a))
    ///             case Err(_) => Ok(None)
    ///         }
    ///     )




    /// pub def choice(xs: List[CsvRecordEvaluator[a]]): CsvRecordEvaluator[a] =
    ///     CsvRecordEvaluator(r -> choiceHelper(r, xs))

    /// def choiceHelper(r: ##flixspt.csvio.InputRow, xs: List[CsvRecordEvaluator[a]]): Result[String, a] \ r =
    ///     match xs {
    ///         case Nil => Err("choice")
    ///         case x1 :: rs => match apply1(x1, r) {
    ///             case Ok(a) => Ok(a)
    ///             case Err(_) => choiceHelper(r, rs)
    ///         }
    ///     }

    // Cell readers

    pub def getStringAt(ix: Int32): CsvRecordEvaluator[ka, Pure, String] =        
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringAt(ix))


    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): CsvRecordEvaluator[ka, Pure, String] =
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringNamed(label))


    pub def hasComment(): CsvRecordEvaluator[ka, Pure, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.hasComment)


    pub def getComment(): CsvRecordEvaluator[ka, Pure, String] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.getComment >> Option.getWithDefault(""))

    pub def isConsistent(): CsvRecordEvaluator[ka, Pure, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isConsistent)

    pub def isMapped(label: String): CsvRecordEvaluator[ka, Pure, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isMapped(label))


    pub def isSetAt(ix: Int32): CsvRecordEvaluator[ka, Pure, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetAt(ix))

    pub def isSetNamed(label: String): CsvRecordEvaluator[ka, Pure, Bool] =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetNamed(label))

    // TODO - toList, toMap...

    pub def parseAt(ix: Int32, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[ka, ef, a] =
        use GradedMonad.{>>=};
        getStringAt(ix) >>= (s -> GradedError.liftOption(msg, parse(s)))

    pub def parseNamed(label: String, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[ka, ef, a] =
        use GradedMonad.{>>=};
        getStringNamed(label) >>= (s -> GradedError.liftOption(msg, parse(s)))


    pub def getInt8At(ix: Int32): CsvRecordEvaluator[ka, Pure, Int8] =
        parseAt(ix, Int8.fromString, "getInt8At(${ix})")

    pub def getInt8Named(label: String): CsvRecordEvaluator[ka, Pure, Int8] =
        parseNamed(label, Int8.fromString, "getInt8Named('${label}'")

    pub def getInt16At(ix: Int32): CsvRecordEvaluator[ka, Pure, Int16] =
        parseAt(ix, Int16.fromString, "getInt16At('${ix}'")

    pub def getInt16Named(label: String): CsvRecordEvaluator[ka, Pure, Int16] =
        parseNamed(label, Int16.fromString, "getInt16Named('${label}'")

    pub def getInt32At(ix: Int32): CsvRecordEvaluator[ka, Pure, Int32] =
        parseAt(ix, Int32.fromString, "getInt32At('${ix}'")

    pub def getInt32Named(label: String): CsvRecordEvaluator[ka, Pure, Int32] =
        parseNamed(label, Int32.fromString, "getInt32Named('${label}'")

    pub def getInt64At(ix: Int32): CsvRecordEvaluator[ka, Pure, Int64] =
        parseAt(ix, Int64.fromString, "getInt64At('${ix}'")

    pub def getInt64Named(label: String): CsvRecordEvaluator[ka, Pure, Int64] =
        parseNamed(label, Int64.fromString, "getInt64Named('${label}'")


    pub def getFloat32At(ix: Int32): CsvRecordEvaluator[ka, Pure, Float32] =
        parseAt(ix, Float32.fromString, "getFloat32At('${ix}'")

    pub def getFloat32Named(label: String): CsvRecordEvaluator[ka, Pure, Float32] =
        parseNamed(label, Float32.fromString, "getFloat32Named('${label}'")

    pub def getFloat64At(ix: Int32): CsvRecordEvaluator[ka, Pure, Float64] =
        parseAt(ix, Float64.fromString, "getFloat64At('${ix}'")

    pub def getFloat64Named(label: String): CsvRecordEvaluator[ka, Pure, Float64] =
        parseNamed(label, Float64.fromString, "getFloat64Named('${label}'")


    pub def getBigIntAt(ix: Int32): CsvRecordEvaluator[ka, Pure, BigInt] =
        parseAt(ix, BigInt.fromString, "getBigIntAt('${ix}'")

    pub def getBigIntNamed(label: String): CsvRecordEvaluator[ka, Pure, BigInt] =
        parseNamed(label, BigInt.fromString, "getBigIntNamed('${label}'")


/*
    /// June 2022 - stubbed out due to regex changes...

    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): CsvRecordEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)
*/


    pub def getLocalDateAt(ix: Int32, 
                            formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalDate] =
        parseAt(ix, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateAt('${ix}'") 

    pub def getLocalDateNamed(label: String, 
                                formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalDate] =
        parseNamed(label, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateNamed('${label}'")


    pub def getLocalDateTimeAt(ix: Int32, 
                                formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalDateTime] =
        parseAt(ix, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeAt('${ix}'") 

    pub def getLocalDateTimeNamed(label: String, 
                                    formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalDateTime] =
        parseNamed(label, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeNamed('${label}'")


    pub def getLocalTimeAt(ix: Int32, 
                            formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalTime] =
        parseAt(ix, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeAt('${ix}'") 

    pub def getLocalTimeNamed(label: String, 
                                formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[ka, Pure, Time.LocalTime] =
        parseNamed(label, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeNamed('${label}'")


}
