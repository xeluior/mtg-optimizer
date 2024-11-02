#!/usr/bin/env python3
import sys
import re
import sqlite3

BASIC_LANDS = ('Plains', 'Island', 'Swamp', 'Mountain', 'Forest')
EXCLUDED_BOOSTERS = ('prerelease%', 'mtgo', 'box-topper%', 'collector-sample', 'arena')

db = sqlite3.connect('data/AllPrintings.sqlite')

def parse_deck_file(filename):
    card_re = re.compile('^([0-9]+ )?(.+)$')
    decklist = []
    with open(filename, 'r') as fd:
        for line in fd:
            match = card_re.match(line)
            if match:
                cardname = match.group(2)
                if cardname in BASIC_LANDS:
                    continue
                decklist.append(cardname)
    return decklist

def find_boosters(cards):
    query_string =  'select setCode, boosterName, sum(cardProbability) from setBoosterCardProbability where 1=1'
    for excluded_booster in EXCLUDED_BOOSTERS:
        query_string += ' and boosterName not like \'%s\'' % excluded_booster
    query_string += ' and cardUuid in (select uuid from cards where 0=1'
    for card in cards:
        query_string += ' or name = ?'
    query_string +=  ') group by setCode, boosterName order by sum(cardProbability)'

    boosters = db.execute(query_string, cards)
    for row in boosters:
        print(row)

def main():
    decklist = parse_deck_file(sys.argv[1])
    find_boosters(decklist)

if __name__ == "__main__":
    main()
