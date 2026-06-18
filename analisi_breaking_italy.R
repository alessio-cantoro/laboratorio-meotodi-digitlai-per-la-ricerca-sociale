# ==============================================================================
# LABORATORIO: Metodi digitali per la ricerca sociale
# ==============================================================================

# 1. INSTALLAZIONE PACCHETTI
# ------------------------------------------------------------------------------
# install.packages("tuber")          # Interazione con le API di YouTube
# install.packages("writexl")        # Esportazione oggetti in xlsx
# install.packages("dplyr")          # Data manipulation
# install.packages("topicmodels")     
# install.packages("tibble")          
# install.packages("quanteda")       # Text analysis avanzata
# install.packages("quanteda.textplots")
# install.packages("quanteda.textstats")
# install.packages("tm")             # Text Mining classico
# install.packages("stringr")        # Manipolazione stringhe
# install.packages("wordcloud")      # Nuvole di parole
# install.packages("openxlsx")       # Gestione avanzata Excel
# install.packages("rjson")          
# install.packages("gistr")          
# install.packages("generics")       
# install.packages("ggplot2")        # Data Visualization
# install.packages("udpipe")         # NLP e Lemmatizzazione
# install.packages("lattice")        
# install.packages("igraph")         # Network Analysis
# install.packages("ggraph")         # Grafica dei network

# 2. CARICAMENTO LIBRERIE
# ------------------------------------------------------------------------------
library(tuber)
library(writexl)
library(dplyr)
library(topicmodels)     
library(tibble)          
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
library(tm)
library(stringr)
library(wordcloud)
library(openxlsx)
library(rjson)
library(gistr)
library(generics)
library(ggplot2)
library(udpipe)
library(lattice)
library(igraph)
library(ggraph)

# 3. AUTENTICAZIONE API YOUTUBE
# ------------------------------------------------------------------------------
client_id <- ""
client_secret <- ""

yt_oauth(app_id = client_id,
         app_secret = client_secret,
         token = ".httr-oauth")

# 4. DATA RETRIEVING (COMMENTI E STATISTICHE)
# ------------------------------------------------------------------------------
# Estrazione commenti da un video singolo di prova
prova <- get_all_comments(video_id = "5_B9PfpMpIQ") 
com_video <- select(prova,               
                    "videoId",
                    "textOriginal",
                    "likeCount",
                    "publishedAt",
                    "updatedAt") 

# Ottenere statistiche del video
stat <- as.data.frame(tuber::get_stats("5_B9PfpMpIQ")) 

# Ottenere statistiche del canale Breaking Italy
stat_canale <- as.data.frame(get_channel_stats("UC4V3oCikXeSqYQr0hBMARwg"))
stat_canale <- select(stat_canale,               
                      "id",
                      "snippet.title",
                      "snippet.description",
                      "snippet.country",
                      "statistics.viewCount",
                      "statistics.subscriberCount",
                      "statistics.videoCount")

# Ricerca video specifici nel canale
ricerca <- tuber::yt_search(term = "giornalista podcast teatro", 
                            channel_id = "UC4V3oCikXeSqYQr0hBMARwg")

# Selezione del subset di video d'interesse (es. le 4 interviste target)
E <- ricerca[c(2, 3, 8, 14), ] 

# Loop per scaricare i commenti di tutti i video selezionati
loop_com <- NULL

for (i in E$video_id) {
  dat <- get_all_comments(i)
  loop_com <- rbind(loop_com, dat) 
  rm(dat)
  Sys.sleep(5) # Pausa di sicurezza per evitare il blocco delle API
}

# Esportazione dei dati grezzi in Excel
write_xlsx(prova, "Commenti_video.xlsx")
write_xlsx(stat, "Statistiche_video.xlsx")
write_xlsx(loop_com, "loop_video.xlsx")


