
lmerepmeasure<-function(dataset){
  
  #index<-length(names(dataset[,grep('_', names(dataset))]))
  index<-dim(dataset)[2]-dim(dataset[,grep('_', names(dataset))])[2]+1
    
  mat<-list()
  mat[[as.character(1)]]<- c("colNumber of ROI","ROI names", "TPs p-values","PT vs. normal","interaction")
  
  for (i in (index:dim(dataset)[2])){
    
  #for (i in seq(9,80,by=1)){
   
   congrow<-try(lme(fixed = as.formula(paste(names(dataset[i]),"TPs*y1", sep ="~")), random = ~ TPs | PIDN , data=dataset))
  
   if(inherits(congrow,"try-error")){next}
   print(i)
    
   if(min(summary(congrow)$tTable[2:4,5])<0.05){
    
     temp<-apply(matrix(summary(congrow)$tTable[2:4,5]),2,function(x) ifelse(x<0.05,x<-round(x,6),x<-"  "))
    
     mat[[as.character(paste(i,j,sep="-"))]]<- c(i,gsub("X.","",names(dataset)[i]), temp)}
    
    else{next}}
  
  mat<-as.data.frame(t(sapply(mat,'[',seq(max(sapply(mat,length))))))
  colnames(mat)<-data.frame(lapply(mat[1,], as.character), stringsAsFactors=FALSE)
  mat <- mat[-1, ]
  
  mat <- sapply(mat, as.character) # since your values are `factor`
  mat[is.na(mat)] <- ""
  mat}

mat<- lmerepmeasure(all)
# mat<-subsetlme(all)

mat<-as.data.frame(mat)
mat

newmat<-data.frame()
for (i in unique(mat[1][[1]])){
  newmat<-rbind(newmat,tail(mat[which(mat$colNumber == i),],1))
  newmat}

 sd_output<-print(newmat,row.names=FALSE)
