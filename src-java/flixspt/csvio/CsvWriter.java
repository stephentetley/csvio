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

import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.ArrayList;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.io.ByteOrderMark;


public class CsvWriter {

    private final Writer outputHandle;
    private final CSVPrinter rowPrinter;

    protected CsvWriter(Writer outputw, CSVFormat format) throws Exception {
        outputHandle = outputw;
        rowPrinter = format.print(outputw);
        return;
    }
    public static CsvWriter createCsvWriter(Path filepath, CSVFormat format, Charset cs) throws Exception {
        OutputStreamWriter outputw = new OutputStreamWriter(new FileOutputStream(filepath.toFile()), cs);
        return new CsvWriter(outputw, format);
    }

    public static CsvWriter createCsvWriterWithBOM(Path filepath, CSVFormat format, Charset cs) throws Exception {
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
        return new CsvWriter(outputw, format);
    }

    public void close() throws Exception {
        outputHandle.close();
    }

    /// ArrayList easy to marshal
    public void writeRowOfObjects(ArrayList<Object> row) throws Exception {
        Object[] cells = row.toArray(new Object[0]);
        rowPrinter.printRecord(cells);
    }


}