# 5. TEXT CLEANING & DISAMBIGUAZIONE
# ------------------------------------------------------------------------------
# Funzione di normalizzazione personalizzata
normalize_terms <- function(text) {
  text <- gsub("\\bdiversa\\b", "divers@", text)
  text <- gsub("\\bdiverse\\b", "divers@", text)
  text <- gsub("\\bdiversi\\b", "divers@", text)
  text <- gsub("\\bamerica\\b", "americ@", text)
  text <- gsub("\\bcrepaldi\\b", "crepald@", text)
  text <- gsub("\\bderiva\\b", "deriv@", text)
  text <- gsub("\\beconomica\\b", "economic@", text)
  text <- gsub("\\bdiverso\\b", "divers@", text)
  return(text)
}

# Applicazione della normalizzazione
loop_com$textOriginal <- sapply(loop_com$textOriginal, normalize_terms)

# Riduzione a minuscolo e Tokenizzazione
testi <- tolower(loop_com$textOriginal) 
toks <- tokens(testi)

# Calcolo metriche di ricchezza lessicale (Type-Token Ratio)
loop_commenti <- cbind(loop_com, ntype(toks), ntoken(toks)) %>% 
  mutate(richness = ntype(toks) / ntoken(toks))

colnames(loop_commenti)[17] <- "word_type"  
colnames(loop_commenti)[18] <- "word_token"

# 6. IDENTIFICAZIONE MULTIWORDS (LOCUZIONI POLIREMATICHE)
# ------------------------------------------------------------------------------
# Estrazione Bigrammi
multiwords2 <- toks %>%
  tokens_remove(stopwords("it")) %>%
  tokens_remove(stopwords("en")) %>%
  tokens_select(pattern = "^[a-z]", valuetype = "regex", case_insensitive = FALSE, padding = TRUE) %>%
  textstat_collocations(min_count = 5, size = 2)       

# Estrazione Trigrammi
multiwords3 <- toks %>%
  tokens_remove(stopwords("it")) %>%
  tokens_remove(stopwords("en")) %>%
  tokens_select(pattern = "^[a-z]", valuetype = "regex", case_insensitive = FALSE, padding = TRUE) %>%
  textstat_collocations(min_count = 3, size = 3)       

# Filtraggio manuale delle multiwords rilevanti
multiwords2 <- multiwords2[c(1,3,4,5,6,7,8,15,19,20,27,28,36,45,78,117,122,127,153,163,164), ]                 
multiwords3 <- multiwords3[c(3,7,9,11,14,20,21,24,30,37,40), ]  

# Unione ed esportazione delle multiwords
multiwords_total <- rbind(multiwords2, multiwords3)            
write.xlsx(multiwords_total, "multiwords.xlsx")             

# Concatenamento delle multiwords nei token
multiwords_vec <- as.character(multiwords_total$collocation) # FIX: Estrazione da multiwords_total (unito)
comp_toks <- tokens_compound(toks, pattern = phrase(multiwords_vec)) 


# 7. ANALISI TESTUALE CLASSICA CON "TM" (TERM-DOCUMENT MATRIX)
# ------------------------------------------------------------------------------
vet <- VCorpus(VectorSource(comp_toks))
dataset <- tm_map(vet, content_transformer(tolower))
dataset <- tm_map(dataset, content_transformer(removeWords), stopwords("italian"))
dataset <- tm_map(dataset, content_transformer(removeWords), stopwords("english"))

# Rimozione Stopwords Generali
custom_stopwords <- c("poi", "qui", "però", "quando", "quindi", "così", "cosa", "mai", 
                      "dopo", "già", "oltre", "sicuramente", "senza", "forse", "proprio", 
                      "fare", "essere", "sempre", "ancora", "solo", "può", "altro", "prima", "pure", "comunque")
dataset <- tm_map(dataset, content_transformer(removeWords), custom_stopwords)

# Pulizia tramite espressioni regolari (Numeri, link, punteggiatura)
f <- content_transformer(function(x, pattern) gsub(pattern, "", x, perl=T))
dataset <- tm_map(dataset, f, "#\\w+\\s+")
dataset <- tm_map(dataset, f, "[[:digit:]]+")    
dataset <- tm_map(dataset, f, "[^_[:^punct:]]")  
dataset <- tm_map(dataset, f, "https\\S*")       
dataset <- tm_map(dataset, f, "amp")             
dataset <- tm_map(dataset, f, "[\r\n]")          
dataset <- tm_map(dataset, content_transformer(stripWhitespace))  
dataset <- tm_map(dataset, content_transformer(PlainTextDocument)) 

