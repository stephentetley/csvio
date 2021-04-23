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

    pub opaque type RowEvaluator[a] = ##flix.runtime.spt.csvio.InputRow ~> Result[a, String]
}


namespace CsvIO/RowEvaluator {


    use Text.Charset.{Charset};

    use CsvIO.CsvFormat;
    use CsvIO.RowEvaluator;
    use CsvIO.RowEvaluator.{RowEvaluator};

    pub def return(x: a): RowEvaluator[a] = 
        RowEvaluator(_ -> Ok(x) as & Impure)

    def apply1(x: RowEvaluator[a], r: ##flix.runtime.spt.csvio.InputRow): Result[a, String] & Impure =
        let RowEvaluator(f) = x;
        f(r)

    pub def runRowEvaluator(x: RowEvaluator[a], r: ##flix.runtime.spt.csvio.InputRow): Result[a, String] & Impure = apply1(x, r)
        

    pub def map(f: a -> b & ef, x: RowEvaluator[a]): RowEvaluator[b] =
        RowEvaluator(r -> 
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )        

    pub def ap(mf: RowEvaluator[a -> b & ef], ma: RowEvaluator[a]): RowEvaluator[b] =
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
        )

    pub def bind(x: RowEvaluator[a], k: a -> RowEvaluator[b]): RowEvaluator[b] = 
        RowEvaluator(r -> 
            match apply1(x, r) { 
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> RowEvaluator[b], x: RowEvaluator[a]): RowEvaluator[b] = bind(x, k)

    pub def optional(x: RowEvaluator[a]): RowEvaluator[Option[a]] =
        RowEvaluator(r ->
            match apply1(x, r) {
                case Ok(a) => Ok(Some(a))
                case Err(_) => Ok(None)
            }
        )


    def liftPrimRowReader(eval: ##flix.runtime.spt.csvio.InputRow ~> Result[a, String]): RowEvaluator[a] =
        RowEvaluator(r -> eval(r))

    pub def liftOption(x: Option[a], errMsg: String): RowEvaluator[a] = match x {
        case Some(a) => return(a)
        case None => throwError(errMsg)
    }

    pub def liftResult(x: Result[a, String]): RowEvaluator[a] = 
        RowEvaluator(_ -> x as & Impure)

    pub def liftOperation(fn: Unit ~> Result[a, String]): RowEvaluator[a] =
        RowEvaluator(_ -> fn())

    pub def throwError(err: String): RowEvaluator[a] =
        RowEvaluator(_ -> Err(err) as & Impure)

    pub def choice(xs: List[RowEvaluator[a]]): RowEvaluator[a] =
        RowEvaluator(r -> choiceHelper(r, xs))

    def choiceHelper(r: ##flix.runtime.spt.csvio.InputRow, xs: List[RowEvaluator[a]]): Result[a, String] & Impure =
        match xs {
            case Nil => Err("choice") as & Impure
            case x1 :: rs => match apply1(x1, r) {
                case Ok(a) => Ok(a)
                case Err(_) => choiceHelper(r, rs)
            }
        }

    // Cell readers

    pub def getStringAt(ix: Int32): RowEvaluator[String] =
        import flix.runtime.spt.csvio.InputRow.getStringAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getStringAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getStringAt('${ix}')")
            }
        )

    ///
    /// Get a string by its column name / label.
    ///
    pub def getStringNamed(label: String): RowEvaluator[String] =
        import flix.runtime.spt.csvio.InputRow.getStringNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getStringNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getStringNamed('${label}')")
            }
        )

