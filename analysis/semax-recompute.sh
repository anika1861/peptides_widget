#!/usr/bin/env bash
# Recomputes headline numbers in two Russian Semax texts from the authors' own figures.
#
# 1. 2011 guideline on Semax 1% in acute stroke (ed. V.I. Skvortsova): 160 patients in 4 arms of 40
#    (placebo, 6, 12 or 18 mg/day for 5 days). The text claims a significant mortality reduction
#    "по критерию Фишера" at 12 and 18 mg (2 and 1 deaths vs 5 on placebo, from its percentages).
#    Table 2 gives 7 placebo deaths, though its own subgroup rows add up to 5.
#    The guideline doesn't say which of Fisher's tests it used, so both are computed:
#    - Fisher's exact test, two-sided: the sum of hypergeometric probabilities <= p(observed);
#      and one-sided: P(treated deaths <= observed).
#    - Fisher's angular transformation (phi*), common in Russian clinical papers:
#      phi = 2*asin(sqrt(p)); phi* = (phi_placebo - phi_treated) * sqrt(n1*n2/(n1+n2));
#      one-sided p from the normal distribution.
# 2. Gusev et al. 2018, Zh Nevrol Psikhiatr Im S S Korsakova 118(3 Vyp 2):61-68,
#    https://doi.org/10.17116/jnevro20181183261-68 : late-rehabilitation Barthel change scores
#    (Table 5, mean +/- SEM; subgroups 2a n=30, 2b n=20, so df = 48) and the reported mean age.
#    The paper prints t = 2.07, p = 0.044 for the reported gap (Table 5, note #).
#
# Needs only awk. Run: bash semax-recompute.sh
#
# Output (7 Nov 2026):
#   Deaths 18mg 1/40 vs placebo 5/40 (text):     exact 2-sided p=0.201  1-sided p=0.100  phi*=1.81 1-sided p=0.035
#   Deaths 12mg 2/40 vs placebo 5/40 (text):     exact 2-sided p=0.432  1-sided p=0.216  phi*=1.22 1-sided p=0.112
#   Deaths 18mg 1/40 vs placebo 7/40 (Table 2):  exact 2-sided p=0.057  1-sided p=0.028  phi*=2.44 1-sided p=0.007
#   Deaths 12mg 2/40 vs placebo 7/40 (Table 2):  exact 2-sided p=0.154  1-sided p=0.077  phi*=1.84 1-sided p=0.033
#   Deaths 12mg 2/40 vs 6mg 3/40:                exact 2-sided p=1.000
#   Deaths 18mg 1/40 vs 6mg 3/40:                exact 2-sided p=0.615
#   Pooled 12+18mg 3/80 vs placebo 5/40:         exact 2-sided p=0.115  1-sided p=0.081  phi*=1.72 1-sided p=0.043
#   Pooled 12+18mg 3/80 vs placebo 7/40:         exact 2-sided p=0.015  1-sided p=0.015  phi*=2.44 1-sided p=0.007
#   Good recovery 12mg 30/40 vs placebo 8/40:    exact 2-sided p=1.4e-06
#   2018: from the table's SEMs, reported gap 23.7 vs 18.7 -> t=2.62 (p=0.012) ; corrected 23.7 vs 20.6 -> t=1.62 (p=0.111)
#   2018: scaled to the paper's own t=2.07 for the 5.0-point gap, the corrected 3.1-point gap -> t=1.28 (p=0.206)
#   2018: age check, weighted mean of groups = 55.8 (paper says 58.0)

awk '
function lf(n,  s,i){s=0; for(i=2;i<=n;i++) s+=log(i); return s}
function lc(n,k){return lf(n)-lf(k)-lf(n-k)}
function hyp(k,K,N,n){return exp(lc(K,k)+lc(N-K,n-k)-lc(N,n))}
function fisher(a,n1,b,n2,   N,K,n,k,lo,hi,pobs,p,tot){
  N=n1+n2; K=a+b; n=n1
  pobs=hyp(a,K,N,n); tot=0
  lo=(K-(N-n)>0)?K-(N-n):0; hi=(K<n)?K:n
  for(k=lo;k<=hi;k++){p=hyp(k,K,N,n); if(p<=pobs*(1+1e-7)) tot+=p}
  return tot }
