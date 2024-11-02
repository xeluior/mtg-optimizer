/* Total weight of all the cards on a sheet */
drop table if exists setBoosterSheetWeight;
create table setBoosterSheetWeight as
select boosterName,
  setCode,
  sheetName,
  sum(cardWeight) as sheetWeight
from setBoosterSheetCards
group by boosterName, setCode, sheetName;

/* Probability of a card on a particular sheet */
drop table setBoosterSheetCardProbability;
create table setBoosterSheetCardProbability as
select a.boosterName,
  a.cardUuid,
  a.setCode,
  a.sheetName,
  cast(a.cardWeight as real) / b.sheetWeight as cardProbability
from setBoosterSheetCards a
join setBoosterSheetWeight b
on a.boosterName = b.boosterName
and a.setCode = b.setCode
and a.sheetName = b.sheetName;

/* Probability of a card on a sheet in a booster index */
drop table setBoosterContentSheetCardProbability;
create table setBoosterContentSheetCardProbability as
select a.boosterIndex,
  a.boosterName,
  a.setCode,
  a.sheetName,
  b.cardUuid,
  b.cardProbability * a.sheetPicks as cardProbability
from setBoosterContents a
join setBoosterSheetCardProbability b
on a.boosterName = b.boosterName
and a.setCode = b.setCode
and a.sheetName = b.sheetName;

/* Total probability of a card on any sheet in a booster index */
drop table setBoosterContentCardProbability;
create table setBoosterContentCardProbability as
select boosterIndex,
  boosterName,
  setCode,
  cardUuid,
  sum(cardProbability) as cardProbability
from setBoosterContentSheetCardProbability
group by boosterIndex, boosterName, setCode, cardUuid;

/* Total weight of all indexes for a booster name */
drop table setBoosterWeights;
create table setBoosterWeights as
select boosterName,
  setCode,
  sum(boosterWeight) as setWeight
from setBoosterContentWeights
group by boosterName, setCode;

/* Probability of a particular booster index in a name */
drop table setBoosterContentProbability;
create table setBoosterContentProbability as
select a.boosterIndex,
  a.boosterName,
  a.setCode,
  cast(a.boosterWeight as real) / b.setWeight as boosterProbability
from setBoosterContentWeights a
join setBoosterWeights b
on a.boosterName = b.boosterName
and a.setCode = b.setCode;

/* Total probability of a card in any sheet in any index of a booster name */
drop table setBoosterCardProbability;
create table setBoosterCardProbability as
select a.boosterName,
  a.setCode,
  a.cardUuid,
  sum(a.cardProbability * b.boosterProbability) as cardProbability
from setBoosterContentCardProbability a
join setBoosterContentProbability b
on a.boosterName = b.boosterName
and a.setCode = b.setCode
group by a.boosterName, a.setCode, a.cardUuid;