    pub def getInt8At(ix: Int32): RowEvaluator[Int8] =
        import flix.runtime.spt.csvio.InputRow.getByteAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getByteAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8At(${ix})")
            }
        )

    pub def getInt8Named(label: String): RowEvaluator[Int8] =
        import flix.runtime.spt.csvio.InputRow.getByteNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getByteNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt8Named('${label}')")
            }
        )

    pub def getInt16At(ix: Int32): RowEvaluator[Int16] =
        import flix.runtime.spt.csvio.InputRow.getShortAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getShortAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16At(${ix})")
            }
        )

    pub def getInt16Named(label: String): RowEvaluator[Int16] =
        import flix.runtime.spt.csvio.InputRow.getShortNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getShortNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt16Named('${label}')")
            }
        )

    pub def getInt32At(ix: Int32): RowEvaluator[Int32] =
        import flix.runtime.spt.csvio.InputRow.getIntAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getIntAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32At(${ix})")
            }
        )

    pub def getInt32Named(label: String): RowEvaluator[Int32] =
        import flix.runtime.spt.csvio.InputRow.getIntNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getIntNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt32Named('${label}')")
            }
        )

    pub def getInt64At(ix: Int32): RowEvaluator[Int64] =
        import flix.runtime.spt.csvio.InputRow.getLongAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getLongAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64At(${ix})")
            }
        )

    pub def getInt64Named(label: String): RowEvaluator[Int64] =
        import flix.runtime.spt.csvio.InputRow.getLongNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getLongNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getInt64Named('${label}')")
            }
        )

    pub def getFloat32At(ix: Int32): RowEvaluator[Float32] =
        import flix.runtime.spt.csvio.InputRow.getFloatAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getFloatAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32At(${ix})")
            }
        )

    pub def getFloat32Named(label: String): RowEvaluator[Float32] =
        import flix.runtime.spt.csvio.InputRow.getFloatNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getFloatNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat32Named('${label}')")
            }
        )

    pub def getFloat64At(ix: Int32): RowEvaluator[Float64] =
        import flix.runtime.spt.csvio.InputRow.getDoubleAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getDoubleAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64At(${ix})")
            }
        )

    pub def getFloat64Named(label: String): RowEvaluator[Float64] =
        import flix.runtime.spt.csvio.InputRow.getDoubleNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getDoubleNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getFloat64Named('${label}')")
            }
        )

    pub def getBigIntAt(ix: Int32): RowEvaluator[BigInt] =
        import flix.runtime.spt.csvio.InputRow.getBigIntegerAt(Int32);
        liftPrimRowReader(row -> 
            try {
                let a = row.getBigIntegerAt(ix);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntAt(${ix})")
            }
        )

    pub def getBigIntNamed(label: String): RowEvaluator[BigInt] =
        import flix.runtime.spt.csvio.InputRow.getBigIntegerNamed(String);
        liftPrimRowReader(row -> 
            try {
                let a = row.getBigIntegerNamed(label);
                Ok(a)
            } catch {
                case _: ##java.lang.Exception => Err("getBigIntNamed('${label}')")
            }
        )

    pub def evalMatchesAt(ix: Int32, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/Regex.evalMatches(input, patt, eval));
        return(ans)

    pub def evalMatchesNamed(label: String, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/Regex.evalMatches(input, patt, eval));
        return(ans)

    pub def evalContainsAt(ix: Int32, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringAt(ix);
        let* ans = liftOperation(_ -> Text/Regex.evalContains(input, patt, eval));
        return(ans)

    pub def evalContainsNamed(label: String, patt: Text/Regex.Pattern, eval: Text/Regex.MatchEvaluator[a]): RowEvaluator[a] =
        let* input = getStringNamed(label);
        let* ans = liftOperation(_ -> Text/Regex.evalContains(input, patt, eval));
        return(ans)

    pub def getLocalDateAt(ix: Int32, formatter: Time/Format.DateFormatter): RowEvaluator[Time.LocalDate] =
        let* input = getStringAt(ix);
        let* ans = liftOption(Time/LocalDate.parse(input, formatter), "getLocalDateAt(${ix})");
        return(ans)

    pub def getLocalDateNamed(label: String, formatter: Time/Format.DateFormatter): RowEvaluator[Time.LocalDate] =
        let* input = getStringNamed(label);
        let* ans = liftOption(Time/LocalDate.parse(input, formatter), "getLocalDateNamed('${label}')");
        return(ans)

    pub def getLocalDateTimeAt(ix: Int32, formatter: Time/Format.DateTimeFormatter): RowEvaluator[Time.LocalDateTime] =
        let* input = getStringAt(ix);
        let* ans = liftOption(Time/LocalDateTime.parse(input, formatter), "getLocalDateTimeAt(${ix})");
        return(ans)

    pub def getLocalDateTimeNamed(label: String, formatter: Time/Format.DateTimeFormatter): RowEvaluator[Time.LocalDateTime] =
        let* input = getStringNamed(label);
        let* ans = liftOption(Time/LocalDateTime.parse(input, formatter), "getLocalDateTimeNamed('${label}')");
        return(ans)

    pub def getLocalTimeAt(ix: Int32, formatter: Time/Format.TimeFormatter): RowEvaluator[Time.LocalTime] =
        let* input = getStringAt(ix);
        let* ans = liftOption(Time/LocalTime.parse(input, formatter), "getLocalTimeAt(${ix})");
        return(ans)

    pub def getLocalTimeNamed(label: String, formatter: Time/Format.TimeFormatter): RowEvaluator[Time.LocalTime] =
        let* input = getStringNamed(label);
        let* ans = liftOption(Time/LocalTime.parse(input, formatter), "getLocalTimeNamed('${label}')");
        return(ans)

    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2]): RowEvaluator[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3]): RowEvaluator[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4]): RowEvaluator[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5]): RowEvaluator[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6]): RowEvaluator[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7]): RowEvaluator[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8]): RowEvaluator[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9]): RowEvaluator[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef, o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9], o10: RowEvaluator[t10]): RowEvaluator[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    ///
    /// Returns a 2 element tuple with the results of applying the evaluators `o1` and `o2`.
    ///
    /// Returns an error if evaluating either `o1` or `o2` is an error.
    ///
    pub def tuple2(o1: RowEvaluator[t1], o2: RowEvaluator[t2]): RowEvaluator[(t1, t2)] =
        lift2((x,y) -> (x,y), o1, o2)

    ///
    /// Returns a 3 element tuple with the results of applying the evaluators `o1`, `o2` and `o3`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2` and `o3` is an error.
    ///
    pub def tuple3(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3]): RowEvaluator[(t1, t2, t3)] =
        lift3((x1, x2, x3) -> (x1, x2, x3), o1, o2, o3)

    ///
    /// Returns a 4 element tuple with the results of applying the evaluators `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, `o3` and `o4` is an error.
    ///
    pub def tuple4(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4]): RowEvaluator[(t1, t2, t3, t4)]  =
        lift4((x1, x2, x3, x4) -> (x1, x2, x3, x4), o1, o2, o3, o4)

    ///
    /// Returns a 5 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o5` is an error.
    ///
    pub def tuple5(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5]): RowEvaluator[(t1, t2, t3, t4, t5)]  =
        lift5((x1, x2, x3, x4, x5) -> (x1, x2, x3, x4, x5), o1, o2, o3, o4, o5)

    ///
    /// Returns a 6 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o6` is an error.
    ///
    pub def tuple6(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6]): RowEvaluator[(t1, t2, t3, t4, t5, t6)]  =
        lift6((x1, x2, x3, x4, x5, x6) -> (x1, x2, x3, x4, x5, x6), o1, o2, o3, o4, o5, o6)

    ///
    /// Returns a 7 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o7` is an error.
    ///
    pub def tuple7(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7)]  =
        lift7((x1, x2, x3, x4, x5, x6, x7) -> (x1, x2, x3, x4, x5, x6, x7), o1, o2, o3, o4, o5, o6, o7)

    ///
    /// Returns a 8 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o8` is an error.
    ///
    pub def tuple8(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8)]  =
        lift8((x1, x2, x3, x4, x5, x6, x7, x8) -> (x1, x2, x3, x4, x5, x6, x7, x8), o1, o2, o3, o4, o5, o6, o7, o8)

    ///
    /// Returns a 9 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o9` is an error.
    ///
    pub def tuple9(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9)]  =
        lift9((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9), o1, o2, o3, o4, o5, o6, o7, o8, o9)

    ///
    /// Returns a 10 element tuple with the results of applying the evaluators `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if evaluating any of `o1`, `o2`, ... `o10` is an error.
    ///
    pub def tuple10(o1: RowEvaluator[t1], o2: RowEvaluator[t2], o3: RowEvaluator[t3], o4: RowEvaluator[t4], o5: RowEvaluator[t5], o6: RowEvaluator[t6], o7: RowEvaluator[t7], o8: RowEvaluator[t8], o9: RowEvaluator[t9], o10: RowEvaluator[t10]): RowEvaluator[(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)]  =
        lift10((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10), o1, o2, o3, o4, o5, o6, o7, o8, o9, o10)

}