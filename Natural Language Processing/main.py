# import flask modules

from flask import Flask, make_response, request, jsonify
import pandas as pd
import pickle5 as pickle

def form_text(df):
    # Function to create result string from given pandas dataframe
    text = ""
    for index, row in df.iterrows():
        text += str(row.date) + "\n" + row.title + "\n"
    return text

app = Flask(__name__)

#data = pd.read_pickle("./datawoarticle.pkl")
data = None
with open("datawoarticle.pkl", "rb") as fh:
    data = pickle.load(fh)
    
#INTENT: newest_news
newest_data = data.iloc[:5, :]
newest_text = form_text(newest_data)
#INTENT: oldest_news
oldest_data = data.iloc[-5:, :]
oldest_text = form_text(oldest_data)
#INTENT: crypto
crypto_pattern = '|'.join(["ethereum", "crypto", "ethereum", "dogecoin"])
crypto_data = data[data.title.str.contains(crypto_pattern)].iloc[:5,:]
crypto_text = form_text(crypto_data)
#INTENT: china
china_pattern = '|'.join(["china", "China"])
china_data = data[data.title.str.contains(china_pattern)].iloc[:5,:]
china_text = form_text(china_data)
#INTENT: covid
covid_pattern = '|'.join(["omicron", "Omicron", "delta", "Delta", "COVID-19", "COVID", "covid"])
covid_data = data[data.title.str.contains(covid_pattern)].iloc[:5,:]
covid_text = form_text(covid_data)

def create_result(text):
    # Function to create dialogflow specific json from given text
    result = {}
    result["fulfillmentText"] = text
    result = jsonify(result)
    result = make_response(result)
    return result

def results():
    req = request.get_json(force=True)
    intent = req.get('queryResult').get('intent').get('displayName')

    if intent == "newest_news":
        return create_result(newest_text)
    if intent == "oldest_news":
        return create_result(oldest_text)
    if intent == "crypto":
        return create_result(crypto_text)
    if intent == "china":
        return create_result(china_text)
    if intent == "covid":
        return create_result(covid_text)

@app.route('/webhook', methods=['GET', 'POST'])
def index():
    return results()

if __name__ == '__main__':
    app.run()
