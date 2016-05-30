{-# LANGUAGE OverloadedStrings #-}

import Network.Wai
import Network.HTTP.Types
import Network.Wai.Handler.Warp (run)
import Data.HashTable.IO as HIO
import qualified Data.ByteString as BS
import Control.Concurrent.MVar
import Control.Monad (when)

data Msg = Msg !BS.ByteString

data Service = Service (MVar Int) (HIO.BasicHashTable Int Msg)

maxItems = 250000

message :: Int -> Msg
message n = Msg $ BS.replicate 1024 (fromIntegral n)

main :: IO ()
main = do
  svc <- Service <$> newMVar 0 <*> HIO.newSized maxItems;
  run 8080 (app svc)

app :: Service -> Application
app svc request respond =
  case rawPathInfo request of
    "/"   -> handle svc request respond
    _     -> handle404 request respond

handle (Service counter hash) _ respond = do
  cnt <- takeMVar counter
  putMVar counter (cnt + 1)
  HIO.insert hash cnt (message cnt)
  when (cnt >= maxItems) $ HIO.delete hash (cnt - maxItems)
  respond $ responseLBS status200 [] "OK"

handle404 :: Application
handle404 _ respond =
  respond $ responseLBS status404 [] "Not Found"
