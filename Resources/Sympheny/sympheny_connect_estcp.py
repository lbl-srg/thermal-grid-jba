# -*- coding: utf-8 -*-
"""
Created on Fri Mar 29 17:41:50 2024

@author: remi

Step by step script:
    1- Delete + Create a new scenario based on "single_hub"
    2- Populate the scenario with the different hubs
    3- Add the energy demands (based on xlsx files) for Cooling + Space heating + Domestic hot water + Electricity
    4- Add on-site resources (extend the existing ones to all the hubs)
    5- Add the supply technologies (extend the existing one to all the hubs)
Improvements:
    2- Hubs : import geospatial data
    5- Imports and exports : dynamic price, how to send a file?
    
"""

import json
import requests
import copy
import os
import pandas as pd
import base64
from dict_sympheny import conversion_ini, storage_ini

def open_target_file(target_path):
    with open(target_path,"rb") as excel_file:
        return excel_file.read()

def decode_excel_profile(path_to_file):
    excel_file = open_target_file(path_to_file)
    encoded_excel = base64.b64encode(excel_file)
    decoded = encoded_excel.decode('utf-8')
    return decoded


sympheny_username = "hcasperfu@lbl.gov" #@param {type:"string"}
sympheny_password = "DoD!ESTCP" #@param {type:"string"}

url = "https://eu-north-1-api.sympheny.com/backoffice/auth/ext/token"

payload = json.dumps({
  "email": sympheny_username,
  "password": sympheny_password
})
headers = { 
  'accept': 'application/json',
  'Content-Type': 'application/json'
}

response = requests.request("POST", url, headers=headers, data=payload)
response_json = json.loads(response.text)
access_token = response_json["access_token"]

headers = {
  'accept': 'application/json',
  'authorization': 'Bearer ' + access_token,
  'content-type': 'application/json',
}

baseUrl = "https://eu-north-1-api.sympheny.com/"

#%% Getting the script working (not from scratch)

# url = baseUrl + "sympheny-app/projects"
# response = requests.request("GET", url, headers=headers, data=payload)

# project_name = "JBA_ESTCP"
# analysis_name = "jba"
# scenario_new = "multi_hub"

# for project in json.loads(response.text)["data"]["projects"]:
#     if project['projectName'] == project_name:
#         projectGuid = project['projectGuid']

# url_project = baseUrl + f"sympheny-app/projects/{projectGuid}"
# response = requests.request("GET", url_project, headers=headers, data=payload)

# projectDetails = json.loads(response.text)["data"]["analyses"]
# for analysis in projectDetails:
#     if analysis['analysisName'] == analysis_name:
#         analysisGuid = analysis['analysisGuid']
#     for scenario in analysis['scenarios']:
#         if scenario['scenarioName'] == scenario_new:
#             scenarioGuid = scenario['scenarioGuid']

# hubs = ['1045', '1380']
# response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)
# hub_rp = json.loads(response.text)

# hub_current = {}
# for k in json.loads(response.text)['data']:
#     hub_current[k['hubName']] = k['hubGuid']
    
# if '1380' not in hubs:
#     hub_ini = hub_current[hubs[0]]
# else:
#     hub_ini = hub_current['1380']

#%% Getting scenarios GUID + creating new ones

url = baseUrl + "sympheny-app/projects"
response = requests.request("GET", url, headers=headers, data=payload)

project_name = "JBA_ESTCP"
analysis_name = "jba"
scenario_name = "single_hub"
scenario_new = "multi_hub"

for project in json.loads(response.text)["data"]["projects"]:
    if project['projectName'] == project_name:
        projectGuid = project['projectGuid']

url_project = baseUrl + f"sympheny-app/projects/{projectGuid}"
response = requests.request("GET", url_project, headers=headers, data=payload)

