* FAZENDO UM PROPENSITY SCORE WEIGHTING
 
**OBJETIVO DO DO-FILE 
*o do-file a seguir calcula pesos por propensity score weighting
*e depois roda uma regressão utilizando os pesos calculadas
*em suma, o intuito desse método é criar ponderações para observações que receberam e que
*que não receberam tratamento para auxiliar no viés de seleção

**IDENTIFICANDO AS VARIÁVEIS
*VARIÁVEIS DE IDENTIFICAÇÃO: ibge DSEI 
*SÃO COVARIADAS: ano pibpcap anosagro media_aprovacao_esq desmata semesgoto
*SÃO TRATAMENTOS: munelegeucand prefeito_ind_el controlecamera
*A VARIÁVEL DE INTERESSE: partinfantil 

**PARTES
*primeira parte ajusta a base deixando ela em formato wide
*segunda parte cria a variável de interesse - a variação da mortalidade
*terceira parte analisa a relação entre covariadas e tratamento escolhido antes do balanceamento
*quarta parte roda os modelos de probabilidade e cria as ponderações
*quinta parte analisa a relação entre covariadas e tratamento escolhido depois do balanceamento
*sexta parte roda a regressão com os pesos

**POSSIBILIDADE DE REUTILIZAÇÃO
*o processo é facilmente replicado, basta substituir as bases,
*substituir as variáveis de interesse, as variáveis de tratamento 
*e as covariadas nos locais indicados pela definição das partes
 
 
**1 PARTE 
*abrindo e ajustando a base 
u  "C:\Users\Matheus\Desktop\stata\prop\popdsei.dta", clear
drop if ano=="2019"
 
save  "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", replace

u"C:\Users\Matheus\Desktop\stata\prop\basefinal.dta", clear

keep ibge DSEI ano partinfantil munelegeucand prefeito_ind_el  pibpcap anosagro media_aprovacao_esq controlecamera desmata semesgoto
reshape wide partinfantil, i(ibge) j(ano)
 
*mais ajustes - colocando popdsei 
merge m:1 DSEI using "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", generate(_mergepopdsei)
drop if _mergepopdsei !=3

**2 PARTE 
*criar a variação - variável de interesse 
replace partinfantil2019=0 if partinfantil2019==.
replace partinfantil2016=0 if partinfantil2016==.

gen variacaomorte =partinfantil2019 - partinfantil2016

**3 PARTE
*analisando a relação entre covariadas e tratamento antes do balanceamento 
reg pibpcap munelegeucand 
reg pibpcap controlecamera 

reg popdsei munelegeucand  
reg popdsei controlecamera 

reg anosagro munelegeucand 
reg anosagro controlecamera 

reg media_aprovacao_esq munelegeucand 
reg media_aprovacao_esq controlecamera 

reg desmata controlecamera

reg semesgoto controlecamera 

**4 PARTE 
*fazendo as previsoes usando função logística 
 logit munelegeucand pibpcap popdsei media_aprovacao_esq 
 
 predict preprob2, pr
 
*fazendo os pesos a partir das previsões
 
 gen psweight=.
 
 replace psweight= (1/preprob2) if munelegeucand == 1
 replace psweight= (1/(1-preprob2)) if munelegeucand==0
 
 
 *5 PARTE 
 *analisando a mesma relação entre covariadas e tratamento depois do balanceamento
 *agora nenhuma é significante
 reg pibpcap controlecamera [pweight = psweight]
 reg popdsei controlecamera  [pweight = psweight]
 reg anosagro controlecamera [pweight = psweight]
 reg media_aprovacao_esq controlecamera [pweight = psweight]
 reg desmata controlecamera [pweight = psweight]
 reg semesgoto controlecamera [pweight = psweight]
 
 destring ano ibge, replace
 
*6 PARTE 
*regressao usando as ponderações 
reg variacaomorte munelegeucand [pweight = psweight]
estimates table, star(.05 .01 .001)
 
