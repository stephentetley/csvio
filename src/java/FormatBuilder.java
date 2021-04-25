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

package flix.runtime.spt.csvio;

import org.apache.commons.csv.CSVFormat;

import java.util.Arrays;

public class FormatBuilder {

    private final String[] headers;

    private final CSVFormat format;

    public FormatBuilder(CSVFormat fmt, int cellCount) throws Exception {
        format = fmt;
        headers = new String[cellCount];
        Arrays.fill(headers, "");
        return;
    }

    public void setHeaderString(int ix, String value) {
        if (ix >= 0 && ix <= headers.length) {
            headers[ix] = value;
        }
    }


    public CSVFormat getCSVFormat() {
        if (headers.length > 0) {
            return format.withHeader(headers);
        } else {
            return format;
        }
    }
}
