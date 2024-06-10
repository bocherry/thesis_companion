import requests
import logging
import time
import datetime
import json
import os
import pandas as pd


TOKEN = ""

def filter_dataset(path_to_dataset):
    """
    Filter projects that uses mongodb or mongoose
    
    parameters:
    -----------
    path_to_dataset: file containing the dataset in csv format (str)
    """

    df = pd.read_csv(path_to_dataset)


    mongodb_dependency = []
    mongoose_dependency = []

    for project_name in df['name'].values:

        dependency = individual_project(project_name)
        mongodb_dependency.append(dependency['mongodb'])
        mongoose_dependency.append(dependency['mongoose'])

    df['mongodb_dependency'] = mongodb_dependency
    df['mongoose_dependency'] = mongoose_dependency

    df.to_csv('seart_filtered.csv')

def individual_project(project_name) -> dict:
    """
    Checks whether a given project uses mongoose or mongodb

    parameters:
    -----------
    project_name: name of the project in form owner/project (e.g. HabitRPG/habitica) (str)

    return:
    -------
    mongo_usage: dict with keys 'mongodb' or 'mongoose' with bool as values (dict)
    """

    ret = {'mongoose': False, 'mongodb': False}
    payload = make_sbom_request(project_name)

    if payload:
        sbom = json.loads(payload)

        for key in sbom['sbom']['packages']:

            if key['name'] == 'npm:mongodb':
                ret['mongodb'] = True

            if key['name'] == 'npm:mongoose':
                ret['mongoose'] = True

    return ret

def make_sbom_request(project_name:str) -> str :
    """
    Make request to github API to get SBOM of the given project

    parameters:
    -----------
    project_name: name of the project in form owner/project (e.g. HabitRPG/habitica) (str)

    return:
    -------
    payload: payload containing the requested sbom (str)
    """

    logger = logging.getLogger('dependency_extract')

    logging.basicConfig(filename='network_handling.log', encoding='utf-8', level=logging.INFO)
    headers = {"Authorization": TOKEN}

    r = requests.get(f'https://api.github.com/repos/{project_name}/dependency-graph/sbom', auth=("", TOKEN))

    payload = ""
    
    match r.status_code:

        case 200:
            
            logger.info(f'{project_name} fetched')
            if int(r.headers['X-RateLimit-Remaining']) == 0:
                time_to_sleep = int(r.headers['X-RateLimit-Reset']) - int(time.time()) + 60
                logger.warning(f'Exceeded limit, waiting {time_to_sleep} secs starting{datetime.datetime.now()}')
                time.sleep(time_to_sleep)

            payload = r.text

            if not os.path.isdir(f'sbom_dump/{project_name.split("/")[0]}'):
                os.mkdir(f'sbom_dump/{project_name.split("/")[0]}')

            with open(f'sbom_dump/{project_name}', 'w') as f:
                f.write(payload)


        case 403:
            logger.error(f'Exceeded Limit while requesting {project_name}')

        case _:
            logger.warning(f'Unexpected while requesting {project_name} : {r.status_code} -> {r.text}')
            

    return payload

filter_dataset('seart_unfiltered.csv')
