module Main exposing (main)

import Bot exposing (Bot)
import Browser as Browser exposing (Document)
import Grid exposing (Cell, Grid)
import Html exposing (Html, button, div, table, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Value)
import Node exposing (Node)
import Result



-- Model


type alias Model =
    { bots : List Bot
    , nodes : List Node
    , columns : Int
    , rows : Int
    , grid : Grid
    , error : Maybe String
    }


initModel : Model
initModel =
    { bots = []
    , nodes = []
    , columns = 20
    , rows = 20
    , grid = []
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
    , body = renderDashboard model
    }


renderDashboard : Model -> List (Html Msg)
renderDashboard model =
    [ button [ onClick GetData ] [ text "Click ME!" ]
    , gridView model
    ]


gridView : Model -> Html Msg
gridView model =
    table [ class "grid" ] (renderRows model.grid)


renderRows : Grid -> List (Html Msg)
renderRows rows =
    rows
        |> List.map (\row -> tr [] (renderColumns row))


renderColumns : List Cell -> List (Html Msg)
renderColumns cols =
    cols
        |> List.map (\cell -> td [] [ text "hi" ])



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Main


init : Value -> ( Model, Cmd Msg )
init flags =
    ( { initModel | grid = Grid.generateGrid initModel.rows initModel.columns }
    , Cmd.none
    )


main : Program Value Model Msg
main =
    Browser.document
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
