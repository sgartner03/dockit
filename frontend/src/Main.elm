module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing (Parser, (</>), int, map, oneOf, s, string)
import Docs

-- NEEDS CHANGES FOR NEW ROUTES

type Route
  = DocsRoute String
  | NotFoundRoute

type Page
  = DocsPage Docs.Model
  | NotFoundPage

parseUrl : Url.Url -> Route
parseUrl url =
    case Url.Parser.parse routeParser url of
        Just route ->
            route
        -- default page
        Nothing ->
            NotFoundRoute

routeParser : Parser (Route -> a) a
routeParser =
  oneOf
    [ Url.Parser.map DocsRoute   (Url.Parser.s "docs" </> string)
    ]

type Msg
  = DocsMsg Docs.Msg
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( DocsMsg subMsg, DocsPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Docs.update subMsg pageModel
            in
            ( { model | page = DocsPage updatedPageModel }
            , Cmd.map DocsMsg updatedCmd
            )
        ( LinkClicked urlRequest, _ ) ->
          case urlRequest of
            Browser.Internal url ->
              ( model, Nav.pushUrl model.navKey (Url.toString url) )
    
            Browser.External href ->
              ( model, Nav.load href )
    
        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( _, _ ) ->
            ( model, Cmd.none )

view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFoundPage ->
            notFoundView

        DocsPage docsModel ->
            let
                dview = Docs.view docsModel
                obody = dview.body
                nbody = List.map (\html -> Html.map DocsMsg html) obody
            in
                { title = dview.title
                , body = [div [class "container py-3"] nbody]
                }

initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                NotFoundRoute ->
                    ( NotFoundPage, Cmd.none )

                DocsRoute route ->
                    let
                        (pageModel, pageCmd) =
                            case model.page of
                                DocsPage docsModel ->
                                    Docs.update (Docs.ChangeText route) docsModel
                                _ ->
                                    Docs.init route
                    in
                    ( DocsPage pageModel, Cmd.map DocsMsg pageCmd )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )

-- DOES NOT NEED CHANGES FOR NEW ROUTES

type alias Model =
  { route : Route
  , page : Page
  , navKey : Nav.Key
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )

notFoundView : Browser.Document msg
notFoundView =
    { title = ""
    , body = [a [href "docs/hallo/"] [ text "not found view" ]]
    }

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
