# save(pos.words, file = "pos.words.rda")
# save(neg.words, file = "neg.words.rda")
require(plyr) 
require(stringr)
library(RCurl)
library(RJSONIO)
load(file = "pos.words.rda")
load(file = "neg.words.rda")
score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{ 
  
  scores = laply(sentences, function(sentence, pos.words, neg.words) {   
    # clean up sentences with R's regex-driven global substitute, gsub():    
    sentence = gsub('[[:punct:]]', '', sentence)    
    sentence = gsub('[[:cntrl:]]', '', sentence)    
    sentence = gsub('\\d+', '', sentence)    
    # and convert to lower case:    
    sentence = tolower(sentence)    
    # split into words. str_split is in the stringr package    
    word.list = str_split(sentence, '\\s+')    
    # sometimes a list() is one level of hierarchy too much    
    words = unlist(word.list)   
    # compare our words to the dictionaries of positive & negative terms    
    pos.matches = match(words, pos.words)   
    neg.matches = match(words, neg.words)   
    # match() returns the position of the matched term or NA    
    # we just want a TRUE/FALSE:    
    pos.matches = !is.na(pos.matches)   
    neg.matches = !is.na(neg.matches)    
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():   
    score = sum(pos.matches) - sum(neg.matches)    
    return(score)    
  }, pos.words, neg.words, .progress=.progress )  
  scores.df = data.frame(score=scores, text=sentences) # data.frame(score=scores) 
  return(scores.df)
}

getSentiment <- function (text, key){
  text <- URLencode(text); 
  #save all the spaces, then get rid of the weird characters that break the API, then convert back the URL-encoded spaces.
  text <- str_replace_all(text, "%20", " ");
  text <- str_replace_all(text, "%\\d\\d", "");
  text <- str_replace_all(text, " ", "%20");  
  if (str_length(text) > 360){
    text <- substr(text, 0, 359);
  }
  ##########################################  
  data <- getURL(paste("http://api.datumbox.com/1.0/TwitterSentimentAnalysis.json?api_key=", key, "&text=",text, sep=""))  
  js <- fromJSON(data, asText=TRUE); 
  # get mood probability
  sentiment = js$output$result  
  ###################################  
#   data <- getURL(paste("http://api.datumbox.com/1.0/SubjectivityAnalysis.json?api_key=", key, "&text=",text, sep=""))  
#   js <- fromJSON(data, asText=TRUE);  
#   # get mood probability
#   subject = js$output$result  
#   ################################## 
#   data <- getURL(paste("http://api.datumbox.com/1.0/TopicClassification.json?api_key=", key, "&text=",text, sep="")) 
#   js <- fromJSON(data, asText=TRUE);
#   # get mood probability
#   topic = js$output$result 
#   ##################################
#   data <- getURL(paste("http://api.datumbox.com/1.0/GenderDetection.json?api_key=", key, "&text=",text, sep=""))  
#   js <- fromJSON(data, asText=TRUE);
#   # get mood probability
#   gender = js$output$result  
# return(list(sentiment=sentiment,subject=subject,topic=topic,gender=gender))
return(list(sentiment=sentiment))

}


shinyServer(function(input, output) {
  
  output$downloadData <- downloadHandler(
    filename = function() { paste('sentimentanalysis', '.csv', sep='') },
    content = function(file) {
      write.csv(wordtable(), file, row.names = FALSE,col.names = FALSE)
    }
  )
  
  filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
      read.csv(infile$datapath, header = FALSE, sep = "\n")
    })
  
  wordtable <- reactive({
    corpus<- as.data.frame(filedata());
    
    if(as.character(input$Method) == "In-house Method"){
      data<- score.sentiment(corpus$V1, pos.words, neg.words, .progress='text');
    }
    if(as.character(input$Method) == "DatumBox API"){
      #data<-as.data.frame(matrix(0,nrow(corpus),4)); colnames(data)<- c('sentiment', 'subject', 'topic', 'gender')
      data<-as.data.frame(matrix(0,nrow(corpus),1)); colnames(data)<-'sentiment'
      
      for(i in 1:nrow(corpus))
      {
        data[i,]<-t(as.data.frame(unlist(getSentiment(as.character(corpus[i,]), "57ccdf93737b46563676b5982fe27b73"))))
      }
      data<- cbind(data,corpus);
      colnames(data)[length(colnames(data))]<- "Text";
      rownames(data)<- NULL;
    } 
    data
  })
  
  output$table <- renderDataTable({
    data= wordtable()
    
    data
  }, 
  options = list(bFilter=0, bSort=1, bProcessing=0, bPaginate=1, bInfo=0,iDisplayLength = 10,
                 bAutoWidth=0, aoColumnDefs = list(list(sWidth="500px", aTargets=c(list(1))))))
  


  
  })



