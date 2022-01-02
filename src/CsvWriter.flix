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


namespace CsvIO/CsvWriter {
    
    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};
    use CsvIO.RowSetter;
    use CsvIO/Internal.OutputHandle;


    ///
    /// outputIndexedCsv.
    /// TODO add optional headings 
    ///
    pub def outputColumnIndexedCsv!(format: CsvFormat,
                        cs: Text.Charset,
                        path: System.FilePath,
                        columnCount: Int32,
                        rowWriter: a -> RowSetter[b],
                        iter: Iterator[Result[a, String]]): Result[Unit, String] & Impure =
        use Result.flatMap;
        let CsvFormat(format1) = format;
        let* handle = CsvIO/Internal/OutputHandle.new(format1, columnCount, cs, path);
        let _       = 
            Iterator.foreach(x1 -> match x1 {
                case Err(_) => () as & Impure
                case Ok(row) => writeRow(row, rowWriter, handle) |> constant(())
            }, iter);
        let* _      = CsvIO/Internal/OutputHandle.close!(handle);
        Ok()


    pub def outputColumnIndexedCsvWithBOM!(format: CsvFormat,
                        cs: Text.Charset,
                        path: System.FilePath,
                        columnCount: Int32,
                        rowWriter: a -> RowSetter[b],
                        iter: Iterator[Result[a, String]]): Result[Unit, String] & Impure =
        use Result.flatMap;
        let CsvFormat(format1) = format;
        let* handle = CsvIO/Internal/OutputHandle.newWithBOM(format1, columnCount, cs, path);
        let _       = 
            Iterator.foreach(x1 -> match x1 {
                case Err(_) => () as & Impure
                case Ok(row) => writeRow(row, rowWriter, handle) |> constant(())
            }, iter);
        let* _      = CsvIO/Internal/OutputHandle.close!(handle);
        Ok()

    def writeRow(row: a, rowWriter: a -> RowSetter[b], handle: OutputHandle): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* _ = CsvIO/Internal/OutputHandle.clearCells!(handle);
        let* _ = CsvIO/RowSetter.runRowSetter!(rowWriter(row), handle);
        let* _ = CsvIO/Internal/OutputHandle.writeRow!(handle);
        Ok()




    /// TODO to N=15
    pub def row2(a: t1, b: t2): RowSetter[Unit] with ToString[t1], ToString[t2] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        point()

    pub def row3(a: t1, b: t2, c: t3): RowSetter[Unit] with ToString[t1], ToString[t2], ToString[t3] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        point()

    pub def row4(a: t1, b: t2, c: t3, d: t4): RowSetter[Unit] with ToString[t1], ToString[t2], ToString[t3], ToString[t4] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        point()

    pub def row5(a: t1, b: t2, c: t3, d: t4, e: t5): RowSetter[Unit] with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        point()

    pub def row6(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        point()

    pub def row7(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        point()

    pub def row8(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        point()

    pub def row9(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        point()

    pub def row10(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        point()

    pub def row11(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10, k: t11): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10], ToString[t11] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        let* _ = putItem!(10, k);
        point()

    pub def row12(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10, k: t11, l: t12): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10], ToString[t11], ToString[t12] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        let* _ = putItem!(10, k);
        let* _ = putItem!(11, l);
        point()

    pub def row13(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10, k: t11, l: t12, m: t13): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10], ToString[t11], ToString[t12], ToString[t13] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        let* _ = putItem!(10, k);
        let* _ = putItem!(11, l);
        let* _ = putItem!(12, m);
        point()

    pub def row14(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10, k: t11, l: t12, m: t13, n: t14): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10], ToString[t11], ToString[t12], ToString[t13], ToString[t14] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        let* _ = putItem!(10, k);
        let* _ = putItem!(11, l);
        let* _ = putItem!(12, m);
        let* _ = putItem!(13, n);
        point()

    pub def row15(a: t1, b: t2, c: t3, d: t4, e: t5, f: t6, g: t7, h: t8, i: t9, j: t10, k: t11, l: t12, m: t13, n: t14, o: t15): RowSetter[Unit] 
        with ToString[t1], ToString[t2], ToString[t3], ToString[t4], ToString[t5], ToString[t6], ToString[t7], ToString[t8], ToString[t9], ToString[t10], ToString[t11], ToString[t12], ToString[t13], ToString[t14], ToString[t15] = 
        use CsvIO/RowSetter.{flatMap, putItem!, point};
        let* _ = putItem!(0, a);
        let* _ = putItem!(1, b);
        let* _ = putItem!(2, c);
        let* _ = putItem!(3, d);
        let* _ = putItem!(4, e);
        let* _ = putItem!(5, f);
        let* _ = putItem!(6, g);
        let* _ = putItem!(7, h);
        let* _ = putItem!(8, i);
        let* _ = putItem!(9, j);
        let* _ = putItem!(10, k);
        let* _ = putItem!(11, l);
        let* _ = putItem!(12, m);
        let* _ = putItem!(13, n);
        let* _ = putItem!(14, o);
        point()

}