projectDetails = json.loads(response.text)["data"]["analyses"]
for analysis in projectDetails:
    if analysis['analysisName'] == analysis_name:
        analysisGuid = analysis['analysisGuid']
    for scenario in analysis['scenarios']:
        if scenario['scenarioName'] == scenario_name:
            scenarioGuid_ini = scenario['scenarioGuid']
        if scenario['scenarioName'] == scenario_new:
            scenariodel = scenario['scenarioGuid']
            response = requests.delete(baseUrl + f"sympheny-app/scenario/{scenariodel}", headers=headers)

response = requests.put(baseUrl + f"sympheny-app/scenarios/copy/{scenarioGuid_ini}", headers=headers)
scenarioGuid = json.loads(response.text)["data"]['scenarioGuid']

payload = json.dumps(
    {
      "scenarioName": scenario_new
      }
    )

response = requests.put(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}", headers=headers, data=payload)


#%% Delete initial input data (hub 1380)

url_demand = baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/energy-demands"

response = requests.get(url_demand, headers=headers)
rp = json.loads(response.text)['data']['energyDemands']

energy_demand = {}
for k in rp:
    response = requests.delete(baseUrl + f"sympheny-app/scenarios/energy-demands/{k['energyDemandGuid']}", headers=headers)
    
response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)
hub_rp = json.loads(response.text)

hub_current = {}
for k in json.loads(response.text)['data']:
    hub_current[k['hubName']] = k['hubGuid']


#%% New hubs 

response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)
hub_rp = json.loads(response.text)

hub_current = {}
for k in json.loads(response.text)['data']:
    hub_current[k['hubName']] = k['hubGuid']

# Modify the first hub in case the building 1380 is not taken into account

hubs_complete = ['1045', '1058x1060', '1065', '1345', '1349', '1359', '1380', 
                 '1500', '1539', '1560', '1569', '1631', '1657', '1676', 
                 '1690', '1691', '1692', '1800', '3500', '3501']

hubs = ['1045', '1380']
hubs_add = hubs.copy()

if '1380' not in hubs:
    payload = json.dumps(
        {
          "hubName": hubs[0]
          }
        )
    response = requests.put(baseUrl + "sympheny-app/scenarios/hubs/hub_current['1380']", headers=headers, data=payload)
    del hubs_add[0]
    response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)
else:
    hubs_add.remove('1380')

response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)

if len(hubs_add) > 0:
    for k in hubs_add:
        payload = json.dumps(
            {
             "hubName": k
             }
            )
        response = requests.post(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers, data=payload)

response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/hubs", headers=headers)
hub_rp = json.loads(response.text)

hub_current = {}
for k in json.loads(response.text)['data']:
    hub_current[k['hubName']] = k['hubGuid']
    
if '1380' not in hubs:
    hub_ini = hub_current[hubs[0]]
else:
    hub_ini = hub_current['1380']


#%% Upload energy profiles

response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/carriers", headers=headers)
energy_scenario = json.loads(response.text)["data"]["energyCarriers"]
energy_carrier = {}
for k in energy_scenario:
    energy_carrier[k['energyCarrierName']] = k['energyCarrierGuid']

url_demand = baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/energy-demands"

folder = r'C:\git\thermal-grid-jba\Resources\Data\Consumption\to_sympheny'
files = pd.DataFrame(os.listdir(folder), columns=['file'])
files['hub'] = files['file'].apply(lambda x: x.split('_')[0])
files['source'] = files['file'].apply(lambda x: x.split('_')[-1].replace('.xlsx', ''))
files['name'] = files['file'].apply(lambda x: x.replace('.xlsx', ''))
files = files[files['hub'].isin(hubs)]

carrier_name = {'ele': 'Electricity', 'coo':'Cooling 10 - 20°C', 
                'hea': 'SH 40-50 °C', 'dhw':'DHW 50-60 °C'}

for k in files.index:
    decoded = decode_excel_profile(os.path.join(folder, files.loc[k, 'file']))
    payload = json.dumps({
          "energyCarrierGuid": energy_carrier[carrier_name[files.loc[k, 'source']]],
          "fileRequestDto":
              {"fileName":files.loc[k, 'file'],
                "encodedFile":f"data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,{decoded}"},
          "hubGuid": hub_current[files.loc[k, 'hub']],
          "multiplicationFactor": 0,
          "name": files.loc[k, 'name']
    })

    response = requests.post(url_demand, headers=headers, data=payload)
    rp = json.loads(response.text)


