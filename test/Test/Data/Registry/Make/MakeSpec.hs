{-# LANGUAGE DataKinds       #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

module Test.Data.Registry.Make.MakeSpec where

import           Data.Registry
import           Data.Text             as T (length)
import           Protolude
import           Test.Tasty.Extensions

-- | Effectful creation with lifting
test_lifted = test "functions can be lifted in order to participate in building instances" $ do
  f1 <- liftIO $
    do let r =    fun (argsTo @IO newF1)
               +: valTo @IO (1::Int)
               +: valTo @IO ("hey"::Text)
               +: end
       make @(IO F1) r

  f1 === F1 1 "hey"

data F1 = F1 Int Text deriving (Eq, Show)

newF1 :: Int -> Text -> IO F1
newF1 i t = pure (F1 i t)

----

test_cycle = test "cycle can be detected" $ do
  -- a registry with 2 functions inverse of each other
  let explosive = makeUnsafe @Text (fun add1 +: fun dda1 +: end)
  r <- liftIO $ try (print explosive)
  case r of
    Left (_ :: SomeException) -> assert True
    Right _                   -> assert False

add1 :: Int -> Text
add1 i = show (i + 1)

-- inverse of add1 (in terms of type signature)
dda1 :: Text -> Int
dda1 = T.length
