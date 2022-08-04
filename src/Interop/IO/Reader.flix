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

namespace Interop/IO {

    /// Abstract class...

    pub enum Reader[_: Region](##java.io.Reader)

    instance Scoped[Reader] {
        pub def regionOf(_: Reader[r]): Region[r] = () as Region[r]
    }

    pub class SubReader[t: Region -> Type] {
        pub def ucast[r: Region](s: t[r]): Reader[r]
        pub def dcast[r: Region](s: Reader[r]): t[r]
    }

}

namespace Interop/IO/Reader {

    use Interop/IO.Reader;
    use Interop/IO.Reader.{Reader};



    pub def getHH(rd: Reader[r]): ##java.io.Reader = 
        let Reader(rd1) = rd;
        rd1



}
