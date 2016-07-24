module Main where

import Prelude

import Control.Monad.Eff
import Halogen (runUI, parentState)
import Halogen.Util (awaitBody)
import Control.Monad.Eff.Exception (throwException)
import Control.Monad.Aff

import Router as R

main :: forall eff. Eff (R.Effects eff) Unit
main = void $ runAff throwException (const (pure unit)) $ do
  body <- awaitBody
  driver <- runUI R.ui (parentState R.init) body
  forkAff $ R.routeSignal driver
