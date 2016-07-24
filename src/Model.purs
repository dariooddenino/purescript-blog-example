module Model where

import Prelude

type PostId = Int

type Post =
  { id    :: PostId
  , title :: String
  , body  :: String
  }

initialPost :: Post
initialPost =
  { id: -1
  , title: ""
  , body: ""
  }

newtype PostSlot = PostSlot PostId
derive instance eqPostSlot :: Eq PostSlot
derive instance ordPostSlot :: Ord PostSlot

type PostList =
  { posts :: Array Post }

initialPostList :: PostList
initialPostList = { posts: [] }

data PostListSlot = PostListSlot
derive instance eqPostListSlot :: Eq PostListSlot
derive instance ordPostListSlot :: Ord PostListSlot