# Creazione della Matrice Termini-Documenti
dat.TDM <- TermDocumentMatrix(dataset) 
dat.tm <- as.matrix(dat.TDM)           

# Calcolo frequenze e ordinamento
dat.tsort <- sort(rowSums(dat.tm), decreasing = TRUE) 
dat.tsort.dtm <- data.frame(parola = names(dat.tsort), freq = dat.tsort)
write.xlsx(dat.tsort.dtm, "most.xlsx")

print(head(dat.tsort, 10))

# Visualizzazione delle parole più frequenti con ggplot2
tb_most_word <- dat.tsort.dtm[1:15, ]

ggplot(tb_most_word, aes(reorder(parola, freq), y = freq)) + 
  geom_bar(stat = "identity", color = "black", fill = "grey") +  
  labs(title = "Le parole più utilizzate\n",                   
       x = "Parole", 
       y = "Frequenza") +
  theme_classic() +  
  coord_flip()      


# 8. NATURAL LANGUAGE PROCESSING & ANNOTAZIONE CON "UDPIPE"
# ------------------------------------------------------------------------------
# FIX: Sostituito loop_video (non esistente) con loop_com
loop_com$textOriginal <- tolower(loop_com$textOriginal) 
loop_com$N_id <- 1:nrow(loop_com) 

# Sostituzione manuale nel testo per l'annotazione NLP
manual_multiwords <- c("francesco costa", "francesco", "america", "barbero", "bellissima puntata", "stati uniti", "crepaldi", "economica", "deriva", "diverso", "breaking italy") 
replacements <- c("francesco_costa", "francesco", "america", "barbero", "bellissima_puntata", "stati_uniti", "crepaldi", "economica", "deriva", "diverso", "breaking_italy")

for (i in seq_along(manual_multiwords)) {
  loop_com$textOriginal <- gsub(manual_multiwords[i], replacements[i], loop_com$textOriginal)
}

# Caricamento modello udpipe in italiano
ud_model <- udpipe_download_model(language = "italian")
ud_model <- udpipe_load_model(ud_model$file_model)

# Annotazione del testo (PoS Tagging)
x <- udpipe_annotate(ud_model, x = loop_com$textOriginal, doc_id = loop_com$N_id)
x <- as.data.frame(x)


# 9. ANALISI DELLE FREQUENZE PER PARTI DEL DISCORSO (UPOS)
# ------------------------------------------------------------------------------
# Grafico delle parti del discorso generali
stats <- txt_freq(x$upos)
stats$key <- factor(stats$key, levels = rev(stats$key)) 
barchart(key ~ freq, data = stats, col = "cadetblue", 
         main = "UPOS (Universal Parts of Speech)\n frequency of occurrence", xlab = "Freq")

# Focus sui Sostantivi (NOUN)
sostantivi <- subset(x, upos %in% c("NOUN")) 
sostantivi <- txt_freq(sostantivi$token)
sostantivi$key <- factor(sostantivi$key, levels = rev(sostantivi$key))
barchart(key ~ freq, data = head(sostantivi, 20), col = "cadetblue", 
         main = "Most occurring nouns", xlab = "Freq")

# Focus sugli Aggettivi (ADJ)
aggettivi <- subset(x, upos %in% c("ADJ")) 
aggettivi <- txt_freq(aggettivi$token)
# Filtro aggettivi di rumore o legati a multiwords specifiche
aggettivi <- aggettivi[!aggettivi$key %in% c("america", "francesco_costa", "francesco", "barbero", "bellissima_puntata", "crepaldi", "breaking_italy", "pompili", "sala"), ]
aggettivi$key <- factor(aggettivi$key, levels = rev(aggettivi$key))
barchart(key ~ freq, data = head(aggettivi, 20), col = "cadetblue", 
         main = "Most occurring adjectives", xlab = "Freq")


