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


mod CsvIO {

    ///
    /// Represents a CSVFormat.
    ///
    pub enum CsvFormat(##org.apache.commons.csv.CSVFormat)

}


mod CsvIO.CsvFormat {

    use CsvIO.CsvFormat
    use CsvIO.CsvFormat.{CsvFormat}
    use CsvIO.CsvFormat.QuoteMode
    use CsvIO.CsvFormat.QuoteMode.{
        All, AllNonNull, Minimal, NonNumeric, NoQuote
    }
    use CsvIO.CsvFormat.PredefinedFormat
    use CsvIO.CsvFormat.PredefinedFormat.{
        DEFAULT, EXCEL, INFORMIX_UNLOAD, INFORMIX_UNLOAD_CSV,
        MONGODB_CSV, MONGODB_TSV, MYSQL, ORACLE,
        RFC4180, POSTGRESQL_CSV, POSTGRESQL_TEXT, TDF
    }

    pub enum QuoteMode with Eq, Order, ToString, Hash {
        case All
        case AllNonNull
        case Minimal
        case NonNumeric
        case NoQuote
    }

    pub def marshalQuoteMode(x: QuoteMode): ##org.apache.commons.csv.QuoteMode = 
        import static get org.apache.commons.csv.QuoteMode.ALL: ##org.apache.commons.csv.QuoteMode \ {} as get_ALL;
        import static get org.apache.commons.csv.QuoteMode.ALL_NON_NULL: ##org.apache.commons.csv.QuoteMode \ {} as get_ALL_NON_NULL;
        import static get org.apache.commons.csv.QuoteMode.MINIMAL: ##org.apache.commons.csv.QuoteMode \ {} as get_MINIMAL;
        import static get org.apache.commons.csv.QuoteMode.NON_NUMERIC: ##org.apache.commons.csv.QuoteMode \ {} as get_NON_NUMERIC;
        import static get org.apache.commons.csv.QuoteMode.NONE: ##org.apache.commons.csv.QuoteMode \ {} as get_NONE;
        match x {
            case All            => get_ALL()
            case AllNonNull     => get_ALL_NON_NULL()
            case Minimal        => get_MINIMAL()
            case NonNumeric     => get_NON_NUMERIC()
            case NoQuote        => get_NONE()
        }


