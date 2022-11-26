module Docs exposing (..)

import Browser
import Html exposing (Html, button, div, text, li, ul, a, span)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Header exposing (..)
import Http
import Markdown
import Json.Decode exposing (Decoder, map2, field, string)

main =
  Browser.document { init = init, update = update, view = view, subscriptions = \_ -> Sub.none}

type alias Model = 
    { name : String
    , content : Content String
    , index : Content (List Index)
    }

type Content a
  = Failure
  | Loading
  | Success a

contentStringify : Content String -> String
contentStringify content =
    case content of
        Success str -> str
        Loading -> "Loading ..."
        Failure -> "Failed to retrive documentation."

realFile : String -> String
realFile x =
    if (String.endsWith ".md" x) then x else (String.append x ".md")

realName : String -> String
realName x =
    if (String.endsWith ".md" x) then (String.dropRight 3 x) else x

fetchContent : String -> Cmd Msg
fetchContent x =
      Http.get
        { url = (String.append "/assets/docs/" (realFile x))
        , expect = Http.expectString GotText
        }

init : String -> (Model, Cmd Msg)
init x =
  ( Model x Loading Loading
  , Cmd.batch [
      fetchContent x
      , Http.get
        { url = "/assets/docs/index.json"
        , expect = Http.expectJson GotIndex (Json.Decode.list indexDecoder)
        }
      ]
  )

type alias Index =
    { display : String
    , fileName : String
    }

indexDecoder : Decoder Index
indexDecoder =
  map2 Index
    (field "display" string)
    (field "file_name" string)

buildNav : Content (List Index) -> String -> Html Msg
buildNav content currentPage =
  let
    links = case content of
        Success indexes -> List.map (\index -> li [class "nav-item"] [
          let
            xclass = if index.fileName == (realName currentPage) then "active" else "link-dark"
            cstyle = if index.fileName == (realName currentPage) then [style "background-color" "#f0f0f0", style "color" "black"] else []
          in
            a ([ href (String.append "/docs/" index.fileName)
              , onClick (ChangeText index.fileName)
              , class (String.append "nav-link " xclass)
              ] ++ cstyle) [text index.display]
          ]
          )
          indexes
        Failure -> [span [] [text "Failed to load index."]]
        Loading -> [span [] [text "Loading..."]]
  in
    div [class "border-end col-md-3 bg-light d-flex flex-column flex-shrink-0 p-2 bg-body"
        , style "min-height" "820px"
        ] 
      [ ul [class "nav nav-pills flex-column mb-auto me-3"] links
      ]

type Msg
  = GotText (Result Http.Error String)
  | GotIndex (Result Http.Error (List Index))
  | ChangeText String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok response ->
            ( { model | content = (Success response) }, Cmd.none )
        Err _ ->
            ( { model | content = (Failure) }, Cmd.none )
    GotIndex result ->
      case result of
        Ok response ->
            ( { model | index = (Success response) }, Cmd.none )
        Err _ ->
            ( { model | index = (Failure) }, Cmd.none )
    ChangeText fileName ->
      ( { model | content = Loading, name = fileName }
      , fetchContent fileName
      )

view : Model -> Browser.Document Msg
view model =
  let
    content = div [class "col-md-8 ms-2"] [Markdown.toHtml [] (contentStringify model.content)]
    withSidebar = div [class "row"] [(buildNav model.index model.name), content]
  in
    { title = ""
    , body = [headerT Docs, withSidebar]
    }
