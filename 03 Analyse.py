# -*- coding: utf8 -*-
import pdb
import re
import os
import pickle
import html
import csv
 
L=os.listdir('pagescollectees')
Base=[['action','prix','cap_boursiere','price_earning_ratio','beta','benefice_par_action','dividendes','action_en_circulation','secteur','effectif']]
for k in L:
        with open('pagescollectees/'+k,'r',encoding='utf8') as output:
                    content = output.read()

        content = html.unescape(content)

        pattern1 = '<h1 class="float_lang_base_1 relativeAttr"\n\tdir="ltr" itemprop="name">(.+?(?=\t</h1>))'
        action = re.findall(pattern1,content)

        pattern2 = 'Clôture précédente</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        prix = re.findall(pattern2,content)

        pattern3 = 'Cap. boursière</span><span class="float_lang_base_2 bold">(.+?(?=B</span></div>))'
        cap_boursiere = re.findall(pattern3,content)

        pattern4 = 'PER</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        price_earning_ratio = re.findall(pattern4,content)

        pattern5 = 'Bêta</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        beta = re.findall(pattern5,content)

        pattern6 = 'BPA</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        benefice_par_action = re.findall(pattern6,content)

        pattern7 = 'Dividende</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        dividendes = re.findall(pattern7,content)

        pattern8 = 'Act. en circulation</span><span class="float_lang_base_2 bold">(.+?(?=</span></div>))'
        action_en_circulation = re.findall(pattern8,content)

        pattern9 = '<div>Secteur<a href="/stock-screener/?sp=country::22|sector::9|industry::a|equityType::a<eq_market_cap;1">(.+?(?=</a></div>))'
        secteur = re.findall(pattern9,content)
        
        pattern10 = '<div>Employés<p class="bold">(.+?(?=</p></div>))'
        effectif = re.findall(pattern10,content)

        action = action[0]
        prix = prix[0]
        cap_boursiere = cap_boursiere[0]
        price_earning_ratio = price_earning_ratio[0]
        beta = beta[0]
        benefice_par_action = benefice_par_action[0]
        dividendes = dividendes[0]
        action_en_circulation = action_en_circulation[0]
        secteur = secteur[0]
        effectif = effectif[0]

        Result = [action,prix,cap_boursiere,price_earning_ratio,beta,benefice_par_action,dividendes,action_en_circulation,secteur,effectif]
        Base.append(Result)
        

with open("mabase_CAC40.csv", "w",encoding='utf8') as outfile:
        data=csv.writer(outfile,delimiter=',',lineterminator='\n')
        for b in Base:
                data.writerow(b)

