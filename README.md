# I giornalisti italiani al "Breaking Italy Night"

Questo repository contiene il progetto di ricerca e analisi dati sviluppato per il laboratorio di **[Metodi digitali per la ricerca sociale](https://www.didattica-cps.unito.it/do/storicocorsi.pl/Show?_id=mzpm_2223)** (A.A. 2023/2024). L'obiettivo dello studio è analizzare il comportamento, il sentiment e le tematiche emergenti all'interno della community di *Breaking Italy*, focalizzandosi in particolare sui commenti degli utenti a quattro video-interviste realizzate con noti giornalisti italiani: Francesco Costa, Giulia Pompili, Cecilia Sala e Giovanni Floris.

## 🎯 Obiettivi del Progetto

* **Data Scraping:** Estrarre programmaticamente i commenti da YouTube utilizzando le API ufficiali e gestire i limiti di quota tramite loop condizionali.
* **Text Analytics & NLP:** Pulire ed elaborare i testi in linguaggio naturale per estrarre strutture grammaticali rilevanti (Sostantivi e Aggettivi) e calcolare metriche di ricchezza lessicale.
* **Network Analysis:** Visualizzare le relazioni, le co-occorrenze e le correlazioni lineari tra le parole per mappare i macro-temi discussi dal pubblico.
* **Keyword in Context (KWIC):** Isolare e analizzare i contesti testuali specifici in cui emergono i concetti chiave del dibattito (es. la percezione del giornalismo e del format).

## 🛠️ Competenze Tecniche e Stack Tecnologico (R)

Il progetto è stato interamente sviluppato in **R**, sfruttando un approccio integrato tra Text Mining classico e NLP avanzato:
* **`tuber`**: Interfacciamento con l'API di YouTube per il recupero di metriche del canale, statistiche dei video e download massivo dei commenti.
* **`quanteda` & `quanteda.textstats`**: Gestione della tokenizzazione, calcolo della ricchezza lessicale (Type-Token Ratio), estrazione delle *multiwords* (bi-grammi e tri-grammi) e analisi KWIC.
* **`tm` (Text Mining)**: Creazione della Matrice Termini-Documenti (TDM), pulizia avanzata del testo (rimozione stop-words personalizzate, rimozione URL, punteggiatura e regex targeting).
* **`udpipe`**: Pipeline di elaborazione linguistica (NLP) per l'italianizzazione, il Part-of-Speech tagging (PoS) e la lemmatizzazione automatica.
* **`igraph` & `ggraph`**: Costruzione e modellazione di grafi di rete basati sulle co-occorrenze semantiche (layout Fruchterman-Reingold).
* **`ggplot2` & `dplyr`**: Manipolazione dei dataset ed esportazione dei grafici di frequenza.
* **`writexl` & `openxlsx`**: Esportazione automatizzata dei report semantici in formato Excel per l'analisi qualitativa.

## 📈 Flusso di Lavoro dell'Analisi

1. **Estrazione Dati (YouTube API):** Autenticazione OAuth, estrazione delle metriche del canale e download temporizzato (per evitare il superamento dei limiti di richiesta delle API di Google) dei commenti legati ai video target.
2. **Pre-processing & Normalizzazione:** Sostituzione delle forme declinate con radici convenzionali (es. *divers@*) e identificazione statistica delle locuzioni polirematiche (*multiwords* come "Breaking Italy", "Francesco Costa").
3. **Analisi delle Occorrenze (TDM):** Costruzione della Matrice Termini-Documenti, filtraggio del rumore linguistico tramite stop-words contestuali e visualizzazione dei termini più frequenti.
4. **Annotazione NLP (PoS Tagging):** Classificazione grammaticale dei token tramite il modello predittivo `udpipe` in lingua italiana, isolando i pattern d'uso di Sostantivi e Aggettivi.
5. **Co-occorrenze & Network delle Parole:** Analisi delle parole adiacenti (tramite *skip-gram*) e delle parole co-presenti nella stessa frase. Generazione di grafi di rete semantici.
6. **Analisi KWIC (Keyword in Context):** Estrazione automatizzata di finestre di testo (7 parole prima e dopo) attorno a concetti chiave (*giornalismo*, *chiacchierata*, *Italia*) esportate in Excel per validare l'interpretazione sociologica.

## 📁 Struttura del Repository

* `analisi_breaking_italy.R`: Lo script R completo, ottimizzato e commentato, contenente l'intero workflow (dallo scraping ai grafi di rete).
* `IstruzioniR.pdf`: Guida di laboratorio passo-passo con la spiegazione metodologica delle funzioni utilizzate.
* `Presentazione.pdf`: Il report di ricerca finale completo di grafici, interpretazione socioculturale dei dati ed insight emersi.

## 🚀 Principali Insight Emersi

* **Percezione del Format:** L'analisi delle co-occorrenze e dei contesti (KWIC) legati al termine "chiacchierata" evidenzia come il pubblico percepisca il format in modo polarizzato: da un lato si apprezza l'informazione "orizzontale" e spontanea, dall'altro si sollevano critiche sulla mancanza di un contraddittorio rigido.
* **Critica Sociale dei Giovani:** Il termine "Italia" (spesso correlato a "giovani" e "cultura") agisce da catalizzatore di discussioni strutturate sull'attualità politica e il divario generazionale, confermando l'alto profilo di engagement civico della community analizzata.