#%% Upload imports/exports

response = requests.get(baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/impexes", headers=headers)
impex_rp = json.loads(response.text)['data']

if len(impex_rp) > 0:
    for k in impex_rp:
        response = requests.delete(baseUrl + f"sympheny-app/impex/{k['type'].upper()}/{k['guid']}", headers=headers)

hubs_all = hubs + ['Plant']

imp = {'Electricity': 0.5, 'Heat Ambient': 0}
for k in imp:
    payload = json.dumps({
          'energyPriceCHFkWh': imp[k],
          "energyCarrierGuid": energy_carrier[k],
          'type':"IMPORT",
          'hubs': [{"hubGuid": hub_current[guid]} for guid in hubs_all]
          })
    response = requests.post(baseUrl + f"sympheny-app/scenario/{scenarioGuid}/impex", headers=headers, data=payload)
    rp = json.loads(response.text)


#%% Update conversion technologies

url_techno = baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/conversion-technologies"
response = requests.get(url_techno, headers=headers)
rp = json.loads(response.text)

converting_list = [k['conversionTechnologyGuid'] for k in rp['data']['conversionTechnologies']]

for n in converting_list[:1]:
    url_techno = baseUrl + f"sympheny-app/scenarios/conversion-technologies/{n}"
    response = requests.get(url_techno, headers=headers)
    rp = json.loads(response.text)['data']
    if rp['hubs'][0]['hubGuid'] == hub_ini:
        choices = ['input', 'output']
        l_ene = []
        for i in choices:
            for k in rp['technologyModes'][0][f'{i}EnergyCarriers']:
                ene_carrier = copy.deepcopy(conversion_ini['conversionTechnologyModes'][0]['energyCarriers'][0])
                for m in k:
                    if m in ene_carrier:
                        ene_carrier[m] = k[m]
                ene_carrier['type'] = i.upper()
                l_ene.append(ene_carrier)
        
        l_conv = copy.deepcopy(conversion_ini['conversionTechnologyModes'][0])
        l_conv['energyCarriers'] = l_ene
        l_conv['primary'] = rp['technologyModes'][0]['primary']
        l_conv['seasonalOperation'] = rp['technologyModes'][0]['seasonalOperationValue']
        
        summary = copy.deepcopy(conversion_ini)
        for k in rp:
            if k in summary:
                summary[k] = rp[k]
        summary['conversionTechnologyModes'] = [l_conv]
        summary['hubGuids'] = [hub_current[k] for k in hubs]
                
        for k in list(summary.keys()):
            if summary[k] == 'string':
                del summary[k]
        
        payload = json.dumps(summary)
        response = requests.put(url_techno, headers=headers, data=payload)
        rp = json.loads(response.text)


#%% Update storage technologies

url_storage = baseUrl + f"sympheny-app/scenarios/{scenarioGuid}/storage-technologies"
response = requests.get(url_storage, headers=headers)
rp = json.loads(response.text)['data']
storage_list = [k['storageTechnologyGuid'] for k in rp['storageTechnologies']]

for n in storage_list:
    url_sto = baseUrl + f"sympheny-app/scenarios/storage-technologies/{n}"
    response = requests.get(url_sto, headers=headers)
    rp = json.loads(response.text)['data']
    if rp['hubs'][0]['hubGuid'] == hub_ini:
        summary = copy.deepcopy(storage_ini)
        for k in rp:
            if k in summary:
                summary[k] = rp[k]
        summary['hubGuids'] = [hub_current[k] for k in hubs]
        summary['energyCarrierGuid'] = rp['storageCarrier']['energyCarrierGuid']
        for k in list(summary.keys()):
            if summary[k] == 'string':
                del summary[k]
        
        payload = json.dumps(summary)
        response = requests.put(url_sto, headers=headers, data=payload)
        rp = json.loads(response.text)