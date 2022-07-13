*import excel "C:\Users\Yana Gerina\Documents\womproject\data\estimation_data.xlsx", sheet("Sheet2") firstrow
egen id = group(url)

encode developer_category, generate(dev_var)
gen change = 0
bysort id: replace change = demand_add if demand_add != demand_add[_n+1]

gen gh_page = 1
replace gh_page = 0 if missing(github_dev)

bysort id (year): generate idyear = _n
xtset id idyear

gen ldem = L.demand_category
gen dev_hier = 1
replace dev_hier = 2 if developer_category == "Member"
replace dev_hier = 3 if developer_category == "Senior Member"
replace dev_hier = 3 if developer_category == "Senior member"
replace dev_hier = 4 if developer_category == "Recognized Developer"
gen men_th = 0
replace men_th = 1 if n_th>0

gen rate_rep = n_rep/n_comm
replace rate_rep = 0 if missing(rate_rep)
gen rate_resp = n_dev/n_comm
replace rate_resp = 0 if missing(rate_resp)


gen men = 0
replace men = 1 if n_p >0

reghdfe n_rep c.demand_category c.dev_hier change#men_th freq_d#men_th gh_page, absorb(years_since_launch year)

predict pred_rep

reghdfe paid_features developer_reactions c.pred_rep##c.pred_rep, absorb(years_since_launch year)

reghdfe rate_rep c.demand_category##men_th c.dev_hier change#men_th  gh_page, absorb(years_since_launch year)

*last version: with lags

bysort id : drop if _n == 1 

gen m_corr = men_th
replace m_corr = 0 if freq_d == 1
bysort id : drop if _n == 1
gen m_change = m_corr*change
gen m_correct  = men_th/freq_dum
correlate n_th freq_dum
correlate men_th freq_dum
gen m_f = men_th
replace m_f = 0 if freq_d == 0
reghdfe rate_rep c.dev_hier c.demand_category##men_th m_corr gh_page, absorb(years_since_launch year)

* last version without lags

reghdfe rate_rep c.demand_category#men_th c.demand_category c.dev_hier m_corr gh_page, absorb(years_since_launch year)
eststo est1
reghdfe response_rate c.demand_category#men_th c.demand_category c.dev_hier m_corr gh_page, absorb(years_since_launch year)
eststo est2