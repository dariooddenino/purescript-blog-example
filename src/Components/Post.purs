module Component.Post where

import Prelude

import Halogen as H
import Halogen.HTML.Indexed as HH

import Model (Post)

data PostQuery a
  = Update Post a
  | Delete a

post :: forall g. H.Component Post PostQuery g
post = H.component { render, eval }
  where

  render :: Post -> H.ComponentHTML PostQuery
  render p = HH.h1_ [ HH.text "POST" ]

  eval :: PostQuery ~> H.ComponentDSL Post PostQuery g
  eval (Update u next) = do
    H.modify (_ { title = u.title, body = u.body })
    pure next
  eval (Delete next) = pure next
