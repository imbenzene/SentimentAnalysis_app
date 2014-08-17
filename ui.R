shinyUI(pageWithSidebar(
  headerPanel("Sentiment Analysis Tool"),
  
  sidebarPanel(width=3,
     fileInput('datafile', 'Upload the csv/txt file',
                accept='csv'),
     helpText("Note: You can download the sample file from the help section"),
     #,textInput('corpus', 'Please enter the text', value = "type...")
     radioButtons("Method", "Select method",
                  c("In-house Method" = "In-house Method",
                    "DatumBox API" = "DatumBox API")),
     downloadButton('downloadData', 'Download'),
     
     helpText("Download the Table")
  ),
  
mainPanel(
  tabsetPanel(
    tabPanel('Sentiment Scores',
             dataTableOutput(outputId="table")),
    tabPanel('Help', HTML('<p>
    <strong>How to Use this Application</strong>
</p>
                          <p>
                          Sample file for testing the application can be downloaded <a href="https://www.dropbox.com/s/40tvapoim2nxx1k/foo.csv">here</a>.
                          </p>
                          <p>
                          <strong>Step 1</strong>
                          </p>
                          <p>
                          Upload the text (csv/txt file) for which you want to apply sentiment analysis. (Each line will considered as one document piece. Current delimiter is \n.
                          Future versions of the application will be have custom delimiter as option.)
                          </p>
                          <p>
                          <strong>Step2</strong>
                          </p>
                          <p>
                          By default the method is in-house based on simple bag of words. You can select Datumbox API as well. It will be a little slow, each document makes an API
                          call, taking about an sec.
                          </p>
                          <p>
                          <strong>Methods</strong>
                          </p>
                          <p>
                          <strong>1] In-house method</strong>
                          </p>
                          <p>
                          Use the positive and negative corpuses available for download <a href="http://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html">here</a>. Simple bad of
                          words approach, comparing number of positive and negative words in the documents and scoring based on sum(#positive) – sum(#negative). Works efficiently,
                          but not super sophisticated. Might fail on complex grammers.
                          </p>
                          <p>
                          <strong>2] Datum-box API</strong>
                          </p>
                          <p>
                          I am on a free tier account. Limit of 1000 calls per day. Might fail when crosses that limit when using this application. Expect it to be a little slow,
                          each API call for each document takes about a sec.
                          </p>
                          <p>
                          <strong>Contact Me</strong>
                          </p>
                          <p>
                          You can reach out to me on <a href="mailto:imbenzene@gmail.com">imbenzene@gmail.com</a> with the feedback, I would be happy to incorporate changes in the
    future version of the application.
</p> 
                          '))
        
        )
  )
))