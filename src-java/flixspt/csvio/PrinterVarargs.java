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

package flixspt.csvio;

import java.io.IOException;
import java.util.ArrayList;
import org.apache.commons.csv.CSVPrinter;

public class PrinterVarargs {

    public static void printRecordOfObjects(CSVPrinter printer, ArrayList<Object> values) throws IOException {
        Object[] arr = values.toArray();
        printer.printRecord(arr);
    }

    public static void printRecordOfStrings(CSVPrinter printer, ArrayList<String> values) throws IOException {
        Object[] arr = values.toArray();
        printer.printRecord(arr);
    }

}

