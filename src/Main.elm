module Main exposing (main)

import Bot exposing (Bot)
import Browser as Browser exposing (Document)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Value)
import Node exposing (Node)
import Result



-- Model


type alias Model =
    { bots : List Bot
    , nodes : List Node
    , error : Maybe String
    }


initModel : Model
initModel =
    { bots = []
    , nodes = []
    , error = Nothing
    }



-- Update


type Msg
    = GetData
    | UpdateBots (Result Http.Error (List Bot))
    | UpdateNodes (Result Http.Error (List Node))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData ->
            let
                cmd =
                    Cmd.batch
                        [ Bot.getBots |> Http.send UpdateBots
                        , Node.getNodes |> Http.send UpdateNodes
                        ]
            in
            ( model, cmd )

        UpdateBots result ->
            case result of
                Result.Ok bots ->
                    ( { model | bots = bots }, Cmd.none )

                Err err ->
                    let
                        jiheh =
                            Debug.log "jiheh" err
                    in
                    ( { model | error = Just "There was an error fetching bots" }
                    , Cmd.none
                    )

        UpdateNodes result ->
            case result of
                Result.Ok nodes ->
                    ( { model | nodes = nodes }, Cmd.none )

                Err _ ->
                    ( { model | error = Just "There was an error fetching nodes" }
                    , Cmd.none
                    )



-- View


view : Model -> Document Msg
view model =
    { title = "Central Mining Service Dashboard"
    , body = getDashboard model
    }


getDashboard : Model -> List (Html Msg)
getDashboard model =
    [ div [] [ text "HELLO WORLD" ]
    , button [ onClick GetData ] [ text "Click ME!" ]
    ]



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Main


init : Value -> ( Model, Cmd Msg )
init flags =
    ( initModel, Cmd.none )


main : Program Value Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