function fisher1(a,n1,b,n2,   N,K,n,k,lo,tot){
  N=n1+n2; K=a+b; n=n1; tot=0
  lo=(K-(N-n)>0)?K-(N-n):0
  for(k=lo;k<=a;k++) tot+=hyp(k,K,N,n)
  return tot }
function erfcc(x,   z,t,r){ z=(x<0)?-x:x; t=1/(1+0.5*z)
  r=t*exp(-z*z-1.26551223+t*(1.00002368+t*(0.37409196+t*(0.09678418+t*(-0.18628806+t*(0.27886807+t*(-1.13520398+t*(1.48851587+t*(-0.82215223+t*0.17087277)))))))))
  return (x>=0)?r:2-r }
function asin_(x){return atan2(x, sqrt(1-x*x))}
function phistar(a,n1,b,n2){return (2*asin_(sqrt(b/n2))-2*asin_(sqrt(a/n1)))*sqrt(n1*n2/(n1+n2))}
function p1norm(z){return 0.5*erfcc(z/sqrt(2))}
function tdens(x,df){return (1+x*x/df)^(-(df+1)/2)}
function tp2(t,df,   L,m,h,i,x,w,tot,inn){
  # two-sided p for Student t by Simpson integration of the unnormalised density
  L=80; m=40000; h=2*L/m; tot=0; inn=0
  for(i=0;i<=m;i++){x=-L+i*h; w=(i==0||i==m)?1:((i%2)?4:2); tot+=w*tdens(x,df); if(x>-t && x<t) inn+=w*tdens(x,df)}
  return 1-inn/tot }
function row(label,a,n1,b,n2){
  printf "%s exact 2-sided p=%.3f  1-sided p=%.3f  phi*=%.2f 1-sided p=%.3f\n", label, fisher(a,n1,b,n2), fisher1(a,n1,b,n2), phistar(a,n1,b,n2), p1norm(phistar(a,n1,b,n2)) }
BEGIN{
 row("Deaths 18mg 1/40 vs placebo 5/40 (text):    ", 1,40,5,40)
 row("Deaths 12mg 2/40 vs placebo 5/40 (text):    ", 2,40,5,40)
 row("Deaths 18mg 1/40 vs placebo 7/40 (Table 2): ", 1,40,7,40)
 row("Deaths 12mg 2/40 vs placebo 7/40 (Table 2): ", 2,40,7,40)
 printf "Deaths 12mg 2/40 vs 6mg 3/40:                exact 2-sided p=%.3f\n", fisher(2,40,3,40)
 printf "Deaths 18mg 1/40 vs 6mg 3/40:                exact 2-sided p=%.3f\n", fisher(1,40,3,40)
 row("Pooled 12+18mg 3/80 vs placebo 5/40:        ", 3,80,5,40)
 row("Pooled 12+18mg 3/80 vs placebo 7/40:        ", 3,80,7,40)
 printf "Good recovery 12mg 30/40 vs placebo 8/40:    exact 2-sided p=%.2g\n", fisher(30,40,8,40)
 # 2018 paper, Table 5, late-rehab change scores (M +/- SEM), subgroups 2a n=30 and 2b n=20
 se=sqrt(1.3^2+1.4^2); df=48
 t1=(23.7-18.7)/se; t2=(23.7-20.6)/se
 printf "2018: from the table\x27s SEMs, reported gap 23.7 vs 18.7 -> t=%.2f (p=%.3f) ; corrected 23.7 vs 20.6 -> t=%.2f (p=%.3f)\n", t1, tp2(t1,df), t2, tp2(t2,df)
 t3=2.07*(23.7-20.6)/(23.7-18.7)
 printf "2018: scaled to the paper\x27s own t=2.07 for the 5.0-point gap, the corrected 3.1-point gap -> t=%.2f (p=%.3f)\n", t3, tp2(t3,df)
 printf "2018: age check, weighted mean of groups = %.1f (paper says 58.0)\n", (54.6*60+57.3*50)/110
}'
