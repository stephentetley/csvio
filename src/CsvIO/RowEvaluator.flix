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


    /// TODO - to be replaced by CsvRecordEvaluator...
    pub enum RowEvaluator[r: Region, a: Type](##flixspt.csvio.InputRow -> Result[a, String] & r)

    instance Functor[RowEvaluator[r]] {
        pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
            CsvIO/RowEvaluator.map(f, x)
    }

    instance Applicative[RowEvaluator[r]] {
        pub def point(x: a): RowEvaluator[r, a] = 
            CsvIO/RowEvaluator.point(x)

        pub def ap(mf: RowEvaluator[r, a -> b & ef], ma: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
            CsvIO/RowEvaluator.ap(mf, ma)
    }

    instance Monad[RowEvaluator[r]] {
        pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
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

    pub def point(x: a): RowEvaluator[r, a] = RowEvaluator(_ -> Ok(x) as & r)

    def apply1(x: RowEvaluator[r, a], row: ##flixspt.csvio.InputRow): Result[a, String] & r =
        let RowEvaluator(f) = x;
        f(row)

    pub def runRowEvaluator(x: RowEvaluator[r, a], row: ##flixspt.csvio.InputRow): Result[a, String] & r = apply1(x, row)
        

    pub def map(f: a -> b & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row -> 
            match apply1(x, row) {
                case Ok(a) => {
                    let ans = f(a) as & r;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: RowEvaluator[r, a -> b & ef], ma: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row -> 
            match apply1(mf, row) {
                case Ok(f)   => { 
                    match apply1(ma, row) {
                        case Ok(a)   => Ok(f(a) as & r)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef


    pub def flatMap(k: a -> RowEvaluator[r, b] & ef, x: RowEvaluator[r, a]): RowEvaluator[r, b] & ef =
        RowEvaluator(row -> 
            match apply1(x, row) { 
                case Ok(a)  => { let ans = k(a) as & Pure; apply1(ans, row) }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def optional(x: RowEvaluator[r, a]): RowEvaluator[r, Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a)  => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    def liftPrimRowReader(eval: ##flixspt.csvio.InputRow -> Result[a, String] & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(row -> eval(row) as & r) as & ef

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[r, a] = match x {
        case Some(a) => point(a)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): RowEvaluator[r, a] = 
        RowEvaluator(_ -> x as & r)

    pub def liftOperation(fn: Unit -> Result[a, String] & ef): RowEvaluator[r, a] & ef =
        RowEvaluator(_ -> fn() as & r) as & ef

    pub def throwError(err: String): RowEvaluator[r, a] =
        RowEvaluator(_ -> Err(err) as & r)

    pub def choice(xs: List[RowEvaluator[r, a]]): RowEvaluator[r, a] =
        RowEvaluator(r -> choiceHelper(r, xs))

    def choiceHelper(r: ##flixspt.csvio.InputRow, xs: List[RowEvaluator[r, a]]): Result[a, String] & r =
        match xs {
            case Nil => Err("choice")
            case x1 :: rs => match apply1(x1, r) {
                case Ok(a) => Ok(a)
                case Err(_) => choiceHelper(r, rs)
            }
        }

    // Cell readers

    pub def getStringAt(ix: Int32): RowEvaluator[r, String] \ Read(r) =
        import flixspt.csvio.InputRow.getStringAt(Int32): String & r;
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
    pub def getStringNamed(label: String): RowEvaluator[r, String] \ Read(r) =
        import flixspt.csvio.InputRow.getStringNamed(String): String & r;
        liftPrimRowReader(row -> 
            try {
                let a = getStringNamed(row, label);
                Ok(a)
            } catch {
                case ex: ##java.lang.Exception => 
                    import java.lang.Throwable.getMessage(): String & r;
                    Err("getStringNamed('${label}'): ${getMessage(ex)}")
            }
        )

    pub def getInt8At(ix: Int32): RowEvaluator[r, Int8] \ Read(r) =
        import flixspt.csvio.InputRow.getByteAt(Int32): Int8 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getByteAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8At(${ix})")
            }
        )

    pub def getInt8Named(label: String): RowEvaluator[r, Int8] \ Read(r) =
        import flixspt.csvio.InputRow.getByteNamed(String): Int8 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getByteNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8Named('${label}')")
            }
        )

    pub def getInt16At(ix: Int32): RowEvaluator[r, Int16] \ Read(r) =
        import flixspt.csvio.InputRow.getShortAt(Int32): Int16 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getShortAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16At(${ix})")
            }
        )

    pub def getInt16Named(label: String): RowEvaluator[r, Int16] \ Read(r) =
        import flixspt.csvio.InputRow.getShortNamed(String): Int16 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getShortNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16Named('${label}')")
            }
        )

    pub def getInt32At(ix: Int32): RowEvaluator[r, Int32] \ Read(r) =
        import flixspt.csvio.InputRow.getIntAt(Int32): Int32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getIntAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32At(${ix})")
            }
        )

    pub def getInt32Named(label: String): RowEvaluator[r, Int32] \ Read(r) =
        import flixspt.csvio.InputRow.getIntNamed(String): Int32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getIntNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32Named('${label}')")
            }
        )

    pub def getInt64At(ix: Int32): RowEvaluator[r, Int64] \ Read(r) =
        import flixspt.csvio.InputRow.getLongAt(Int32): Int64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getLongAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64At(${ix})")
            }
        )

    pub def getInt64Named(label: String): RowEvaluator[r, Int64] \ Read(r) =
        import flixspt.csvio.InputRow.getLongNamed(String): Int64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getLongNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64Named('${label}')")
            }
        )

    pub def getFloat32At(ix: Int32): RowEvaluator[r, Float32] \ Read(r) =
        import flixspt.csvio.InputRow.getFloatAt(Int32): Float32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32At(${ix})")
            }
        )

    pub def getFloat32Named(label: String): RowEvaluator[r, Float32] \ Read(r) =
        import flixspt.csvio.InputRow.getFloatNamed(String): Float32 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getFloatNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32Named('${label}')")
            }
        )

    pub def getFloat64At(ix: Int32): RowEvaluator[r, Float64] \ Read(r) =
        import flixspt.csvio.InputRow.getDoubleAt(Int32): Float64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64At(${ix})")
            }
        )

    pub def getFloat64Named(label: String): RowEvaluator[r, Float64] \ Read(r) =
        import flixspt.csvio.InputRow.getDoubleNamed(String): Float64 & r;
        liftPrimRowReader(row -> 
            try {
                let a = getDoubleNamed(row, label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64Named('${label}')")
            }
        )

    pub def getBigIntAt(ix: Int32): RowEvaluator[r, BigInt] \ Read(r) =
        import flixspt.csvio.InputRow.getBigIntegerAt(Int32): BigInt & r;
        liftPrimRowReader(row -> 
            try {
                let a = getBigIntegerAt(row, ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntAt(${ix})")
            }
        )

    pub def getBigIntNamed(label: String): RowEvaluator[r, BigInt] \ Read(r) =
        import flixspt.csvio.InputRow.getBigIntegerNamed(String): BigInt & r;
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

    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[r, a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[r, a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.matches(patt, eval, input));
        point(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[r, a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: MatchEvaluator[a]): RowEvaluator[r, a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/RegexEval/Regex.contains(patt, eval, input));
        point(ans)
*/

    pub def getLocalDateAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateFormat]): RowEvaluator[r, Time.LocalDate] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDate.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalDateTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.DateTimeFormat]): RowEvaluator[r, Time.LocalDateTime] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalDateTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeAt(ix: Int32, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringAt(ix);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

    pub def getLocalTimeNamed(label: String, formatter: DateTimeFormatter[Time/Format.TimeFormat]): RowEvaluator[r, Time.LocalTime] \ Read(r) =
        let* input = getStringNamed(label);
        let* ans = liftResult(Time/LocalTime.parse(formatter, input));
        point(ans)

}
