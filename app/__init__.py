#!/usr/bin/env python3
import json
from flask import Flask, stream_template, request, redirect
from . import decklist

app = Flask(__name__)

def get_recs(decklist):
    pass

@app.get("/")
def index():
    return stream_template("index.html")

@app.post("/")
def process():
    card_list = request.files["decklistFile"].read().decode('utf-8')
    if len(card_list) == 0:
        card_list = request.form["decklist"]
    cards = card_list.split('\n')
    boosters = decklist.parse(cards, 'ignoreLands' in request.form)
    return stream_template("index.html", boosters=boosters)
