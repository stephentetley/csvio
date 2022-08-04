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

    use Interop/IO.InputStream;
    use Interop/IO.InputStream.{InputStream};

    pub enum FileInputStream[_: Region](##java.io.FileInputStream)

    instance Scoped[FileInputStream] {
        pub def regionOf(_: FileInputStream[r]): Region[r] = () as Region[r]
    }


    instance Interop/IO.SubInputStream[FileInputStream] {
        pub def ucast(s: FileInputStream[r]): InputStream[r] = 
            let FileInputStream(s1) = s;
            InputStream(s1 as ##java.io.InputStream)

        pub def dcast(s: InputStream[r]): FileInputStream[r] = 
            let InputStream(s1) = s;
            FileInputStream(s1 as ##java.io.FileInputStream) 
    }


}

namespace Interop/IO/FileInputStream {

    use Interop/IO.FileInputStream;
    use Interop/IO.FileInputStream.{FileInputStream};

    pub def getFileInputStream(ins: FileInputStream[r]): ##java.io.FileInputStream = 
        let FileInputStream(ins1) = ins;
        ins1

    pub def newFileInputStream(_: Region[r], file: ##java.io.File): Result[FileInputStream[r], String] \ {Write(r), IO} = 
        try {
            import new java.io.FileInputStream(##java.io.File): ##java.io.FileInputStream \ IO as newFileInputStream;
            FileInputStream(newFileInputStream(file)) |> Ok
        } catch {
            case ex: ##java.io.IOException =>
                import java.lang.Throwable.getMessage(): String & r;
                Err(getMessage(ex))
        }

}
