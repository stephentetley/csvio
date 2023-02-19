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



    pub enum CsvRecordEvaluator[_r: Region, ka: Type, ef: Bool, a: Type](
        Graded.MutStateError[ka, Interop/Apache/Commons/Csv.CSVRecord[r], ef, a])

    instance Functor[CsvRecordEvaluator[r, ka]] {
        pub def map(f: a -> b \ ef1, x: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1, b] =
            CsvIO/CsvRecordEvaluator.map(f, x)
    }

    instance Applicative[CsvRecordEvaluator[r, ka]] {
        pub def point(x: a): CsvRecordEvaluator[r, ka, Pure, a] = 
            CsvIO/CsvRecordEvaluator.point(x)

        pub def ap(mf: CsvRecordEvaluator[r, ka, ef1, a -> b \ ef2], 
                    ma: CsvRecordEvaluator[r, ka, ef, a]): CsvRecordEvaluator[r, ka, ef and ef1 and ef2, b] =
            CsvIO/CsvRecordEvaluator.ap(mf, ma)
    }

    instance Monad[CsvRecordEvaluator[r, ka]] {
        pub def flatMap(k: a -> CsvRecordEvaluator[r, ka, b] \ ef, x: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] \ ef =
            CsvIO/CsvRecordEvaluator.flatMap(k, x)
    }    
    
    instance MonadZero[CsvRecordEvaluator[r, ka]] {
        pub def empty(): CsvRecordEvaluator[r, ka, a] = CsvIO/CsvRecordEvaluator.empty()
    }
    
    instance Graded.MonadOr[CsvRecordEvaluator[r, ka]] {
        pub def orelse(a: CsvRecordEvaluator[r, ka, a], b: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] =
            CsvIO/CsvRecordEvaluator.orelse(a, b)
    }

    instance Graded.MonadError[CsvRecordEvaluator[r, ka]] {
        pub def throwError(msg: String): CsvRecordEvaluator[r, ka, a] = 
            CsvIO/CsvRecordEvaluator.throwError(msg)

        pub def mapError(f: String -> String \ ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] \ ef =
            CsvIO/CsvRecordEvaluator.mapError(f, ma)

        pub def catchError(ma: CsvRecordEvaluator[r, ka, a], f: String -> CsvRecordEvaluator[r, ka, a] \ ef): CsvRecordEvaluator[r, ka, a] \ ef =
            CsvIO/CsvRecordEvaluator.catchError(ma, f)
    }

}

/// Note - the underlying library - Apache Commons Csv - supports both named 
/// and indexed getters, so there isn't a compelling reason to have CsvRecordEvaluator 
/// and NamedCsvRecordEvaluator modules.

namespace CsvIO/CsvRecordEvaluator {

    use Monad.{>>=};
    
    use Time/Format.DateTimeFormatter;

    use Interop/Apache/Commons/Csv.CSVRecord;

    use CsvIO.CsvFormat;
    use CsvIO.CsvRecordEvaluator;
    use CsvIO.CsvRecordEvaluator.{CsvRecordEvaluator};



    pub def getCsvRecordEvaluator(x: CsvRecordEvaluator[r, ka, a]): Graded.Evaluator[r, ka, CSVRecord[r], a] = 
        let CsvRecordEvaluator(x1) = x;
        x1
        
    pub def runCsvRecordEvaluator(r: Region[r], 
                                    ma: CsvRecordEvaluator[r, a, a], 
                                    st: CSVRecord[r]): Result[String, a] \ r =
        Graded/MutStateError.runEvaluator(r, getCsvRecordEvaluator(ma), st)


    pub def point(x: a): CsvRecordEvaluator[r, ka, a] = CsvRecordEvaluator(Graded/MutStateError.point(x))

    pub def map(f: a -> b \ ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] \ ef =
        CsvRecordEvaluator(Graded/MutStateError.map(f, getCsvRecordEvaluator(ma)))

    pub def ap(mf: CsvRecordEvaluator[r, ka, a -> b \ ef], ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] \ ef =
        CsvRecordEvaluator(Graded/MutStateError.ap(getCsvRecordEvaluator(mf), getCsvRecordEvaluator(ma)))


    pub def flatMap(f: a -> CsvRecordEvaluator[r, ka, b] \ ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] \ ef =
        CsvRecordEvaluator(Graded/MutStateError.flatMap(f >> getCsvRecordEvaluator, getCsvRecordEvaluator(ma)))



    pub def throwError(msg: String): CsvRecordEvaluator[r, ka, a] = 
        CsvRecordEvaluator(Graded/MutStateError.throwError(msg))

    pub def mapError(f: String -> String \ ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] \ ef = 
        CsvRecordEvaluator(Graded/MutStateError.mapError(f, getCsvRecordEvaluator(ma)))

    pub def catchError(ma: CsvRecordEvaluator[r, ka, a], f: String -> CsvRecordEvaluator[r, ka, a] \ ef): CsvRecordEvaluator[r, ka, a] \ ef =
        CsvRecordEvaluator(Graded/MutStateError.catchError(getCsvRecordEvaluator(ma), f >> getCsvRecordEvaluator))

    pub def empty(): CsvRecordEvaluator[r, ka, a] = 
        CsvRecordEvaluator(Graded/MutStateError.empty())
        
    pub def orelse(ma: CsvRecordEvaluator[r, ka, a], mb: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] =
        CsvRecordEvaluator(Graded/MutStateError.orelse(getCsvRecordEvaluator(ma), getCsvRecordEvaluator(mb)))

