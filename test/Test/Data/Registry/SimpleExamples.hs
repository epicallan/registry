{-# LANGUAGE DataKinds        #-}
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

{-
  These examples are simply provided to show what must compile
-}
module Test.Data.Registry.SimpleExamples where

import           Data.Registry
import           Data.Text     as T (length)
import           Protolude hiding (C1)


-- | No typeclass instance is necessary for a "record of functions" to be a Registry component
data Logging = Logging {
  info  :: Text -> IO ()
, debug :: Text -> IO ()
}

logging = make @Logging (fun Logging { info = print, debug = print } +: end)

-- | Simple datatypes which can be used in a registry
newtype Text1 = Text1 Text deriving (Eq, Show)
newtype Text2 = Text2 Text deriving (Eq, Show)
newtype Int1 = Int1 Int deriving (Eq, Show)

-- | values and functions
int1 :: Int
int1 = 1

add1 :: Int -> Text
add1 i = show (i + 1)

add2 :: Int -> Text -> Text1
add2 i j = Text1 (show (i+1) <> j)

text1 :: Text
text1 = "text1"

toText2 :: Text1 -> Text2
toText2 (Text1 t) = Text2 t

registry1 :: Registry [Int, Text, Text1] [Int, Text, Text1, Text2]
registry1 = normalize $
     val int1
  +: fun add1
  +: fun add2
  +: fun toText2
  +: end

countSize :: Text -> Maybe Int
countSize t = Just (T.length t)

m = make @Text $ fun (\(t::Text) -> t) +: end

made1 :: Text
made1 = make @Text registry1

made2 :: Text1
made2 = make @Text1 registry1

made3 :: Text2
made3 = make @Text2 registry1

--
countSize1 :: Text -> Int1
countSize1 t = Int1 (T.length t)

registry2 :: Registry '[Int, Text] '[Int, Text, Int1]
registry2 =
     fun int1
  +: fun add1
  +: fun countSize1
  +: end

made4 :: Int1
made4 = make @Int1 registry2

-- | This does *not* compile because Double in not in the
--   list of outputs for registry2
{-
wrong :: Double
wrong = make @Double registry2
-}

-- | This does *not* compile because the list of inputs
--   in registry2 is not included in the list of outputs
unknown :: Double -> Text1
unknown _ = Text1 "text1"

registry3 :: Registry [Double, Int, Text] [Int, Text1, Text, Int1]
registry3 =
     val int1
  +: fun unknown
  +: fun add1
  +: fun countSize1
  +: end

-- | This does not compile because we need a double
--   to make Text1 and it is not in the list of outputs
{-
wrong :: Text1
wrong = make @Text1 registry3
-}

-- | This version compiles but throws an exception at runtime
dangerous :: Text1
dangerous = makeUnsafe @Text1 registry3
