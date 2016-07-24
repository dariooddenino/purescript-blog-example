module Router where

import Prelude

import Data.Either
import Data.Functor.Coproduct (Coproduct(..), left)
import Data.Maybe
import Control.Monad.Aff
import Control.Monad.Aff.AVar
import Control.Monad.Eff.Exception

import Routing
import Routing.Match
import Routing.Match.Class
import Data.Functor
import Control.Alt
import Data.Tuple
import DOM

import Halogen as H
import Halogen.HTML.Indexed as HH
import Halogen.HTML.Events.Indexed as HE
import Halogen.HTML.Properties.Indexed as HP
import Halogen.Component.ChildPath (ChildPath(), cpR, cpL)

import Model
import Component.PostList (PostListQuery)
import Component.Post (PostQuery)

data Query a
  = Goto Routes a

data Routes
  = Home
  | Posts Number

type State = { currentPage :: String }

init :: State
init = { currentPage: "Home" }

routing :: Match Routes
routing
    = Home <$ lit ""
  <|> Posts <$> (lit "posts" *> num)

type ChildState = Either PostList Post
type ChildQuery = Coproduct PostListQuery PostQuery
type ChildSlot = Either PostListSlot PostSlot

pathToPostList :: ChildPath PostList ChildState PostListQuery ChildQuery PostListSlot ChildSlot
pathToPostList = cpL

pathToPost :: ChildPath Post ChildState PostQuery ChildQuery PostSlot ChildSlot
pathToPost = cpR

type StateP g = H.ParentState State ChildState Query ChildQuery g ChildSlot
type QueryP = Coproduct Query (H.ChildF ChildSlot ChildQuery)

ui :: forall g. (Functor g) => H.Component (StateP g) QueryP g
ui = H.parentComponent { render, eval, peek: Nothing }
  where

  render :: State -> H.ParentHTML ChildState Query ChildQuery g ChildSlot
  render st =
    HH.h1_ [ HH.text "router" ]

  eval :: Query ~> H.ParentDSL State ChildState Query ChildQuery g ChildSlot
  eval (Goto _ next) = do
    pure next

type Effects e = (dom :: DOM, avar :: AVAR, err :: EXCEPTION | e)

routeSignal :: forall eff. H.Driver QueryP eff
            -> Aff (Effects eff) Unit
routeSignal driver = do
  Tuple old new <- matchesAff routing
  redirects driver old new

redirects :: forall eff. H.Driver QueryP eff
          -> Maybe Routes
          -> Routes
          -> Aff (Effects eff) Unit
redirects driver _ =
  driver <<< left <<< H.action <<< Goto
