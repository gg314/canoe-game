port module Canoe exposing (Model, Msg(..), init, inputPort, main, outputPort, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (id, style, type_, attribute, placeholder, value, class, name, for)
import Html.Events exposing (onInput, onSubmit, onClick)

import Dict
import Set exposing (Set)
import Tuple
import Time
import Json.Encode
import Json.Decode

import User exposing (User)



-- MAIN


main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias JSONMessage = 
  { action : String 
  , content : Json.Encode.Value
  }

type alias Model =
  { nameInProgress : String
  , topMessage : String
  , board : List ( List (Int) )
  , selectedReds : Set (Int, Int)
  , selectedBlues : Set (Int, Int)
  , lastCell : Int
  , turn : Int
  , currentTimer : Int
  , debugString : String
  , red : Maybe User
  , blue : Maybe User
  , user : Maybe User
  , users : List ( User )
  }

buildDefault : List ( List (Int) )
buildDefault = 
  [[-1,  0,  0, -1, -1, -1, -1, -1, -1, -1,  0,  0, -1],
  [0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
  [0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
  [0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
  [-1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1],
  [-1, -1, -1,  0,  0,  0,  0,  0,  0,  0, -1, -1, -1]]

init : () -> (Model, Cmd Msg)
init _ =
  (Model
    ""
    ""
    buildDefault
    Set.empty
    Set.empty
    3
    1
    0
    "&nbsp;"
    Nothing
    Nothing
    Nothing
    []
  , Cmd.none )


tempCanoeList : List ( List ( List ( List ( Int, Int ))))
tempCanoeList = [ [ [], [[(0, 1), (1, 0), (2, 0), (3, 1)], [(1, 0), (0, 1), (0, 2), (1, 3)], [(1, 0), (2, 1), (2, 2), (1, 3)]], [[(0, 1), (1, 0), (2, 0), (3, 1)], [(2, 0), (1, 1), (1, 2), (2, 3)], [(2, 0), (3, 1), (3, 2), (2, 3)]], [], [], [], [], [], [], [], [[(9, 1), (10, 0), (11, 0), (12, 1)], [(10, 0), (9, 1), (9, 2), (10, 3)], [(10, 0), (11, 1), (11, 2), (10, 3)]], [[(9, 1), (10, 0), (11, 0), (12, 1)], [(11, 0), (10, 1), (10, 2), (11, 3)], [(11, 0), (12, 1), (12, 2), (11, 3)]], []]
                , [ [[(0, 1), (1, 2), (2, 2), (3, 1)], [(0, 1), (1, 0), (2, 0), (3, 1)], [(1, 0), (0, 1), (0, 2), (1, 3)]], [[(1, 1), (2, 2), (3, 2), (4, 1)], [(0, 2), (1, 1), (2, 1), (3, 2)], [(2, 0), (1, 1), (1, 2), (2, 3)], [(1, 1), (0, 2), (0, 3), (1, 4)], [(1, 1), (2, 2), (2, 3), (1, 4)]], [[(2, 1), (3, 2), (4, 2), (5, 1)], [(0, 2), (1, 1), (2, 1), (3, 2)], [(1, 2), (2, 1), (3, 1), (4, 2)], [(2, 1), (1, 2), (1, 3), (2, 4)], [(1, 0), (2, 1), (2, 2), (1, 3)], [(2, 1), (3, 2), (3, 3), (2, 4)]], [[(3, 1), (4, 2), (5, 2), (6, 1)], [(0, 1), (1, 2), (2, 2), (3, 1)], [(0, 1), (1, 0), (2, 0), (3, 1)], [(1, 2), (2, 1), (3, 1), (4, 2)], [(2, 2), (3, 1), (4, 1), (5, 2)], [(3, 1), (2, 2), (2, 3), (3, 4)], [(2, 0), (3, 1), (3, 2), (2, 3)], [(3, 1), (4, 2), (4, 3), (3, 4)]], [[(4, 1), (5, 2), (6, 2), (7, 1)], [(1, 1), (2, 2), (3, 2), (4, 1)], [(2, 2), (3, 1), (4, 1), (5, 2)], [(3, 2), (4, 1), (5, 1), (6, 2)], [(4, 1), (3, 2), (3, 3), (4, 4)], [(4, 1), (5, 2), (5, 3), (4, 4)]], [[(5, 1), (6, 2), (7, 2), (8, 1)], [(2, 1), (3, 2), (4, 2), (5, 1)], [(3, 2), (4, 1), (5, 1), (6, 2)], [(4, 2), (5, 1), (6, 1), (7, 2)], [(5, 1), (4, 2), (4, 3), (5, 4)], [(5, 1), (6, 2), (6, 3), (5, 4)]], [[(6, 1), (7, 2), (8, 2), (9, 1)], [(3, 1), (4, 2), (5, 2), (6, 1)], [(4, 2), (5, 1), (6, 1), (7, 2)], [(5, 2), (6, 1), (7, 1), (8, 2)], [(6, 1), (5, 2), (5, 3), (6, 4)], [(6, 1), (7, 2), (7, 3), (6, 4)]], [[(7, 1), (8, 2), (9, 2), (10, 1)], [(4, 1), (5, 2), (6, 2), (7, 1)], [(5, 2), (6, 1), (7, 1), (8, 2)], [(6, 2), (7, 1), (8, 1), (9, 2)], [(7, 1), (6, 2), (6, 3), (7, 4)], [(7, 1), (8, 2), (8, 3), (7, 4)]], [[(8, 1), (9, 2), (10, 2), (11, 1)], [(5, 1), (6, 2), (7, 2), (8, 1)], [(6, 2), (7, 1), (8, 1), (9, 2)], [(7, 2), (8, 1), (9, 1), (10, 2)], [(8, 1), (7, 2), (7, 3), (8, 4)], [(8, 1), (9, 2), (9, 3), (8, 4)]], [[(9, 1), (10, 2), (11, 2), (12, 1)], [(6, 1), (7, 2), (8, 2), (9, 1)], [(7, 2), (8, 1), (9, 1), (10, 2)], [(8, 2), (9, 1), (10, 1), (11, 2)], [(9, 1), (10, 0), (11, 0), (12, 1)], [(10, 0), (9, 1), (9, 2), (10, 3)], [(9, 1), (8, 2), (8, 3), (9, 4)], [(9, 1), (10, 2), (10, 3), (9, 4)]], [[(7, 1), (8, 2), (9, 2), (10, 1)], [(8, 2), (9, 1), (10, 1), (11, 2)], [(9, 2), (10, 1), (11, 1), (12, 2)], [(11, 0), (10, 1), (10, 2), (11, 3)], [(10, 1), (9, 2), (9, 3), (10, 4)], [(10, 1), (11, 2), (11, 3), (10, 4)]], [[(8, 1), (9, 2), (10, 2), (11, 1)], [(9, 2), (10, 1), (11, 1), (12, 2)], [(11, 1), (10, 2), (10, 3), (11, 4)], [(10, 0), (11, 1), (11, 2), (10, 3)], [(11, 1), (12, 2), (12, 3), (11, 4)]], [[(9, 1), (10, 2), (11, 2), (12, 1)], [(9, 1), (10, 0), (11, 0), (12, 1)], [(11, 0), (12, 1), (12, 2), (11, 3)]] ]
                , [ [[(0, 2), (1, 3), (2, 3), (3, 2)], [(0, 2), (1, 1), (2, 1), (3, 2)], [(1, 0), (0, 1), (0, 2), (1, 3)], [(1, 1), (0, 2), (0, 3), (1, 4)]], [[(1, 2), (2, 3), (3, 3), (4, 2)], [(0, 1), (1, 2), (2, 2), (4, 1)], [(0, 3), (1, 2), (2, 2), (3, 3)], [(1, 2), (2, 1), (3, 1), (4, 2)], [(2, 0), (1, 1), (1, 2), (2, 3)], [(2, 1), (1, 2), (1, 3), (2, 4)]], [[(2, 2), (3, 3), (4, 3), (5, 2)], [(1, 1), (2, 2), (3, 2), (5, 1)], [(0, 1), (1, 2), (2, 2), (3, 1)], [(0, 3), (1, 2), (2, 2), (3, 3)], [(1, 3), (2, 2), (3, 2), (4, 3)], [(2, 2), (3, 1), (4, 1), (5, 2)], [(3, 1), (2, 2), (2, 3), (3, 4)], [(1, 0), (2, 1), (2, 2), (1, 3)], [(1, 1), (2, 2), (2, 3), (1, 4)]], [[(3, 2), (4, 3), (5, 3), (6, 2)], [(0, 2), (1, 3), (2, 3), (3, 2)], [(2, 1), (3, 2), (4, 2), (6, 1)], [(1, 1), (2, 2), (3, 2), (4, 1)], [(0, 2), (1, 1), (2, 1), (3, 2)], [(1, 3), (2, 2), (3, 2), (4, 3)], [(2, 3), (3, 2), (4, 2), (5, 3)], [(3, 2), (4, 1), (5, 1), (6, 2)], [(4, 1), (3, 2), (3, 3), (4, 4)], [(3, 2), (2, 3), (2, 4), (3, 5)], [(2, 0), (3, 1), (3, 2), (2, 3)], [(2, 1), (3, 2), (3, 3), (2, 4)], [(3, 2), (4, 3), (4, 4), (3, 5)]], [[(4, 2), (5, 3), (6, 3), (7, 2)], [(1, 2), (2, 3), (3, 3), (4, 2)], [(3, 1), (4, 2), (5, 2), (7, 1)], [(2, 1), (3, 2), (4, 2), (5, 1)], [(1, 2), (2, 1), (3, 1), (4, 2)], [(2, 3), (3, 2), (4, 2), (5, 3)], [(3, 3), (4, 2), (5, 2), (6, 3)], [(4, 2), (5, 1), (6, 1), (7, 2)], [(5, 1), (4, 2), (4, 3), (5, 4)], [(4, 2), (3, 3), (3, 4), (4, 5)], [(3, 1), (4, 2), (4, 3), (3, 4)], [(4, 2), (5, 3), (5, 4), (4, 5)]], [[(5, 2), (6, 3), (7, 3), (8, 2)], [(2, 2), (3, 3), (4, 3), (5, 2)], [(4, 1), (5, 2), (6, 2), (8, 1)], [(3, 1), (4, 2), (5, 2), (6, 1)], [(2, 2), (3, 1), (4, 1), (5, 2)], [(3, 3), (4, 2), (5, 2), (6, 3)], [(4, 3), (5, 2), (6, 2), (7, 3)], [(5, 2), (6, 1), (7, 1), (8, 2)], [(6, 1), (5, 2), (5, 3), (6, 4)], [(5, 2), (4, 3), (4, 4), (5, 5)], [(4, 1), (5, 2), (5, 3), (4, 4)], [(5, 2), (6, 3), (6, 4), (5, 5)]], [[(6, 2), (7, 3), (8, 3), (9, 2)], [(3, 2), (4, 3), (5, 3), (6, 2)], [(5, 1), (6, 2), (7, 2), (9, 1)], [(4, 1), (5, 2), (6, 2), (7, 1)], [(3, 2), (4, 1), (5, 1), (6, 2)], [(4, 3), (5, 2), (6, 2), (7, 3)], [(5, 3), (6, 2), (7, 2), (8, 3)], [(6, 2), (7, 1), (8, 1), (9, 2)], [(7, 1), (6, 2), (6, 3), (7, 4)], [(6, 2), (5, 3), (5, 4), (6, 5)], [(5, 1), (6, 2), (6, 3), (5, 4)], [(6, 2), (7, 3), (7, 4), (6, 5)]], [[(7, 2), (8, 3), (9, 3), (10, 2)], [(4, 2), (5, 3), (6, 3), (7, 2)], [(6, 1), (7, 2), (8, 2), (10, 1)], [(5, 1), (6, 2), (7, 2), (8, 1)], [(4, 2), (5, 1), (6, 1), (7, 2)], [(5, 3), (6, 2), (7, 2), (8, 3)], [(6, 3), (7, 2), (8, 2), (9, 3)], [(7, 2), (8, 1), (9, 1), (10, 2)], [(8, 1), (7, 2), (7, 3), (8, 4)], [(7, 2), (6, 3), (6, 4), (7, 5)], [(6, 1), (7, 2), (7, 3), (6, 4)], [(7, 2), (8, 3), (8, 4), (7, 5)]], [[(8, 2), (9, 3), (10, 3), (11, 2)], [(5, 2), (6, 3), (7, 3), (8, 2)], [(7, 1), (8, 2), (9, 2), (11, 1)], [(6, 1), (7, 2), (8, 2), (9, 1)], [(5, 2), (6, 1), (7, 1), (8, 2)], [(6, 3), (7, 2), (8, 2), (9, 3)], [(7, 3), (8, 2), (9, 2), (10, 3)], [(8, 2), (9, 1), (10, 1), (11, 2)], [(9, 1), (8, 2), (8, 3), (9, 4)], [(8, 2), (7, 3), (7, 4), (8, 5)], [(7, 1), (8, 2), (8, 3), (7, 4)], [(8, 2), (9, 3), (9, 4), (8, 5)]], [[(9, 2), (10, 3), (11, 3), (12, 2)], [(6, 2), (7, 3), (8, 3), (9, 2)], [(8, 1), (9, 2), (10, 2), (12, 1)], [(7, 1), (8, 2), (9, 2), (10, 1)], [(6, 2), (7, 1), (8, 1), (9, 2)], [(7, 3), (8, 2), (9, 2), (10, 3)], [(8, 3), (9, 2), (10, 2), (11, 3)], [(9, 2), (10, 1), (11, 1), (12, 2)], [(10, 0), (9, 1), (9, 2), (10, 3)], [(10, 1), (9, 2), (9, 3), (10, 4)], [(9, 2), (8, 3), (8, 4), (9, 5)], [(8, 1), (9, 2), (9, 3), (8, 4)], [(9, 2), (10, 3), (10, 4), (9, 5)]], [[(7, 2), (8, 3), (9, 3), (10, 2)], [(8, 1), (9, 2), (10, 2), (11, 1)], [(7, 2), (8, 1), (9, 1), (10, 2)], [(8, 3), (9, 2), (10, 2), (11, 3)], [(9, 3), (10, 2), (11, 2), (12, 3)], [(11, 0), (10, 1), (10, 2), (11, 3)], [(11, 1), (10, 2), (10, 3), (11, 4)], [(9, 1), (10, 2), (10, 3), (9, 4)]], [[(8, 2), (9, 3), (10, 3), (11, 2)], [(9, 1), (10, 2), (11, 2), (12, 1)], [(8, 2), (9, 1), (10, 1), (11, 2)], [(9, 3), (10, 2), (11, 2), (12, 3)], [(10, 0), (11, 1), (11, 2), (10, 3)], [(10, 1), (11, 2), (11, 3), (10, 4)]], [[(9, 2), (10, 3), (11, 3), (12, 2)], [(9, 2), (10, 1), (11, 1), (12, 2)], [(11, 0), (12, 1), (12, 2), (11, 3)], [(11, 1), (12, 2), (12, 3), (11, 4)]] ]
                , [ [[(0, 3), (1, 4), (2, 4), (3, 3)], [(0, 3), (1, 2), (2, 2), (3, 3)], [(1, 1), (0, 2), (0, 3), (1, 4)]], [[(1, 3), (2, 4), (3, 4), (4, 3)], [(0, 2), (1, 3), (2, 3), (4, 2)], [(1, 3), (2, 2), (3, 2), (4, 3)], [(1, 0), (0, 1), (0, 2), (1, 3)], [(2, 1), (1, 2), (1, 3), (2, 4)], [(1, 0), (2, 1), (2, 2), (1, 3)]], [[(2, 3), (3, 4), (4, 4), (5, 3)], [(1, 2), (2, 3), (3, 3), (5, 2)], [(0, 2), (1, 3), (2, 3), (3, 2)], [(1, 4), (2, 3), (3, 3), (4, 4)], [(2, 3), (3, 2), (4, 2), (5, 3)], [(2, 0), (1, 1), (1, 2), (2, 3)], [(3, 1), (2, 2), (2, 3), (3, 4)], [(3, 2), (2, 3), (2, 4), (3, 5)], [(2, 0), (3, 1), (3, 2), (2, 3)], [(1, 1), (2, 2), (2, 3), (1, 4)]], [[(3, 3), (4, 4), (5, 4), (6, 3)], [(0, 3), (1, 4), (2, 4), (3, 3)], [(2, 2), (3, 3), (4, 3), (6, 2)], [(1, 2), (2, 3), (3, 3), (4, 2)], [(0, 3), (1, 2), (2, 2), (3, 3)], [(1, 4), (2, 3), (3, 3), (4, 4)], [(2, 4), (3, 3), (4, 3), (5, 4)], [(3, 3), (4, 2), (5, 2), (6, 3)], [(4, 1), (3, 2), (3, 3), (4, 4)], [(4, 2), (3, 3), (3, 4), (4, 5)], [(2, 1), (3, 2), (3, 3), (2, 4)]], [[(4, 3), (5, 4), (6, 4), (7, 3)], [(1, 3), (2, 4), (3, 4), (4, 3)], [(3, 2), (4, 3), (5, 3), (7, 2)], [(2, 2), (3, 3), (4, 3), (5, 2)], [(1, 3), (2, 2), (3, 2), (4, 3)], [(2, 4), (3, 3), (4, 3), (5, 4)], [(3, 4), (4, 3), (5, 3), (6, 4)], [(4, 3), (5, 2), (6, 2), (7, 3)], [(5, 1), (4, 2), (4, 3), (5, 4)], [(5, 2), (4, 3), (4, 4), (5, 5)], [(3, 1), (4, 2), (4, 3), (3, 4)], [(3, 2), (4, 3), (4, 4), (3, 5)]], [[(5, 3), (6, 4), (7, 4), (8, 3)], [(2, 3), (3, 4), (4, 4), (5, 3)], [(4, 2), (5, 3), (6, 3), (8, 2)], [(3, 2), (4, 3), (5, 3), (6, 2)], [(2, 3), (3, 2), (4, 2), (5, 3)], [(3, 4), (4, 3), (5, 3), (6, 4)], [(4, 4), (5, 3), (6, 3), (7, 4)], [(5, 3), (6, 2), (7, 2), (8, 3)], [(6, 1), (5, 2), (5, 3), (6, 4)], [(6, 2), (5, 3), (5, 4), (6, 5)], [(4, 1), (5, 2), (5, 3), (4, 4)], [(4, 2), (5, 3), (5, 4), (4, 5)]], [[(6, 3), (7, 4), (8, 4), (9, 3)], [(3, 3), (4, 4), (5, 4), (6, 3)], [(5, 2), (6, 3), (7, 3), (9, 2)], [(4, 2), (5, 3), (6, 3), (7, 2)], [(3, 3), (4, 2), (5, 2), (6, 3)], [(4, 4), (5, 3), (6, 3), (7, 4)], [(5, 4), (6, 3), (7, 3), (8, 4)], [(6, 3), (7, 2), (8, 2), (9, 3)], [(7, 1), (6, 2), (6, 3), (7, 4)], [(7, 2), (6, 3), (6, 4), (7, 5)], [(5, 1), (6, 2), (6, 3), (5, 4)], [(5, 2), (6, 3), (6, 4), (5, 5)]], [[(7, 3), (8, 4), (9, 4), (10, 3)], [(4, 3), (5, 4), (6, 4), (7, 3)], [(6, 2), (7, 3), (8, 3), (10, 2)], [(5, 2), (6, 3), (7, 3), (8, 2)], [(4, 3), (5, 2), (6, 2), (7, 3)], [(5, 4), (6, 3), (7, 3), (8, 4)], [(6, 4), (7, 3), (8, 3), (9, 4)], [(7, 3), (8, 2), (9, 2), (10, 3)], [(8, 1), (7, 2), (7, 3), (8, 4)], [(8, 2), (7, 3), (7, 4), (8, 5)], [(6, 1), (7, 2), (7, 3), (6, 4)], [(6, 2), (7, 3), (7, 4), (6, 5)]], [[(8, 3), (9, 4), (10, 4), (11, 3)], [(5, 3), (6, 4), (7, 4), (8, 3)], [(7, 2), (8, 3), (9, 3), (11, 2)], [(6, 2), (7, 3), (8, 3), (9, 2)], [(5, 3), (6, 2), (7, 2), (8, 3)], [(6, 4), (7, 3), (8, 3), (9, 4)], [(7, 4), (8, 3), (9, 3), (10, 4)], [(8, 3), (9, 2), (10, 2), (11, 3)], [(9, 1), (8, 2), (8, 3), (9, 4)], [(9, 2), (8, 3), (8, 4), (9, 5)], [(7, 1), (8, 2), (8, 3), (7, 4)], [(7, 2), (8, 3), (8, 4), (7, 5)]], [[(9, 3), (10, 4), (11, 4), (12, 3)], [(6, 3), (7, 4), (8, 4), (9, 3)], [(8, 2), (9, 3), (10, 3), (12, 2)], [(7, 2), (8, 3), (9, 3), (10, 2)], [(6, 3), (7, 2), (8, 2), (9, 3)], [(7, 4), (8, 3), (9, 3), (10, 4)], [(8, 4), (9, 3), (10, 3), (11, 4)], [(9, 3), (10, 2), (11, 2), (12, 3)], [(10, 1), (9, 2), (9, 3), (10, 4)], [(8, 1), (9, 2), (9, 3), (8, 4)], [(8, 2), (9, 3), (9, 4), (8, 5)]], [[(7, 3), (8, 4), (9, 4), (10, 3)], [(8, 2), (9, 3), (10, 3), (11, 2)], [(7, 3), (8, 2), (9, 2), (10, 3)], [(8, 4), (9, 3), (10, 3), (11, 4)], [(10, 0), (9, 1), (9, 2), (10, 3)], [(11, 1), (10, 2), (10, 3), (11, 4)], [(10, 0), (11, 1), (11, 2), (10, 3)], [(9, 1), (10, 2), (10, 3), (9, 4)], [(9, 2), (10, 3), (10, 4), (9, 5)]], [[(8, 3), (9, 4), (10, 4), (11, 3)], [(9, 2), (10, 3), (11, 3), (12, 2)], [(8, 3), (9, 2), (10, 2), (11, 3)], [(11, 0), (10, 1), (10, 2), (11, 3)], [(11, 0), (12, 1), (12, 2), (11, 3)], [(10, 1), (11, 2), (11, 3), (10, 4)]], [[(9, 3), (10, 4), (11, 4), (12, 3)], [(9, 3), (10, 2), (11, 2), (12, 3)], [(11, 1), (12, 2), (12, 3), (11, 4)]] ]
                , [ [], [[(0, 3), (1, 4), (2, 4), (4, 3)], [(1, 4), (2, 3), (3, 3), (4, 4)], [(1, 1), (0, 2), (0, 3), (1, 4)], [(1, 1), (2, 2), (2, 3), (1, 4)]], [[(2, 4), (3, 5), (4, 5), (5, 4)], [(1, 3), (2, 4), (3, 4), (5, 3)], [(0, 3), (1, 4), (2, 4), (3, 3)], [(2, 4), (3, 3), (4, 3), (5, 4)], [(2, 1), (1, 2), (1, 3), (2, 4)], [(3, 2), (2, 3), (2, 4), (3, 5)], [(2, 1), (3, 2), (3, 3), (2, 4)]], [[(3, 4), (4, 5), (5, 5), (6, 4)], [(2, 3), (3, 4), (4, 4), (6, 3)], [(1, 3), (2, 4), (3, 4), (4, 3)], [(3, 4), (4, 3), (5, 3), (6, 4)], [(3, 1), (2, 2), (2, 3), (3, 4)], [(4, 2), (3, 3), (3, 4), (4, 5)], [(3, 1), (4, 2), (4, 3), (3, 4)]], [[(4, 4), (5, 5), (6, 5), (7, 4)], [(3, 3), (4, 4), (5, 4), (7, 3)], [(2, 3), (3, 4), (4, 4), (5, 3)], [(1, 4), (2, 3), (3, 3), (4, 4)], [(3, 5), (4, 4), (5, 4), (6, 5)], [(4, 4), (5, 3), (6, 3), (7, 4)], [(4, 1), (3, 2), (3, 3), (4, 4)], [(5, 2), (4, 3), (4, 4), (5, 5)], [(4, 1), (5, 2), (5, 3), (4, 4)], [(3, 2), (4, 3), (4, 4), (3, 5)]], [[(5, 4), (6, 5), (7, 5), (8, 4)], [(2, 4), (3, 5), (4, 5), (5, 4)], [(4, 3), (5, 4), (6, 4), (8, 3)], [(3, 3), (4, 4), (5, 4), (6, 3)], [(2, 4), (3, 3), (4, 3), (5, 4)], [(3, 5), (4, 4), (5, 4), (6, 5)], [(4, 5), (5, 4), (6, 4), (7, 5)], [(5, 4), (6, 3), (7, 3), (8, 4)], [(5, 1), (4, 2), (4, 3), (5, 4)], [(6, 2), (5, 3), (5, 4), (6, 5)], [(5, 1), (6, 2), (6, 3), (5, 4)], [(4, 2), (5, 3), (5, 4), (4, 5)]], [[(6, 4), (7, 5), (8, 5), (9, 4)], [(3, 4), (4, 5), (5, 5), (6, 4)], [(5, 3), (6, 4), (7, 4), (9, 3)], [(4, 3), (5, 4), (6, 4), (7, 3)], [(3, 4), (4, 3), (5, 3), (6, 4)], [(4, 5), (5, 4), (6, 4), (7, 5)], [(5, 5), (6, 4), (7, 4), (8, 5)], [(6, 4), (7, 3), (8, 3), (9, 4)], [(6, 1), (5, 2), (5, 3), (6, 4)], [(7, 2), (6, 3), (6, 4), (7, 5)], [(6, 1), (7, 2), (7, 3), (6, 4)], [(5, 2), (6, 3), (6, 4), (5, 5)]], [[(7, 4), (8, 5), (9, 5), (10, 4)], [(4, 4), (5, 5), (6, 5), (7, 4)], [(6, 3), (7, 4), (8, 4), (10, 3)], [(5, 3), (6, 4), (7, 4), (8, 3)], [(4, 4), (5, 3), (6, 3), (7, 4)], [(5, 5), (6, 4), (7, 4), (8, 5)], [(6, 5), (7, 4), (8, 4), (9, 5)], [(7, 4), (8, 3), (9, 3), (10, 4)], [(7, 1), (6, 2), (6, 3), (7, 4)], [(8, 2), (7, 3), (7, 4), (8, 5)], [(7, 1), (8, 2), (8, 3), (7, 4)], [(6, 2), (7, 3), (7, 4), (6, 5)]], [[(5, 4), (6, 5), (7, 5), (8, 4)], [(7, 3), (8, 4), (9, 4), (11, 3)], [(6, 3), (7, 4), (8, 4), (9, 3)], [(5, 4), (6, 3), (7, 3), (8, 4)], [(6, 5), (7, 4), (8, 4), (9, 5)], [(8, 4), (9, 3), (10, 3), (11, 4)], [(8, 1), (7, 2), (7, 3), (8, 4)], [(9, 2), (8, 3), (8, 4), (9, 5)], [(8, 1), (9, 2), (9, 3), (8, 4)], [(7, 2), (8, 3), (8, 4), (7, 5)]], [[(6, 4), (7, 5), (8, 5), (9, 4)], [(8, 3), (9, 4), (10, 4), (12, 3)], [(7, 3), (8, 4), (9, 4), (10, 3)], [(6, 4), (7, 3), (8, 3), (9, 4)], [(9, 1), (8, 2), (8, 3), (9, 4)], [(9, 1), (10, 2), (10, 3), (9, 4)], [(8, 2), (9, 3), (9, 4), (8, 5)]], [[(7, 4), (8, 5), (9, 5), (10, 4)], [(8, 3), (9, 4), (10, 4), (11, 3)], [(7, 4), (8, 3), (9, 3), (10, 4)], [(10, 1), (9, 2), (9, 3), (10, 4)], [(10, 1), (11, 2), (11, 3), (10, 4)], [(9, 2), (10, 3), (10, 4), (9, 5)]], [[(9, 3), (10, 4), (11, 4), (12, 3)], [(8, 4), (9, 3), (10, 3), (11, 4)], [(11, 1), (10, 2), (10, 3), (11, 4)], [(11, 1), (12, 2), (12, 3), (11, 4)]], [] ]
                , [ [], [], [], [[(2, 4), (3, 5), (4, 5), (6, 4)], [(3, 5), (4, 4), (5, 4), (6, 5)], [(3, 2), (2, 3), (2, 4), (3, 5)], [(3, 2), (4, 3), (4, 4), (3, 5)]], [[(3, 4), (4, 5), (5, 5), (7, 4)], [(2, 4), (3, 5), (4, 5), (5, 4)], [(4, 5), (5, 4), (6, 4), (7, 5)], [(4, 2), (3, 3), (3, 4), (4, 5)], [(4, 2), (5, 3), (5, 4), (4, 5)]], [[(4, 4), (5, 5), (6, 5), (8, 4)], [(3, 4), (4, 5), (5, 5), (6, 4)], [(5, 5), (6, 4), (7, 4), (8, 5)], [(5, 2), (4, 3), (4, 4), (5, 5)], [(5, 2), (6, 3), (6, 4), (5, 5)]], [[(5, 4), (6, 5), (7, 5), (9, 4)], [(4, 4), (5, 5), (6, 5), (7, 4)], [(3, 5), (4, 4), (5, 4), (6, 5)], [(6, 5), (7, 4), (8, 4), (9, 5)], [(6, 2), (5, 3), (5, 4), (6, 5)], [(6, 2), (7, 3), (7, 4), (6, 5)]], [[(6, 4), (7, 5), (8, 5), (10, 4)], [(5, 4), (6, 5), (7, 5), (8, 4)], [(4, 5), (5, 4), (6, 4), (7, 5)], [(7, 2), (6, 3), (6, 4), (7, 5)], [(7, 2), (8, 3), (8, 4), (7, 5)]], [[(7, 4), (8, 5), (9, 5), (11, 4)], [(6, 4), (7, 5), (8, 5), (9, 4)], [(5, 5), (6, 4), (7, 4), (8, 5)], [(8, 2), (7, 3), (7, 4), (8, 5)], [(8, 2), (9, 3), (9, 4), (8, 5)]], [[(7, 4), (8, 5), (9, 5), (10, 4)], [(6, 5), (7, 4), (8, 4), (9, 5)], [(9, 2), (8, 3), (8, 4), (9, 5)], [(9, 2), (10, 3), (10, 4), (9, 5)]], [], [], [] ]
                ]



-- UPDATE


type Msg
  = SetName String
  | NewGame
  | Tick Time.Posix
  | Ping Time.Posix
  | GetJSON Json.Encode.Value              -- Parse incoming JSON
  | GetBoard Json.Encode.Value
  | GetUsersList Json.Encode.Value
  | GetUser Json.Encode.Value
  | GetMessage Json.Encode.Value
  | ConnectToServer Json.Encode.Value      -- 000
  | SetTeam Int
  | AddMove Int Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of -- case Debug.log "MESSAGE: " msg of
    SetName name ->
      ( { model | nameInProgress = name }, Cmd.none )
      
    NewGame -> -- TODO!
      ( { model | nameInProgress = "New game" }, Cmd.none )

    Tick newTime ->
      let
          currentTimerDisplay = model.currentTimer + 1
      in
          ( { model | currentTimer = currentTimerDisplay }, Cmd.none )

    Ping newTime ->
      ( { model | currentTimer = (model.currentTimer + 1) }
        , outputPort (Json.Encode.encode
                        0
                      ( Json.Encode.object
                      [ ( "action", Json.Encode.string "ping"),
                        ( "content", Json.Encode.string "ping" ) ] ) )
      )

    GetJSON json ->
      case Json.Decode.decodeValue decodeJSON json of
        Ok {action, content} ->
          case action of
            "update_chat" ->
              ((Debug.log "Error: not implemented" model), Cmd.none ) -- Error: missing code
            "update_scoreboard" ->
              update (GetUsersList content) model
            "update_user" ->
              update (GetUser content) model
            "update_board" ->
              update (GetBoard content) model
            "update_message" ->
              update (GetMessage content) model
            _ ->
              ((Debug.log "Error: unknown code in JSON message" model), Cmd.none ) -- Error: missing code

        Err _ ->
          ( { model | debugString = ("Bad JSON: " ++ (Json.Encode.encode 0 json))}, Cmd.none )

    GetBoard json ->
      case Json.Decode.decodeValue (Json.Decode.list (Json.Decode.list Json.Decode.int)) json of
        Ok board ->
          ( { model | board = board}, Cmd.none )
        Err _ ->
          ( { model | debugString = "Critical error getting new board"}, Cmd.none )

    GetUsersList json ->
      case Json.Decode.decodeValue User.decodeUsersList json of
        Ok usersList ->
          let
            red_user =
              case List.filter (\z -> .team z == 1) (Dict.values usersList) of
                []     -> Nothing
                u::_ -> Just u
            blue_user =
              case List.filter (\z -> .team z == 2) (Dict.values usersList) of
                []     -> Nothing
                u::_ -> Just u
          in
            ( { model | users = Dict.values usersList, red = red_user, blue = blue_user }, Cmd.none )
        Err _ ->
          ( { model | debugString = "Error parsing userlist JSON"}, Cmd.none )

    GetUser json ->
      case Json.Decode.decodeValue User.decodeUser json of
        Ok user ->
          ( { model | user = Just user}, Cmd.none )
        Err _ ->
          ( { model | debugString = "Error parsing user JSON"}, Cmd.none )

    GetMessage json ->
      case Json.Decode.decodeValue Json.Decode.string json of
        Ok message ->
          ( { model | topMessage = message}, Cmd.none )
        Err _ ->
          ( { model | debugString = "Error parsing msg JSON"}, Cmd.none )

    ConnectToServer _ ->
      ( model,
        outputPort
          ( Json.Encode.encode
            0
            ( Json.Encode.object
              [ ("action", Json.Encode.string "create_user")
              , ("content", Json.Encode.string "") ] ))
        )

    SetTeam team ->
      ( model, outputPort
            ( Json.Encode.encode
              0
              ( Json.Encode.object
                [ ("action", Json.Encode.string "game_action")
                , ("content", Json.Encode.object
                  [ ("action", Json.Encode.string "set_team"),
                    ("content", Json.Encode.int team) ] ) ] ) ) )

    -- Add move.
    AddMove tx ty ->
      let
        newTurn = -1*model.turn+3
        newBoard = updateRows 0 tx ty newTurn model.board
        possibleCanoes = getCanoes tempCanoeList 0 tx ty
        selectedReds = if model.turn == 1 then Set.insert (tx, ty) model.selectedReds else model.selectedReds
        selectedBlues = if model.turn == 2 then Set.insert (tx, ty) model.selectedBlues else model.selectedBlues
        isNewCanoe = checkNewCanoe possibleCanoes (if model.turn == 1 then selectedReds else selectedBlues)
      in
        ( { model | debugString = Debug.toString isNewCanoe, selectedReds = selectedReds, selectedBlues = selectedBlues, turn = newTurn, board = newBoard}, 
          outputPort
            ( Json.Encode.encode
              0
              ( Json.Encode.object
                [ ("action", Json.Encode.string "game_action")
                , ("content", Json.Encode.object
                  [ ("action", Json.Encode.string "submit_movelist"),
                    ("content", Json.Encode.list Json.Encode.int [tx, ty])
                  ]
                )
              ]
            )
          )
        )

checkNewCanoe : List ( List ( Int, Int )) -> Set ( Int, Int ) -> Bool
checkNewCanoe possibleCanoes pegs =
  case possibleCanoes of
    c::cs ->
      let
        cset = Set.fromList c
      in
        if Set.size (Set.intersect cset pegs) == 4 then
          True
        else
          checkNewCanoe cs pegs
    _ ->
      False

getCanoes : List ( List ( List ( List (Int, Int)))) -> Int -> Int -> Int -> List ( List (Int, Int) )
getCanoes board row tx ty =
  case board of
    r::rs ->
      case getCanoesHelper r 0 row tx ty of
        Just c ->
          c
        Nothing -> 
          (getCanoes rs (row+1) tx ty)
    _ ->
      [[]]

getCanoesHelper : List ( List ( List (Int, Int))) -> Int -> Int-> Int -> Int -> Maybe (List ( List (Int, Int)))
getCanoesHelper row ix iy tx ty =
  case row of
    c::cs ->
      if (ix, iy) == (tx, ty) then
        Just c
      else
        getCanoesHelper cs (ix+1) iy tx ty
    _ ->
      Nothing

updateRows : Int -> Int -> Int -> Int -> List ( List (Int )) -> List ( List (Int) )
updateRows iy tx ty value board =
  case board of
    r::rs ->
      updateCol 0 iy tx ty value r::updateRows (iy+1) tx ty value rs
    _ ->
      []

      
updateCol : Int -> Int -> Int -> Int -> Int -> List (Int ) -> List (Int)
updateCol ix iy tx ty value board =
  case board of
    c::cs ->
      if (ix, iy) == (tx, ty) then
        value :: cs
      else
        c :: updateCol (ix+1) iy tx ty value cs
    _ ->
      []

decodeJSON : Json.Decode.Decoder JSONMessage
decodeJSON =
  Json.Decode.map2
    JSONMessage
    (Json.Decode.field "action" Json.Decode.string)
    (Json.Decode.field "content" Json.Decode.value)
    

decodeTeams : Json.Decode.Decoder ( String, String )
decodeTeams =
  Json.Decode.map2
    Tuple.pair
    (Json.Decode.field "red" Json.Decode.string)
    (Json.Decode.field "blue" Json.Decode.string)


-- SUBSCRIPTIONS

port outputPort : (String) -> Cmd msg
port inputPort : (Json.Encode.Value -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ Time.every 50000 Ping
    , Time.every 1000 Tick
    , inputPort GetJSON
    ]


-- VIEW
drawCells : Int -> Int -> List (Int) -> List (Html Msg)
drawCells x y remainingCells =
  case remainingCells of
    [] ->
      []
    v::vs ->
      case v of
        0 ->
          div [class "c"]
          [ div [ class "s", onClick (AddMove x y) ] [] ] :: drawCells (x+1) y vs
        1 ->
          div [class "c"]
          [ div [ class "s red" ] [] ] :: drawCells (x+1) y vs
        2 ->
          div [class "c"]
          [ div [ class "s blue" ] [] ] :: drawCells (x+1) y vs
        _ ->
          div [class "c"] [] :: drawCells (x+1) y vs

drawRows : Int -> List ( List (Int)) -> List (Html Msg)
drawRows y remainingRows =
  case remainingRows of
    [] ->
      []
    r::rs ->
      List.append (drawCells 0 y r) (drawRows (y+1) rs)

formatName : Maybe User -> String -> List ( Html Msg )
formatName user color =
  case user of
     Nothing ->
      [ div [ class ("s " ++ color) ] []
      , span []
        [ text "Waiting..."
        , em [] [ text "0" ]
        ]
      ]
     Just u  ->
      [ div [ class ("s " ++ color) ] []
        , span []
          [ text u.nickname
          , em [] [ text (String.fromInt u.score) ]
          ]
        ]

modalSpectators : Maybe User -> Maybe User -> List ( User )-> String
modalSpectators red_user blue_user all_users =
  String.join ", " (List.map .nickname all_users)

modalUser : Maybe User -> String -> Int -> Html Msg
modalUser user color teamid =
  case user of
     Nothing -> div [ class ("modal_" ++ String.toLower color), onClick (SetTeam teamid) ] [ div [ class "pad" ] [ h3 [] [ text (color ++ " player") ], h4 [] [ text "Click to join" ] ] ]
     Just u -> div [ class ("inactive modal_" ++ String.toLower color), onClick (SetTeam 0) ] [ div [ class "pad" ] [ h3 [] [ text (color ++ " player") ], h4 [] [ text u.nickname ] ] ]


showModal red blue users = 
  div [ class "lightbox" ]
  [ div [ class "modal"]
    [ div [ class "flex_container" ]
      [ modalUser red "Red" 1
      , modalUser blue "Blue" 2
      , div [ class "modal_spectators" ] [ h3 [] [ text "Spectators" ], text (modalSpectators red blue users) ]
      ]
    ]
  ]


view : Model -> Html Msg
view model =
  let
    drawBoard board = drawRows 0 board
  in 
    div [ class "container"]
    [ main_ []
      [ div [ class "top_message" ] [ text model.topMessage ]
      , div [] [ text model.debugString ]
      , div [ class "grid" ]
        ( model.board |> drawBoard )
      , div [ class "requests" ]
        [ div [ class "player-colors" ]
          [ div [ class "player-colors__row" ]
            (formatName model.red "red")
          , div [ class "player-colors__row" ]
            (formatName model.blue "blue")
          ]
        , div [class "a"]
          [ text "Resign" ]
        , div [class "a"]
          [ text "Help" ]
        ]
      ]
    , (if (model.red == Nothing || model.blue == Nothing) then showModal model.red model.blue model.users else div [] [])
    ]