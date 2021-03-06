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

import java.util.ArrayList;
import org.apache.commons.csv.CSVFormat;

public class BuilderVarargs {

    public static CSVFormat.Builder setHeaderEmpty(CSVFormat.Builder builder) throws Exception {
        String[] arr = new String[0];
        return builder.setHeader(arr);
    }

    public static CSVFormat.Builder setHeader(CSVFormat.Builder builder, ArrayList<String> headers) throws Exception {
        String[] arr = headers.toArray(new String[0]);
        return builder.setHeader(arr);
    }

    public static CSVFormat.Builder setHeaderComments(CSVFormat.Builder builder, ArrayList<String> headers) throws Exception {
        String[] arr = headers.toArray(new String[0]);
        return builder.setHeaderComments(arr);
    }

}

