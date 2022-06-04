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


namespace CsvIO {

    ///
    /// Represents a CSVFormat.
    ///
    pub enum CsvFormat(##org.apache.commons.csv.CSVFormat)

}


namespace CsvIO/CsvFormat {

    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};

    pub enum QuoteMode with Eq, Order, ToString, Boxable, Hash {
        case All
        case AllNonNull
        case Minimal
        case NonNumeric
        case NoQuote
    }



    pub def marshalQuoteMode(x: QuoteMode): ##org.apache.commons.csv.QuoteMode = 
        import static get org.apache.commons.csv.QuoteMode.ALL: ##org.apache.commons.csv.QuoteMode & Pure as get_ALL;
        import static get org.apache.commons.csv.QuoteMode.ALL_NON_NULL: ##org.apache.commons.csv.QuoteMode & Pure as get_ALL_NON_NULL;
        import static get org.apache.commons.csv.QuoteMode.MINIMAL: ##org.apache.commons.csv.QuoteMode & Pure as get_MINIMAL;
        import static get org.apache.commons.csv.QuoteMode.NON_NUMERIC: ##org.apache.commons.csv.QuoteMode & Pure as get_NON_NUMERIC;
        import static get org.apache.commons.csv.QuoteMode.NONE: ##org.apache.commons.csv.QuoteMode & Pure as get_NONE;
        match x {
            case All            => get_ALL()
            case AllNonNull     => get_ALL_NON_NULL()
            case Minimal        => get_MINIMAL()
            case NonNumeric     => get_NON_NUMERIC()
            case NoQuote        => get_NONE()
        }


