module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
import Json.Decode
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required, requiredAt)
import Json.Encode
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket


-- APP


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , dots : List Dot
    }


type alias Dot =
    { name : String
    , color : String
    , pulsing : String
    , index : Int
    }


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init websocketRoute
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "dot:update" channelName DotUpdate


websocketRoute : String
websocketRoute =
    "ws://localhost:4000/socket/websocket"


init : ( Model, Cmd Msg )
init =
    let
        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.onJoin (always PhoenixJoin)
                |> Phoenix.Channel.onClose (always (PhoenixResponse channelName))

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel initSocket
    in
    ( { phxSocket = phxSocket, dots = [] }
    , Cmd.map PhoenixMsg phxCmd
    )


channelName : String
channelName =
    "dot:channel"



-- UPDATE


type Msg
    = PhoenixMsg (Phoenix.Socket.Msg Msg)
    | PhoenixJoin
    | PhoenixResponse String
    | DotUpdate Json.Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixJoin ->
            let
                push_ =
                    Phoenix.Push.init "dot:init" channelName

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push_ model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        PhoenixResponse response ->
            ( model, Cmd.none )

        PhoenixMsg phoenixMsg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update phoenixMsg model.phxSocket
            in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

        DotUpdate payload ->
            case Json.Decode.decodeValue dotsPayloadDecoder payload of
                Ok { dots } ->
                    let
                        _ =
                            Debug.log "new dots" dots
                    in
                    ( { model | dots = dots }, Cmd.none )

                Err error ->
                    let
                        _ =
                            Debug.log "DotUpdate error" error
                    in
                    ( model, Cmd.none )


type alias DotsPayload =
    { dots : List Dot }


type alias Dots =
    List Dot


dotsPayloadDecoder : Json.Decode.Decoder DotsPayload
dotsPayloadDecoder =
    decode DotsPayload
        |> required "dots" dotsDecoder


dotsDecoder =
    Json.Decode.list dotDecoder


dotDecoder : Json.Decode.Decoder Dot
dotDecoder =
    decode Dot
        |> required "name" Json.Decode.string
        |> required "color" Json.Decode.string
        |> required "pulsing" Json.Decode.string
        |> required "index" Json.Decode.int



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { phxSocket } =
    Sub.batch
        [ Phoenix.Socket.listen phxSocket PhoenixMsg
        ]



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div [ class "container", style [ ( "margin-top", "30px" ), ( "text-align", "center" ) ] ]
        [ renderDots model ]


renderDots { dots } =
    let
        renderedDots =
            List.map renderDot dots
    in
    div [ style containerStyle ] renderedDots


renderDot dot =
    div [ dot |> dotStyle |> style, dot |> dotClass |> class ]
        [ span [ style textStyle ] [ text dot.name ]
        ]


containerStyle =
    []


textStyle =
    [ ( "display", "inline-block" )
    , ( "vertical-align", "middle" )
    , ( "line-height", "normal" )
    , ( "font-size", "40px" )
    , ( "text-shadow", "white 0px 0px 5px" )
    ]


dotClass { pulsing } =
    case pulsing of
        "true" ->
            "pulse"

        _ ->
            ""


dotStyle { color, index } =
    [ ( "height", "200px" )
    , ( "width", "200px" )
    , ( "position", "absolute" )
    , ( "backgroundColor", color )
    , ( "border-radius", "50%" )
    , ( "text-align", "center" )
    , ( "line-height", "200px" )
    , ( "marginLeft", marginLeftForIndex index )
    , ( "marginTop", marginTopForIndex index )
    , ( "top", "0px" )
    ]


marginLeftForIndex index =
    let
        mod =
            (index % 4 * 250 + 100)
                |> toString
    in
    String.concat [ mod, "px" ]


marginTopForIndex index =
    let
        mod =
            (index // 4 * 250 + 100)
                |> toString
    in
    String.concat [ mod, "px" ]
