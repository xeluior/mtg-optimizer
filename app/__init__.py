#!/usr/bin/env python3
import json
from flask import Flask, render_template, request, redirect

app = Flask(__name__)

def get_recs(decklist):
    pass

@app.get("/")
def index():
    return render_template("index.html")

@app.post("/")
def process():
    if request.files["decklistFile"].content_length > 0:
        recs = get_recs(request.files["decklistFile"].read())
    else:
        recs = get_recs(request.form["decklist"])
    return redirect('/')
