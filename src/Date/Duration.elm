module Date.Duration
  ( add
  , firstOfTheMonth
  , Duration (..)
  ) where

{-| A Duration is time period that may vary with with calendar and time.

Name of type concept copied from NodaTime.

@docs add
@docs firstOfTheMonth
@docs Duration

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Date, Month)

-- import Date.Calendar as Calendar
import Date.Core as Core
import Date.Period as Period

{-| A Duration is time period that may vary with with calendar and time.

Name of type copied from NodaTime.
-}
type Duration
  = Millisecond
  | Second
  | Minute
  | Hour
  | Day
  | Week
  | Month
  | Year
  -- | Combo {year,month,week,day,hour,min,sec,millisecond}
  -- DateDiff can return a Duration Combo :) neat.

{-| Add duration * count to date. -}
add : Duration -> Int -> Date -> Date
add duration =
  case duration of
    Millisecond -> Period.add Period.Millisecond
    Second -> Period.add Period.Second
    Minute -> Period.add Period.Minute
    Hour -> Period.add Period.Hour
    Day -> Period.add Period.Day
    Week -> Period.add Period.Week
    Month -> addMonth
    Year -> addYear


{- Return a date with month count added to date. -}
addMonth : Int -> Date -> Date
addMonth monthCount date =
  let
    goalDay = Date.day date
  in
    if monthCount == 0 then
       date
    else if monthCount > 0 then
      addMonthPositive goalDay monthCount date
    else -- if monthCount < 0 then
      addMonthNegative goalDay monthCount date


addMonthPositive : Int -> Int -> Date -> Date
addMonthPositive goalDay monthCount date =
  let
    thisMonthMaxDay = Core.daysInMonthDate date
    nextMonthMaxDay = Core.daysInNextMonth date
    nextMonthTargetDay = min goalDay nextMonthMaxDay
    addDays = thisMonthMaxDay - (Date.day date) + nextMonthTargetDay
    -- _ = Debug.log("addMonthPositive") (goalDay, addDays, monthCount, (Format.isoString date))
    nextMonth = Core.fromTime ((Core.toTime date) + (addDays * Core.ticksADay))
  in
    if monthCount == 0 then
      date
    else
      addMonthPositive goalDay (monthCount - 1) nextMonth


addMonthNegative : Int -> Int -> Date -> Date
addMonthNegative goalDay monthCount date =
  let
    prevMonthMaxDay = Core.daysInPrevMonth date
    prevMonthTargetDay = min goalDay prevMonthMaxDay
    addDays = -(Date.day date) - (prevMonthMaxDay - prevMonthTargetDay)
    -- _ = Debug.log("addMonthNegative'") (goalDay, addDays, monthCount, (Format.isoString date))
    prevMonth = Core.fromTime ((Core.toTime date) + (addDays * Core.ticksADay))
  in
    if monthCount == 0 then
      date
    else
      addMonthNegative goalDay (monthCount + 1) prevMonth


{- Return a date with year count added to date. -}
addYear : Int -> Date -> Date
addYear yearCount date  =
  addMonth (12 * yearCount) date


{-| Return first of month for year of date adjusted to given month. -}
firstOfTheMonth : Date -> Month -> Date
firstOfTheMonth baseDate targetMonth =
  let
    date = Core.toFirstOfMonth baseDate
    month = Date.month date
    monthDiff =
      (Core.monthToInt targetMonth) - (Core.monthToInt month)
  in
    add Month monthDiff date