    def primEqualsQuoteMode(x: ##org.apache.commons.csv.QuoteMode, y: ##org.apache.commons.csv.QuoteMode): Bool =
        import java.lang.Enum.equals(##java.lang.Object): Bool \ {};
        let x1: ##java.lang.Enum = checked_cast(x);
        let y1: ##java.lang.Object = checked_cast(y);
        equals(x1, y1)

    pub def unmarshalQuoteMode(x: ##org.apache.commons.csv.QuoteMode): QuoteMode = 
        import static get org.apache.commons.csv.QuoteMode.ALL: ##org.apache.commons.csv.QuoteMode \ {} as get_ALL;
        import static get org.apache.commons.csv.QuoteMode.ALL_NON_NULL: ##org.apache.commons.csv.QuoteMode \ {} as get_ALL_NON_NULL;
        import static get org.apache.commons.csv.QuoteMode.MINIMAL: ##org.apache.commons.csv.QuoteMode \ {} as get_MINIMAL;
        import static get org.apache.commons.csv.QuoteMode.NON_NUMERIC: ##org.apache.commons.csv.QuoteMode \ {} as get_NON_NUMERIC;
        import static get org.apache.commons.csv.QuoteMode.NONE: ##org.apache.commons.csv.QuoteMode \ {} as get_NONE;
        match x {
            case x1 if primEqualsQuoteMode(x1, get_ALL())           => All            
            case x1 if primEqualsQuoteMode(x1, get_ALL_NON_NULL())  => AllNonNull
            case x1 if primEqualsQuoteMode(x1, get_MINIMAL())       => Minimal
            case x1 if primEqualsQuoteMode(x1, get_NON_NUMERIC())   => NonNumeric
            case x1 if primEqualsQuoteMode(x1, get_NONE())          => NoQuote
            case _                                                  => bug!("unmarshalQuoteMode")
        }


    pub def getHH(f: CsvFormat): ##org.apache.commons.csv.CSVFormat = 
        let CsvFormat(f1) = f;
        f1

    pub def toCSVFormat(f: CsvFormat): CsvIO.Internal.Apache.Commons.Csv.CSVFormat = 
        use CsvIO.Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat};
        let CsvFormat(f1) = f;
        CSVFormat(f1)

    pub def fromCSVFormat(f: CsvIO.Internal.Apache.Commons.Csv.CSVFormat): CsvFormat = 
        use CsvIO.Internal.Apache.Commons.Csv.CSVFormat.{CSVFormat};
        let CSVFormat(f1) = f;
        CsvFormat(f1)


    pub enum PredefinedFormat with Eq, Order, ToString, Hash {
        case DEFAULT
        case EXCEL
        case INFORMIX_UNLOAD
        case INFORMIX_UNLOAD_CSV
        case MONGODB_CSV
        case MONGODB_TSV
        case MYSQL
        case ORACLE
        case RFC4180
        case POSTGRESQL_CSV
        case POSTGRESQL_TEXT
        case TDF
    }


    pub def makeCsvFormat(format: PredefinedFormat): CsvFormat = 
        match format {
            case DEFAULT                => {
                import static get org.apache.commons.csv.CSVFormat.DEFAULT: ##org.apache.commons.csv.CSVFormat \ {} as get_DEFAULT;
                get_DEFAULT()
            }
            case EXCEL                  => {
                import static get org.apache.commons.csv.CSVFormat.EXCEL: ##org.apache.commons.csv.CSVFormat \ {} as get_EXCEL;
                get_EXCEL()
            }
            case INFORMIX_UNLOAD        => {
                import static get org.apache.commons.csv.CSVFormat.INFORMIX_UNLOAD: ##org.apache.commons.csv.CSVFormat \ {} as get_INFORMIX_UNLOAD;
                get_INFORMIX_UNLOAD()
            }
            case INFORMIX_UNLOAD_CSV    => {
                import static get org.apache.commons.csv.CSVFormat.INFORMIX_UNLOAD_CSV: ##org.apache.commons.csv.CSVFormat \ {} as get_INFORMIX_UNLOAD_CSV;
                get_INFORMIX_UNLOAD_CSV()
            }
            case MONGODB_CSV            => {
                import static get org.apache.commons.csv.CSVFormat.MONGODB_CSV: ##org.apache.commons.csv.CSVFormat \ {} as get_MONGODB_CSV;
                get_MONGODB_CSV()
            }
            case MONGODB_TSV            => {
                import static get org.apache.commons.csv.CSVFormat.MONGODB_TSV: ##org.apache.commons.csv.CSVFormat \ {} as get_MONGODB_TSV;
                get_MONGODB_TSV()
            }        
            case MYSQL                  => {
                import static get org.apache.commons.csv.CSVFormat.MYSQL: ##org.apache.commons.csv.CSVFormat \ {} as get_MYSQL;
                get_MYSQL()
            }
            case ORACLE     => {
                import static get org.apache.commons.csv.CSVFormat.ORACLE: ##org.apache.commons.csv.CSVFormat \ {} as get_ORACLE;
                get_ORACLE()        
            }
            case POSTGRESQL_CSV => {
                import static get org.apache.commons.csv.CSVFormat.POSTGRESQL_CSV: ##org.apache.commons.csv.CSVFormat \ {} as get_POSTGRESQL_CSV;
                get_POSTGRESQL_CSV()
            }
            case POSTGRESQL_TEXT => {
                import static get org.apache.commons.csv.CSVFormat.POSTGRESQL_TEXT: ##org.apache.commons.csv.CSVFormat \ {} as get_POSTGRESQL_TEXT;
                get_POSTGRESQL_TEXT()
            }
            case RFC4180    => {
                import static get org.apache.commons.csv.CSVFormat.RFC4180: ##org.apache.commons.csv.CSVFormat \ {} as get_RFC4180;
                get_RFC4180()
            }
            case TDF    => {
                import static get org.apache.commons.csv.CSVFormat.TDF: ##org.apache.commons.csv.CSVFormat \ {} as get_TDF;
                get_TDF()
            }
        } |> CsvFormat
        
        



    pub def makeCsvFormatWithHeaders(format: PredefinedFormat, headers: List[String]): Result[String, CsvFormat] =
        region r1 {
            CsvIO.CsvFormatBuilder.toCsvFormatWithCsvFormat(r1, makeCsvFormat(format), CsvIO.CsvFormatBuilder.setHeaders!(headers))
        }

}
