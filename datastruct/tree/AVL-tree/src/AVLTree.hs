-- AVLTree.hs
-- Copyright (C) 2010 Liu Xinyu (liuxinyu95@gmail.com)
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

module AVLTree where

import Test.QuickCheck
import qualified Data.List as L -- for verification purpose only

data AVLTree a = Empty
               | Br (AVLTree a) a (AVLTree a) Int 

insert::(Ord a)=>AVLTree a -> a -> AVLTree a
insert t x = fst $ ins t where
    -- result of ins is a pair (t, d), t: tree, d: increment of height
    ins Empty = (Br Empty x Empty 0, 1)
    ins (Br l k r d) 
        | x < k     = balance (ins l) k (r, 0) d
        | x == k    = (Br l k r d, 0)
        | otherwise = balance (l, 0) k (ins r) d

-- balance (left, increment on left) key (right, increment on right)
balance::(AVLTree a, Int) -> a -> (AVLTree a, Int) -> Int -> (AVLTree a, Int)
balance (l, dl) k (r, dr) d = fix (Br l k r d', delta) where
    d' = d + dr - dl
    delta = if d' ==0 then 0 else dr+dl

fix :: (AVLTree a, Int) -> (AVLTree a, Int)
fix (Br (Br (Br a x b h) y c (-1)) z d (-2), _) = (Br (Br a x b h) y (Br c z d 0) 0, 0)
fix (Br (Br a x (Br b y c _)    1) z d (-2), _) = (Br (Br a x b 0) y (Br c z d 0) 0, 0)
fix (Br a x (Br b y (Br c z d h)    1)    2, _) = (Br (Br a x b 0) y (Br c z d h) 0, 0)
fix (Br a x (Br (Br b y c _) z d (-1))    2, _) = (Br (Br a x b 0) y (Br c z d 0) 0, 0)
fix (t, d) = (t, d)

-- check if a AVLTree is valid
isAVL :: (AVLTree a) -> Bool
isAVL Empty = True
isAVL (Br l _ r d) = and [isAVL l, isAVL r, d == (height r - height l), abs d <= 1]

height :: (AVLTree a) -> Int
height Empty = 0
height (Br l _ r _) = 1 + max (height l) (height r)

-- Auxiliary functions to build tree from a list, as same as BST

fromList::(Ord a)=>[a] -> AVLTree a
fromList = foldl insert Empty

toList :: (AVLTree a) -> [a] 
toList Empty = []
toList (Br l k r _) = toList l ++ [k] ++ toList r

-- test
prop_bst :: (Ord a, Num a) => [a] -> Bool
prop_bst xs = (L.sort $ L.nub xs) == (toList $ fromList xs)

prop_avl :: (Ord a, Num a) => [a] -> Bool
prop_avl = isAVL . fromList . L.nub

-- Helper function for pretty printing
instance Show a => Show (AVLTree a) where
    show Empty = "."
    show (Br l k r d) = "(" ++ show l ++ " " ++ 
                          show k ++ ":[" ++ show d ++ "] " ++
                          show r ++ ")"

