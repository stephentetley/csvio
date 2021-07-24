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
    pub opaque type CsvFormat = ##org.apache.commons.csv.CSVFormat

}


namespace CsvIO/CsvFormat {

    use CsvIO.CsvFormat;
    use CsvIO.CsvFormat.{CsvFormat};

    pub enum QuoteMode {
        case All,
        case AllNonNull,
        case Minimal,
        case NonNumeric,
        case NoQuote
    }


    def makeFormatWithHeaders(format: ##org.apache.commons.csv.CSVFormat, headers: Array[String]): CsvFormat & Impure = 
        import new flix.runtime.spt.csvio.FormatBuilder(##org.apache.commons.csv.CSVFormat, Int) as newBuilder;
        import flix.runtime.spt.csvio.FormatBuilder.setHeaderString(Int, String);
        import flix.runtime.spt.csvio.FormatBuilder.getCSVFormat();
        try {
            let builder = newBuilder(format, Array.length(headers));
            Array.foreachWithIndex((x, ix) -> setHeaderString(builder, ix, x),  headers);
            CsvFormat(getCSVFormat(builder))
        } catch {
            case _: ##java.lang.Exception => bug!("CsvFormat.makeFormatWithHeaders should not fail...")
        }


    pub def defaultFormat(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:DEFAULT as get_DEFAULT;
        let javafmt = get_DEFAULT();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

 

    pub def excel(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:EXCEL as get_EXCEL;
        let javafmt = get_EXCEL();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def informix_unload(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:INFORMIX_UNLOAD as get_INFORMIX_UNLOAD;
        let javafmt = get_INFORMIX_UNLOAD();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def informix_unload_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:INFORMIX_UNLOAD_CSV as get_INFORMIX_UNLOAD_CSV;
        let javafmt = get_INFORMIX_UNLOAD_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mongodb_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:MONGODB_CSV as get_MONGODB_CSV;
        let javafmt = get_MONGODB_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mongodb_tsv(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:MONGODB_TSV as get_MONGODB_TSV;
        let javafmt = get_MONGODB_TSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def mysql(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:MYSQL as get_MYSQL;
        let javafmt = get_MYSQL();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def oracle(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:ORACLE as get_ORACLE;
        let javafmt = get_ORACLE();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def postgresql_csv(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:POSTGRESQL_CSV as get_POSTGRESQL_CSV;
        let javafmt = get_POSTGRESQL_CSV();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def postgresql_text(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:POSTGRESQL_TEXT as get_POSTGRESQL_TEXT;
        let javafmt = get_POSTGRESQL_TEXT();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def rfc4180(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:RFC4180 as get_RFC4180;
        let javafmt = get_RFC4180();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }

    pub def tdf(headers: Option[Array[String]]): CsvFormat & Impure =
        import get org.apache.commons.csv.CSVFormat:TDF as get_TDF;
        let javafmt = get_TDF();
        match headers { 
            case Some(arr) => makeFormatWithHeaders(javafmt, arr)
            case None => CsvFormat(javafmt)
        }


    pub def toString(x: CsvFormat): String =
        import org.apache.commons.csv.CSVFormat.toString();
        let CsvFormat(x1) = x;
        x1.toString() as & Pure

    pub def getAllowMissingColumnNames(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getAllowMissingColumnNames();
        let CsvFormat(x1) = x;
        x1.getAllowMissingColumnNames() as & Pure

    pub def putAllowMissingColumnNames(x: CsvFormat, allow: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withAllowMissingColumnNames(Bool);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withAllowMissingColumnNames(allow)) as & Pure

    pub def getDelimiter(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getDelimiter();
        let CsvFormat(x1) = x;
        x1.getDelimiter() as & Pure

    pub def putDelimiter(x: CsvFormat, delimiter: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withDelimiter(Char);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withDelimiter(delimiter)) as & Pure

    pub def getEscapeChar(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getEscapeCharacter();
        import java.lang.Character.charValue();
        let CsvFormat(x1) = x;
        x1.getEscapeCharacter().charValue() as & Pure

    pub def putEscapeChar(x: CsvFormat, escape: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withEscape(Char);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withEscape(escape)) as & Pure


    pub def getIgnoreEmptyLines(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getIgnoreEmptyLines();
        let CsvFormat(x1) = x;
        x1.getIgnoreEmptyLines() as & Pure

    pub def putIgnoreEmptyLines(x: CsvFormat, ignore: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withIgnoreEmptyLines(Bool);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withIgnoreEmptyLines(ignore)) as & Pure


    pub def getQuoteChar(x: CsvFormat): Char =
        import org.apache.commons.csv.CSVFormat.getQuoteCharacter();
        import java.lang.Character.charValue();
        let CsvFormat(x1) = x;
        x1.getQuoteCharacter().charValue() as & Pure

    pub def putQuoteChar(x: CsvFormat, quote: Char): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withQuote(Char);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withQuote(quote)) as & Pure

    pub def getSkipHeaderRecord(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getSkipHeaderRecord();
        let CsvFormat(x1) = x;
        x1.getSkipHeaderRecord() as & Pure

    pub def putSkipHeaderRecord(x: CsvFormat, skip: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withSkipHeaderRecord(Bool);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withSkipHeaderRecord(skip)) as & Pure

    pub def getTrim(x: CsvFormat): Bool =
        import org.apache.commons.csv.CSVFormat.getTrim();
        let CsvFormat(x1) = x;
        x1.getTrim() as & Pure

    pub def putTrim(x: CsvFormat, trim: Bool): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withTrim(Bool);
        let CsvFormat(x1) = x;
        CsvFormat(x1.withTrim(trim)) as & Pure

    pub def putFirstRecordAsHeader(x: CsvFormat): CsvFormat =
        import org.apache.commons.csv.CSVFormat.withFirstRecordAsHeader();
        let CsvFormat(x1) = x;
        CsvFormat(x1.withFirstRecordAsHeader()) as & Pure

}
