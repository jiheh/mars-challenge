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
import Time



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
    = GetData Time.Posix
    | UpdateBots (Result Http.Error (List Bot))
    | UpdateNodes (Result Http.Error (List Node))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData _ ->
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
    , body = gridView model
    }


gridView : Model -> List (Html Msg)
gridView model =
    [ table [ class "grid" ] (renderRows model.grid model.bots model.nodes) ]


renderRows : Grid -> List Bot -> List Node -> List (Html Msg)
renderRows rows bots nodes =
    rows
        |> List.map (\row -> tr [] (renderColumns row bots nodes))


renderColumns : List Cell -> List Bot -> List Node -> List (Html Msg)
renderColumns cols bots nodes =
    cols
        |> List.map (\cell -> renderCell cell bots nodes)


renderCell : Cell -> List Bot -> List Node -> Html Msg
renderCell cell bots nodes =
    let
        visitingBot =
            bots
                |> List.filter (\b -> b.locationX == cell.x && b.locationY == cell.y)
                |> List.head
                |> Maybe.map .id
                |> Maybe.withDefault ""

        node =
            nodes
                |> List.filter (\n -> n.locationX == cell.x && n.locationY == cell.y)
                |> List.head
                |> Maybe.map .value
                |> Maybe.withDefault 0
    in
    td [] [ text visitingBot, text (String.fromInt node) ]



-- Subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 GetData



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
