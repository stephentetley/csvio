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

import org.apache.commons.csv.*;
import org.apache.commons.io.input.BOMInputStream;

import java.io.*;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.util.Iterator;

public class ReadIterator {

    private Reader inputReader;
    private Iterator<CSVRecord> csvIterator;

    // 0 DEFAULT
    // 1 EXCEL
    // 2 INFORMIX_UNLOAD
    // 3 INFORMIX_UNLOAD_CSV
    // 4 MONGODB_CSV
    // 5 MONGODB_TSV
    // 6 MYSQL
    // 7 RFC4180
    // 8 ORACLE
    // 9 POSTGRESQL_CSV
    // 10 POSTGRESQL_TEXT
    // 11 TDF
    private CSVFormat selectFormat(int fmt) {
        switch (fmt) {
            case 1:
                return CSVFormat.EXCEL;
            case 2:
                return CSVFormat.INFORMIX_UNLOAD;
            case 3:
                return CSVFormat.INFORMIX_UNLOAD_CSV;
            case 4:
                return CSVFormat.MONGODB_CSV;
            case 5:
                return CSVFormat.MONGODB_TSV;
            case 6:
                return CSVFormat.MYSQL;
            case 7:
                return CSVFormat.RFC4180;
            case 8:
                return CSVFormat.ORACLE;
            case 9:
                return CSVFormat.POSTGRESQL_CSV;
            case 10:
                return CSVFormat.POSTGRESQL_TEXT;
            case 11:
                return CSVFormat.TDF;
            default:
                return CSVFormat.DEFAULT;
        }
    }

    protected ReadIterator(Reader reader, CSVFormat format) throws Exception {
        inputReader = reader;
        Iterable<CSVRecord> iterable = format.parse(inputReader);
        csvIterator = iterable.iterator();
    }


    public static ReadIterator createIterForFile(Path path, CSVFormat format, Charset cs) throws Exception {
        FileInputStream instream = new FileInputStream(path.toFile());
        Reader reader = new InputStreamReader(instream, cs);
        return new ReadIterator(reader, format);
    }

    /// Call this factory method for Excel created files...
    public static ReadIterator createIterForBOMFile(Path path, CSVFormat format) throws Exception {
        InputStream instream = new FileInputStream(path.toFile());
        BOMInputStream bomInstream = new BOMInputStream(instream);
        String csname = bomInstream.getBOMCharsetName();
        if (csname == null) csname = "UTF-16";
        Charset charset = Charset.forName(csname);
        Reader reader = new InputStreamReader(bomInstream, charset);
        return new ReadIterator(reader, format);
    }

    public boolean hasNext() {
        return csvIterator.hasNext();
    }

    public InputRow next() throws Exception {
        InputRow row = new InputRow(csvIterator.next());
        return row;
    }

    // NOTE - explicit close
    public void close() throws IOException {
        inputReader.close();
    }

}
