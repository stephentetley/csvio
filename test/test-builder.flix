
mod TestBuilder {

    use GradedApplicative.{point, *>};
    use CsvIO.CsvFormat;
   
    @test
    def testBuilder01(): Result[String, CsvFormat] =
        use CsvIO.CsvFormatBuilder.{toCsvFormat, setHeaders!, setEscape!, setDelimiter!, setTrim!};
        region r1 {
            let builder = 
                setHeaders!("Manufacturer" :: "Model" :: "Serial Number" :: Nil)
                    *> setEscape!('\\')
                    *> setDelimiter!(',')
                    *> setTrim!(true)
                ;
            toCsvFormat(r1, builder)
        }

}
