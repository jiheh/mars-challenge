module Main exposing (main)

import Browser as Browser exposing (Document)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Value)



-- Model


type alias Model =
    { test : String }


initModel : Model
initModel =
    { test = "test" }



-- Update


type Msg
    = NoOp
    | UpdateString String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateString string ->
            ( { model | test = string }, Cmd.none )



-- View


view : Model -> Document Msg
view model =
    let
        body =
            [ div [] [ text model.test ]
            , button [ onClick (UpdateString "CLICK") ] [ text "Click ME!" ]
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