# 10. CO-OCCORRENZE E NETWORK ANALYSIS (GRAFI DI RETE)
# ------------------------------------------------------------------------------
# 10.1 Co-occorrenze Sostantivi/Aggettivi nella stessa frase
cooc <- cooccurrence(x = subset(x, upos %in% c("NOUN", "ADJ")), 
                     term = "lemma", 
                     group = c("doc_id", "paragraph_id", "sentence_id"))

# Pulizia e lemmatizzazione manuale delle co-occorrenze
cooc$term1 <- gsub("salo", "sala", cooc$term1)
cooc$term1 <- gsub("pompile", "pompili", cooc$term1)
cooc$term1 <- gsub("bello", "bella", cooc$term1)
cooc$term1 <- gsub("unico", "unica", cooc$term1)

cooc$term2 <- gsub("salo", "sala", cooc$term2)
cooc$term2 <- gsub("pompile", "pompili", cooc$term2)
cooc$term2 <- gsub("bello", "bella", cooc$term2)
cooc$term2 <- gsub("unico", "unica", cooc$term2)

cooc_dat <- data.frame(cooc)

# Generazione del primo Network Graph (Frase)
wordnetwork <- head(cooc_dat, 50)
wordnetwork <- graph_from_data_frame(wordnetwork)
ggraph(wordnetwork, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "pink") +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "sans") +  
  theme(legend.position = "none") +
  labs(title = "Cooccurrences within sentence", subtitle = "Nouns & Adjective")

# 10.2 Co-occorrenze di successione (Parole adiacenti con Skipgram)
cooc_skip <- cooccurrence(x$token, relevant = x$upos %in% c("NOUN", "ADJ"), skipgram = 1)
cooc_skip_dat <- data.frame(cooc_skip)

# Generazione del secondo Network Graph (Successione)
wordnetwork_skip <- head(cooc_skip, 25)
wordnetwork_skip <- graph_from_data_frame(wordnetwork_skip)
ggraph(wordnetwork_skip, layout = "fr") +
  geom_edge_link(aes(width = cooc, edge_alpha = cooc)) +
  geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
  theme_graph(base_family = "sans") + # Sostituito con 'sans' generico per evitare crash di font
  labs(title = "Words following one another", subtitle = "Nouns & Adjective")


# 11. MATRICE DI CORRELAZIONE LINEARE TRA TERMINI
# ------------------------------------------------------------------------------
x$id <- unique_identifier(x, fields = c("sentence_id", "doc_id"))
dtm <- subset(x, upos %in% c("NOUN", "ADJ"))
dtm <- document_term_frequencies(dtm, document = "id", term = "lemma")
dtm <- document_term_matrix(dtm)
dtm <- dtm_remove_lowfreq(dtm, minfreq = 5)
termcorrelations <- dtm_cor(dtm)
y <- as_cooccurrence(termcorrelations)
y <- subset(y, term1 < term2 & abs(cooc) > 0.2)
y <- y[order(abs(y$cooc), decreasing = TRUE), ]
print(head(y))


# 12. CONTESTUALIZZAZIONE LESSICALE (KWIC - KEYWORD IN CONTEXT)
# ------------------------------------------------------------------------------
# Estrazione dei contesti d'uso per parole chiave e salvataggio diretto in Excel

keywords <- c("giornalista", "giornali", "giornalismo", "chiacchierata", "informazione", "intervista", "italia")

for (kw in keywords) {
  kw_res <- kwic(tokens(testi), pattern = kw, valuetype = "glob", window = 7)
  kw_df <- as.data.frame(kw_res)
  write.xlsx(kw_df, file = paste0(kw, "_kwic.xlsx"))
}

# Estrazioni KWIC multicriterio specifiche
giornalismo1 <- kwic(tokens(testi), pattern = c("giornalismo", "italia"), window = 7)
giornalismo1_df <- as.data.frame(giornalismo1)
write.xlsx(giornalismo1_df, file = "giornalismo1_kwic.xlsx")

giornalismo2 <- kwic(tokens(testi), pattern = phrase("giornalismo italiano"), valuetype = "glob", window = 7)
giornalismo2_df <- as.data.frame(giornalismo2) # FIX: Corretto errore di battitura informazionea_df
write.xlsx(giornalismo2_df, file = "giornalismo2_kwic.xlsx")