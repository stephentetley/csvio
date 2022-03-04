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

package flixspt.csvio;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.io.ByteOrderMark;

import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.Arrays;

public class CsvWriter {

    /// This is a nested writer "handle".
    /// There are two levels - at the `row` we set individual cells;
    /// at the `printer` level we write a row to the output stream.
    /// The handle `outw` is at class level so we can close it manually.
    /// The decision not to move a row represented as Array[String] from
    /// Flix to Java was due to a runtime errors in the (automatic)
    /// marshalling which might not still be present.
    private final Writer outw;
    private final CSVPrinter printer;
    private final String[] row;

    protected CsvWriter(Writer outputw, CSVFormat format, int cellCount) throws Exception {
        outw = outputw;
        printer = format.print(outw);
        row = new String[cellCount];
        return;
    }

    public static CsvWriter createCsvWriter(Path filepath, CSVFormat format, int cellCount, Charset cs) throws Exception {
        OutputStreamWriter outputw = new OutputStreamWriter(new FileOutputStream(filepath.toFile()), cs);
        return new CsvWriter(outputw, format, cellCount);
    }

    public static CsvWriter createCsvWriterWithBOM(Path filepath, CSVFormat format, int cellCount, Charset cs) throws Exception {
        OutputStreamWriter outputw = new OutputStreamWriter(new FileOutputStream(filepath.toFile()), cs);
        byte[] bom;
        String boms = "";
        if (cs == StandardCharsets.UTF_8) {
            bom = ByteOrderMark.UTF_8.getBytes();
            boms = new String(bom, StandardCharsets.UTF_8);
        } else if (cs == StandardCharsets.UTF_16LE) {
            bom = ByteOrderMark.UTF_16LE.getBytes();
            boms = new String(bom, StandardCharsets.UTF_16LE);
        } else if (cs == StandardCharsets.UTF_16BE) {
            bom = ByteOrderMark.UTF_16BE.getBytes();
            boms = new String(bom, StandardCharsets.UTF_16BE);
        } else {
            bom = new byte[0];
        }
        outputw.write(boms);
        return new CsvWriter(outputw, format, cellCount);
    }

    public void setCellString(int ix, String value) {
        row[ix] = value;
    }

    public void writeRow() throws Exception {
        Iterable<String> cells = Arrays.asList(row);
        printer.printRecord(cells);
    }

    public void clearCells() throws Exception {
        Arrays.fill(row, "");
    }

    public void close() throws Exception {
        outw.close();
    }

}