    def liftGetter(f: CSVRecord[r] -> a \ ef): CsvRecordEvaluator[r, ka, a] \ ef =
        CsvRecordEvaluator(Graded/MutStateError.liftGetter(f))

    def liftGetterResult(f: CSVRecord[r] -> Result[err, a] \ ef): CsvRecordEvaluator[r, ka, a] \ ef with ToString[err] =
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

    pub def getStringAt(ix: Int32): CsvRecordEvaluator[r, ka, String] \ Read(r) =        
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringAt(ix))


    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): CsvRecordEvaluator[r, ka, String] \ Read(r) =
        liftGetterResult(Interop/Apache/Commons/Csv/CSVRecord.getStringNamed(label))


    pub def hasComment(): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.hasComment)


    pub def getComment(): CsvRecordEvaluator[r, ka, String] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.getComment >> Option.getWithDefault(""))

    pub def isConsistent(): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isConsistent)

    pub def isMapped(label: String): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isMapped(label))


    pub def isSetAt(ix: Int32): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetAt(ix))

    pub def isSetNamed(label: String): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        liftGetter(Interop/Apache/Commons/Csv/CSVRecord.isSetNamed(label))

    // TODO - toList, toMap...

    pub def parseAt(ix: Int32, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[r, ka, a] \ { Read(r), ef } =
        let* s = getStringAt(ix);
        Graded/MutStateError.liftOption(msg, parse(s))

    pub def parseNamed(label: String, parse: String -> Option[a] \ ef, msg: String): CsvRecordEvaluator[r, ka, a] \ { Read(r), ef } =
        let* s = getStringNamed(label);
        Graded/MutStateError.liftOption(msg, parse(s))


    pub def getInt8At(ix: Int32): CsvRecordEvaluator[r, ka, Int8] \ Read(r) =
        parseAt(ix, Int8.fromString, "getInt8At(${ix})")

    pub def getInt8Named(label: String): CsvRecordEvaluator[r, ka, Int8] \ Read(r) =
        parseNamed(label, Int8.fromString, "getInt8Named('${label}'")

    pub def getInt16At(ix: Int32): CsvRecordEvaluator[r, ka, Int16] \ Read(r) =
        parseAt(ix, Int16.fromString, "getInt16At('${ix}'")

    pub def getInt16Named(label: String): CsvRecordEvaluator[r, ka, Int16] \ Read(r) =
        parseNamed(label, Int16.fromString, "getInt16Named('${label}'")

    pub def getInt32At(ix: Int32): CsvRecordEvaluator[r, ka, Int32] \ Read(r) =
        parseAt(ix, Int32.fromString, "getInt32At('${ix}'")

    pub def getInt32Named(label: String): CsvRecordEvaluator[r, ka, Int32] \ Read(r) =
        parseNamed(label, Int32.fromString, "getInt32Named('${label}'")

    pub def getInt64At(ix: Int32): CsvRecordEvaluator[r, ka, Int64] \ Read(r) =
        parseAt(ix, Int64.fromString, "getInt64At('${ix}'")

    pub def getInt64Named(label: String): CsvRecordEvaluator[r, ka, Int64] \ Read(r) =
        parseNamed(label, Int64.fromString, "getInt64Named('${label}'")


    pub def getFloat32At(ix: Int32): CsvRecordEvaluator[r, ka, Float32] \ Read(r) =
        parseAt(ix, Float32.fromString, "getFloat32At('${ix}'")

    pub def getFloat32Named(label: String): CsvRecordEvaluator[r, ka, Float32] \ Read(r) =
        parseNamed(label, Float32.fromString, "getFloat32Named('${label}'")

    pub def getFloat64At(ix: Int32): CsvRecordEvaluator[r, ka, Float64] \ Read(r) =
        parseAt(ix, Float64.fromString, "getFloat64At('${ix}'")

    pub def getFloat64Named(label: String): CsvRecordEvaluator[r, ka, Float64] \ Read(r) =
        parseNamed(label, Float64.fromString, "getFloat64Named('${label}'")


    pub def getBigIntAt(ix: Int32): CsvRecordEvaluator[r, ka, BigInt] \ Read(r) =
        parseAt(ix, BigInt.fromString, "getBigIntAt('${ix}'")

    pub def getBigIntNamed(label: String): CsvRecordEvaluator[r, ka, BigInt] \ Read(r) =
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


    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, ka, Time.LocalDate] \ Read(r) =
        parseAt(ix, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateAt('${ix}'") 

    pub def getLocalDateNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, ka, Time.LocalDate] \ Read(r) =
        parseNamed(label, Time/LocalDate.parse(formatter) >> Result.toOption, "getLocalDateNamed('${label}'")


    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, ka, Time.LocalDateTime] \ Read(r) =
        parseAt(ix, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeAt('${ix}'") 

    pub def getLocalDateTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, ka, Time.LocalDateTime] \ Read(r) =
        parseNamed(label, Time/LocalDateTime.parse(formatter) >> Result.toOption, "getLocalDateTimeNamed('${label}'")


    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, ka, Time.LocalTime] \ Read(r) =
        parseAt(ix, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeAt('${ix}'") 

    pub def getLocalTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, ka, Time.LocalTime] \ Read(r) =
        parseNamed(label, Time/LocalTime.parse(formatter) >> Result.toOption, "getLocalTimeNamed('${label}'")


}
