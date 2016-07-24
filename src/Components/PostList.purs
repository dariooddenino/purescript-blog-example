module Component.PostList where

import Prelude

import Data.Array (snoc, filter, length)
import Data.Functor.Coproduct (Coproduct)
import Data.Map as M
import Data.Maybe (Maybe(..), fromMaybe)

import Halogen as H
import Halogen.HTML.Events.Indexed as HE
import Halogen.HTML.Indexed as HH

import Model (Post, PostList, PostId, PostSlot(..), initialPost)
import Component.Post (PostQuery(..), post)


data PostListQuery a
  = NewPost Post a

type State g = H.ParentState PostList Post PostListQuery PostQuery g PostSlot
type Query = Coproduct PostListQuery (H.ChildF PostSlot PostQuery)

postlist :: forall g. Functor g => H.Component (State g) Query g
postlist = H.parentComponent { render, eval, peek: Just peek }
  where

  render :: PostList -> H.ParentHTML Post PostListQuery PostQuery g PostSlot
  render st =
    HH.h1_ [ HH.text "List" ]

  eval :: PostListQuery ~> H.ParentDSL PostList Post PostListQuery PostQuery g PostSlot
  eval (NewPost p next) = do
    -- H.modify addPost ajax
    pure next

  peek :: forall a. H.ChildF PostSlot PostQuery a -> H.ParentDSL PostList Post PostListQuery PostQuery g PostSlot Unit
  peek (H.ChildF p q) = case q of
    -- Delete _ -> H.modify (removeTask p)
    _ -> pure unit

-- ajax
-- addPost :: PostList -> PostList
-- addPost st = st { posts = st.posts `snoc` result}

removePost :: PostSlot -> PostList -> PostList
removePost (PostSlot id) st = st { posts = filter (\p -> p.id /= id) st.posts }
