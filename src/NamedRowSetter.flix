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

    use CsvIO/Internal.OutputHandle;

    pub opaque type NamedRowSetter[a] = (Map[String, Int32], OutputHandle) -> Result[a, String] & Impure

}

namespace CsvIO/NamedRowSetter {


    use CsvIO.NamedRowSetter;
    use CsvIO.NamedRowSetter.{NamedRowSetter};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle};

    pub def return(x: a): NamedRowSetter[a] =
        NamedRowSetter((_,_) -> Ok(x) as & Impure)

    def apply1(x: NamedRowSetter[a], headers: Map[String, Int32], r: OutputHandle): Result[a, String] & Impure =
        let NamedRowSetter(f) = x;
        f(headers, r)

    pub def map(f: a -> b & ef, x: NamedRowSetter[a]): NamedRowSetter[b] =
        NamedRowSetter((hdrs, r) ->
            match apply1(x, hdrs, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: NamedRowSetter[a -> b & ef], ma: NamedRowSetter[a]): NamedRowSetter[b] =
        NamedRowSetter((hdrs,r) ->
            match apply1(mf, hdrs, r) {
                case Ok(f) => {
                    match apply1(ma, hdrs, r) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        )

    pub def bind(x: NamedRowSetter[a], k: a -> NamedRowSetter[b]): NamedRowSetter[b] =
        NamedRowSetter((hdrs,r) ->
            match apply1(x, hdrs, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, hdrs, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> NamedRowSetter[b], x: NamedRowSetter[a]): NamedRowSetter[b] = bind(x, k)

    def primWriteCell!(label: String, value: String): NamedRowSetter[Unit] =
        use CsvIO/Internal/OutputHandle.{setCellString!};
        NamedRowSetter((hdrs, r) ->
            match Map.get(label, hdrs) {
                case Some(ix) => setCellString!(r, ix, value)
                case None => Err("primWriteCell - unknown label: '${label}'")
             }
        )

    pub def putEmpty!(label: String): NamedRowSetter[Unit] =
        primWriteCell!(label, "")


    pub def putItem!(label: String, item: a): NamedRowSetter[Unit] with ToString[a]=
        primWriteCell!(label, ToString.toString(item))


    pub def putOptional!(label: String, x: Option[a]): NamedRowSetter[Unit] with ToString[a] = match x {
        case Some(n) => putItem!(label, n)
        case None => putEmpty!(label)
    }


    pub def putString!(label: String, str: String): NamedRowSetter[Unit] =
        primWriteCell!(label, str)




    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: NamedRowSetter[t1], o2: NamedRowSetter[t2]): NamedRowSetter[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3]): NamedRowSetter[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4]): NamedRowSetter[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4],
                  o5: NamedRowSetter[t5]): NamedRowSetter[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4],
                  o5: NamedRowSetter[t5],
                  o6: NamedRowSetter[t6]): NamedRowSetter[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4],
                  o5: NamedRowSetter[t5],
                  o6: NamedRowSetter[t6],
                  o7: NamedRowSetter[t7]): NamedRowSetter[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4],
                  o5: NamedRowSetter[t5],
                  o6: NamedRowSetter[t6],
                  o7: NamedRowSetter[t7],
                  o8: NamedRowSetter[t8]): NamedRowSetter[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef,
                  o1: NamedRowSetter[t1],
                  o2: NamedRowSetter[t2],
                  o3: NamedRowSetter[t3],
                  o4: NamedRowSetter[t4],
                  o5: NamedRowSetter[t5],
                  o6: NamedRowSetter[t6],
                  o7: NamedRowSetter[t7],
                  o8: NamedRowSetter[t8],
                  o9: NamedRowSetter[t9]): NamedRowSetter[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef,
                   o1: NamedRowSetter[t1],
                   o2: NamedRowSetter[t2],
                   o3: NamedRowSetter[t3],
                   o4: NamedRowSetter[t4],
                   o5: NamedRowSetter[t5],
                   o6: NamedRowSetter[t6],
                   o7: NamedRowSetter[t7],
                   o8: NamedRowSetter[t8],
                   o9: NamedRowSetter[t9],
                   o10: NamedRowSetter[t10]): NamedRowSetter[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    pub def foldM(mf: (b, a) -> NamedRowSetter[b], start: b, xs: List[a]): NamedRowSetter[b] =
        NamedRowSetter((hdrs, r) ->
            foldMHelper(hdrs, r, mf, start, xs, e -> Err(e), ac -> Ok(ac))
        )

    def foldMHelper(hdrs: Map[String, Int32],
                    r: OutputHandle,
                    mf: (b, a) -> NamedRowSetter[b],
                    acc: b,
                    xs: List[a],
                    fk: String -> Result[b, String],
                    sk: b -> Result[b, String]): Result[b, String] & Impure =
        match xs {
            case Nil => sk(acc)
            case x :: rs => {
                let ma = mf(acc, x);
                match apply1(ma, hdrs, r) {
                    case Err(e) => fk(e)
                    case Ok(acc1) => foldMHelper(hdrs, r, mf, acc1, rs, fk, sk)
                }
            }
        }


}

