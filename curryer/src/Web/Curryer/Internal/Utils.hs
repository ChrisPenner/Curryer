{-# language ViewPatterns #-}
{-# language OverloadedStrings #-}
module Web.Curryer.Internal.Utils where

import Data.Bifunctor
import Data.Maybe
import qualified Data.Map as M
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text.Lazy as LT
import qualified Data.Text.Lazy.Encoding as LT
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.CaseInsensitive as CI

import Network.HTTP.Types.Header
import Network.HTTP.Types.URI

import Web.Curryer.Types

toBS :: T.Text -> BS.ByteString
toBS = T.encodeUtf8

toLBS :: T.Text -> LBS.ByteString
toLBS = LT.encodeUtf8 . LT.fromStrict

fromBS :: BS.ByteString -> T.Text
fromBS = T.decodeUtf8

fromLBS :: LBS.ByteString -> T.Text
fromLBS = LT.toStrict . LT.decodeUtf8

mkHeader :: T.Text -> T.Text -> Header
mkHeader headerName headerVal = (CI.mk (toBS headerName), toBS headerVal)

convertHeaders :: RequestHeaders -> HeaderMap
convertHeaders = M.fromListWith mappend . fmap (bimap mapName mapVal)
  where
    mapName = CI.map fromBS
    mapVal val = [fromBS val]

qsToList :: Query -> [(T.Text, Maybe T.Text)]
qsToList = fmap (bimap fromBS (fmap fromBS))

-- Get all occurances of query params
convertQueries :: Query -> MultiQueryMap
convertQueries = M.fromListWith (flip mappend) . fmap (second maybeToList) . qsToList

-- | Get first occurrance of each query param
simpleQuery :: Query -> QueryMap
simpleQuery = M.fromListWith (flip const) . fmap (second (fromMaybe "")) . qsToList

