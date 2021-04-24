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

    pub opaque type RowSetter[a] = OutputHandle ~> Result[a, String]

}

namespace CsvIO/RowSetter {

    use CsvIO.RowSetter;
    use CsvIO.RowSetter.{RowSetter};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle}; 

    pub def return(x: a): RowSetter[a] =
        RowSetter(_ -> Ok(x) as & Impure)

    /// TODO should this be called `apply!` ?
    def apply1(x: RowSetter[a], r: OutputHandle): Result[a, String] & Impure =
        let RowSetter(f) = x;
        f(r)
    
    pub def runRowSetter!(x: RowSetter[a], r: OutputHandle): Result[a, String] & Impure = apply1(x, r)
     

    pub def map(f: a -> b & ef, x: RowSetter[a]): RowSetter[b] =
        RowSetter(r ->
            match apply1(x, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        )

    pub def ap(mf: RowSetter[a -> b & ef], ma: RowSetter[a]): RowSetter[b] =
        RowSetter(r ->
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

    pub def bind(x: RowSetter[a], k: a -> RowSetter[b]): RowSetter[b] =
        RowSetter(r ->
            match apply1(x, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, r) }
                case Err(e) => Err(e)
            }
        )

    pub def flatMap(k: a -> RowSetter[b], x: RowSetter[a]): RowSetter[b] = bind(x, k)

    def primWriteCell!(ix: Int32, value: String): RowSetter[Unit] =
        use CsvIO/Internal/OutputHandle.{setCellString!};
        RowSetter(r -> setCellString!(r, ix, value))

    pub def putEmpty!(ix: Int32): RowSetter[Unit] =
        primWriteCell!(ix, "")


    pub def putItem!(ix: Int32, item: a): RowSetter[Unit] with ToString[a]=
        primWriteCell!(ix, ToString.toString(item))


    pub def putOptional!(ix: Int32, x: Option[a]): RowSetter[Unit] with ToString[a] = match x {
        case Some(n) => putItem!(ix, n)
        case None => putEmpty!(ix)
    }


    pub def putString!(ix: Int32, str: String): RowSetter[Unit] =
        primWriteCell!(ix, str)

    ///
    /// Applies the binary function `f` to the values in `o1` and `o2`.
    ///
    /// Returns an error if either `o1` or `o2` are errors.
    ///
    pub def lift2(f: (t1, t2) -> u & ef, o1: RowSetter[t1], o2: RowSetter[t2]): RowSetter[u] =
        ap(map(f, o1), o2)

    ///
    /// Applies the ternary function `f` to the values in `o1`, `o2` and `o3`.
    ///
    /// Returns an error if any of `o1`, `o2` and `o3` are errors.
    ///
    pub def lift3(f: (t1, t2, t3) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3]): RowSetter[u] =
        ap(lift2(f, o1, o2), o3)

    ///
    /// Applies the 4-ary function `f` to the values in `o1`, `o2`, `o3` and `o4`.
    ///
    /// Returns an error if any of `o1`, `o2`, `o3` and `o4` are errors.
    ///
    pub def lift4(f: (t1, t2, t3, t4) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4]): RowSetter[u] =
        ap(lift3(f, o1, o2, o3), o4)

    ///
    /// Applies the 5-ary function `f` to the values in `o1`, `o2`, ... `o5`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o5` are errors.
    ///
    pub def lift5(f: (t1, t2, t3, t4, t5) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4],
                  o5: RowSetter[t5]): RowSetter[u] =
        ap(lift4(f, o1, o2, o3, o4), o5)

    ///
    /// Applies the 6-ary function `f` to the values in `o1`, `o2`, ... `o6`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o6` are errors.
    ///
    pub def lift6(f: (t1, t2, t3, t4, t5, t6) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4],
                  o5: RowSetter[t5],
                  o6: RowSetter[t6]): RowSetter[u] =
        ap(lift5(f, o1, o2, o3, o4, o5), o6)

    ///
    /// Applies the 7-ary function `f` to the values in `o1`, `o2`, ... `o7`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o7` are errors.
    ///
    pub def lift7(f: (t1, t2, t3, t4, t5, t6, t7) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4],
                  o5: RowSetter[t5],
                  o6: RowSetter[t6],
                  o7: RowSetter[t7]): RowSetter[u] =
        ap(lift6(f, o1, o2, o3, o4, o5, o6), o7)

    ///
    /// Applies the 8-ary function `f` to the values in `o1`, `o2`, ... `o8`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o8` are errors.
    ///
    pub def lift8(f: (t1, t2, t3, t4, t5, t6, t7, t8) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4],
                  o5: RowSetter[t5],
                  o6: RowSetter[t6],
                  o7: RowSetter[t7],
                  o8: RowSetter[t8]): RowSetter[u] =
        ap(lift7(f, o1, o2, o3, o4, o5, o6, o7), o8)

    ///
    /// Applies the 9-ary function `f` to the values in `o1`, `o2`, ... `o9`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o9` are errors.
    ///
    pub def lift9(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9) -> u & ef,
                  o1: RowSetter[t1],
                  o2: RowSetter[t2],
                  o3: RowSetter[t3],
                  o4: RowSetter[t4],
                  o5: RowSetter[t5],
                  o6: RowSetter[t6],
                  o7: RowSetter[t7],
                  o8: RowSetter[t8],
                  o9: RowSetter[t9]): RowSetter[u] =
        ap(lift8(f, o1, o2, o3, o4, o5, o6, o7, o8), o9)

    ///
    /// Applies the 10-ary function `f` to the values in `o1`, `o2`, ... `o10`.
    ///
    /// Returns an error if any of `o1`, `o2`, ... `o10` are errors.
    ///
    pub def lift10(f: (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10) -> u & ef,
                   o1: RowSetter[t1],
                   o2: RowSetter[t2],
                   o3: RowSetter[t3],
                   o4: RowSetter[t4],
                   o5: RowSetter[t5],
                   o6: RowSetter[t6],
                   o7: RowSetter[t7],
                   o8: RowSetter[t8],
                   o9: RowSetter[t9],
                   o10: RowSetter[t10]): RowSetter[u] =
        ap(lift9(f, o1, o2, o3, o4, o5, o6, o7, o8, o9), o10)

    pub def foldM(mf: (b, a) -> RowSetter[b], start: b, xs: List[a]): RowSetter[b] =
        RowSetter(r ->
            foldMHelper(r, mf, start, xs, e -> Err(e), ac -> Ok(ac))
        )

    def foldMHelper(r: OutputHandle,
                    mf: (b, a) -> RowSetter[b],
                    acc: b,
                    xs: List[a],
                    fk: String -> Result[b, String],
                    sk: b -> Result[b, String]): Result[b, String] & Impure =
        match xs {
            case Nil => sk(acc)
            case x :: rs => {
                let ma = mf(acc, x);
                match apply1(ma, r) {
                    case Err(e) => fk(e)
                    case Ok(acc1) => foldMHelper(r, mf, acc1, rs, fk, sk)
                }
            }
        }


}

