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



    pub enum CsvRecordEvaluator[r: Region, ka: Type, a: Type](MonadLib.Evaluator[r, ka, ##org.apache.commons.csv.CSVRecord, a])

    instance Functor[CsvRecordEvaluator[r, ka]] {
        pub def map(f: a -> b & ef, x: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
            CsvIO/CsvRecordEvaluator.map(f, x)
    }

    instance Applicative[CsvRecordEvaluator[r, ka]] {
        pub def point(x: a): CsvRecordEvaluator[r, ka, a] = 
            CsvIO/CsvRecordEvaluator.point(x)

        pub def ap(mf: CsvRecordEvaluator[r, ka, a -> b & ef], ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
            CsvIO/CsvRecordEvaluator.ap(mf, ma)
    }

    instance Monad[CsvRecordEvaluator[r, ka]] {
        pub def flatMap(k: a -> CsvRecordEvaluator[r, ka, b] & ef, x: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
            CsvIO/CsvRecordEvaluator.flatMap(k, x)
    }    
    
    instance MonadZero[CsvRecordEvaluator[r, ka]] {
        pub def empty(): CsvRecordEvaluator[r, ka, a] = CsvIO/CsvRecordEvaluator.empty()
    }
    
    instance MonadLib.MonadOr[CsvRecordEvaluator[r, ka]] {
        pub def orelse(a: CsvRecordEvaluator[r, ka, a], b: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] =
            CsvIO/CsvRecordEvaluator.orelse(a, b)
    }
}

/// Note - the underlying library - Apache Commons Csv - supports both named 
/// and indexed getters, so there isn't a compelling reason to have CsvRecordEvaluator 
/// and NamedCsvRecordEvaluator modules.

namespace CsvIO/CsvRecordEvaluator {

    use Monad.{>>=};

    use FlixSandbox/Text.Charset.{Charset};
    
    use Time/Format.DateTimeFormatter;

    /// use Text/RegexEval.MatchEvaluator;

    use CsvIO.CsvFormat;
    use CsvIO.CsvRecordEvaluator;
    use CsvIO.CsvRecordEvaluator.{CsvRecordEvaluator};



    pub def getCsvRecordEvaluator(x: CsvRecordEvaluator[r, ka, a]): MonadLib.Evaluator[r, ka, ##org.apache.commons.csv.CSVRecord, a] = 
        let CsvRecordEvaluator(x1) = x;
        x1
        
    pub def runCsvRecordEvaluator(r: Region[r], 
                                ma: CsvRecordEvaluator[r, a, a], 
                                st: ##org.apache.commons.csv.CSVRecord): Result[a, String] & r =
        MonadLib/Evaluator.runEvaluator(r, getCsvRecordEvaluator(ma), st)


    pub def point(x: a): CsvRecordEvaluator[r, ka, a] = CsvRecordEvaluator(MonadLib/Evaluator.point(x))

    pub def map(f: a -> b & ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
        CsvRecordEvaluator(MonadLib/Evaluator.map(f, getCsvRecordEvaluator(ma)))

    pub def ap(mf: CsvRecordEvaluator[r, ka, a -> b & ef], ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
        CsvRecordEvaluator(MonadLib/Evaluator.ap(getCsvRecordEvaluator(mf), getCsvRecordEvaluator(ma)))


    pub def flatMap(f: a -> CsvRecordEvaluator[r, ka, b] & ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, b] & ef =
        CsvRecordEvaluator(MonadLib/Evaluator.flatMap(f >> getCsvRecordEvaluator, getCsvRecordEvaluator(ma)))



    pub def throwError(msg: String): CsvRecordEvaluator[r, ka, a] = 
        CsvRecordEvaluator(MonadLib/Evaluator.throwError(msg))

    pub def swapError(msg: String, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] = 
        CsvRecordEvaluator(MonadLib/Evaluator.swapError(msg, getCsvRecordEvaluator(ma)))

    pub def modifyError(f: String -> String & ef, ma: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] & ef = 
        CsvRecordEvaluator(MonadLib/Evaluator.modifyError(f, getCsvRecordEvaluator(ma)))

    pub def empty(): CsvRecordEvaluator[r, ka, a] = CsvRecordEvaluator(MonadLib/Evaluator.empty())
        
    pub def orelse(ma: CsvRecordEvaluator[r, ka, a], mb: CsvRecordEvaluator[r, ka, a]): CsvRecordEvaluator[r, ka, a] =
        CsvRecordEvaluator(MonadLib/Evaluator.orelse(getCsvRecordEvaluator(ma), getCsvRecordEvaluator(mb)))

    def liftGetter(f: ##org.apache.commons.csv.CSVRecord -> a & ef): CsvRecordEvaluator[r, ka, a] & ef =
        CsvRecordEvaluator(MonadLib/Evaluator.liftGetter(f))

    pub def liftResult(x: Result[a, String]): CsvRecordEvaluator[r, ka, a] =  match x {
        case Ok(x1)   => point(x1)
        case Err(msg) => throwError(msg)
    }

    /// pub def optional(x: CsvRecordEvaluator[r, a]): CsvRecordEvaluator[r, Option[a]] =
    ///     CsvRecordEvaluator(r ->
    ///         match apply1(x, r) {
    ///             case Ok(a)  => Ok(Some(a))
    ///             case Err(_) => Ok(None)
    ///         }
    ///     )

    /// pub def liftOption(x: Option[a], errMsg: String): CsvRecordEvaluator[r, a] = match x {
    ///     case Some(a) => point(a)
    ///     case None => throwError(errMsg)
    /// }



    /// pub def liftOperation(fn: Unit -> Result[a, String] & ef): CsvRecordEvaluator[r, a] & ef =
    ///     CsvRecordEvaluator(_ -> fn() as & r) as & ef


    /// pub def choice(xs: List[CsvRecordEvaluator[r, a]]): CsvRecordEvaluator[r, a] =
    ///     CsvRecordEvaluator(r -> choiceHelper(r, xs))

    /// def choiceHelper(r: ##flixspt.csvio.InputRow, xs: List[CsvRecordEvaluator[r, a]]): Result[a, String] & r =
    ///     match xs {
    ///         case Nil => Err("choice")
    ///         case x1 :: rs => match apply1(x1, r) {
    ///             case Ok(a) => Ok(a)
    ///             case Err(_) => choiceHelper(r, rs)
    ///         }
    ///     }

    // Cell readers

    pub def getStringAt(ix: Int32): CsvRecordEvaluator[r, ka, String] \ Read(r) =
        import org.apache.commons.csv.CSVRecord.get(Int32): String & r as get1;
        liftGetter(flip(get1, ix))


    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): CsvRecordEvaluator[r, ka, String] \ Read(r) =
        import org.apache.commons.csv.CSVRecord.get(String): String & r as get1;
        liftGetter(flip(get1, label)) |> modifyError(msg -> "getStringNamed('${label}'): ${msg}")


    pub def hasComment(): CsvRecordEvaluator[r, ka, Bool] \ Read(r) =
        import org.apache.commons.csv.CSVRecord.hasComment(): Bool & r;
        liftGetter(hasComment)


    pub def getComment(): CsvRecordEvaluator[r, ka, String] \ Read(r) =
        import org.apache.commons.csv.CSVRecord.getComment(): String & r;
        liftGetter(getComment) |> map(s -> if (Object.isNull(s)) "" else s)


    pub def getInt8At(ix: Int32): CsvRecordEvaluator[r, ka, Int8] \ Read(r) =
        getStringAt(ix) >>= (Int8.fromString >> liftResult) |> modifyError(msg -> "getInt8At('${ix}'): ${msg}")

    pub def getInt8Named(label: String): CsvRecordEvaluator[r, ka, Int8] \ Read(r) =
        getStringNamed(label) >>= (Int8.fromString >> liftResult) |> modifyError(msg -> "getInt8Named('${label}'): ${msg}")

/*

    pub def getInt16At(ix: Int32): CsvRecordEvaluator[r, Int16] \ Read(r) =
        import flixspt.csvio.InputRow.getShortAt(Int32): Int16 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getShortAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16At(${ix})")
            }
        )

    pub def getInt16Named(label: String): CsvRecordEvaluator[r, Int16] \ Read(r) =
        import flixspt.csvio.InputRow.getShortNamed(String): Int16 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getShortNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16Named('${label}')")
            }
        )

    pub def getInt32At(ix: Int32): CsvRecordEvaluator[r, Int32] \ Read(r) =
        import flixspt.csvio.InputRow.getIntAt(Int32): Int32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getIntAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32At(${ix})")
            }
        )

    pub def getInt32Named(label: String): CsvRecordEvaluator[r, Int32] \ Read(r) =
        import flixspt.csvio.InputRow.getIntNamed(String): Int32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getIntNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32Named('${label}')")
            }
        )

    pub def getInt64At(ix: Int32): CsvRecordEvaluator[r, Int64] \ Read(r) =
        import flixspt.csvio.InputRow.getLongAt(Int32): Int64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getLongAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64At(${ix})")
            }
        )

    pub def getInt64Named(label: String): CsvRecordEvaluator[r, Int64] \ Read(r) =
        import flixspt.csvio.InputRow.getLongNamed(String): Int64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getLongNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64Named('${label}')")
            }
        )

    pub def getFloat32At(ix: Int32): CsvRecordEvaluator[r, Float32] \ Read(r) =
        import flixspt.csvio.InputRow.getFloatAt(Int32): Float32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32At(${ix})")
            }
        )

    pub def getFloat32Named(label: String): CsvRecordEvaluator[r, Float32] \ Read(r) =
        import flixspt.csvio.InputRow.getFloatNamed(String): Float32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32Named('${label}')")
            }
        )

    pub def getFloat64At(ix: Int32): CsvRecordEvaluator[r, Float64] \ Read(r) =
        import flixspt.csvio.InputRow.getDoubleAt(Int32): Float64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64At(${ix})")
            }
        )

    pub def getFloat64Named(label: String): CsvRecordEvaluator[r, Float64] \ Read(r) =
        import flixspt.csvio.InputRow.getDoubleNamed(String): Float64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64Named('${label}')")
            }
        )

    pub def getBigIntAt(ix: Int32): CsvRecordEvaluator[r, BigInt] \ Read(r) =
        import flixspt.csvio.InputRow.getBigIntegerAt(Int32): BigInt & r;
        liftPrimRowReader(row -> 
            try {
                let a = getBigIntegerAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntAt(${ix})")
            }
        )

    pub def getBigIntNamed(label: String): CsvRecordEvaluator[r, BigInt] \ Read(r) =
        import flixspt.csvio.InputRow.getBigIntegerNamed(String): BigInt & r;
        liftPrimRowReader(row -> 
            try {
                let a = getBigIntegerNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntNamed('${label}')")
            }
        )
*/
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


/*
    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateFormat]): CsvRecordEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): CsvRecordEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.TimeFormat]): CsvRecordEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

*/

}
