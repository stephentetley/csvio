/*
 * Copyright 2021 Stephen Tetley
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

    pub enum RowEvaluator[a](##flixspt.csvio.InputRow -> Result[a, String] & Impure)

    instance Functor[RowEvaluator] {
        pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
            CsvIO/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator] {
        pub def point(x: a): RowEvaluator[a] = 
            CsvIO/RowEvaluator.point(x)

        pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] & ef =
            CsvIO/RowEvaluator.ap(mf, ma)
    }

    instance Monad[RowEvaluator] {
        pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
            CsvIO/RowEvaluator.flatMap(k, x)
    }    

}

/// Note - the underlying library - Apache Commons Csv - supports both named 
/// and indexed getters, so there isn't a compelling reason to have RowEvaluator 
/// and NamedRowEvaluator modules.

namespace CsvIO/RowEvaluator {

    use FlixSandbox/Text.Charset.{Charset};
    
    use Time/Format.DateTimeFormatter;

    /// use Text/RegexEval.MatchEvaluator;

    use CsvIO.CsvFormat;
    use CsvIO.RowEvaluator;
    use CsvIO.RowEvaluator.{RowEvaluator};

    pub def point(x: a): RowEvaluator[a] = 
        RowEvaluator(_ -> Ok(x) as & Impure)

    def apply1(x: RowEvaluator[a], r: ##flixspt.csvio.InputRow): Result[a, String] & Impure =
        let RowEvaluator(f) = x;
        f(r)

    pub def runRowEvaluator(x: RowEvaluator[a], r: ##flixspt.csvio.InputRow): Result[a, String] & Impure = apply1(x, r)
        

    pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(r -> 
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(r -> 
            match apply1(mf, r) {
                case Ok(f) => { 
                    match apply1(ma, r) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def flatMap(k: a -> RowEvaluator[b] & ef, x: RowEvaluator[a]): RowEvaluator[b] & ef =
        RowEvaluator(r -> 
            match apply1(x, r) { 
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def optional(x: RowEvaluator[a]): RowEvaluator[Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    def liftPrimRowReader(eval: ##flixspt.csvio.InputRow -> Result[a, String] & Impure): RowEvaluator[a] =
        RowEvaluator(r -> eval(r))

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[a] = match x {
        case Some(a) => point(a)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): RowEvaluator[a] = 
        RowEvaluator(_ -> x as & Impure)

    pub def liftOperation(fn: Unit -> Result[a, String] & Impure): RowEvaluator[a] =
        RowEvaluator(_ -> fn())

    pub def throwError(err: String): RowEvaluator[a] =
        RowEvaluator(_ -> Err(err) as & Impure)

    pub def choice(xs: List[RowEvaluator[a]]): RowEvaluator[a] =
        RowEvaluator(r -> choiceHelper(r, xs))

    def choiceHelper(r: ##flixspt.csvio.InputRow, xs: List[RowEvaluator[a]]): Result[a, String] & Impure =
        match xs {
            case Nil => Err("choice") as & Impure
            case x1 :: rs => match apply1(x1, r) {
                case Ok(a) => Ok(a)
                case Err(_) => choiceHelper(r, rs)
            }
        }

    // Cell readers

    pub def getStringAt(ix: Int32): RowEvaluator[String] =
        import flixspt.csvio.InputRow.getStringAt(Int32): String & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getStringAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getStringAt('${ix}')")
            }
        )

    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): RowEvaluator[String] =
        import flixspt.csvio.InputRow.getStringNamed(String): String & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getStringNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getStringNamed('${label}')")
            }
        )

    pub def getInt8At(ix: Int32): RowEvaluator[Int8] =
        import flixspt.csvio.InputRow.getByteAt(Int32): Int8 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getByteAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8At(${ix})")
            }
        )

    pub def getInt8Named(label: String): RowEvaluator[Int8] =
        import flixspt.csvio.InputRow.getByteNamed(String): Int8 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getByteNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8Named('${label}')")
            }
        )

    pub def getInt16At(ix: Int32): RowEvaluator[Int16] =
        import flixspt.csvio.InputRow.getShortAt(Int32): Int16 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getShortAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16At(${ix})")
            }
        )

    pub def getInt16Named(label: String): RowEvaluator[Int16] =
        import flixspt.csvio.InputRow.getShortNamed(String): Int16 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getShortNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16Named('${label}')")
            }
        )

    pub def getInt32At(ix: Int32): RowEvaluator[Int32] =
        import flixspt.csvio.InputRow.getIntAt(Int32): Int32 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getIntAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32At(${ix})")
            }
        )

    pub def getInt32Named(label: String): RowEvaluator[Int32] =
        import flixspt.csvio.InputRow.getIntNamed(String): Int32 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getIntNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32Named('${label}')")
            }
        )

    pub def getInt64At(ix: Int32): RowEvaluator[Int64] =
        import flixspt.csvio.InputRow.getLongAt(Int32): Int64 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getLongAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64At(${ix})")
            }
        )

    pub def getInt64Named(label: String): RowEvaluator[Int64] =
        import flixspt.csvio.InputRow.getLongNamed(String): Int64 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getLongNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64Named('${label}')")
            }
        )

    pub def getFloat32At(ix: Int32): RowEvaluator[Float32] =
        import flixspt.csvio.InputRow.getFloatAt(Int32): Float32 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32At(${ix})")
            }
        )

    pub def getFloat32Named(label: String): RowEvaluator[Float32] =
        import flixspt.csvio.InputRow.getFloatNamed(String): Float32 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32Named('${label}')")
            }
        )

    pub def getFloat64At(ix: Int32): RowEvaluator[Float64] =
        import flixspt.csvio.InputRow.getDoubleAt(Int32): Float64 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64At(${ix})")
            }
        )

    pub def getFloat64Named(label: String): RowEvaluator[Float64] =
        import flixspt.csvio.InputRow.getDoubleNamed(String): Float64 & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64Named('${label}')")
            }
        )

    pub def getBigIntAt(ix: Int32): RowEvaluator[BigInt] =
        import flixspt.csvio.InputRow.getBigIntegerAt(Int32): BigInt & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getBigIntegerAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntAt(${ix})")
            }
        )

    pub def getBigIntNamed(label: String): RowEvaluator[BigInt] =
        import flixspt.csvio.InputRow.getBigIntegerNamed(String): BigInt & Impure;
        liftPrimRowReader(row -> 
            try {
                let a = getBigIntegerNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntNamed('${label}')")
            }
        )

/*
    /// June 2022 - stubbed out due to regex changes...

    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)
*/

    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[Time.LocalDate] =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[Time.LocalDate] =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[Time.LocalDateTime] =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[Time.LocalDateTime] =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[Time.LocalTime] =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[Time.LocalTime] =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

}
