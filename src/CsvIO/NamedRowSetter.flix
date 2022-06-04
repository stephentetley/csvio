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

    pub enum NamedRowSetter[a]((Map[String, Int32], OutputHandle) -> Result[a, String] & Impure)

    instance Functor[NamedRowSetter] {
        pub def map(f: a -> b & ef, x: NamedRowSetter[a]): NamedRowSetter[b] & ef =
            CsvIO/NamedRowSetter.map(f, x)
    }

    instance Applicative[NamedRowSetter] {
        pub def point(x: a): NamedRowSetter[a] = 
            CsvIO/NamedRowSetter.point(x)

        pub def ap(mf: NamedRowSetter[a -> b & ef], ma: NamedRowSetter[a]): NamedRowSetter[b] & ef =
            CsvIO/NamedRowSetter.ap(mf, ma)
    }

    instance Monad[NamedRowSetter] {
        pub def flatMap(k: a -> NamedRowSetter[b] & ef, x: NamedRowSetter[a]): NamedRowSetter[b] & ef =
            CsvIO/NamedRowSetter.flatMap(k, x)
    }    


}

namespace CsvIO/NamedRowSetter {


    use CsvIO.NamedRowSetter;
    use CsvIO.NamedRowSetter.{NamedRowSetter};

    use CsvIO/Internal.OutputHandle;
    use CsvIO/Internal.OutputHandle.{OutputHandle};

    pub def point(x: a): NamedRowSetter[a] =
        NamedRowSetter((_,_) -> Ok(x) as & Impure)

    def apply1(x: NamedRowSetter[a], headers: Map[String, Int32], r: OutputHandle): Result[a, String] & Impure =
        let NamedRowSetter(f) = x;
        f(headers, r)

    pub def map(f: a -> b & ef, x: NamedRowSetter[a]): NamedRowSetter[b] & ef =
        NamedRowSetter((hdrs, r) ->
            match apply1(x, hdrs, r) {
                case Ok(a) => {
                    let ans = f(a) as & Impure;
                    Ok(ans)
                }
                case Err(e) => Err(e)
            }
        ) as & ef

    pub def ap(mf: NamedRowSetter[a -> b & ef], ma: NamedRowSetter[a]): NamedRowSetter[b] & ef =
        NamedRowSetter((hdrs, r) ->
            match apply1(mf, hdrs, r) {
                case Ok(f) => {
                    match apply1(ma, hdrs, r) {
                        case Ok(a) => Ok(f(a) as & Impure)
                        case Err(e2) => Err(e2)
                    }
                }
                case Err(e1) => Err(e1)
            }
        ) as & ef

    pub def flatMap(k: a -> NamedRowSetter[b] & ef, x: NamedRowSetter[a]): NamedRowSetter[b] & ef = 
        NamedRowSetter((hdrs, r) ->
            match apply1(x, hdrs, r) {
                case Ok(a) => { let ans = k(a); apply1(ans, hdrs, r) }
                case Err(e) => Err(e)
            }
        ) as & ef

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



}

