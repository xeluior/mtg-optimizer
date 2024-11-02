/* Total card weights for each sheet */
drop table if exists setBoosterSheetCardWeightTotals;
create table setBoosterSheetCardWeightTotals as
select boosterName,
  setCode,
  sheetName,
  sum(cardWeight) as totalWeight
from setBoosterSheetCards
group by boosterName, setCode, sheetName;

/* P(card(uuid) in sheet(boosterName, setCode, sheetName)) */
drop table if exists setBoosterSheetCardProbability;
create table setBoosterSheetCardProbability as
select a.boosterName,
  a.setCode,
  a.sheetName,
  a.cardUuid,
  cast(a.cardWeight as real) / b.totalWeight as cardProbability
from setBoosterSheetCards a
join setBoosterSheetCardWeightTotals b
on a.boosterName = b.boosterName
and a.setCode = b.setCode
and a.sheetName = b.sheetName;

/* Total sheetPicks in booster(index, nmae, set) */
drop table if exists setBoosterSheetPicksTotal;
create table setBoosterSheetPicksTotal as
select boosterIndex,
  boosterName,
  setCode,
  sum(sheetPicks) as totalPicks
from setBoosterContents
group by boosterIndex, boosterName, setCode;

/* P(sheet(name) in booster(index, name, set)) */
drop table if exists setBoosterSheetPicksProbability;
create table setBoosterSheetPicksProbability as
select a.boosterIndex,
  a.boosterName,
  a.setCode,
  a.sheetName,
  cast(a.sheetPicks as real) / b.totalPicks as sheetProbability
from setBoosterContents a
join setBoosterSheetPicksTotal b
on a.boosterIndex = b.boosterIndex
and a.boosterName = b.boosterName
and a.setCode = b.setCode;

/* P(card(uuid) in booster(index, name, set)) */
drop table if exists setBoosterContentCardProbability;
create table setBoosterContentCardProbability as
select a.boosterIndex,
  a.boosterName,
  a.setCode,
  b.cardUuid,
  sum(a.sheetProbability * b.cardProbability) as cardProbability
from setBoosterSheetPicksProbability a
join setBoosterSheetCardProbability b
on a.boosterName = b.boosterName
and a.setCode = b.setCode
and a.sheetName = b.sheetName
group by a.boosterIndex, a.boosterName, a.setCode, b.cardUuid;

/* Total boosterWeights in booster(name, set) */
drop table if exists setBoosterContentWeightTotal;
create table setBoosterContentWeightTotal as
select boosterName,
  setCode,
  sum(boosterWeight) as totalWeight
from setBoosterContentWeights
group by boosterName, setCode;

/* P(booster(index, name, set) in booster(name, set)) */
drop table if exists setBoosterContentProbability;
create table setBoosterContentProbability as
select a.boosterIndex,
  a.boosterName,
  a.setCode,
  cast(a.boosterWeight as real) / b.totalWeight as contentProbability
from setBoosterContentWeights a
join setBoosterContentWeightTotal b
on a.boosterName = b.boosterName
and a.setCode = b.setCode;

/* P(card(uuid) in booster(name, set)) */
drop table if exists setBoosterCardProbability;
create table setBoosterCardProbability as
select a.boosterName,
  a.setCode,
  a.cardUuid,
  sum(a.cardProbability * b.contentProbability) as cardProbability
from setBoosterContentCardProbability a
join setBoosterContentProbability b
on a.boosterIndex = b.boosterIndex
and a.boosterName = b.boosterName
and a.setCode = b.setCode
group by a.boosterName, a.setCode, a.cardUuid;
