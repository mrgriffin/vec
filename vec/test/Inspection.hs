{-# LANGUAGE GADTs           #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -O -fplugin Test.Inspection.Plugin #-}
module Main (main) where

import Prelude hiding (zipWith)

import Data.Vec.Lazy   (Vec (..))
import Test.Inspection

import qualified Data.Fin             as F
import qualified Data.Type.Nat        as N
import qualified Data.Vec.Lazy        as L
import qualified Data.Vec.Lazy.Inline as I

-------------------------------------------------------------------------------
-- zipWith
-------------------------------------------------------------------------------

-- | This doesn't evaluate compile time.
lhsInline :: Vec N.Nat2 Int
lhsInline = I.zipWith (+) xs ys

-- | This doesn't evaluate compile time.
lhsNormal :: Vec N.Nat2 Int
lhsNormal = L.zipWith (+) xs ys

xs :: Vec N.Nat2 Int
xs = 1 ::: 2 ::: VNil

ys :: Vec N.Nat2 Int
ys = 2 ::: 3 ::: VNil

rhsZipWith :: Vec N.Nat2 Int
rhsZipWith = 3 ::: 5 ::: VNil

inspect $ 'lhsInline === 'rhsZipWith
inspect $ 'lhsNormal =/= 'rhsZipWith

-------------------------------------------------------------------------------
-- imap
-------------------------------------------------------------------------------

lhsIMap :: Vec N.Nat2 (F.Fin N.Nat2, Char)
lhsIMap = I.imap (,) $ 'a' ::: 'b' ::: VNil

lhsIMap' :: Vec N.Nat2 (F.Fin N.Nat2, Char)
lhsIMap' = L.imap (,) $ 'a' ::: 'b' ::: VNil

rhsIMap :: Vec N.Nat2 (F.Fin N.Nat2, Char)
rhsIMap = (F.Z,'a') ::: (F.S F.Z,'b') ::: VNil

inspect $ 'lhsIMap  === 'rhsIMap
inspect $ 'lhsIMap' =/= 'rhsIMap

-------------------------------------------------------------------------------
-- dotProduct
-------------------------------------------------------------------------------

{-
 -- TODO: for this example LHS produces better core :O
 -- though, inlining isn't done if element is Num a => a
 --
lhsDotProduct :: Vec N.Nat2 Int -> Vec N.Nat2 Int -> Int
lhsDotProduct xs ys = I.sum (I.zipWith (+) xs ys)

rhsDotProduct :: Vec N.Nat2 Int -> Vec N.Nat2 Int -> Int
rhsDotProduct (x0 ::: x1 ::: _) (y0 ::: y1 ::: _) =
    x0 * y0 + x1 * y1

inspect $ 'lhsDotProduct === 'rhsDotProduct
-}

-------------------------------------------------------------------------------
-- join
-------------------------------------------------------------------------------

lhsJoin :: Vec N.Nat2 Char
lhsJoin = I.join $ ('a' ::: 'b' ::: VNil) ::: ('c' ::: 'd' ::: VNil) ::: VNil

lhsJoin' :: Vec N.Nat2 Char
lhsJoin' = L.join $ ('a' ::: 'b' ::: VNil) ::: ('c' ::: 'd' ::: VNil) ::: VNil

rhsJoin :: Vec N.Nat2 Char
rhsJoin = 'a' ::: 'd' ::: VNil

inspect $ 'lhsJoin  === 'rhsJoin
inspect $ 'lhsJoin' =/= 'rhsJoin

-------------------------------------------------------------------------------
-- Main to make GHC happy
-------------------------------------------------------------------------------

main :: IO ()
main = return ()
