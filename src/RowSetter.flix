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

    pub opaque type RowSetter[a] = OutputHandle -> Result[a, String] & Impure

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

