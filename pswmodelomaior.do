 *PROPENSITY SCORE WEIGHTING
 
*NESSE DO-FILE, UTILIZA-SE UMA ESTRUTURA MUITO SEMELHANTE AO psw.do SENDO A ÚNICA DIFERENÇA O TAMANHO DO MODELO ESTIMADO,
*NO AQUI PRESENTE, O MODELO UTILIZA MAIS COVARIADAS NA PREVISÃO DE RECEBIMENTO DO TRATAMENTO (TAMBÉM SE USA UMA VARIÁVEL DE INTERESSE DIFERENTE,
*MAS ELAS SÃO ALTERÁVEIS) 
 
u  "C:\Users\Matheus\Desktop\stata\prop\popdsei.dta", clear
drop if ano=="2019"
 
save  "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", replace
 
 u"C:\Users\Matheus\Desktop\stata\prop\basefinal.dta", clear

keep ibge DSEI ano partacomat desmata semesgoto munelegeucand prefeito_ind_el prop_ind_eleito pibpcap anosagro media_aprovacao_esq 
reshape wide partacomat, i(ibge) j(ano)
 
*colocando popdsei 
merge m:1 DSEI using "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", generate(_mergepopdsei)
drop if _mergepopdsei !=3
drop ano
*criar a variação
*foreach k in partagressao partmort_totais partparto partmenosde5 partinfantil 
replace partacomat2019=0 if partacomat2019==.
replace partacomat2016=0 if partacomat2016==.

gen variacaomorte =partacomat2019 - partacomat2016


*balanceamento antes 
reg pibpcap munelegeucand 
reg pibpcap prop_ind_eleito 

reg popdsei munelegeucand  
reg popdsei prop_ind_eleito 

reg anosagro munelegeucand 
reg anosagro prop_ind_eleito

reg media_aprovacao_esq munelegeucand 
reg media_aprovacao_esq prop_ind_eleito

reg semesgoto munelegeucand 

reg desmata munelegeucand 


 
 
 *criando as previsoes 
 logit munelegeucand pibpcap popdsei media_aprovacao_esq anosagro semesgoto desmata
 
 predict preprob2, pr
 
 *fazendo os pesos
 
 gen psweight=.
 
 replace psweight= (1/preprob2) if munelegeucand == 1
 replace psweight= (1/(1-preprob2)) if munelegeucand==0
 
 *checando o balaceamento depois - agora nenhuma é significante
 reg pibpcap munelegeucand [pweight = psweight]
 reg popdsei munelegeucand  [pweight = psweight]
 reg anosagro munelegeucand [pweight = psweight]
 reg media_aprovacao_esq munelegeucand [pweight = psweight]
 reg semesgoto munelegeucand [pweight = psweight]
 reg desmata munelegeucand [pweight = psweight]



 
 
 
 *analise de fato
 
 
reg variacaomorte munelegeucand [pweight = psweight]
estimates table, star(.05 .01 .001)