    def primEqualsQuoteMode(x: ##org.apache.commons.csv.QuoteMode, y: ##org.apache.commons.csv.QuoteMode): Bool =
        import java.lang.Enum.equals(##java.lang.Object): Bool & Pure;
        let x1 = x as ##java.lang.Enum;
        let y1 = y as ##java.lang.Object;
        equals(x1, y1)

    pub def unmarshalQuoteMode(x: ##org.apache.commons.csv.QuoteMode): QuoteMode = 
        import static get org.apache.commons.csv.QuoteMode.ALL: ##org.apache.commons.csv.QuoteMode & Pure as get_ALL;
        import static get org.apache.commons.csv.QuoteMode.ALL_NON_NULL: ##org.apache.commons.csv.QuoteMode & Pure as get_ALL_NON_NULL;
        import static get org.apache.commons.csv.QuoteMode.MINIMAL: ##org.apache.commons.csv.QuoteMode & Pure as get_MINIMAL;
        import static get org.apache.commons.csv.QuoteMode.NON_NUMERIC: ##org.apache.commons.csv.QuoteMode & Pure as get_NON_NUMERIC;
        import static get org.apache.commons.csv.QuoteMode.NONE: ##org.apache.commons.csv.QuoteMode & Pure as get_NONE;
        match x {
            case x1 if primEqualsQuoteMode(x1, get_ALL())          => All            
            case x1 if primEqualsQuoteMode(x1, get_ALL_NON_NULL()) => AllNonNull
            case x1 if primEqualsQuoteMode(x1, get_MINIMAL())      => Minimal
            case x1 if primEqualsQuoteMode(x1, get_NON_NUMERIC())  => NonNumeric
            case x1 if primEqualsQuoteMode(x1, get_NONE())         => NoQuote
        }


    pub def getCsvFormat(f: CsvFormat): ##org.apache.commons.csv.CSVFormat = 
        let CsvFormat(f1) = f;
        f1

    def makeFormatWithHeaders(format: ##org.apache.commons.csv.CSVFormat, headers: Array[String]): CsvFormat & Impure = 
        import new flixspt.csvio.FormatBuilder(##org.apache.commons.csv.CSVFormat, Int32): ##flixspt.csvio.FormatBuilder & Impure as newBuilder;
        import flixspt.csvio.FormatBuilder.setHeaderString(Int32, String): Unit & Impure;
        import flixspt.csvio.FormatBuilder.getCSVFormat(): ##org.apache.commons.csv.CSVFormat & Impure;
        try {
            let builder = newBuilder(format, Array.length(headers));
            Array.foreachWithIndex((x, ix) -> setHeaderString(builder, ix, x),  headers);
            CsvFormat(getCSVFormat(builder))
        } catch {
            case _: ##java.lang.Exception => bug!("CsvFormat.makeFormatWithHeaders should not fail...")
        }


    pub def defaultFormat(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.DEFAULT: ##org.apache.commons.csv.CSVFormat & Pure as get_DEFAULT;
        let javafmt = get_DEFAULT();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

 

    pub def excel(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.EXCEL: ##org.apache.commons.csv.CSVFormat & Pure as get_EXCEL;
        let javafmt = get_EXCEL();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def informix_unload(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.INFORMIX_UNLOAD: ##org.apache.commons.csv.CSVFormat & Pure as get_INFORMIX_UNLOAD;
        let javafmt = get_INFORMIX_UNLOAD();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def informix_unload_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.INFORMIX_UNLOAD_CSV: ##org.apache.commons.csv.CSVFormat & Pure as get_INFORMIX_UNLOAD_CSV;
        let javafmt = get_INFORMIX_UNLOAD_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mongodb_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.MONGODB_CSV: ##org.apache.commons.csv.CSVFormat & Pure as get_MONGODB_CSV;
        let javafmt = get_MONGODB_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mongodb_tsv(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.MONGODB_TSV: ##org.apache.commons.csv.CSVFormat & Pure as get_MONGODB_TSV;
        let javafmt = get_MONGODB_TSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mysql(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.MYSQL: ##org.apache.commons.csv.CSVFormat & Pure as get_MYSQL;
        let javafmt = get_MYSQL();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def oracle(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.ORACLE: ##org.apache.commons.csv.CSVFormat & Pure as get_ORACLE;
        let javafmt = get_ORACLE();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def postgresql_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.POSTGRESQL_CSV: ##org.apache.commons.csv.CSVFormat & Pure as get_POSTGRESQL_CSV;
        let javafmt = get_POSTGRESQL_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def postgresql_text(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.POSTGRESQL_TEXT: ##org.apache.commons.csv.CSVFormat & Pure as get_POSTGRESQL_TEXT;
        let javafmt = get_POSTGRESQL_TEXT();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def rfc4180(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.RFC4180: ##org.apache.commons.csv.CSVFormat & Pure as get_RFC4180;
        let javafmt = get_RFC4180();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def tdf(headers: Option[Array[String]]): CsvFormat & Impure =
        import static get org.apache.commons.csv.CSVFormat.TDF: ##org.apache.commons.csv.CSVFormat & Pure as get_TDF;
        let javafmt = get_TDF();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }


    pub def toString(x: CsvFormat): String =
        import org.apache.commons.csv.CSVFormat.toString(): String & Pure;
        let CsvFormat(x1) = x;
        toString(x1)

    pub def getAllowMissingColumnNames(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getAllowMissingColumnNames(): Bool & Pure;
        let CsvFormat(x1) = x;
        getAllowMissingColumnNames(x1)

    /// TODO is this Pure?
    pub def putAllowMissingColumnNames(x: CsvFormat, allow: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withAllowMissingColumnNames(Bool): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withAllowMissingColumnNames(x1, allow))

    pub def getDelimiter(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getDelimiter(): Char & Pure;
        let CsvFormat(x1) = x;
        getDelimiter(x1)

    pub def putDelimiter(x: CsvFormat, delimiter: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withDelimiter(Char): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withDelimiter(x1, delimiter))

    pub def getEscapeChar(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getEscapeCharacter(): ##java.lang.Character & Pure;
        import java.lang.Character.charValue(): Char & Pure;
        let CsvFormat(x1) = x;
        (x1 |> getEscapeCharacter |> charValue)

    pub def putEscapeChar(x: CsvFormat, escape: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withEscape(Char): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withEscape(x1, escape))


    pub def getIgnoreEmptyLines(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getIgnoreEmptyLines(): Bool & Pure;
        let CsvFormat(x1) = x;
        getIgnoreEmptyLines(x1)

    pub def putIgnoreEmptyLines(x: CsvFormat, ignore: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withIgnoreEmptyLines(Bool): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withIgnoreEmptyLines(x1, ignore))


    pub def getQuoteChar(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getQuoteCharacter(): ##java.lang.Character & Pure;
        import java.lang.Character.charValue(): Char & Pure;
        let CsvFormat(x1) = x;
        (x1 |> getQuoteCharacter |> charValue)

    pub def putQuoteChar(x: CsvFormat, quote: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withQuote(Char): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withQuote(x1, quote))

    pub def getSkipHeaderRecord(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getSkipHeaderRecord(): Bool & Pure;
        let CsvFormat(x1) = x;
        getSkipHeaderRecord(x1)

    pub def putSkipHeaderRecord(x: CsvFormat, skip: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withSkipHeaderRecord(Bool): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withSkipHeaderRecord(x1, skip))

    pub def getTrim(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getTrim(): Bool & Pure;
        let CsvFormat(x1) = x;
        getTrim(x1)

    pub def putTrim(x: CsvFormat, trim: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withTrim(Bool): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withTrim(x1, trim))

    pub def putFirstRecordAsHeader(x: CsvFormat): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withFirstRecordAsHeader(): ##org.apache.commons.csv.CSVFormat & Pure;
        let CsvFormat(x1) = x;
        CsvFormat(withFirstRecordAsHeader(x1))

}
