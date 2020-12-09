import pyodbc
from sqlalchemy import create_engine
import pandas as pd


server = 'LAPTOP-Q5O9P275\SQLEXPRESS'
database = 'themeparks'
engine = create_engine('mssql+pyodbc://@' + server + '/' + database + '?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server')

querry1 = '''SELECT t1.id,
                    t1.name, 
                    t1.visitors_per_annum as visitors, 
                    t1.area_in_acres as area,
                    t2.website,
                    t3.total_attr,
                    t3.rollercoasters,
                    t3.waterrides,
                    t4.country
            FROM themeparks as t1 
            JOIN tp_contact as t2 ON t1.id = t2.tp_id
            JOIN tp_attractions_num as t3 ON t1.id = t3.tp_id
            JOIN tp_locations as t4 ON t1.id = t4.tp_id
'''
querry2 = '''SELECT t1.distance,
                    t2.name as city,
                    t3.country as tp_country
            FROM distance as t1
            JOIN cities_cz as t2 ON t1.city_id = t2.id
            JOIN tp_locations as t3 ON t1.tp_id = t3.tp_id        
'''

df_info = pd.read_sql(querry1, engine)
df_distance = pd.read_sql(querry2, engine)
df_cities = pd.read_sql('select distinct name from cities_cz', engine)

zeme_cz_en = {'Švédsko':'Sweden', 'Belgie':'Belgium', 'Dánsko':'Denmark', 'Anglie':'England',
              'Francie':'France', 'Německo':'Germany', 'Itálie':'Italy', 'Nizozemsko':'Netherlands',
              'Polsko':'Poland', 'Španělsko':'Spain'
             }

def main(dict_zemi_en, df_cities, df_info, df_distance):
    while True:
        print_greeting()
        mesta_na_vyber = df_cities['name'].tolist()
        mesto = check_input_city(get_input_city(mesta_na_vyber))
        zeme_na_vyber = [key for key in zeme_cz_en]
        zeme = change_country_en(check_input_country(get_input_country(zeme_na_vyber)), dict_zemi_en)
        dict_answ_info = get_info(df_info, zeme)
        distance = get_distance(df_distance, zeme, mesto)
        print_answer(dict_answ_info, distance)
        pokracovat = new_search()
        if pokracovat == 'N':
            break

def print_greeting():
    print('Dobrý den, vítejte ve vyhladávači zábavních parků.')

def get_input_city(list):
    list_mest = list
    vstup_city = input('Z jakého města budete vyjíždět? Vyberte z nabídky {}: '.format(list_mest))
    return vstup_city, list_mest

def check_input_city(input_tuple):
    vstup_city = input_tuple[0]
    list_mest = input_tuple[1]
    wrong_input = True
    while wrong_input:
        if vstup_city not in list_mest:
            vstup_city = input('Chybně zadané město. Vyberte z následující nabídky: {}: '.format(list_mest))
        else:
            wrong_input = False
    return vstup_city

def get_input_country(list):
    list_zemi = list
    vstup_country = input('Do jaké země se chcete podívat? Vyberte z nabídky {}: '.format(list_zemi))
    return vstup_country, list_zemi

def check_input_country(input_tuple):
    vstup_country = input_tuple[0]
    list_zemi = input_tuple[1]
    wrong_input = True
    while wrong_input:
        if vstup_country not in list_zemi:
            vstup_country = input('Chybně zadaná země. Vyberte z nabídky {}: '.format(list_zemi))
        else:
            wrong_input = False
    return vstup_country

def change_country_en(string, dict):
    en_country = dict[string]
    return en_country

def get_info(df, vstup_co):
    list_answ = ['name', 'visitors', 'area', 'website', 'total_attr', 'rollercoasters',
                 'waterrides', 'country']
    dict_answ1 = {i:df[df['country'].str.contains(vstup_co)][i].iloc[0] for i in list_answ}
    return dict_answ1

def get_distance(df, vstup_co, vstup_ci):
    distance = df[(df['tp_country'].str.contains(vstup_co)) & (df['city'].str.contains(vstup_ci))]['distance'].iloc[0]
    return round(distance, 2)

def print_answer(dict_answers, distance):
    print('''\nVe Vámi vybrané zemi se nachazí zábavní park {}, který je z Vašeho výchozího města vzdálen {} km. \n
Zábavní park leží na rozloze {} akrů a v roce 2019 jej navštívilo {} milionů návštěvníků. V parku {} se nachází 
celkem {} atrakcí, z toho {} horských drah a {} vodních atrakcí. \nVíce informací můžete najít na webových stránkách {}. \n
'''.format(dict_answers['name'], distance, dict_answers['area'], dict_answers['visitors'], dict_answers['name'],
           dict_answers['total_attr'], dict_answers['rollercoasters'], dict_answers['waterrides'], dict_answers['website']
           ))

def new_search():
    pokracovat = input('Zvolte prosím "A" pro další hledání, "N" pro ukončení programu:')
    wrong_input = True
    while wrong_input:
        if pokracovat.upper() not in ('A', 'N'):
            pokracovat = input('Zvolte prosím "A" pro další hledání, "N" pro ukončení programu:')
        else:
            wrong_input = False
    return pokracovat.upper()


main(zeme_cz_en, df_cities, df_info, df_distance)