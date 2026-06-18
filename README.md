# laboratorio-meotodi-digitlai-per-la-ricerca-sociale
# I giornalisti italiani al "Breaking Italy Night".

Questo repository contiene il progetto di ricerca e analisi dati sviluppato per il laboratorio di **Metodi digitali per la ricerca sociale** (A.A. 2023/2024). L'obiettivo è analizzare il comportamento, il sentiment e le tematiche emergenti all'interno della community di *Breaking Italy*, focalizzandosi in particolare sui commenti degli utenti a quattro video-interviste realizzate con noti giornalisti italiani: Francesco Costa, Giulia Pompili, Cecilia Sala e Giovanni Floris.

## 🎯 Obiettivi del Progetto

* **Data Scraping:** Estrarre programmaticamente i commenti da YouTube utilizzando le API ufficiali.
* **Text Analytics & NLP:** Pulire ed elaborare i testi in linguaggio naturale per estrarre strutture grammaticali rilevanti (Sostantivi e Aggettivi).
* **Network Analysis:** Visualizzare le relazioni e le co-occorrenze tra le parole per mappare i macro-temi discussi dal pubblico (es. percezione del format, opinioni sull'attualità e la società italiana).

## 🛠️ Competenze Tecniche e Stack Tecnologico (R)

Il progetto è stato interamente sviluppato in **R**, utilizzando i seguenti pacchetti:
* **`tuber`**: Per l'interfacciamento con l'API di YouTube, il recupero delle statistiche del canale e il retrieving dei commenti.
* **`udpipe`**: Per l'analisi linguistica avanzata (Tokenization, Lemmatization e Part-of-Speech tagging in lingua italiana).
* **`igraph` & `ggraph`**: Per la costruzione e la visualizzazione di grafici di rete (Word Networks) basati sulle co-occorrenze semantiche.
* **`ggplot2` & `dplyr`**: Per la manipolazione dei dati, il calcolo delle frequenze e la data visualization.

## 📈 Flusso di Lavoro dell'Analisi

1. **Retrieving dei Dati:** Autenticazione tramite le API di Google, estrazione delle metriche del canale e download massivo dei commenti legati ai target selezionati.
2. **Text Processing & Multiwords:** Filtraggio del testo, rimozione delle stop-words e identificazione delle parole composte (multiwords) per non perdere il contesto logico (es. "Breaking Italy", "Francesco Costa").
3. **Analisi delle Occorrenze:** Calcolo delle statistiche di frequenza assolute e relative per sostantivi e aggettivi, evidenziando i focus di interesse del pubblico.
4. **Co-occorrenze & Network delle Parole:** Analisi delle parole che si susseguono o compaiono nella stessa frase. Generazione di un grafo di rete (layout Fruchterman-Reingold) per mappare visivamente le associazioni mentali e tematiche della community.
5. **Matrice Termini-Documenti & Correlazioni:** Calcolo delle correlazioni lineari tra termini ad alta co-occorrenza per identificare cluster semantici specifici (es. discussioni sul degrado culturale, la politica, il giornalismo o il giudizio sul format della "chiacchierata").

## 📁 Struttura del Repository

* `IstruzioniR.pdf`: Documentazione tecnica passo-passo contenente il codice R utilizzato, i pacchetti necessari e la spiegazione delle funzioni.
* `Presentazione.pdf`: Report finale di ricerca con grafici, matrici di correlazione e interpretazione dei risultati emersi.

## 🚀 Principali Insight Emersi

* **Percezione del Format:** L'analisi delle co-occorrenze legata al termine "chiacchierata" ha mostrato una forte polarizzazione tra chi apprezza la spontaneità dello show e chi ne critica la mancanza di una struttura rigida.
* **Critica Sociale:** Il termine "Italia" è emerso come catalizzatore di discussioni approfondite da parte della community under-35 riguardo al degrado culturale, la situazione dei giovani e il confronto con l'estero, confermando l'elevato livello di engagement civico del pubblico del canale.
