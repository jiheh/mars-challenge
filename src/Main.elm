module Main exposing (main)

import Browser as Browser exposing (Document)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Value)
import Restaurant exposing (Restaurant)
import Result



-- Model


type alias Model =
    { restaurants : List Restaurant }


initModel : Model
initModel =
    { restaurants = [] }



-- Update


type Msg
    = NoOp
    | GetRestaurants
    | UpdateRestaurants (Result Http.Error (List Restaurant))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetRestaurants ->
            ( model, Restaurant.getRestaurants |> Http.send UpdateRestaurants )

        UpdateRestaurants result ->
            case result of
                Result.Ok restaurants ->
                    ( { model | restaurants = restaurants }, Cmd.none )

                Err error ->
                    let
                        log =
                            Debug.log "ERROR" error
                    in
                    ( model, Cmd.none )



-- View


view : Model -> Document Msg
view model =
    let
        body =
            [ div [] [ text "HELLO WORLD" ]
            , button [ onClick GetRestaurants ] [ text "Click ME!" ]
            ]
    in
    { title = "Mars Challenge"
    , body = body
    }



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
