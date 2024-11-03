#!/usr/bin/env python3
import sqlite3
import re

BASIC_LANDS = {'Plains', 'Island', 'Swamp', 'Mountain', 'Forest'}
EXCLUDED_BOOSTERS = ('prerelease%', 'mtgo', 'box-topper%', 'collector-sample', 'arena')

def query(cards):
    db = sqlite3.connect('data/AllPrintings.sqlite')
    db.row_factory = sqlite3.Row

    query_string =  '''
    select a.boosterName,
        b.name as cardName,
        c.name as setName,
        sum(a.cardProbability) as probability
    from setBoosterCardProbability a
    join cards b
    on a.cardUuid = b.uuid
    join sets c
    on a.setCode = c.code
    where 1=1
    '''

    for excluded_booster in EXCLUDED_BOOSTERS:
        query_string += f' and a.boosterName not like \'{excluded_booster}\''

    query_string += ' and (0=1'

    for _ in cards:
        query_string += ' or b.name = ?'
    query_string +=  '''
    ) group by a.boosterName, b.name, c.name
    order by sum(cardProbability)
    '''

    rows = db.execute(query_string, list(cards))
    return rows

def parse_deck(deck, ignore_lands=False):
    card_re = re.compile('^([0-9]*x? )?(.*)$')

    cards = set()
    for card in deck:
        card_match = card_re.match(card)
        if card_match:
            card_name = card_match.group(2)
            if ignore_lands and card_name in BASIC_LANDS:
                continue
            cards.add(card_name)
    return cards

def parse(deck, ignore_lands=False):
    print(deck)
    cards = parse_deck(deck, ignore_lands)

    sets = {}
    for booster in query(cards):
        booster_name = f'{booster["setName"]} {booster["boosterName"]}'
        card_name = booster["cardName"]
        card_prb = booster["probability"]

        if booster_name not in sets:
            sets[booster_name] = {}
        sets[booster_name][card_name] = card_prb

    return sets
