 *PROPENSITY SCORE WEIGHTING
 
u  "C:\Users\Matheus\Desktop\stata\prop\popdsei.dta", clear
drop if ano=="2019"
 
save  "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", replace
 
 u"C:\Users\Matheus\Desktop\stata\prop\basefinal.dta", clear

keep ibge DSEI ano partinfantil munelegeucand prefeito_ind_el prop_vereador_ind pibpcap anosagro media_aprovacao_esq controlecamera desmata semesgoto
reshape wide partinfantil, i(ibge) j(ano)
 
*colocando popdsei 
merge m:1 DSEI using "C:\Users\Matheus\Desktop\stata\psw\popdseiso2016.dta", generate(_mergepopdsei)
drop if _mergepopdsei !=3

*criar a variação
replace partinfantil2019=0 if partinfantil2019==.
replace partinfantil2016=0 if partinfantil2016==.

gen variacaomorte =partinfantil2019 - partinfantil2016


*balanceamento antes 
reg pibpcap munelegeucand 
reg pibpcap controlecamera //significativa

reg popdsei munelegeucand  
reg popdsei controlecamera //significativa

reg anosagro munelegeucand //nao significativa
reg anosagro controlecamera // n significativa

reg media_aprovacao_esq munelegeucand 
reg media_aprovacao_esq controlecamera //significativa

reg desmata controlecamera

reg semesgoto controlecamera 
 
 *criando as previsoes 
 logit munelegeucand pibpcap popdsei media_aprovacao_esq 
 
 predict preprob2, pr
 
 *fazendo os pesos
 
 gen psweight=.
 
 replace psweight= (1/preprob2) if munelegeucand == 1
 replace psweight= (1/(1-preprob2)) if munelegeucand==0
 
 *checando o balaceamento depois - agora nenhuma é significante
 reg pibpcap controlecamera [pweight = psweight]
 reg popdsei controlecamera  [pweight = psweight]
 reg anosagro controlecamera [pweight = psweight]
 reg media_aprovacao_esq controlecamera [pweight = psweight]
 reg desmata controlecamera [pweight = psweight]
 reg semesgoto controlecamera [pweight = psweight]
 
 destring ano ibge, replace
 
 *analise de fato
xtset ibge ano
 
reg variacaomorte munelegeucand [pweight = psweight]
estimates table, star(.05 .01 .001)
 
 *modelo com todas e com controle de camera municipal
*vdd :resp nao deu por muito
*vdd: infantil quase deu 
*vdd:acomat tb nao
*vdd: menos de cinco tambem nao
*vdd: partparto tb nao
*prevum tb nao
*todas as prev nao
* DEU PORRA NENHUMA

*modelo com 3 tops e munelegeucand so deu infantil



*modelo com 3 tops e camera municipal
*partinfantil DA
*suicidio NAO DA
 *agressao NAO DA
 *menosde5 NAO DA
 *part nao da da
 *prevum nao dada
 *partacomat nao da
 
 
 
 
 *teffects ipw(partprevtres) (munelegeucand pibpcap popdsei anosagro media_aprovacao_esq)
