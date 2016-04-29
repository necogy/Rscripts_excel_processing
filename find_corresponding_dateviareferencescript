find_exact_date <- function (unknown,refer){
 
  unknown$corresponding_image_date <- unknown$PIDN
  unknown$sourceID4mismatch <- unknown$Source.ID
  unknown$referring_date <-NA
  
   for (i in seq_len(length(unknown$PIDN))){  ## each record in unknown
     for (j in which(refer$PIDN == unknown$PIDN[i])) { 
      if (unknown[i,]$corresponding_image_date !=unknown[i,]$PIDN){next}
       
      else if (refer[j,]$Date == unknown[i,]$DATE) 
      {cat( refer$PIDN[j], refer$Date[j], "\n")
        unknown[i,]$corresponding_image_date<-refer[j,]$Date
        unknown$sourceID4mismatch[i] <-""}
       
       else if (j == tail(which(refer$PIDN == unknown$PIDN[i]),1) & unknown[i,]$corresponding_image_date ==unknown[i,]$PIDN)
       {cat(unknown$PIDN[i], unknown$Source.ID[i],refer[which(refer$PIDN == unknown_date$PIDN[i]),]$Date, "\n")
         unknown[i,]$corresponding_image_date<-""}
     #    unknown[i,]$referring_date<-cat(refer[which(refer$PIDN == unknown_date$PIDN[i]),]$Date)}
       
     }}
     
     find_most_close_date <- function (unknown,refer){
  

  for (i in seq_len(length(unknown$PIDN))){  ## each PIDN in unknown
      # check whether corresponding image date is already stored
      if (unknown[i,]$image_date !=""){next}
      else if (length(which(refer$PIDN == unknown$PIDN[i])) ==0){cat(i, unknown$PIDN[i], "\n")}
      else {
      ind<-which(refer$PIDN == unknown$PIDN[i])    
      timediff<-difftime(refer[ind,]$Date,unknown$Clinical.Date[i],units = "days")
      finalind<-ind[which(abs(timediff) == min(abs(timediff)))]
      unknown$image_date[i]<-refer$Date[finalind]
      cat(i, unknown$PIDN[i],unknown$image_date[i], "\n")}}}

find_most_close_date(awaited_t1date,nifdroi[1:5]) 
