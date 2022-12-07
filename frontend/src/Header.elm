module Header exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

type ActivePage
  = Docker
  | Postgres
  | Docs

headerT : ActivePage -> Html a
headerT _ =
    header [] [
        div [class "d-flex flex-column flex-md-row align-items-center pb-3 mb-4 border-bottom"] [
            a [href "/", class "d-flex align-items-center text-dark text-decoration-none"] [
                img [class "ml-5", src "/assets/brand/logo.png", width 60, height 50] []
                , span [class "fs-4 mr-3"] [text "Dockit (beta)"]
                ]
            , nav [class "d-inline-flex mt-2 mt-md-0 ms-md-auto"] [
                a [class "me-3 py-2 text-dark text-decoration-none", href "../"] [text "Docker"]
                , a [class "me-3 py-2 text-dark text-decoration-none", href "../"] [text "Dokumentation"]
                , a [class "py-2 text-dark text-decoration-none", href "../"] [
                    button [class "btn btn-sm btn-outline-danger"] [text "Abmelden"]
                ]
            ]
        ]
        ]
